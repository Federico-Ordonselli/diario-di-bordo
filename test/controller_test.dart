import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/application/profile_providers.dart';
import 'package:diario_bordo/domain/profile.dart';
import 'package:diario_bordo/data/json_profile_repository.dart';
import 'package:diario_bordo/storage/profile_store.dart';
import 'fakes.dart';
import 'test_catalog.dart';

void main() {
  test('Errore di scrittura conserva lo stato mostrato', () async {
    final dir = await Directory.systemTemp.createTemp('kh-controller-');
    final container = profileContainer(
      testCatalog(),
      JsonProfileRepository(ProfileStore(dir)),
    );
    final notifier = container.read(profileProvider.notifier);
    final engine = container.read(engineProvider);
    try {
      await notifier.initialize();
      final previous = container.read(profileProvider).profile;
      final foreign = ProfileStore(dir);
      await foreign.loadRaw();
      final newer = Profile({...previous, 'storyPoint': 'another-window'});
      await foreign.save(newer);
      final accepted = await notifier.commit(
        (s) => engine.increment(s, 'gale', 1),
      );
      final view = container.read(profileProvider);
      expect(accepted, false);
      expect(identical(view.profile, previous), true);
      expect(view.busy, false);
      expect(view.error, contains('altra finestra'));
    } finally {
      container.dispose();
      await dir.delete(recursive: true);
    }
  });
  test(
    'Profilo corrotto conservato, operazioni bloccate e recupero con backup',
    () async {
      final dir = await Directory.systemTemp.createTemp('kh-corrupt-');
      final store = ProfileStore(dir), catalog = testCatalog();
      final container = profileContainer(catalog, JsonProfileRepository(store));
      final notifier = container.read(profileProvider.notifier);
      final engine = container.read(engineProvider);
      try {
        await store.profile.writeAsString('{broken');
        await notifier.initialize();
        expect(container.read(profileProvider).blocked, true);
        expect(
          await notifier.commit((s) => engine.increment(s, 'gale', 1)),
          false,
        );
        expect(await store.profile.readAsString(), '{broken');
        expect(
          await notifier.commit((_) => catalog.fresh(), importing: true),
          true,
        );
        expect(container.read(profileProvider).blocked, false);
        expect(await store.backup.readAsString(), '{broken');
        expect(
          jsonDecode(await store.profile.readAsString())['schemaVersion'],
          2,
        );
      } finally {
        container.dispose();
        await dir.delete(recursive: true);
      }
    },
  );
}
