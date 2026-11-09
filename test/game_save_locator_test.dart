import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_diario/storage/game_save_locator.dart';

void main() {
  late Directory home;
  setUp(() => home = Directory.systemTemp.createTempSync('kh-locator'));
  tearDown(() => home.deleteSync(recursive: true));

  File save(String library, String user, DateTime modified) {
    final file = File(
      '$library/steamapps/compatdata/2552430/pfx/drive_c/users/steamuser/'
      'Documents/My Games/KINGDOM HEARTS HD 1.5+2.5 ReMIX/Steam/$user/'
      'KHFM_WW.png',
    )..createSync(recursive: true);
    file.setLastModifiedSync(modified);
    return file;
  }

  test('Trova il save più recente tra le librerie Steam', () {
    final steam = '${home.path}/.local/share/Steam';
    final extra = '${home.path}/storage/SteamLibrary';
    File('$steam/steamapps/libraryfolders.vdf')
      ..createSync(recursive: true)
      ..writeAsStringSync(
        '"libraryfolders"\n{\n\t"0"\n\t{\n\t\t"path"\t\t"$steam"\n\t}\n'
        '\t"1"\n\t{\n\t\t"path"\t\t"$extra"\n\t}\n}\n',
      );
    save(steam, '111', DateTime(2026, 10, 1));
    final newest = save(extra, '222', DateTime(2026, 10, 22));
    final found = GameSaveLocator.find(home: home.path, environment: {});
    expect(found?.path, newest.path);
  });

  test('KH_SAVE_PATH ha la priorità', () {
    final custom = File('${home.path}/altro/KHFM_WW.png')
      ..createSync(recursive: true);
    final found = GameSaveLocator.find(
      home: home.path,
      environment: {'KH_SAVE_PATH': custom.path},
    );
    expect(found?.path, custom.path);
  });

  test('Nessun save trovato restituisce null', () {
    expect(GameSaveLocator.find(home: home.path, environment: {}), null);
  });
}
