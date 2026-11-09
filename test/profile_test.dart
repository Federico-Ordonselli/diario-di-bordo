import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/domain/catalog.dart';
import 'package:diario_bordo/domain/engine.dart';
import 'package:diario_bordo/domain/profile.dart';
import 'package:diario_bordo/domain/validation.dart';
import 'test_catalog.dart';

void main() {
  final catalog = testCatalog(), engine = Engine(catalog);

  test('I campi tipizzati leggono il profilo iniziale', () {
    final p = catalog.fresh();
    expect(p.schemaVersion, Profile.currentSchemaVersion);
    expect(p.inventory['lucid_shard'], 19);
    expect(p.inventory['lucid_crystal'], isNull);
    expect(p.everCrafted['energy_bangle'], true);
    expect(p.craftCount['energy_bangle'], isNull);
    expect(p.collection('dm_01'), CollectionStatus.unknown);
    expect(p.plan.mode, PlanMode.all);
    expect(p.plan.rewards, {'dark_matter': 5, 'orichalcum': 10});
    expect(p.settings.level, isNull);
    expect(p.activeSave, isNull);
    expect(p.transactions, isEmpty);
  });

  test('Profilo vuoto: stessa forma, nessun progresso, valido', () {
    final p = catalog.empty(), template = catalog.fresh();
    expect(p.inventory.keys, template.inventory.keys);
    expect(p.inventory.values.toSet(), {0});
    expect(p.everCrafted.values.toSet(), {false});
    expect(p.craftCount.values.toSet(), {0});
    for (final c in catalog.collections) {
      expect(p.collection(c['id'] as String), CollectionStatus.unknown);
    }
    expect(p.completion, isEmpty);
    expect(p.appliedEvidence, isEmpty);
    expect(catalog.summary(p)['done'], 0);
    expect(engine.distinct(p), 0);
    expect(jsonEncode(ProfileValidator(catalog).profile(p)), jsonEncode(p));
  });

  test('Profile è il JSON stesso: nessuna copia, scritture visibili', () {
    final json = copyJson(catalog.initial), p = Profile(json);
    expect(identical(p, json), true);
    p.inventory['gale'] = 42;
    p.plan.mode = PlanMode.route15;
    p.setCollection('dm_01', CollectionStatus.notCollected);
    p.settings.setFlag('Stop', true);
    expect(json['inventory']['gale'], 42);
    expect(json['plan']['mode'], '15');
    expect(json['collections']['dm_01'], 'not_collected');
    expect(json['settings']['Stop'], true);
    expect(jsonDecode(jsonEncode(p)), json);
  });

  test('Valori sconosciuti negli enum sono errori di formato', () {
    expect(() => CollectionStatus.parse('boh'), throwsFormatException);
    expect(() => PlanMode.parse('boh'), throwsFormatException);
  });

  test('La cronologia registra origine e stato precedente tipizzati', () {
    final s = engine.applyEvidence(catalog.fresh());
    final next = engine.increment(s, 'gale', 2);
    expect(next.transactions.map((t) => t.origin), [
      TransactionOrigin.evidence,
      TransactionOrigin.manual,
    ]);
    final last = next.transactions.last;
    expect(last.label, contains('→'));
    expect(last.before['inventory']['gale'], s.inventory['gale']);
    expect(
      next.manualOverrides['app']!['inventory.gale'],
      next.inventory['gale'],
    );
    expect(engine.undo(next).inventory['gale'], s.inventory['gale']);
  });
}
