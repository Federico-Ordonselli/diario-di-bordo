import 'dart:math' as math;
import 'catalog.dart';
import 'profile.dart';

bool validQuantity(dynamic value, [int max = 999999]) =>
    value is int && value >= 0 && value <= max;
String scope(Json snapshot) => SaveSnapshot(snapshot).scope;
String currentScope(Profile state) => state.activeSave?.scope ?? 'app';
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
  int distinct(Profile s) =>
      catalog.recipes.where((r) => s.everCrafted[r['id']] == true).length;
  bool unlocked(Profile s, int group) {
    if (group == 1) return true;
    final previous = catalog.recipes.where((r) => (r['group'] as int) < group);
    final count = previous.where((r) => s.everCrafted[r['id']] == true).length;
    return group == 6
        ? count == 30
        : count >= ({2: 3, 3: 9, 4: 15, 5: 21}[group] ?? 999);
  }

  Json recipeStatus(Profile s, Json recipe) {
    final costs = recipe['costs'] as Json, inventory = s.inventory;
    final unknown =
        costs.keys.any((id) => inventory[id] == null) ||
        recipe['output'] != null && inventory[recipe['output']] == null;
    final deficits = costs.entries
        .map(
          (e) => <String, dynamic>{
            'id': e.key,
            'need': e.value,
            'have': inventory[e.key],
            'missing': inventory[e.key] == null
                ? null
                : math.max(0, (e.value as int) - inventory[e.key]!),
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

  List<String> routeRemaining(Profile s) {
    final completed = catalog.recipes
        .where(
          (r) => (r['group'] as int) <= 3 && s.everCrafted[r['id']] == true,
        )
        .length;
    return catalog.route15
        .where((id) => s.everCrafted[id] != true)
        .take(math.max(0, 15 - completed))
        .toList();
  }

  Json plan(Profile s) {
    final mode = s.plan.mode, inventory = s.inventory;
    final ids = switch (mode) {
      PlanMode.all => catalog.recipes.map((r) => r['id']).toList(),
      PlanMode.route15 => routeRemaining(s),
      PlanMode.selected => s.plan.selected,
    };
    final counts = <String, dynamic>{
      for (final r in catalog.recipes)
        r['id'] as String:
            ids.contains(r['id']) && s.everCrafted[r['id']] != true ? 1 : 0,
    };
    final rewards = <String, dynamic>{
      for (final id in ['dark_matter', 'orichalcum'])
        id: mode == PlanMode.route15 ? 0 : s.plan.rewards[id],
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
      if (inventory[id] == null && (t['gross'][id] as int) > 0) {
        uncertain.add(id);
        uncertain.addAll((catalog.recipesById[id]!['costs'] as Json).keys);
        if (id == 'dark_matter' && inventory['mythril'] == null) {
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
                (inventory[id] ?? 0) -
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
      final int? missing = inventory[id] == null || uncertain.contains(id)
          ? null
          : math.max(0, external - inventory[id]!);
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

  Json simulate(Profile s, [Json? computed]) {
    final p = computed ?? plan(s), virtual = Profile(copyJson(s));
    final inventory = virtual.inventory;
    final left = Map<String, dynamic>.from(p['counts'] as Json),
        steps = <String>[];
    for (final e in (p['rewards'] as Json).entries) {
      if (inventory[e.key] != null) {
        inventory[e.key] = inventory[e.key]! + (e.value as int);
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
        inventory[cost.key] = inventory[cost.key]! - (cost.value as int);
      }
      final output = r['output'] as String?;
      if (output != null) inventory[output] = inventory[output]! + 1;
      virtual.everCrafted[r['id'] as String] = true;
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

  Profile transact(
    Profile s,
    String label,
    void Function(Profile) action, {
    TransactionOrigin origin = TransactionOrigin.manual,
  }) {
    // Cronologia e snapshot non vengono mai modificati sul posto: si
    // condividono invece di copiarli in profondità a ogni operazione.
    final rest = {...s}
      ..remove('transactions')
      ..remove('saveSnapshots');
    final next = Profile(
          copyJson(rest)..['saveSnapshots'] = {...s['saveSnapshots'] as Json},
        ),
        before = copyJson(rest);
    action(next);
    if (origin == TransactionOrigin.manual) {
      final overrides = next.manualOverrides[currentScope(s)] ??=
          <String, dynamic>{};
      for (final key in changedTargets(s, next)) {
        overrides[key] = targetValue(next, key);
      }
    }
    next.updatedAt = DateTime.now().toUtc().toIso8601String();
    final history = [
      ...s.transactions,
      ProfileTransaction({
        'label': label,
        'at': next.updatedAt,
        'origin': origin.name,
        'before': before,
      }),
    ];
    next.transactions = history
        .skip(math.max(0, history.length - 100))
        .toList();
    return next;
  }

  Profile quantity(Profile s, String id, dynamic value) {
    if (!catalog.materialsById.containsKey(id) ||
        !(value == null || validQuantity(value))) {
      throw const FormatException(
        'Inserisci un intero tra 0 e 999999, oppure lascia vuoto.',
      );
    }
    if (s.inventory[id] == value) return s;
    return transact(
      s,
      '${catalog.materialsById[id]!['name']}: ${s.inventory[id] ?? '?'} → ${value ?? '?'}',
      (n) => n.inventory[id] = value as int?,
    );
  }

  Profile increment(Profile s, String id, int delta) {
    final current = s.inventory[id];
    if (current == null) {
      throw const FormatException('Conferma prima la scorta reale.');
    }
    return quantity(s, id, (current + delta).clamp(0, 999999));
  }

  Profile completion(Profile s, String id, bool? done) {
    final item = catalog.itemsById[id];
    if (item == null || item['recipeId'] != null && done == null) {
      throw const FormatException('Voce non valida.');
    }
    if (item['recipeId'] != null
        ? catalog.completed(s, item) == done
        : s.completion.containsKey(id) && s.completion[id] == done) {
      return s;
    }
    return transact(
      s,
      '${done == true ? 'Completato' : 'Da completare'}: ${item['title']}',
      (n) {
        final recipeId = item['recipeId'] as String?;
        if (recipeId != null) {
          n.everCrafted[recipeId] = done!;
          n.craftCount[recipeId] = null;
        } else {
          n.completion[id] = done;
        }
      },
    );
  }

  Profile markCrafted(Profile s, String id) {
    if (!catalog.recipesById.containsKey(id)) {
      throw const FormatException('Ricetta non valida.');
    }
    if (s.everCrafted[id] == true) return s;
    return transact(
      s,
      'Già sintetizzato: ${catalog.recipesById[id]!['name']}',
      (n) {
        n.everCrafted[id] = true;
        n.craftCount[id] = null;
      },
    );
  }

  Profile craft(Profile s, String id) {
    final r = catalog.recipesById[id];
    if (r == null || recipeStatus(s, r)['ready'] != true) {
      throw const FormatException(
        'Servono gruppo sbloccato e scorte sufficienti e confermate.',
      );
    }
    return transact(s, 'Sintesi: ${r['name']}', (n) {
      final inventory = n.inventory, count = n.craftCount[id];
      for (final cost in (r['costs'] as Json).entries) {
        inventory[cost.key] = inventory[cost.key]! - (cost.value as int);
      }
      final output = r['output'] as String?;
      if (output != null) {
        if (inventory[output] == 999999) {
          throw const FormatException('Scorta al limite.');
        }
        inventory[output] = inventory[output]! + 1;
      }
      n.everCrafted[id] = true;
      if (count != null) n.craftCount[id] = count + 1;
    });
  }

  Profile collect(
    Profile s,
    String id, {
    bool now = false,
    String status = 'collected',
  }) {
    final source = catalog.collections.firstWhere((c) => c['id'] == id);
    final material = source['material'] as String,
        target = CollectionStatus.parse(status);
    if (now && s.collection(id) == CollectionStatus.collected) {
      throw const FormatException('Fonte già raccolta.');
    }
    if (now && s.inventory[material] == null) {
      throw const FormatException('Conferma prima la scorta.');
    }
    if (!now && s.collection(id) == target) return s;
    return transact(
      s,
      '${now ? 'Raccolto adesso' : 'Stato fonte'}: ${source['world']} / ${source['area']}',
      (n) {
        n.setCollection(id, target);
        if (now) {
          final have = n.inventory[material]!;
          if (have >= 999999) {
            throw const FormatException('Scorta al limite.');
          }
          n.inventory[material] = have + 1;
          final rewards = n.plan.rewards;
          rewards[material] = math.max(0, rewards[material]! - 1);
        }
      },
    );
  }

  Profile sessionCollect(Profile s, String id, int delta) => transact(
    s,
    'Raccolta sessione: ${catalog.materialsById[id]!['name']} +$delta',
    (n) {
      final have = n.inventory[id], session = n.session[id] ?? 0;
      if (have == null) {
        throw const FormatException('Conferma prima la scorta.');
      }
      if (!validQuantity(have + delta) || !validQuantity(session + delta)) {
        throw const FormatException('Contatore al limite.');
      }
      n.inventory[id] = have + delta;
      n.session[id] = session + delta;
    },
  );
  Profile undo(Profile s) {
    final history = s.transactions;
    if (history.isEmpty) return s;
    return Profile({
      ...copyJson(history.last.before),
      'saveSnapshots': copyJson(s['saveSnapshots'] as Json),
      'appliedEvidence': [...s.appliedEvidence],
      'transactions': history.take(history.length - 1).toList(),
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Profile applyEvidence(Profile s) {
    final id = catalog.evidence['id'] as String?;
    if (id == null || s.appliedEvidence.contains(id)) return s;
    return transact(
      s,
      'Progressi dagli screenshot: 21 achievement e sblocchi certi',
      (n) {
        for (final item in catalog.evidence['items'] as List) {
          n.completion[item['id'] as String] = true;
        }
        n.appliedEvidence.add(id);
        for (final unlock in ['Trio Bianco', 'Trio Giallo', 'Stop']) {
          n.settings.setFlag(unlock, true);
        }
      },
      origin: TransactionOrigin.evidence,
    );
  }
}
