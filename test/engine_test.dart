import 'package:flutter_test/flutter_test.dart';
import 'package:kh_diario/domain/catalog.dart';
import 'package:kh_diario/domain/engine.dart';
import 'package:kh_diario/domain/validation.dart';
import 'test_catalog.dart';

void main() {
  final catalog = testCatalog(), engine = Engine(catalog), expected = fixture();
  test(
    'Dataset completo: 794 voci, 15 categorie, 34 materiali e 33 ricette',
    () {
      expect(catalog.items.length, 794);
      expect(catalog.categories.length, 15);
      expect(catalog.materials.length, 34);
      expect(catalog.recipes.length, 33);
      expect(catalog.collections.length, 30);
    },
  );
  for (final scenario in (expected['scenarios'] as List).cast<Json>()) {
    test('Parità col motore originale: ${scenario['name']}', () {
      final s = scenario['state'] as Json;
      expect(engine.plan(s), scenario['plan']);
      expect(engine.simulate(s), scenario['simulation']);
      expect(
        ProfileValidator(catalog).validate(s)['inventory'],
        s['inventory'],
      );
    });
  }
  test('Le transazioni coincidono col motore originale', () {
    final s = catalog.fresh(), operations = expected['operations'] as Json;
    expect(
      withoutDates(engine.craft(s, 'cottage')),
      withoutDates(operations['crafted']),
    );
    expect(
      withoutDates(engine.increment(s, 'lucid_shard', 5)),
      withoutDates(operations['incremented']),
    );
    expect(
      withoutDates(
        engine.collect(s, catalog.collections.first['id'] as String, now: true),
      ),
      withoutDates(operations['collected']),
    );
    expect(
      withoutDates(
        engine.completion(s, catalog.items.first['id'] as String, true),
      ),
      withoutDates(operations['completed']),
    );
  });
  test('Quantità sconosciute non sono zero e bloccano raccolte e sintesi', () {
    final s = catalog.fresh();
    expect(
      () => engine.increment(s, 'lucid_crystal', 1),
      throwsFormatException,
    );
    expect(() => engine.quantity(s, 'lucid_shard', -1), throwsFormatException);
    expect(() => engine.quantity(s, 'lucid_shard', 1.5), throwsFormatException);
    expect(
      engine.quantity(s, 'lucid_crystal', 0)['inventory']['lucid_crystal'],
      0,
    );
    expect(() => engine.craft(s, 'ultima_weapon'), throwsFormatException);
  });
  test('Annullamento atomico e evidence applicata una sola volta', () {
    final s = catalog.fresh(), next = engine.applyEvidence(s);
    expect(identical(engine.applyEvidence(next), next), true);
    final undone = engine.undo(next);
    expect(undone['completion'], s['completion']);
    expect(undone['appliedEvidence'], [catalog.evidence['id']]);
    expect(identical(engine.applyEvidence(undone), undone), true);
    final collected = engine.collect(
      s,
      catalog.collections.first['id'] as String,
      now: true,
    );
    expect(withoutDates(engine.undo(collected)), withoutDates(s));
  });
  test('Sessione aggiorna inventario e contatore insieme', () {
    final s = catalog.fresh(), next = engine.sessionCollect(s, 'gale', 5);
    expect(next['inventory']['gale'], 8);
    expect(next['session']['gale'], 5);
    expect(withoutDates(engine.undo(next)), withoutDates(s));
  });
  test('Cronologia limita a 100 operazioni e i backup restano validi', () {
    var s = catalog.fresh();
    for (var i = 0; i < 110; i++) {
      s = engine.increment(s, 'gale', 1);
    }
    expect((s['transactions'] as List).length, 100);
    expect(ProfileValidator(catalog).validate(s)['inventory']['gale'], 113);
  });
  test('Migra schema 1 senza perdere scorte o cronologia', () {
    final legacy = catalog.fresh()..['schemaVersion'] = 1;
    legacy.remove('completion');
    legacy.remove('completionDatasetVersion');
    final restored = ProfileValidator(catalog).validate(legacy);
    expect(restored['schemaVersion'], 2);
    expect(restored['inventory'], legacy['inventory']);
  });
  test('Backup malformati rifiutati', () {
    final validator = ProfileValidator(catalog);
    expect(
      () => validator.validate({'schemaVersion': 2}),
      throwsFormatException,
    );
    final s = catalog.fresh();
    s['completion']['sconosciuto'] = true;
    expect(() => validator.validate(s), throwsFormatException);
    final invalid = catalog.fresh();
    invalid['saveValues']['postcards'] = 11;
    expect(() => validator.validate(invalid), throwsFormatException);
  });
}
