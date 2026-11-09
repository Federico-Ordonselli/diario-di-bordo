import 'dart:convert';
import 'dart:typed_data';
import 'package:diario_bordo/domain/catalog.dart';
import 'package:diario_bordo/domain/profile.dart';
import 'package:diario_bordo/domain/profile_repository.dart';

/// Repository in memoria: serializza come quello reale (così i test vedono
/// copie indipendenti, non riferimenti condivisi) ma senza toccare il disco.
class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository([this.stored]);

  /// Contenuto "su disco"; impostarlo a mano simula archivi esistenti o corrotti.
  String? stored;
  String? backup;
  int saves = 0;

  @override
  String get location => 'memoria';

  @override
  Future<Json?> load() async {
    if (stored == null) return null;
    final decoded = jsonDecode(stored!);
    if (decoded is! Json) throw const FormatException('Non è un oggetto.');
    return decoded;
  }

  @override
  Future<void> save(Profile profile, {bool beforeImport = false}) async {
    if (beforeImport && stored != null) backup = stored;
    stored = jsonEncode(profile);
    saves++;
  }

  @override
  Future<Uint8List?> previousBackup() async =>
      backup == null ? null : utf8.encode(backup!);
}
