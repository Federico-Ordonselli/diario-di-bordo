import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/application/profile_providers.dart';
import 'package:diario_bordo/data/json_profile_repository.dart';
import 'package:diario_bordo/domain/catalog.dart';
import 'package:diario_bordo/domain/profile.dart';
import 'package:diario_bordo/domain/profile_repository.dart';
import 'package:diario_bordo/storage/profile_store.dart';
import 'fakes.dart';
import 'test_catalog.dart';

/// Lo stesso contratto vale per ogni implementazione di [ProfileRepository]:
/// quando arriverà quella SQLite basterà aggiungerla qui.
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

  group('ProfileNotifier con repository in memoria', () {
    final catalog = testCatalog();

    test('Primo avvio salva il profilo iniziale con le evidence', () async {
      final repository = InMemoryProfileRepository();
      final container = profileContainer(catalog, repository);
      addTearDown(container.dispose);
      await container.read(profileProvider.notifier).initialize();
      final view = container.read(profileProvider);
      expect(view.blocked, false);
      expect(view.busy, false);
      expect(repository.saves, 1);
      expect(view.profile.appliedEvidence, contains(catalog.evidence['id']));
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
