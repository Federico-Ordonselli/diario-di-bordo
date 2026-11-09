import 'dart:typed_data';
import 'catalog.dart';
import 'profile.dart';

/// Persistenza del profilo, indipendente dal supporto (file JSON oggi,
/// SQLite domani).
///
/// Il repository non valida: [load] restituisce il contenuto decodificato così
/// com'è, e la validazione contro il catalogo resta nel dominio.
abstract interface class ProfileRepository {
  /// Dove sono conservati i dati, da mostrare all'utente.
  String get location;

  /// Profilo salvato, `null` se non esiste ancora.
  /// Lancia [FormatException] se l'archivio non è decodificabile.
  Future<Json?> load();

  /// Salva [profile]. Fallisce se l'archivio è stato modificato da altri dopo
  /// l'ultimo [load]/[save]. Con [beforeImport] conserva prima una copia del
  /// profilo corrente, recuperabile con [previousBackup].
  Future<void> save(Profile profile, {bool beforeImport = false});

  /// Copia conservata prima dell'ultima importazione, `null` se assente.
  Future<Uint8List?> previousBackup();
}
