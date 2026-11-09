import 'dart:convert';
import 'package:drift/drift.dart';
import '../domain/catalog.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';
import 'database/database.dart';

typedef _CachedTransaction = ({int seq, String encoded});

/// [ProfileRepository] su SQLite (drift), un profilo per `game_id`.
///
/// Il profilo è scomposto in tabelle normalizzate; snapshot del save e `before`
/// delle operazioni restano documenti JSON. Ogni [save] è una transazione:
/// le tabelle piccole vengono riscritte, quelle pesanti (snapshot, cronologia:
/// quasi tutto il volume) solo nelle righe cambiate rispetto all'ultima
/// versione letta o scritta. Le mappe si rileggono in ordine di `rowid`, cioè
/// di inserimento: il JSON ricostruito ha lo stesso ordine delle chiavi.
class DriftProfileRepository implements ProfileRepository {
  DriftProfileRepository(
    this.db, {
    this.gameId = defaultGameId,
    this.location = 'SQLite',
  });

  final AppDatabase db;
  final String gameId;
  @override
  final String location;

  /// Revisione dell'ultima lettura/scrittura; `null` = nessun profilo atteso.
  int? _revision;

  /// Snapshot (id → JSON) e cronologia come sono ora nel database: servono a
  /// scrivere solo le differenze. Validi finché la revisione coincide.
  Map<String, String> _snapshots = {};
  List<_CachedTransaction> _transactions = [];

  /// `false` se l'ultima lettura non è arrivata in fondo: [_snapshots] e
  /// [_transactions] non sono affidabili.
  bool _cached = true;

  @override
  Future<Json?> load() => db.transaction(() async {
    final row = await _profileRow();
    _revision = row?.revision;
    _snapshots = {};
    _transactions = [];
    _cached = row == null;
    if (row == null) return null;
    final (profile, transactions) = await _read(row);
    _snapshots = {
      for (final e in (profile['saveSnapshots'] as Json).entries)
        e.key: jsonEncode(e.value),
    };
    _transactions = transactions;
    _cached = true;
    return profile;
  });

  @override
  Future<void> save(Profile profile, {bool beforeImport = false}) async {
    final everCrafted = profile.everCrafted, craftCount = profile.craftCount;
    if (everCrafted.length != craftCount.length ||
        !everCrafted.keys.every(craftCount.containsKey)) {
      throw const FormatException('Storico ricette incoerente.');
    }
    final snapshots = {
      for (final e in profile.saveSnapshots.entries) e.key: jsonEncode(e.value),
    };
    final transactions = [for (final t in profile.transactions) jsonEncode(t)];

    final (revision, cached) = await db.transaction(() async {
      final current = await _profileRow();
      if (current?.revision != _revision) throw const ProfileConflict();
      if (current == null &&
          await (db.select(
                db.games,
              )..where((g) => g.id.equals(gameId))).getSingleOrNull() ==
              null) {
        throw StateError('Titolo non registrato: $gameId');
      }
      if (current != null && beforeImport) {
        final content = await _backupContent(current);
        await db
            .into(db.backups)
            .insertOnConflictUpdate(
              BackupsCompanion.insert(
                gameId: Value(gameId),
                createdAt: DateTime.now().toUtc().toIso8601String(),
                content: content,
              ),
            );
      }
      if (current == null || !_cached) {
        // Nessun profilo, o ultima lettura fallita (righe corrotte): la cache
        // non descrive le righe pesanti, quindi si riscrivono da zero.
        _snapshots = {};
        _transactions = [];
        await _clear(db.saveSnapshots);
        await _clear(db.profileTransactions);
      }
      final revision = (current?.revision ?? 0) + 1;
      await db
          .into(db.profiles)
          .insertOnConflictUpdate(
            ProfilesCompanion.insert(
              gameId: Value(gameId),
              schemaVersion: profile.schemaVersion,
              datasetVersion: profile.datasetVersion,
              completionDatasetVersion: Value(profile.completionDatasetVersion),
              storyPoint: Value(profile.storyPoint),
              updatedAt: profile.updatedAt,
              activeSaveId: Value(profile.activeSaveId),
              planMode: profile.plan.mode,
              revision: Value(revision),
            ),
          );
      await _writeSmallTables(profile);
      await _writeSnapshots(profile, snapshots);
      return (revision, await _writeTransactions(profile, transactions));
    });
    _revision = revision;
    _snapshots = snapshots;
    _transactions = cached;
    _cached = true;
  }

  @override
  Future<Uint8List?> previousBackup() async {
    final row = await (db.select(
      db.backups,
    )..where((t) => t.gameId.equals(gameId))).getSingleOrNull();
    return row == null ? null : utf8.encode(row.content);
  }

