import 'dart:math' as math;
import 'catalog.dart';

bool validQuantity(dynamic value, [int max = 999999]) =>
    value is int && value >= 0 && value <= max;
String scope(Json snapshot) =>
    '${snapshot['source']['filename']}#slot:${snapshot['slotNumber']}';
String currentScope(Json state) => state['activeSaveId'] == null
    ? 'app'
    : scope(state['saveSnapshots'][state['activeSaveId']] as Json);
dynamic targetValue(Json state, String key) {
  final parts = key.split('.');
  final kind = parts.removeAt(0), id = parts.join('.');
  final field = kind == 'save' ? 'saveValues' : kind;
  if (!['inventory', 'settings', 'completion', 'saveValues'].contains(field)) {
    throw const FormatException('Campo non riconosciuto.');
  }
  final map = state[field] as Map;
  return map.containsKey(id)
      ? map[id]
      : kind == 'completion'
      ? false
      : null;
}

void writeTarget(Json state, String key, dynamic value) {
  final parts = key.split('.');
  final kind = parts.removeAt(0);
  state[kind == 'save' ? 'saveValues' : kind][parts.join('.')] = value;
}

List<String> changedTargets(Json before, Json after) {
  final keys = <String>{};
  for (final field in ['inventory', 'settings', 'completion', 'saveValues']) {
    for (final id in {
      ...(before[field] as Map).keys,
      ...(after[field] as Map).keys,
    }) {
      keys.add('${field == 'saveValues' ? 'save' : field}.$id');
    }
  }
  return keys
      .where((key) => targetValue(before, key) != targetValue(after, key))
      .toList();
}

class Engine {
  Engine(this.catalog);
  final Catalog catalog;
  int distinct(Json s) =>
      catalog.recipes.where((r) => s['everCrafted'][r['id']] == true).length;
  bool unlocked(Json s, int group) {
    if (group == 1) return true;
    final previous = catalog.recipes.where((r) => (r['group'] as int) < group);
    final count = previous
        .where((r) => s['everCrafted'][r['id']] == true)
        .length;
    return group == 6
        ? count == 30
        : count >= ({2: 3, 3: 9, 4: 15, 5: 21}[group] ?? 999);
  }

  Json recipeStatus(Json s, Json recipe) {
    final costs = recipe['costs'] as Json;
    final unknown =
        costs.keys.any((id) => s['inventory'][id] == null) ||
        recipe['output'] != null && s['inventory'][recipe['output']] == null;
    final deficits = costs.entries
        .map(
          (e) => <String, dynamic>{
            'id': e.key,
            'need': e.value,
            'have': s['inventory'][e.key],
            'missing': s['inventory'][e.key] == null
                ? null
                : math.max(
                    0,
                    (e.value as int) - (s['inventory'][e.key] as int),
                  ),
          },
        )
        .toList();
    final open = unlocked(s, recipe['group'] as int);
    return {
      'unlocked': open,
      'unknown': unknown,
      'deficits': deficits,
      'ready': open && !unknown && deficits.every((d) => d['missing'] == 0),
    };
  }

  List<String> routeRemaining(Json s) {
    final completed = catalog.recipes
        .where(
          (r) => (r['group'] as int) <= 3 && s['everCrafted'][r['id']] == true,
        )
        .length;
    return catalog.route15
        .where((id) => s['everCrafted'][id] != true)
        .take(math.max(0, 15 - completed))
        .toList();
  }

