import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_diario/storage/profile_store.dart';

void main() {
  late Directory temporary, project;
  setUp(() {
    temporary = Directory.systemTemp.createTempSync('kh-location-');
    project = Directory('${temporary.path}/project')..createSync();
    File('${project.path}/pubspec.yaml').writeAsStringSync('name: kh_diario\n');
    Directory('${project.path}/assets/datasets').createSync(recursive: true);
    File(
      '${project.path}/assets/datasets/initial-profile.json',
    ).writeAsStringSync('{}');
  });
  tearDown(() => temporary.deleteSync(recursive: true));
  Directory resolve({String? configured, String? executable, String? cwd}) =>
      ProfileStore.selectDirectory(
        configured: configured,
        executable:
            executable ??
            '${project.path}/build/linux/x64/release/bundle/kh_diario',
        workingDirectory: cwd ?? temporary.path,
        applicationSupport: '${temporary.path}/support',
      );
  test('Il binario avviato direttamente riusa data del progetto', () {
    expect(resolve().path, '${project.path}/data');
  });
  test('flutter run ritrova il progetto dalla cartella di lavoro', () {
    expect(
      resolve(
        executable: '${temporary.path}/sdk/flutter_tester',
        cwd: project.path,
      ).path,
      '${project.path}/data',
    );
  });
  test(
    'KH_DATA_DIR esplicito conserva priorità e profili di prova isolati',
    () {
      expect(
        resolve(configured: '${temporary.path}/custom').path,
        '${temporary.path}/custom',
      );
    },
  );
  test(
    'Bundle autonomo usa la cartella supporto, non data di un altro progetto',
    () {
      File(
        '${project.path}/pubspec.yaml',
      ).writeAsStringSync('name: another_app\n');
      expect(
        resolve(cwd: project.path).path,
        '${temporary.path}/support/kh-diario',
      );
    },
  );
}
