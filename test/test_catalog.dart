import 'dart:convert';
import 'dart:io';
import 'package:diario_bordo/domain/catalog.dart';

Json _read(String path) => jsonDecode(File(path).readAsStringSync()) as Json;

/// Catalogo della vecchia app: profilo di partenza ed evidence storici,
/// necessari ai fixture di parità generati dal motore originale.
Catalog testCatalog() => Catalog(
  _read('assets/datasets/synthesis.json'),
  _read('assets/datasets/completion.json'),
  _read('test/fixtures/legacy-initial-profile.json'),
  evidence: _read('test/fixtures/evidence.json'),
);

/// Catalogo come lo carica l'app: solo asset, template neutro, niente evidence.
Catalog appCatalog() => Catalog(
  _read('assets/datasets/synthesis.json'),
  _read('assets/datasets/completion.json'),
  _read('assets/datasets/initial-profile.json'),
);

/// Fixture generati dal motore originale, senza `reportPath`: era il link al
/// report del save della vecchia app, non più prodotto (report personale,
/// uscito dagli asset).
Json fixture() =>
    _withoutKey(_read('test/parity-fixtures.json'), 'reportPath') as Json;

dynamic _withoutKey(dynamic value, String key) => switch (value) {
  Map() => <String, dynamic>{
    for (final e in value.entries)
      if (e.key != key) e.key: _withoutKey(e.value, key),
  },
  List() => [for (final v in value) _withoutKey(v, key)],
  _ => value,
};
dynamic withoutDates(dynamic value) {
  if (value is Map) {
    return {
      for (final e in value.entries)
        if (!['updatedAt', 'at', 'importedAt'].contains(e.key))
          e.key: withoutDates(e.value),
    };
  }
  if (value is List) return value.map(withoutDates).toList();
  return value;
}
