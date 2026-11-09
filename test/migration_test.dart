import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/data/database/database.dart';
import 'package:diario_bordo/data/drift_profile_repository.dart';
import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;
import 'generated_migrations/schema_v2.dart' as v2;
import 'profile_repository_test.dart' show richProfile;
import 'test_catalog.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;
  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('v1 → v2: schema uguale a un database v2 nuovo', () async {
    final schema = await verifier.schemaAt(1);
    final db = AppDatabase(schema.newConnection());
    await verifier.migrateAndValidate(db, 2);
    await db.close();
  });

  test('v1 → v2: righe conservate, titoli registrati', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, old) {
        for (final game in ['kh1fm', 'altro']) {
          batch.insert(
            old.profiles,
            v1.ProfilesCompanion.insert(
              gameId: Value(game),
              schemaVersion: 2,
              datasetVersion: 'd-$game',
              updatedAt: '2026-11-09',
              planMode: 'all',
              revision: const Value(7),
            ),
          );
        }
        batch.insert(
          old.inventory,
          v1.InventoryCompanion.insert(
            materialId: 'gale',
            quantity: const Value(3),
          ),
        );
        batch.insert(
          old.overrideScopes,
          v1.OverrideScopesCompanion.insert(scope: 'app'),
        );
        batch.insert(
          old.manualOverrides,
          v1.ManualOverridesCompanion.insert(
            scope: 'app',
            key: 'inventory.gale',
            value: '5',
          ),
        );
      },
      validateItems: (db) async {
        final games = await db.select(db.games).get();
        expect(
          {for (final g in games) g.id: g.name},
          {'kh1fm': defaultGameName, 'altro': 'altro'},
        );
        final profiles = await db.select(db.profiles).get();
        expect(profiles.map((p) => (p.gameId, p.datasetVersion, p.revision)), [
          ('kh1fm', 'd-kh1fm', 7),
          ('altro', 'd-altro', 7),
        ]);
        expect((await db.select(db.inventory).getSingle()).quantity, 3);
        expect((await db.select(db.manualOverrides).getSingle()).value, '5');
      },
    );
  });

  test(
    'v1 → v2: un profilo completo si rilegge identico dopo la migrazione',
    () async {
      final catalog = testCatalog();
      final dir = Directory.systemTemp.createTempSync('migrazione');
      addTearDown(() => dir.deleteSync(recursive: true));

      // Profilo scritto dal repository attuale su un database v2.
      final source = File('${dir.path}/sorgente.sqlite');
      final written = AppDatabase(NativeDatabase(source));
      await DriftProfileRepository(written).save(richProfile(catalog));
      final expected = jsonEncode(await DriftProfileRepository(written).load());
      await written.close();

      // Stesse righe in un database v1: tutte le tabelle tranne `games`
      // hanno le stesse colonne nei due schemi.
      final schema = await verifier.schemaAt(1);
      final old = v1.DatabaseAtV1(schema.newConnection());
      await old.customStatement("ATTACH DATABASE '${source.path}' AS src");
      for (final table in old.allTables) {
        await old.customStatement(
          'INSERT INTO main.${table.actualTableName} '
          'SELECT * FROM src.${table.actualTableName}',
        );
      }
      await old.customStatement('DETACH DATABASE src');
      expect(await old.select(old.saveSnapshots).get(), hasLength(2));
      await old.close();

      // L'app apre il file v1: migrazione all'apertura, poi lettura normale.
      final migrated = AppDatabase(schema.newConnection());
      final repository = DriftProfileRepository(migrated);
      expect(jsonEncode(await repository.load()), expected);
      await repository.save(richProfile(catalog)..inventory['gale'] = 99);
      expect((await repository.load())!['inventory']['gale'], 99);
      await migrated.close();
    },
  );
}