  Json plan(Json s) {
    final mode = s['plan']['mode'];
    final ids = mode == 'all'
        ? catalog.recipes.map((r) => r['id']).toList()
        : mode == '15'
        ? routeRemaining(s)
        : s['plan']['selected'] as List;
    final counts = <String, dynamic>{
      for (final r in catalog.recipes)
        r['id'] as String:
            ids.contains(r['id']) && s['everCrafted'][r['id']] != true ? 1 : 0,
    };
    final rewards = <String, dynamic>{
      'dark_matter': mode == '15' ? 0 : s['plan']['rewards']['dark_matter'],
      'orichalcum': mode == '15' ? 0 : s['plan']['rewards']['orichalcum'],
    };
    final uncertain = <String>{};
    Json totals() {
      final gross = <String, dynamic>{
        for (final m in catalog.materials) m['id'] as String: 0,
      };
      final produced = Map<String, dynamic>.from(gross);
      for (final r in catalog.recipes) {
        for (final cost in (r['costs'] as Json).entries) {
          gross[cost.key] =
              (gross[cost.key] as int) +
              (cost.value as int) * (counts[r['id']] as int);
        }
        if (r['output'] != null) {
          produced[r['output'] as String] =
              (produced[r['output']] as int) + (counts[r['id']] as int);
        }
      }
      return {'gross': gross, 'produced': produced};
    }

    for (final id in ['dark_matter', 'mythril']) {
      final t = totals();
      if (s['inventory'][id] == null && (t['gross'][id] as int) > 0) {
        uncertain.add(id);
        uncertain.addAll((catalog.recipesById[id]!['costs'] as Json).keys);
        if (id == 'dark_matter' && s['inventory']['mythril'] == null) {
          uncertain.addAll(
            (catalog.recipesById['mythril']!['costs'] as Json).keys,
          );
        }
      }
      counts[id] =
          (counts[id] as int) +
          math.max(
            0,
            (t['gross'][id] as int) -
                (t['produced'][id] as int) -
                ((s['inventory'][id] ?? 0) as int) -
                ((rewards[id] ?? 0) as int),
          );
    }
    final t = totals();
    final rows = <String, dynamic>{};
    for (final m in catalog.materials) {
      final id = m['id'] as String;
      final external = math.max(
        0,
        (t['gross'][id] as int) - (t['produced'][id] as int),
      );
      final int? missing = s['inventory'][id] == null || uncertain.contains(id)
          ? null
          : math.max(0, external - (s['inventory'][id] as int));
      final int? planned = missing == null
          ? null
          : math.min(missing, (rewards[id] ?? 0) as int);
      rows[id] = {
        'gross': t['gross'][id],
        'produced': t['produced'][id],
        'external': external,
        'uncertain': uncertain.contains(id),
        'missing': missing,
        'planned': planned,
        'uncovered': missing == null ? null : missing - planned!,
        'sufficient': missing == 0,
        'unknown': missing == null,
      };
    }
    return {
      'counts': counts,
      'rows': rows,
      'rewards': rewards,
      'uncertainDependencies': uncertain.toList(),
      'total': counts.values.fold<int>(0, (sum, n) => sum + (n as int)),
    };
  }

  Json simulate(Json s, [Json? computed]) {
    final p = computed ?? plan(s), virtual = copyJson(s);
    final left = Map<String, dynamic>.from(p['counts'] as Json),
        steps = <String>[];
    for (final e in (p['rewards'] as Json).entries) {
      if (virtual['inventory'][e.key] != null) {
        virtual['inventory'][e.key] += e.value;
      }
    }
    for (var i = 0; i < 500; i++) {
      final ready = catalog.recipes.where(
        (r) =>
            (left[r['id']] as int) > 0 &&
            recipeStatus(virtual, r)['ready'] == true,
      );
      if (ready.isEmpty) break;
      final r = ready.first;
      for (final cost in (r['costs'] as Json).entries) {
        virtual['inventory'][cost.key] -= cost.value;
      }
      if (r['output'] != null) virtual['inventory'][r['output']]++;
      virtual['everCrafted'][r['id']] = true;
      left[r['id'] as String] = (left[r['id']] as int) - 1;
      steps.add(r['id'] as String);
    }
    return {
      'steps': steps,
      'left': left,
      'complete': left.values.every((n) => n == 0),
      'assumesRewards': (p['rewards'] as Json).values.any(
        (n) => (n as int) > 0,
      ),
    };
  }

  Json transact(
    Json s,
    String label,
    void Function(Json) action, {
    String origin = 'manual',
  }) {
    // Cronologia e snapshot non vengono mai modificati sul posto: si
    // condividono invece di copiarli in profondità a ogni operazione.
    final rest = {...s}
      ..remove('transactions')
      ..remove('saveSnapshots');
    final next = copyJson(rest)
          ..['saveSnapshots'] = {...s['saveSnapshots'] as Json},
        before = copyJson(rest);
    action(next);
    if (origin == 'manual') {
      final editScope = currentScope(s);
      final overrides = next['manualOverrides'] as Json;
      overrides[editScope] ??= <String, dynamic>{};
      for (final key in changedTargets(s, next)) {
        overrides[editScope][key] = targetValue(next, key);
      }
    }
    next['updatedAt'] = DateTime.now().toUtc().toIso8601String();
    final history = [
      ...s['transactions'] as List,
      {
        'label': label,
        'at': next['updatedAt'],
        'origin': origin,
        'before': before,
      },
    ];
    next['transactions'] = history
        .skip(math.max(0, history.length - 100))
        .toList();
    return next;
  }

  Json quantity(Json s, String id, dynamic value) {
    if (!catalog.materialsById.containsKey(id) ||
        !(value == null || validQuantity(value))) {
      throw const FormatException(
        'Inserisci un intero tra 0 e 999999, oppure lascia vuoto.',
      );
    }
    if (s['inventory'][id] == value) return s;
    return transact(
      s,
      '${catalog.materialsById[id]!['name']}: ${s['inventory'][id] ?? '?'} → ${value ?? '?'}',
      (n) => n['inventory'][id] = value,
    );
  }

