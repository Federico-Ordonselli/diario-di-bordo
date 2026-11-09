import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_providers.dart';
import '../../domain/catalog.dart';
import '../../domain/save_adapter.dart';
import '../../domain/save_decoder.dart';

/// Snapshot incluso negli asset: fornisce le mappature per decodificare il
/// PNG del gioco. Caricato alla prima apertura della pagina Save.
final saveReferenceProvider = FutureProvider<Json>((ref) async {
  final text = await rootBundle.loadString(
    'assets/datasets/analyzed-save.json',
  );
  return SaveAdapter(ref.watch(engineProvider)).validate(jsonDecode(text));
});

/// Decodifica [bytes] in un isolate per non bloccare l'interfaccia. Lavora
/// sui byte e non su un percorso: su Android il file scelto non ha un path.
/// Top-level di proposito: una closure creata in un metodo di State
/// condivide il contesto con `this`, e l'isolate rifiuterebbe di copiarlo.
Future<Json> decodeSaveInIsolate(
  Uint8List bytes,
  Json reference,
  String name,
) => Isolate.run(() => decodeSave(bytes, reference, filename: name));
