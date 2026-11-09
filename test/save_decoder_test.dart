import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/domain/catalog.dart';
import 'package:diario_bordo/domain/engine.dart';
import 'package:diario_bordo/domain/save_adapter.dart';
import 'package:diario_bordo/domain/save_decoder.dart';
import 'test_catalog.dart';

Json readJson(String path) => jsonDecode(File(path).readAsStringSync()) as Json;

/// Date e provenienza dipendono dal momento e dal file ridotto: il resto deve
/// coincidere con l'analisi Python del save completo.
Json comparable(Json snapshot) {
  final copy = copyJson(snapshot)
    ..remove('generated_at')
    ..remove('source');
  for (final slot in (copy['slots'] as List).cast<Json>()) {
    for (final key in ['created_at', 'modified_at']) {
      slot[key] = DateTime.parse(slot[key] as String).toUtc().toIso8601String();
    }
  }
  return copy;
}

void main() {
  final png = File('test/fixtures/KHFM_WW-2026-10-22.png').readAsBytesSync();
  final expected = readJson('test/fixtures/KHFM_WW-2026-10-22.json');

  test('Il PNG decodificato coincide con lo snapshot analizzato', () {
    final decoded = decodeSave(
      png,
      readJson('test/analyzed-save-2026-10-09.json'),
    );
    expect(comparable(decoded), comparable(expected));
    expect(decoded['source'], {
      'filename': 'KHFM_WW.png',
      'size_bytes': png.length,
      'sha256': sha256.convert(png).toString(),
      'png_crc_valid': true,
      'source_save_modified': false,
    });
  });

  test('Il riferimento incluso nell’app produce lo stesso snapshot', () {
    final decoded = decodeSave(
      png,
      readJson('assets/datasets/analyzed-save.json'),
    );
    expect(comparable(decoded), comparable(expected));
  });

  test('Lo snapshot decodificato è importabile dall’adattatore', () {
    final adapter = SaveAdapter(Engine(testCatalog()));
    final raw = adapter.validate(
      decodeSave(png, readJson('assets/datasets/analyzed-save.json')),
    );
    expect(adapter.normalizeSlot(raw, 1)['level'], 67);
  });

  test('File non validi vengono rifiutati', () {
    final reference = readJson('assets/datasets/analyzed-save.json');
    expect(
      () => decodeSave(utf8.encode('non un png'), reference),
      throwsFormatException,
    );
    final noPayload = png.sublist(0, 33);
    expect(() => decodeSave(noPayload, reference), throwsFormatException);
  });
}
