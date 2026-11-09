import 'dart:io';

/// Trova KHFM_WW.png nelle cartelle del gioco: Steam con Proton su Linux,
/// Documenti su Windows. `KH_SAVE_PATH` ha sempre la priorità.
class GameSaveLocator {
  static const fileName = 'KHFM_WW.png';
  static const steamAppId = '2552430';
  static const gameFolder = 'My Games/KINGDOM HEARTS HD 1.5+2.5 ReMIX';

  static File? find({String? home, Map<String, String>? environment}) {
    final env = environment ?? Platform.environment;
    final configured = env['KH_SAVE_PATH'];
    if (configured != null && configured.isNotEmpty) {
      final file = File(configured);
      return file.existsSync() ? file : null;
    }
    final saves = candidates(
      home ?? env['HOME'] ?? env['USERPROFILE'] ?? '',
    ).where((f) => f.existsSync()).toList();
    if (saves.isEmpty) return null;
    saves.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return saves.first;
  }

  /// Cartelle dei documenti del gioco: quelle di Windows e quelle dei
  /// prefissi Proton di ogni libreria Steam.
  static List<File> candidates(String home) {
    final documents = <String>{
      '$home/Documents',
      for (final library in steamLibraries(home))
        '$library/steamapps/compatdata/$steamAppId/pfx/drive_c/users/steamuser/Documents',
    };
    return [
      for (final docs in documents)
        // Steam/<id utente>/ ed Epic Games Store/<id utente>/
        for (final store in _children(Directory('$docs/$gameFolder')))
          for (final user in _children(store)) File('${user.path}/$fileName'),
    ];
  }

  static Set<String> steamLibraries(String home) {
    final roots = [
      '$home/.local/share/Steam',
      '$home/.steam/steam',
      '$home/.var/app/com.valvesoftware.Steam/.local/share/Steam',
    ];
    final libraries = <String>{};
    for (final root in roots) {
      final config = File('$root/steamapps/libraryfolders.vdf');
      if (!Directory(root).existsSync()) continue;
      libraries.add(Directory(root).resolveSymbolicLinksSync());
      if (!config.existsSync()) continue;
      for (final match in RegExp(
        r'"path"\s+"([^"]+)"',
      ).allMatches(config.readAsStringSync())) {
        final path = match.group(1)!.replaceAll(r'\\', r'\');
        if (Directory(path).existsSync()) {
          libraries.add(Directory(path).resolveSymbolicLinksSync());
        }
      }
    }
    return libraries;
  }

  static List<Directory> _children(Directory directory) {
    if (!directory.existsSync()) return [];
    return directory.listSync().whereType<Directory>().toList();
  }
}