  Json increment(Json s, String id, int delta) {
    if (s['inventory'][id] == null) {
      throw const FormatException('Conferma prima la scorta reale.');
    }
    return quantity(
      s,
      id,
      ((s['inventory'][id] as int) + delta).clamp(0, 999999),
    );
  }

  Json completion(Json s, String id, bool? done) {
    final item = catalog.itemsById[id];
    if (item == null || item['recipeId'] != null && done == null) {
      throw const FormatException('Voce non valida.');
    }
    if (item['recipeId'] != null
        ? catalog.completed(s, item) == done
        : (s['completion'] as Map).containsKey(id) &&
              s['completion'][id] == done) {
      return s;
    }
    return transact(
      s,
      '${done == true ? 'Completato' : 'Da completare'}: ${item['title']}',
      (n) {
        if (item['recipeId'] != null) {
          n['everCrafted'][item['recipeId']] = done;
          n['craftCount'][item['recipeId']] = null;
        } else {
          n['completion'][id] = done;
        }
      },
    );
  }

  Json markCrafted(Json s, String id) {
    if (!catalog.recipesById.containsKey(id)) {
      throw const FormatException('Ricetta non valida.');
    }
    if (s['everCrafted'][id] == true) return s;
    return transact(
      s,
      'Già sintetizzato: ${catalog.recipesById[id]!['name']}',
      (n) {
        n['everCrafted'][id] = true;
        n['craftCount'][id] = null;
      },
    );
  }

  Json craft(Json s, String id) {
    final r = catalog.recipesById[id];
    if (r == null || recipeStatus(s, r)['ready'] != true) {
      throw const FormatException(
        'Servono gruppo sbloccato e scorte sufficienti e confermate.',
      );
    }
    return transact(s, 'Sintesi: ${r['name']}', (n) {
      for (final cost in (r['costs'] as Json).entries) {
        n['inventory'][cost.key] -= cost.value;
      }
      if (r['output'] != null) {
        if (n['inventory'][r['output']] == 999999) {
          throw const FormatException('Scorta al limite.');
        }
        n['inventory'][r['output']]++;
      }
      n['everCrafted'][id] = true;
      if (n['craftCount'][id] != null) n['craftCount'][id]++;
    });
  }

  Json collect(
    Json s,
    String id, {
    bool now = false,
    String status = 'collected',
  }) {
    final source = catalog.collections.firstWhere((c) => c['id'] == id);
    if (!['unknown', 'collected', 'not_collected'].contains(status)) {
      throw const FormatException('Stato non valido.');
    }
    if (now && s['collections'][id] == 'collected') {
      throw const FormatException('Fonte già raccolta.');
    }
    if (now && s['inventory'][source['material']] == null) {
      throw const FormatException('Conferma prima la scorta.');
    }
    if (!now && s['collections'][id] == status) return s;
    return transact(
      s,
      '${now ? 'Raccolto adesso' : 'Stato fonte'}: ${source['world']} / ${source['area']}',
      (n) {
        n['collections'][id] = status;
        if (now) {
          if (n['inventory'][source['material']] >= 999999) {
            throw const FormatException('Scorta al limite.');
          }
          n['inventory'][source['material']]++;
          n['plan']['rewards'][source['material']] = math.max(
            0,
            (n['plan']['rewards'][source['material']] as int) - 1,
          );
        }
      },
    );
  }

  Json sessionCollect(Json s, String id, int delta) => transact(
    s,
    'Raccolta sessione: ${catalog.materialsById[id]!['name']} +$delta',
    (n) {
      if (n['inventory'][id] == null) {
        throw const FormatException('Conferma prima la scorta.');
      }
      if (!validQuantity((n['inventory'][id] as int) + delta) ||
          !validQuantity(((n['session'][id] ?? 0) as int) + delta)) {
        throw const FormatException('Contatore al limite.');
      }
      n['inventory'][id] += delta;
      n['session'][id] = ((n['session'][id] ?? 0) as int) + delta;
    },
  );
  Json undo(Json s) {
    final history = s['transactions'] as List;
    if (history.isEmpty) return s;
    return {
      ...copyJson(history.last['before'] as Json),
      'saveSnapshots': copyJson(s['saveSnapshots'] as Json),
      'appliedEvidence': [...s['appliedEvidence'] as List],
      'transactions': history.take(history.length - 1).toList(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
  }

  Json applyEvidence(Json s) {
    if ((s['appliedEvidence'] as List).contains(catalog.evidence['id'])) {
      return s;
    }
    return transact(
      s,
      'Progressi dagli screenshot: 21 achievement e sblocchi certi',
      (n) {
        for (final item in catalog.evidence['items'] as List) {
          n['completion'][item['id']] = true;
        }
        n['appliedEvidence'].add(catalog.evidence['id']);
        n['settings']['Trio Bianco'] = true;
        n['settings']['Trio Giallo'] = true;
        n['settings']['Stop'] = true;
      },
      origin: 'evidence',
    );
  }
}
