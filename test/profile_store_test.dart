import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_diario/storage/profile_store.dart';
import 'test_catalog.dart';

void main() {
  test(
    'Scrittura atomica, conflitti tra finestre e backup prima dell’importazione',
    () async {
      final directory = await Directory.systemTemp.createTemp('kh-store-test-');
      try {
        final a = ProfileStore(directory),
            b = ProfileStore(directory),
            s = testCatalog().fresh();
        await a.loadRaw();
        await b.loadRaw();
        await a.save(s);
        expect(await a.profile.exists(), true);
        await expectLater(b.save(s), throwsA(isA<FileSystemException>()));
        final raw = await b.loadRaw();
        final changed = {...s, 'storyPoint': 'test'};
        await b.save(changed, beforeImport: true);
        expect(await b.backup.readAsString(), raw);
        expect(
          (await directory.list().toList()).where(
            (file) => file.path.endsWith('.tmp'),
          ),
          isEmpty,
        );
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );
}
