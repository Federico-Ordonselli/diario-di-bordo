import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kh_diario/domain/catalog.dart';
import 'package:kh_diario/domain/engine.dart';
import 'package:kh_diario/domain/save_adapter.dart';
import 'package:kh_diario/domain/validation.dart';
import 'test_catalog.dart';

void main() {
  final catalog = testCatalog(),
      engine = Engine(catalog),
      adapter = SaveAdapter(engine);
  final raw =
      jsonDecode(File('test/analyzed-save-2026-10-09.json').readAsStringSync())
          as Json;
  final expected = fixture();
  test('Tutti gli slot normalizzati coincidono con il vecchio adattatore', () {
    adapter.validate(raw);
    for (final snapshot in (expected['snapshots'] as List).cast<Json>()) {
      expect(
        adapter.normalizeSlot(raw, snapshot['slotNumber'] as int),
        snapshot,
      );
    }
  });
  test('Anteprima e importazione coincidono con il motore originale', () {
    final s = catalog.fresh();
    expect(adapter.preview(s, raw, 1), expected['preview']);
    final next = adapter.apply(s, raw, 1);
    expect(withoutDates(next), withoutDates(expected['imported']));
    expect(
      ProfileValidator(catalog).validate(next)['inventory'],
      next['inventory'],
    );
    final undone = engine.undo(next);
    expect(undone['inventory'], s['inventory']);
    expect(undone['activeSaveId'], null);
    expect((undone['saveSnapshots'] as Json).length, 1);
  });
  test(
    'Le modifiche manuali sono conflitti e si possono risolvere esplicitamente',
    () {
      final s = engine.quantity(catalog.fresh(), 'gale', 77),
          p = adapter.preview(s, raw, 1);
      final row = (p['rows'] as List).firstWhere(
        (r) => r['key'] == 'inventory.gale',
      );
      expect(row['conflict'], true);
      expect(row['after'], 77);
      expect(adapter.apply(s, raw, 1)['inventory']['gale'], 77);
      final next = adapter.apply(s, raw, 1, {'inventory.gale': 'save'});
      expect(next['inventory']['gale'], row['value']);
    },
  );
  test(
    'Le modifiche manuali anteriori al save cedono, quelle confermate spariscono',
    () {
      final later = copyJson(raw);
      for (final slot in (later['slots'] as List).cast<Json>()) {
        slot['modified_at'] = '2099-01-01T00:00:00+00:00';
      }
      final s = engine.quantity(catalog.fresh(), 'gale', 77),
          p = adapter.preview(s, later, 1);
      final row = (p['rows'] as List).firstWhere(
        (r) => r['key'] == 'inventory.gale',
      );
      expect(row['conflict'], true);
      expect(row['kept'], false);
      final next = adapter.apply(s, later, 1);
      expect(next['inventory']['gale'], row['value']);
      final scoped = next['manualOverrides'][p['scope']] as Json;
      expect(scoped.containsKey('inventory.gale'), false);
      expect(
        adapter.apply(s, later, 1, {
          'inventory.gale': 'keep',
        })['inventory']['gale'],
        77,
      );
      final equal = engine.quantity(
            engine.quantity(next, 'gale', 5),
            'gale',
            row['value'] as int,
          ),
          again = adapter.apply(equal, raw, 1);
      expect(
        (equal['manualOverrides'][p['scope']] as Json).containsKey(
          'inventory.gale',
        ),
        true,
      );
      expect(
        (again['manualOverrides'][p['scope']] as Json).containsKey(
          'inventory.gale',
        ),
        false,
      );
    },
  );
  test('Override di slot diversi non vengono trasferiti', () {
    final slot1 = adapter.apply(catalog.fresh(), raw, 1);
    final manual = engine.quantity(slot1, 'gale', 99);
    final slot2 = adapter.apply(manual, raw, 2);
    expect(
      slot2['inventory']['gale'],
      adapter.normalizeSlot(raw, 2)['observations']['inventory.gale']['value'],
    );
    expect(adapter.apply(slot2, raw, 1)['inventory']['gale'], 99);
  });
  test('Counter e forzieri indipendenti dalla checklist Excel', () {
    final s = adapter.apply(catalog.fresh(), raw, 1);
    final next = adapter.edit(s, 'postcards', null);
    expect(next['saveValues']['postcards'], null);
    expect(next['completion'], s['completion']);
    expect(() => adapter.edit(s, 'postcards', 11), throwsFormatException);
  });
}
