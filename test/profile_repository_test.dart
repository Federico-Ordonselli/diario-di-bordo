import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/application/profile_providers.dart';
import 'package:diario_bordo/data/database/database.dart';
import 'package:diario_bordo/data/drift_profile_repository.dart';
import 'package:diario_bordo/data/json_profile_repository.dart';
import 'package:diario_bordo/domain/catalog.dart';
import 'package:diario_bordo/domain/profile.dart';
import 'package:diario_bordo/domain/profile_repository.dart';
import 'package:diario_bordo/domain/validation.dart';
import 'package:diario_bordo/storage/profile_store.dart';
import 'fakes.dart';
import 'test_catalog.dart';

/// Profilo con tutte le strutture popolate: snapshot, override (anche un
/// ambito vuoto), cronologia, sessione, piano, valori `null` e tipi misti.
Profile richProfile(Catalog catalog) {
  final p = catalog.fresh();
  final recipe = catalog.recipes.first['id'] as String;
  final item = catalog.items.firstWhere((i) => i['recipeId'] == null);
  Json snapshot(String id, int slot) => {
    'id': id,
    'slotNumber': slot,
    'savedAt': '2026-10-0${slot}T10:00:00+02:00',
    'source': {'filename': 'save.png', 'size_bytes': 10},
    'observations': {
      'inventory.gale': {'value': 3, 'label': 'Gale', 'path': 'a.b'},
    },
    'chests': [
      {'id': 1, 'opened': true},
    ],
    'importedAt': '2026-10-09T10:00:00Z',
  };
  p
    ..['saveSnapshots'] = {'s1': snapshot('s1', 1), 's2': snapshot('s2', 2)}
    ..activeSaveId = 's2'
    ..['saveValues'] = {'chest.1': true, 'postcards': 6, 'trinity.Blue': null}
    ..['manualOverrides'] = {
      'app': <String, dynamic>{},
      'save.png#slot:2': {'inventory.gale': 4, 'settings.Stop': true},
    }
    ..completion[item['id'] as String] = null
    ..appliedEvidence.add('evidence-1')
    ..session['gale'] = 2
    ..settings.setFlag('Stop', true)
    ..['settings']['level'] = 42
    ..plan.mode = PlanMode.selected
    ..plan.selected.add(recipe)
    ..setCollection(
      catalog.collections.first['id'] as String,
      CollectionStatus.collected,
    );
  p.transactions = [
    for (var i = 0; i < 3; i++)
      ProfileTransaction({
        'label': 'Operazione $i',
        'at': '2026-10-1${i}T10:00:00Z',
        'origin': 'manual',
        'before': {
          ...copyJson(p)
            ..remove('transactions')
            ..remove('saveSnapshots'),
          'storyPoint': 'p$i',
        },
      }),
  ];
  return p;
}

/// Lo stesso contratto vale per ogni implementazione di [ProfileRepository].
void contract(String name, Future<ProfileRepository> Function() create) {
  group('Contratto ProfileRepository: $name', () {
    final catalog = testCatalog();

    test('Archivio vuoto: nessun profilo e nessun backup', () async {
      final repository = await create();
      expect(await repository.load(), isNull);
      expect(await repository.previousBackup(), isNull);
    });

    test('Salva e rilegge lo stesso contenuto', () async {
      final repository = await create(), profile = catalog.fresh();
      profile.inventory['gale'] = 7;
      await repository.save(profile);
      final loaded = Profile((await repository.load())!);
      expect(loaded.inventory['gale'], 7);
      expect(loaded.json, profile.json);
    });

    test('Prima di un import conserva la versione precedente', () async {
      final repository = await create(), first = catalog.fresh();
      await repository.save(first);
      final second = Profile(copyJson(first))..inventory['gale'] = 1;
      await repository.save(second, beforeImport: true);
      final backup = await repository.previousBackup();
      expect(jsonDecode(utf8.decode(backup!)), first.json);
    });

    test(
      'Profilo completo: rilettura identica, anche dopo modifiche',
      () async {
        final repository = await create(), profile = richProfile(catalog);
        await repository.save(profile);
        final loaded = Profile((await repository.load())!);
        expect(loaded.json, profile.json);
        expect(
          jsonEncode(loaded),
          jsonEncode(profile),
          reason: 'ordine chiavi',
        );

        // Cronologia che scorre, snapshot rimosso, override e scorte cambiati.
        loaded
          ..transactions = [
            ...loaded.transactions.skip(1),
            ProfileTransaction({
              'label': 'Nuova',
              'at': '2026-10-20T10:00:00Z',
              'origin': 'save',
              'before': <String, dynamic>{'storyPoint': 'nuovo'},
            }),
          ]
          ..saveSnapshots.remove('s1')
          ..activeSaveId = null
          ..manualOverrides.remove('app')
          ..inventory['gale'] = 9;
        await repository.save(loaded);
        expect((await repository.load())!, loaded.json);
      },
    );
  });
}

