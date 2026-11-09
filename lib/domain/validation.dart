import 'catalog.dart';
import 'engine.dart';

class ProfileValidator {
  ProfileValidator(this.catalog);
  final Catalog catalog;
  Never fail(String message) => throw FormatException(message);
  bool validTarget(String key, dynamic value) {
    final parts = key.split('.'),
        kind = parts.removeAt(0),
        id = parts.join('.');
    final flag = value == null || value is bool;
    if (kind == 'inventory') {
      return catalog.materialsById.containsKey(id) &&
          (value == null || validQuantity(value));
    }
    if (kind == 'completion') {
      return catalog.itemsById.containsKey(id) &&
          catalog.itemsById[id]!['recipeId'] == null &&
          flag;
    }
    if (kind == 'settings') {
      if (!(catalog.initial['settings'] as Json).containsKey(id)) return false;
      if (id == 'edition') return value is String && value.length <= 100;
      if (['level', 'mp', 'lucky', 'munny'].contains(id)) {
        return value == null ||
            validQuantity(value, id == 'lucky' ? 3 : 999999);
      }
      return flag;
    }
    if (kind == 'save') {
      if (RegExp(r'^chest\.\d+$').hasMatch(id)) return flag;
      if (id == 'postcards') return value == null || validQuantity(value, 10);
      const totals = {
        'Blue': 17,
        'Red': 6,
        'Green': 9,
        'Yellow': 4,
        'White': 10,
      };
      if (parts.length == 2 &&
          parts[0] == 'trinity' &&
          totals.containsKey(parts[1])) {
        return value == null || validQuantity(value, totals[parts[1]]!);
      }
    }
    return false;
  }