  /// Copia del profilo corrente prima di un import. Se non è leggibile (è il
  /// caso tipico in cui si importa un backup) conserva il testo grezzo delle
  /// colonne JSON, come il vecchio archivio conservava il file originale:
  /// altrimenti la decodifica fallirebbe e l'import non potrebbe ripararlo.
  Future<String> _backupContent(ProfileRow current) async {
    try {
      final (previous, _) = await _read(current);
      return jsonEncode(previous);
    } on FormatException catch (e) {
      Future<List<String>> raw(String sql) => db
          .customSelect(sql, variables: [Variable(gameId)])
          .map((r) => r.read<String>('v'))
          .get();
      return jsonEncode({
        'unreadable': '$e',
        'saveSnapshots': await raw(
          'SELECT data AS v FROM save_snapshots WHERE game_id = ? ORDER BY rowid',
        ),
        'transactions': await raw(
          'SELECT "before" AS v FROM profile_transactions WHERE game_id = ? ORDER BY seq',
        ),
      });
    }
  }

  Future<ProfileRow?> _profileRow() => (db.select(
    db.profiles,
  )..where((t) => t.gameId.equals(gameId))).getSingleOrNull();

  /// Righe del titolo in ordine di inserimento.
  Future<List<R>> _rows<T extends GameScoped, R>(TableInfo<T, R> table) =>
      (db.select(table)
            ..where((t) => t.gameId.equals(gameId))
            ..orderBy([(_) => OrderingTerm(expression: table.rowId)]))
          .get();

  Future<void> _clear<T extends GameScoped, R>(TableInfo<T, R> table) =>
      (db.delete(table)..where((t) => t.gameId.equals(gameId))).go();

  Future<void> _replace<T extends GameScoped, R>(
    TableInfo<T, R> table,
    Iterable<Insertable<R>> rows,
  ) async {
    await _clear(table);
    await db.batch((b) => b.insertAll(table, rows));
  }

  /// Ricostruisce il profilo JSON (con le mappe tipizzate `dynamic`, come le
  /// produce `jsonDecode`, perché il dominio le modifica sul posto) e la
  /// cronologia così com'è nel database.
  Future<(Json, List<_CachedTransaction>)> _read(ProfileRow row) async {
    final scopes = <String, dynamic>{
      for (final s in await _rows(db.overrideScopes))
        s.scope: <String, dynamic>{},
    };
    for (final o in await _rows(db.manualOverrides)) {
      (scopes[o.scope] as Json)[o.key] = o.value;
    }
    final recipes = await _rows(db.recipes);
    final transactionRows =
        await (db.select(db.profileTransactions)
              ..where((t) => t.gameId.equals(gameId))
              ..orderBy([(t) => OrderingTerm(expression: t.seq)]))
            .get();
    final transactions = <dynamic>[
      for (final t in transactionRows)
        <String, dynamic>{
          'label': t.label,
          'at': t.at,
          'origin': t.origin.name,
          'before': t.before,
        },
    ];
    final profile = <String, dynamic>{
      'saveSnapshots': <String, dynamic>{
        for (final s in await _rows(db.saveSnapshots)) s.id: s.data,
      },
      'activeSaveId': row.activeSaveId,
      'saveValues': <String, dynamic>{
        for (final v in await _rows(db.saveValues)) v.key: v.value,
      },
      'manualOverrides': scopes,
      'schemaVersion': row.schemaVersion,
      'datasetVersion': row.datasetVersion,
      'completionDatasetVersion': row.completionDatasetVersion,
      'completion': <String, dynamic>{
        for (final c in await _rows(db.completion)) c.itemId: c.done,
      },
      'appliedEvidence': <dynamic>[
        for (final e in await _rows(db.appliedEvidence)) e.evidenceId,
      ],
      'storyPoint': row.storyPoint,
      'inventory': <String, dynamic>{
        for (final i in await _rows(db.inventory)) i.materialId: i.quantity,
      },
      'everCrafted': <String, dynamic>{
        for (final r in recipes) r.recipeId: r.everCrafted,
      },
      'craftCount': <String, dynamic>{
        for (final r in recipes) r.recipeId: r.craftCount,
      },
      'collections': <String, dynamic>{
        for (final c in await _rows(db.collections))
          c.collectionId: c.status.wire,
      },
      'plan': <String, dynamic>{
        'mode': row.planMode.wire,
        'selected': <dynamic>[
          for (final r in await _rows(db.planRecipes)) r.recipeId,
        ],
        'rewards': <String, dynamic>{
          for (final r in await _rows(db.planRewards)) r.materialId: r.quantity,
        },
      },
      'settings': <String, dynamic>{
        for (final s in await _rows(db.playerSettings)) s.key: s.value,
      },
      'session': <String, dynamic>{
        for (final s in await _rows(db.sessionMaterials))
          s.materialId: s.quantity,
      },
      'transactions': transactions,
      'updatedAt': row.updatedAt,
    };
    return (
      profile,
      [
        for (var i = 0; i < transactionRows.length; i++)
          (seq: transactionRows[i].seq, encoded: jsonEncode(transactions[i])),
      ],
    );
  }