void main() {
  final directories = <Directory>[];
  tearDownAll(() async {
    for (final d in directories) {
      await d.delete(recursive: true);
    }
  });
  contract('JSON su file', () async {
    final dir = await Directory.systemTemp.createTemp('kh-repo-');
    directories.add(dir);
    return JsonProfileRepository(ProfileStore(dir));
  });
  contract('in memoria', () async => InMemoryProfileRepository());
  contract('SQLite (drift in memoria)', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return DriftProfileRepository(db);
  });

  group('DriftProfileRepository', () {
    final catalog = testCatalog();
    late AppDatabase db;
    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('Scrittura concorrente da un altro processo: conflitto', () async {
      final first = DriftProfileRepository(db),
          second = DriftProfileRepository(db);
      await first.save(catalog.fresh());
      await second.load();
      await second.save(catalog.fresh()..inventory['gale'] = 1);
      await expectLater(
        first.save(catalog.fresh()),
        throwsA(isA<ProfileConflict>()),
      );
      expect(Profile((await first.load())!).inventory['gale'], 1);
    });

    test('La cronologia scrive solo le voci nuove', () async {
      final repository = DriftProfileRepository(db);
      final profile = richProfile(catalog);
      await repository.save(profile);
      Future<List<int>> seqs() async => [
        for (final t in await (db.select(
          db.profileTransactions,
        )..orderBy([(t) => OrderingTerm(expression: t.seq)])).get())
          t.seq,
      ];
      final before = await seqs();
      profile.transactions = [
        ...profile.transactions.skip(1),
        ProfileTransaction({
          'label': 'Nuova',
          'at': '2026-10-20T10:00:00Z',
          'origin': 'manual',
          'before': <String, dynamic>{},
        }),
      ];
      await repository.save(profile);
      expect(await seqs(), [...before.skip(1), before.last + 1]);
    });

    test('Ogni titolo ha il suo profilo', () async {
      final main = DriftProfileRepository(db),
          other = DriftProfileRepository(db, gameId: 'altro');
      await main.save(richProfile(catalog));
      expect(await other.load(), isNull);
      await db.registerGame('altro', 'Altro titolo');
      await other.save(catalog.fresh());
      expect(Profile((await main.load())!).saveSnapshots, hasLength(2));
      expect(Profile((await other.load())!).saveSnapshots, isEmpty);
    });

    test('Titolo non registrato: salvataggio rifiutato', () async {
      final other = DriftProfileRepository(db, gameId: 'sconosciuto');
      expect(await other.load(), isNull);
      await expectLater(other.save(catalog.fresh()), throwsStateError);
      expect(await db.select(db.profiles).get(), isEmpty);
      // Anche scrivendo a mano la FK lo impedisce.
      await expectLater(
        db.customStatement(
          'INSERT INTO profiles (game_id, schema_version, dataset_version, '
          "updated_at, plan_mode) VALUES ('sconosciuto', 2, 'x', 'x', 'all')",
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Database nuovo: titolo predefinito già registrato', () async {
      expect((await db.select(db.games).get()).map((g) => g.id), [
        defaultGameId,
      ]);
    });

    test('JSON corrotto nel database: FormatException', () async {
      final repository = DriftProfileRepository(db);
      await repository.save(richProfile(catalog));
      await db.customStatement("UPDATE save_snapshots SET data = '[1'");
      await expectLater(repository.load(), throwsFormatException);
    });
  });

  group('ProfileNotifier con repository in memoria', () {
    final catalog = testCatalog();

    test('Primo avvio salva un profilo vuoto, senza evidence', () async {
      final repository = InMemoryProfileRepository();
      final container = profileContainer(catalog, repository);
      addTearDown(container.dispose);
      await container.read(profileProvider.notifier).initialize();
      final view = container.read(profileProvider);
      expect(view.blocked, false);
      expect(view.busy, false);
      expect(repository.saves, 1);
      expect(view.profile.appliedEvidence, isEmpty);
      expect(view.profile.transactions, isEmpty);
      expect(catalog.summary(view.profile)['done'], 0);
      expect(container.read(engineProvider).distinct(view.profile), 0);
    });

    test('Profilo esistente caricato senza riscriverlo', () async {
      final stored = richProfile(catalog);
      final repository = InMemoryProfileRepository(jsonEncode(stored));
      final container = profileContainer(catalog, repository);
      addTearDown(container.dispose);
      await container.read(profileProvider.notifier).initialize();
      expect(repository.saves, 0);
      expect(
        jsonEncode(container.read(profileProvider).profile),
        jsonEncode(ProfileValidator(catalog).profile(stored)),
      );
    });

    test('Archivio non decodificabile blocca senza sovrascrivere', () async {
      final repository = InMemoryProfileRepository('[1, 2]');
      final container = profileContainer(catalog, repository);
      addTearDown(container.dispose);
      await container.read(profileProvider.notifier).initialize();
      final view = container.read(profileProvider);
      expect(view.blocked, true);
      expect(view.error, contains('Archivio non leggibile'));
      expect(repository.stored, '[1, 2]');
      expect(repository.saves, 0);
    });

    test('I listener vedono busy durante il salvataggio', () async {
      final container = profileContainer(catalog, InMemoryProfileRepository());
      addTearDown(container.dispose);
      final notifier = container.read(profileProvider.notifier);
      await notifier.initialize();
      final busy = <bool>[];
      container.listen(profileProvider, (_, next) => busy.add(next.busy));
      final engine = container.read(engineProvider);
      final before =
          container.read(profileProvider).profile.inventory['gale'] as int;
      expect(
        await notifier.commit((s) => engine.increment(s, 'gale', 1)),
        true,
      );
      expect(busy, [true, false]);
      expect(
        container.read(profileProvider).profile.inventory['gale'],
        before + 1,
      );
    });
  });
}