  /// [snapshots] sono snapshot già validati: la cronologia li riusa invece di
  /// copiarli e ricontrollarli per ogni operazione.
  Json validate(dynamic raw, {bool history = true, Json? snapshots}) {
    if (raw is! Json ||
        ![1, 2].contains(raw['schemaVersion']) ||
        raw['datasetVersion'] != catalog.initial['datasetVersion']) {
      fail('Versione backup non compatibile.');
    }
    if (raw['schemaVersion'] == 2 &&
        raw['completionDatasetVersion'] != catalog.workbook['version']) {
      fail('Checklist non compatibile.');
    }
    final s = catalog.fresh();
    final completion = raw['completion'];
    if (completion == null && raw['schemaVersion'] == 1) {
      // Schema 1 precede la checklist, che viene inizializzata dal catalogo.
    } else {
      if (completion is! Json) fail('Checklist non valida.');
      for (final e in completion.entries) {
        if (!validTarget('completion.${e.key}', e.value)) {
          fail('Voce checklist non valida: ${e.key}');
        }
        s['completion'][e.key] = e.value;
      }
    }
    for (final field in ['saveSnapshots', 'saveValues', 'manualOverrides']) {
      if (field == 'saveSnapshots' && snapshots != null) continue;
      if (raw[field] != null && raw[field] is! Json) {
        fail('Metadati save non validi.');
      }
      s[field] = copyJson((raw[field] ?? <String, dynamic>{}) as Json);
    }
    if (snapshots != null) s['saveSnapshots'] = snapshots;
    if ((s['saveSnapshots'] as Json).length > 100) fail('Troppi snapshot.');
    for (final e
        in snapshots == null
            ? (s['saveSnapshots'] as Json).entries
            : const <MapEntry<String, dynamic>>[]) {
      final v = e.value;
      if (v is! Json ||
          v['id'] != e.key ||
          !validQuantity(v['slotNumber'], 200) ||
          v['slotNumber'] == 0 ||
          v['savedAt'] is! String ||
          v['source'] is! Json ||
          v['source']['filename'] is! String ||
          v['observations'] is! Json ||
          v['chests'] is! List ||
          (v['chests'] as List).length > 1500) {
        fail('Snapshot archiviato non valido.');
      }
      for (final observation in (v['observations'] as Json).entries) {
        final value = observation.value;
        if (value is! Json ||
            !validTarget(observation.key, value['value']) ||
            value['label'] is! String ||
            value['path'] is! String) {
          fail('Osservazione non valida.');
        }
      }
    }
    s['activeSaveId'] = raw['activeSaveId'];
    if (s['activeSaveId'] != null &&
        !(s['saveSnapshots'] as Json).containsKey(s['activeSaveId'])) {
      fail('Snapshot attivo assente.');
    }
    for (final e in (s['saveValues'] as Json).entries) {
      if (!validTarget('save.${e.key}', e.value)) {
        fail('Contatore save non valido.');
      }
    }
    for (final overrides in (s['manualOverrides'] as Json).values) {
      if (overrides is! Json) fail('Override non valido.');
      for (final e in overrides.entries) {
        if (!validTarget(e.key, e.value)) fail('Override non valido: ${e.key}');
      }
    }
    final evidence = raw['appliedEvidence'] ?? [];
    if (evidence is! List ||
        evidence.length > 100 ||
        evidence.any((id) => id is! String || id.length > 150) ||
        evidence.toSet().length != evidence.length) {
      fail('Importazioni evidence non valide.');
    }
    s['appliedEvidence'] = [...evidence];
    if (raw['inventory'] is! Json ||
        raw['everCrafted'] is! Json ||
        raw['craftCount'] is! Json ||
        raw['collections'] is! Json) {
      fail('Profilo incompleto.');
    }
    for (final m in catalog.materials) {
      final id = m['id'] as String, value = raw['inventory'][m['id']];
      if (!(raw['inventory'] as Json).containsKey(id) ||
          !(value == null || validQuantity(value))) {
        fail('Quantità non valida: ${m['name']}');
      }
      s['inventory'][id] = value;
    }
    for (final r in catalog.recipes) {
      final id = r['id'] as String, value = raw['craftCount'][r['id']];
      if (raw['everCrafted'][id] is! bool ||
          !(raw['craftCount'] as Json).containsKey(id) ||
          !(value == null || validQuantity(value))) {
        fail('Storico non valido: ${r['name']}');
      }
      s['everCrafted'][id] = raw['everCrafted'][id];
      s['craftCount'][id] = value;
    }
    for (final c in catalog.collections) {
      if (![
        'unknown',
        'collected',
        'not_collected',
      ].contains(raw['collections'][c['id']])) {
        fail('Fonte non valida.');
      }
      s['collections'][c['id']] = raw['collections'][c['id']];
    }
    final p = raw['plan'];
    if (p is! Json ||
        !['all', '15', 'selected'].contains(p['mode']) ||
        p['selected'] is! List ||
        (p['selected'] as List).length > 33 ||
        (p['selected'] as List).toSet().length !=
            (p['selected'] as List).length ||
        (p['selected'] as List).any(
          (id) => !catalog.recipesById.containsKey(id),
        ) ||
        p['rewards'] is! Json) {
      fail('Piano non valido.');
    }
    for (final id in ['dark_matter', 'orichalcum']) {
      if (!validQuantity(p['rewards'][id])) fail('Ricompense non valide.');
    }
    s['plan'] = copyJson(p);
    if (raw['settings'] != null && raw['settings'] is! Json) {
      fail('Configurazione non valida.');
    }
    for (final key in (s['settings'] as Json).keys.toList()) {
      final value = raw['settings']?[key] ?? s['settings'][key];
      if (!validTarget('settings.$key', value)) {
        fail('Configurazione non valida: $key');
      }
      s['settings'][key] = value;
    }
    if (raw['session'] != null) {
      if (raw['session'] is! Json) fail('Sessione non valida.');
      for (final e in (raw['session'] as Json).entries) {
        if (!catalog.materialsById.containsKey(e.key) ||
            !validQuantity(e.value)) {
          fail('Sessione non valida.');
        }
        s['session'][e.key] = e.value;
      }
    }
    if (history) {
      if (raw['transactions'] is! List ||
          (raw['transactions'] as List).length > 100) {
        fail('Cronologia non valida.');
      }
      s['transactions'] = (raw['transactions'] as List).map((t) {
        if (t is! Json ||
            t['label'] is! String ||
            (t['label'] as String).length > 500 ||
            t['at'] is! String ||
            t['before'] is! Json) {
          fail('Operazione non valida.');
        }
        final origin =
            t['origin'] ??
            ((t['label'] as String).startsWith('Progressi dagli screenshot')
                ? 'evidence'
                : 'manual');
        if (!['manual', 'save', 'evidence'].contains(origin)) {
          fail('Origine non valida.');
        }
        final before =
            validate(
                {...t['before'] as Json, 'transactions': []},
                history: false,
                snapshots: s['saveSnapshots'] as Json,
              )
              ..remove('transactions')
              ..remove('saveSnapshots');
        return {
          'label': t['label'],
          'at': t['at'],
          'origin': origin,
          'before': before,
        };
      }).toList();
    }
    s['updatedAt'] = raw['updatedAt'] is String
        ? raw['updatedAt']
        : s['updatedAt'];
    return s;
  }
}
