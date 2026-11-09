import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/domain/engine.dart';
import 'package:diario_bordo/domain/profile.dart';
import 'package:diario_bordo/storage/controller.dart';
import 'package:diario_bordo/data/json_profile_repository.dart';
import 'package:diario_bordo/storage/profile_store.dart';
import 'test_catalog.dart';

void main() {
  test('Errore di scrittura conserva lo stato mostrato', () async {
    final dir = await Directory.systemTemp.createTemp('kh-controller-');
    final controller = ProfileController(
      Engine(testCatalog()),
      JsonProfileRepository(ProfileStore(dir)),
    );
    try {
      await controller.initialize();
      final previous = controller.state;
      final foreign = ProfileStore(dir);
      await foreign.loadRaw();
      final newer = Profile({...previous, 'storyPoint': 'another-window'});
      await foreign.save(newer);
      final accepted = await controller.commit(
        (s) => controller.engine.increment(s, 'gale', 1),
      );
      expect(accepted, false);
      expect(identical(controller.state, previous), true);
      expect(controller.error, contains('altra finestra'));
    } finally {
      controller.dispose();
      await dir.delete(recursive: true);
    }
  });
  test(
    'Profilo corrotto conservato, operazioni bloccate e recupero con backup',
    () async {
      final dir = await Directory.systemTemp.createTemp('kh-corrupt-');
      final store = ProfileStore(dir), engine = Engine(testCatalog());
      final controller = ProfileController(
        engine,
        JsonProfileRepository(store),
      );
      try {
        await store.profile.writeAsString('{broken');
        await controller.initialize();
        expect(controller.blocked, true);
        expect(
          await controller.commit((s) => engine.increment(s, 'gale', 1)),
          false,
        );
        expect(await store.profile.readAsString(), '{broken');
        expect(
          await controller.commit(
            (_) => engine.catalog.fresh(),
            importing: true,
          ),
          true,
        );
        expect(controller.blocked, false);
        expect(await store.backup.readAsString(), '{broken');
        expect(
          jsonDecode(await store.profile.readAsString())['schemaVersion'],
          2,
        );
      } finally {
        controller.dispose();
        await dir.delete(recursive: true);
      }
    },
  );
}