  Future<void> _writeSmallTables(Profile p) async {
    final id = Value(gameId);
    await _replace(db.inventory, [
      for (final e in p.inventory.entries)
        InventoryCompanion.insert(
          gameId: id,
          materialId: e.key,
          quantity: Value(e.value),
        ),
    ]);
    await _replace(db.completion, [
      for (final e in p.completion.entries)
        CompletionCompanion.insert(
          gameId: id,
          itemId: e.key,
          done: Value(e.value),
        ),
    ]);
    await _replace(db.recipes, [
      for (final e in p.everCrafted.entries)
        RecipesCompanion.insert(
          gameId: id,
          recipeId: e.key,
          everCrafted: e.value,
          craftCount: Value(p.craftCount[e.key]),
        ),
    ]);
    await _replace(db.collections, [
      for (final key in (p['collections'] as Json).keys)
        CollectionsCompanion.insert(
          gameId: id,
          collectionId: key,
          status: p.collection(key),
        ),
    ]);
    await _replace(db.playerSettings, [
      for (final e in p.settings.entries)
        PlayerSettingsCompanion.insert(gameId: id, key: e.key, value: e.value),
    ]);
    await _replace(db.saveValues, [
      for (final e in p.saveValues.entries)
        SaveValuesCompanion.insert(gameId: id, key: e.key, value: e.value),
    ]);
    // Prima gli override, che dipendono dagli ambiti (chiave esterna).
    await _clear(db.manualOverrides);
    await _replace(db.overrideScopes, [
      for (final scope in p.manualOverrides.keys)
        OverrideScopesCompanion.insert(gameId: id, scope: scope),
    ]);
    await db.batch(
      (b) => b.insertAll(db.manualOverrides, [
        for (final s in p.manualOverrides.entries)
          for (final e in s.value.entries)
            ManualOverridesCompanion.insert(
              gameId: id,
              scope: s.key,
              key: e.key,
              value: e.value,
            ),
      ]),
    );
    await _replace(db.planRecipes, [
      for (final recipe in p.plan.selected)
        PlanRecipesCompanion.insert(gameId: id, recipeId: recipe),
    ]);
    await _replace(db.planRewards, [
      for (final e in p.plan.rewards.entries)
        PlanRewardsCompanion.insert(
          gameId: id,
          materialId: e.key,
          quantity: e.value,
        ),
    ]);
    await _replace(db.sessionMaterials, [
      for (final e in p.session.entries)
        SessionMaterialsCompanion.insert(
          gameId: id,
          materialId: e.key,
          quantity: e.value,
        ),
    ]);
    await _replace(db.appliedEvidence, [
      for (final evidence in p.appliedEvidence)
        AppliedEvidenceCompanion.insert(gameId: id, evidenceId: evidence),
    ]);
  }

  /// Elimina gli snapshot rimossi e scrive solo quelli nuovi o cambiati.
  /// L'upsert aggiorna sul posto, quindi il `rowid` (l'ordine) non cambia.
  Future<void> _writeSnapshots(Profile p, Map<String, String> encoded) async {
    final removed = _snapshots.keys.where((id) => !encoded.containsKey(id));
    if (removed.isNotEmpty) {
      await (db.delete(db.saveSnapshots)..where(
            (t) => t.gameId.equals(gameId) & t.id.isIn(removed.toList()),
          ))
          .go();
    }
    for (final e in encoded.entries) {
      if (_snapshots[e.key] == e.value) continue;
      final snapshot = p.saveSnapshots[e.key]!;
      await db
          .into(db.saveSnapshots)
          .insertOnConflictUpdate(
            SaveSnapshotsCompanion.insert(
              gameId: Value(gameId),
              id: e.key,
              slotNumber: snapshot.slotNumber,
              savedAt: snapshot.savedAt,
              sourceFilename: snapshot.sourceFilename,
              data: snapshot.json,
            ),
          );
    }
  }

  /// La cronologia di solito cambia ai bordi: un'operazione in coda, la più
  /// vecchia che esce dal limite di 100, l'ultima tolta da un annullamento.
  /// Si conserva il tratto comune più lungo che parte dalla prima voce nuova,
  /// si elimina il resto e si accodano le voci mancanti: i `seq` crescenti
  /// mantengono l'ordine. Restituisce la cronologia ora nel database.
  Future<List<_CachedTransaction>> _writeTransactions(
    Profile p,
    List<String> encoded,
  ) async {
    final old = _transactions;
    var start = encoded.isEmpty
        ? old.length
        : old.indexWhere((t) => t.encoded == encoded.first);
    if (start < 0) start = old.length;
    var kept = 0;
    while (start + kept < old.length &&
        kept < encoded.length &&
        old[start + kept].encoded == encoded[kept]) {
      kept++;
    }
    final stale = [
      for (final t in [...old.take(start), ...old.skip(start + kept)]) t.seq,
    ];
    if (stale.isNotEmpty) {
      await (db.delete(
        db.profileTransactions,
      )..where((t) => t.gameId.equals(gameId) & t.seq.isIn(stale))).go();
    }
    final result = old.sublist(start, start + kept);
    for (var i = kept; i < encoded.length; i++) {
      final t = p.transactions[i];
      final seq = await db
          .into(db.profileTransactions)
          .insert(
            ProfileTransactionsCompanion.insert(
              gameId: Value(gameId),
              label: t.label,
              at: t.at,
              origin: t.origin,
              before: t.before,
            ),
          );
      result.add((seq: seq, encoded: encoded[i]));
    }
    return result;
  }
}
