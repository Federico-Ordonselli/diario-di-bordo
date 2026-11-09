import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/application/profile_providers.dart';
import 'package:diario_bordo/data/database/database.dart';
import 'package:diario_bordo/data/drift_profile_repository.dart';
import 'fakes.dart';
import 'profile_repository_test.dart' show richProfile;
import 'test_catalog.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('Errore di scrittura conserva lo stato mostrato', () async {
    final container = profileContainer(
      testCatalog(),
      DriftProfileRepository(db),
    );
    addTearDown(container.dispose);
    final notifier = container.read(profileProvider.notifier);
    final engine = container.read(engineProvider);
    await notifier.initialize();
    final previous = container.read(profileProvider).profile;
    // Un'altra istanza (altra finestra) scrive per prima.
    final foreign = DriftProfileRepository(db);
    await foreign.load();
    await foreign.save(engine.increment(previous, 'lucid_shard', 1));
    final accepted = await notifier.commit(
      (s) => engine.increment(s, 'gale', 1),
    );
    final view = container.read(profileProvider);
    expect(accepted, false);
    expect(identical(view.profile, previous), true);
    expect(view.busy, false);
    expect(view.error, contains('altra finestra'));
  });

  test(
    'Profilo corrotto conservato, operazioni bloccate e recupero con backup',
    () async {
      final catalog = testCatalog();
      await DriftProfileRepository(db).save(richProfile(catalog));
      await db.customStatement("UPDATE save_snapshots SET data = '[1'");
      final repository = DriftProfileRepository(db);
      final container = profileContainer(catalog, repository);
      addTearDown(container.dispose);
      final notifier = container.read(profileProvider.notifier);
      final engine = container.read(engineProvider);
      await notifier.initialize();
      expect(container.read(profileProvider).blocked, true);
      expect(
        await notifier.commit((s) => engine.increment(s, 'gale', 1)),
        false,
      );
      Future<List<String>> corrupt() => db
          .customSelect('SELECT data FROM save_snapshots')
          .map((r) => r.read<String>('data'))
          .get();
      expect(await corrupt(), everyElement('[1'));
      await notifier.commit((_) => catalog.fresh(), importing: true);
      final view = container.read(profileProvider);
      expect(view.error, isNull);
      expect(view.blocked, false);
      expect((await repository.load())!['schemaVersion'], 2);
      final backup = jsonDecode(
        utf8.decode((await repository.previousBackup())!),
      );
      expect(backup['unreadable'], contains('FormatException'));
      expect(backup['saveSnapshots'], everyElement('[1'));
    },
  );
}
