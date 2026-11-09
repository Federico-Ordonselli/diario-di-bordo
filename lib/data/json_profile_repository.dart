import 'dart:convert';
import 'dart:typed_data';
import '../domain/catalog.dart';
import '../domain/profile.dart';
import '../domain/profile_repository.dart';
import '../storage/profile_store.dart';

/// [ProfileRepository] su file JSON, sopra [ProfileStore] (lock, rename
/// atomico, rilevamento conflitti tra finestre).
class JsonProfileRepository implements ProfileRepository {
  JsonProfileRepository(this.store);
  final ProfileStore store;

  static Future<JsonProfileRepository> open() async =>
      JsonProfileRepository(await ProfileStore.open());

  @override
  String get location => store.directory.path;

  @override
  Future<Json?> load() async {
    final raw = await store.loadRaw();
    if (raw == null) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Json) {
      throw const FormatException('Il profilo non è un oggetto JSON.');
    }
    return decoded;
  }

  @override
  Future<void> save(Profile profile, {bool beforeImport = false}) =>
      store.save(profile, beforeImport: beforeImport);

  @override
  Future<Uint8List?> previousBackup() async =>
      await store.backup.exists() ? await store.backup.readAsBytes() : null;
}
