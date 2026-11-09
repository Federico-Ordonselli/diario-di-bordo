import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'game_save_locator.dart';

/// Save del gioco già letto in memoria: da qui in poi desktop e mobile
/// seguono gli stessi passi (decodifica dei byte, anteprima, conferma).
typedef GameSaveFile = ({Uint8List bytes, String name, String origin});

/// Limite di sicurezza: il save reale pesa qualche centinaio di KB.
const maxSaveBytes = 32 * 1024 * 1024;

/// Filtro del selettore. iOS vuole un UTI, Android un MIME, i desktop
/// l'estensione: senza UTI `openFile` su iOS lancia `ArgumentError`.
const saveTypeGroup = XTypeGroup(
  label: 'Save PNG',
  extensions: ['png'],
  mimeTypes: ['image/png'],
  uniformTypeIdentifiers: ['public.png'],
);

/// Ricerca automatica del save nelle cartelle del gioco: solo dove il gioco
/// gira (Windows, Linux con Proton). Su mobile e macOS c'è solo il selettore.
/// `defaultTargetPlatform` (non `Platform`): i widget test possono simularlo.
bool get canLocateGameSave =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.windows);

/// Save trovato da [GameSaveLocator], `null` se assente o non supportato.
Future<GameSaveFile?> readLocatedSave() async {
  if (!canLocateGameSave) return null;
  final file = GameSaveLocator.find();
  if (file == null) return null;
  final modified = await file.lastModified();
  return (
    bytes: await _checkedBytes(await file.length(), file.readAsBytes),
    name: file.uri.pathSegments.last,
    origin: '${file.path} · file modificato ${_format(modified)}',
  );
}

/// Cartella proposta al selettore (solo desktop, dove esiste un percorso).
String? suggestedSaveDirectory() =>
    canLocateGameSave ? GameSaveLocator.find()?.parent.path : null;

/// Save scelto dall'utente. Su Android il file arriva come byte con un
/// percorso che non è un file vero: si usano solo i metodi di [XFile].
Future<GameSaveFile> readPickedSave(XFile file) async {
  DateTime? modified;
  try {
    modified = await file.lastModified();
  } catch (_) {
    // Non disponibile per i file passati come byte (Android).
  }
  final name = file.name.toLowerCase().endsWith('.png')
      ? file.name
      : GameSaveLocator.fileName;
  return (
    bytes: await _checkedBytes(await file.length(), file.readAsBytes),
    name: name,
    origin: modified == null
        ? name
        : '$name · file modificato ${_format(modified)}',
  );
}

Future<Uint8List> _checkedBytes(
  int length,
  Future<Uint8List> Function() read,
) async {
  if (length > maxSaveBytes) {
    throw const FormatException('File troppo grande per un save del gioco.');
  }
  return read();
}

String _format(DateTime value) => value.toString().substring(0, 19);
