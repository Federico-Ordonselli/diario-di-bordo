import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../domain/catalog.dart';

/// Archivio nativo: lock tra processi, confronto revisione e rename atomico.
class ProfileStore {
  ProfileStore(this.directory);
  final Directory directory;
  String? _revision;
  File get profile => File('${directory.path}/profile.json');
  File get backup => File('${directory.path}/before-import.json');

  /// Il bundle eseguito dal progetto usa l'archivio originale anche quando
  /// avviato senza launcher. Un'installazione autonoma usa la cartella supporto.
  static Directory selectDirectory({
    String? configured,
    required String executable,
    required String workingDirectory,
    required String applicationSupport,
  }) {
    if (configured != null && configured.isNotEmpty) {
      return Directory(configured);
    }
    for (final start in [
      File(executable).absolute.parent,
      Directory(workingDirectory).absolute,
    ]) {
      var candidate = start;
      while (true) {
        final manifest = File('${candidate.path}/pubspec.yaml');
        final catalog = File(
          '${candidate.path}/assets/datasets/initial-profile.json',
        );
        if (manifest.existsSync() &&
            catalog.existsSync() &&
            RegExp(
              r'^name:\s*diario_bordo\s*$',
              multiLine: true,
            ).hasMatch(manifest.readAsStringSync())) {
          return Directory('${candidate.path}/data');
        }
        final parent = candidate.parent;
        if (parent.path == candidate.path) break;
        candidate = parent;
      }
    }
    return Directory('$applicationSupport/diario-bordo');
  }

  static Future<ProfileStore> open() async {
    final directory = selectDirectory(
      configured: Platform.environment['KH_DATA_DIR'],
      executable: Platform.resolvedExecutable,
      workingDirectory: Directory.current.path,
      applicationSupport: (await getApplicationSupportDirectory()).path,
    );
    await directory.create(recursive: true);
    return ProfileStore(directory);
  }

  Future<String?> loadRaw() async {
    _revision = await profile.exists() ? await profile.readAsString() : null;
    return _revision;
  }

  Future<void> _atomic(File target, String contents) async {
    final temporary = File(
      '${target.path}.${pid}_${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    try {
      await temporary.writeAsString(contents, flush: true);
      await temporary.rename(target.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
  }

  Future<void> save(Json state, {bool beforeImport = false}) async {
    final lock = await File(
      '${directory.path}/profile.lock',
    ).open(mode: FileMode.append);
    try {
      await lock.lock(FileLock.blockingExclusive);
      final actual = await profile.exists()
          ? await profile.readAsString()
          : null;
      if (actual != _revision) {
        throw const FileSystemException(
          'Il profilo è cambiato in un’altra finestra. Ricarica prima di continuare.',
        );
      }
      if (beforeImport && actual != null) await _atomic(backup, actual);
      final encoded = const JsonEncoder.withIndent('  ').convert(state);
      await _atomic(profile, encoded);
      _revision = encoded;
    } finally {
      await lock.close();
    }
  }
}
