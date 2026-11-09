import 'dart:convert';
import 'dart:io';
import 'package:kh_diario/domain/catalog.dart';

Catalog testCatalog() {
  Json read(String name) =>
      jsonDecode(File('assets/datasets/$name.json').readAsStringSync()) as Json;
  return Catalog(
    read('synthesis'),
    read('completion'),
    read('evidence'),
    read('initial-profile'),
  );
}

Json fixture() =>
    jsonDecode(File('test/parity-fixtures.json').readAsStringSync()) as Json;
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
