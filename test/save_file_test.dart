import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/domain/catalog.dart';
import 'package:diario_bordo/domain/save_decoder.dart';
import 'package:diario_bordo/features/save/save_reference.dart';
import 'package:diario_bordo/storage/save_file.dart';

void main() {
  const fixture = 'test/fixtures/KHFM_WW-2026-10-22.png';
  final png = File(fixture).readAsBytesSync();

  test(
    'Android: file come byte con percorso content:// non leggibile',
    () async {
      final save = await readPickedSave(
        XFile.fromData(
          png,
          path: 'content://com.android.providers.downloads/document/42',
          length: png.length,
        ),
      );
      expect(save.bytes, png);
      expect(save.name, 'KHFM_WW.png');
      expect(save.origin, 'KHFM_WW.png');
    },
  );

  test('Desktop: file vero, nome e data di modifica conservati', () async {
    final save = await readPickedSave(XFile(fixture));
    expect(save.bytes, png);
    expect(save.name, 'KHFM_WW-2026-10-22.png');
    expect(
      save.origin,
      startsWith('KHFM_WW-2026-10-22.png · file modificato '),
    );
  });

  test('File troppo grande rifiutato prima della lettura', () async {
    final huge = XFile.fromData(
      Uint8List(0),
      path: '/x/save.png',
      length: maxSaveBytes + 1,
    );
    await expectLater(readPickedSave(huge), throwsFormatException);
  });

  test('Il filtro funziona su iOS (UTI), Android (MIME) e desktop', () {
    expect(saveTypeGroup.uniformTypeIdentifiers, ['public.png']);
    expect(saveTypeGroup.mimeTypes, ['image/png']);
    expect(saveTypeGroup.extensions, ['png']);
  });

  test(
    'La decodifica in isolate dai byte coincide con quella diretta',
    () async {
      final reference =
          jsonDecode(
                File('test/analyzed-save-2026-10-09.json').readAsStringSync(),
              )
              as Json;
      final picked = await readPickedSave(XFile.fromData(png, path: 'x'));
      final isolated = await decodeSaveInIsolate(
        picked.bytes,
        reference,
        picked.name,
      );
      final direct = decodeSave(png, reference, filename: 'KHFM_WW.png');
      expect(
        jsonEncode(isolated..remove('generated_at')),
        jsonEncode(direct..remove('generated_at')),
      );
    },
  );
}
