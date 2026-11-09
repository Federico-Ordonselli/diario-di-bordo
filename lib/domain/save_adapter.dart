import 'catalog.dart';
import 'engine.dart';

class SaveAdapter {
  SaveAdapter(this.engine);
  final Engine engine;
  Catalog get catalog => engine.catalog;
  static const spells = {
    'Fire': ['Fire', 'Fira', 'Firaga'],
    'Blizzard': ['Blizzard', 'Blizzara', 'Blizzaga'],
    'Thunder': ['Thunder', 'Thundara', 'Thundaga'],
    'Cure': ['Cure', 'Cura', 'Curaga'],
    'Gravity': ['Gravity', 'Gravira', 'Graviga'],
    'Stop': ['Stop', 'Stopra', 'Stopga'],
    'Aero': ['Aero', 'Aerora', 'Aeroga'],
  };
  dynamic flag(dynamic v, String label) {
    if (v != null && v is! bool) {
      throw FormatException('$label: flag non valido.');
    }
    return v;
  }

  dynamic quantity(dynamic v, String label, [int max = 999999]) {
    if (v != null && !validQuantity(v, max)) {
      throw FormatException('$label: quantità non valida.');
    }
    return v;
  }

  List<dynamic> array(dynamic v, String label) {
    if (v == null) return [];
    if (v is! List || v.any((item) => item is! Json)) {
      throw FormatException('$label: elenco non valido.');
    }
    return v;
  }

  String date(dynamic v) {
    if (v is! String || DateTime.tryParse(v) == null) {
      throw const FormatException('Data non valida.');
    }
    return v;
  }

  Json? find(List<dynamic> list, bool Function(Json) predicate) {
    for (final item in list.cast<Json>()) {
      if (predicate(item)) return item;
    }
    return null;
  }

  void unique(List<dynamic> list, String key) {
    if (list.map((v) => v[key]).toSet().length != list.length) {
      throw FormatException('Valori duplicati: $key');
    }
  }

  Json validate(dynamic raw) {
    if (raw is! Json ||
        raw['schema'] != 'kh1fm-save-snapshot' ||
        raw['schema_version'] != 1) {
      throw const FormatException(
        'Atteso snapshot analizzato kh1fm-save-snapshot versione 1.',
      );
    }
    final slots = array(raw['slots'], 'Slot');
    if (slots.isEmpty || slots.length > 200) {
      throw const FormatException('Elenco slot non valido.');
    }
    unique(slots, 'slot_number');
    if (raw['source'] is! Json ||
        raw['source']['filename'] is! String ||
        (raw['source']['filename'] as String).isEmpty ||
        raw['source']['sha256'] is! String ||
        !RegExp(
          r'^[a-fA-F0-9]{64}$',
        ).hasMatch(raw['source']['sha256'] as String)) {
      throw const FormatException('Provenienza non valida.');
    }
    date(raw['generated_at']);
    for (final slot in slots) {
      if (slot['slot_number'] is! int) {
        throw const FormatException('Slot non valido.');
      }
      normalizeSlot(raw, slot['slot_number'] as int);
    }
    return raw;
  }

  Json normalizeSlot(Json raw, int number) {
    final slot = find(
      array(raw['slots'], 'Slot'),
      (s) => s['slot_number'] == number,
    );
    if (slot == null || number < 1 || number > 200) {
      throw const FormatException('Slot non trovato.');
    }
    final observations = <String, dynamic>{};
    void add(
      String key,
      dynamic value,
      String label,
      String path, [
      String confidence = 'mapped',
    ]) {
      observations[key] = {
        'value': value,
        'label': label,
        'path': path,
        'confidence': confidence,
      };
    }

    void complete(
      String category,
      String title,
      dynamic value,
      String path, [
      String confidence = 'mapped',
    ]) {
      final item = catalog.lookup(category, title);
      add(
        'completion.${item['id']}',
        value,
        '${item['categoryLabel']} · ${item['title']}',
        path,
        confidence,
      );
    }

    final inventory = array(slot['inventory'], 'Inventario');
    unique(inventory, 'item_id');
    for (final item in inventory) {
      quantity(item['quantity'], '${item['name']}');
      if (!validQuantity(item['item_id'], 255) || item['name'] is! String) {
        throw const FormatException('ID inventario non valido.');
      }
    }
    if (slot['materials'] != null && slot['materials'] is! Json) {
      throw const FormatException('Materiali non validi.');
    }
    final values = (slot['materials'] ?? <String, dynamic>{}) as Json;
    for (final m in catalog.materials) {
      final matches = values.keys.where(
        (n) => normalize(n) == normalize(m['name'] as String),
      );
      final name = matches.isEmpty ? null : matches.first;
      final value = quantity(
        name == null ? null : values[name],
        m['name'] as String,
      );
      final item = find(
        inventory,
        (i) => normalize(i['name'] as String) == normalize(m['name'] as String),
      );
      if (value != null &&
          item?['quantity'] != null &&
          value != item?['quantity']) {
        throw FormatException('Quantità discordante: ${m['name']}');
      }
      add(
        'inventory.${m['id']}',
        value,
        m['name'] as String,
        'materials.${name ?? m['name']}${item == null ? '' : ' · inventory[item_id=${item['item_id']}]'}',
      );
    }
    final weapons = array(slot['keyblades'], 'Keyblade');
    unique(weapons, 'name');
    for (final item in catalog.items.where(
      (i) => i['categoryId'] == 'keyblades',
    )) {
      final weapon = find(
        weapons,
        (w) =>
            w['name'] is String &&
            normalize(w['name'] as String) ==
                normalize(item['title'] as String),
      );
      complete(
        'keyblades',
        item['title'] as String,
        flag(weapon?['owned'], item['title'] as String),
        'keyblades.${item['title']}.owned',
        'mapped_current_ownership',
      );
    }
    final magic = array(slot['magic'], 'Magie');
    unique(magic, 'family');
    for (final entry in spells.entries) {
      final spell = find(magic, (m) => m['family'] == entry.key);
      final unlocked = flag(spell?['unlocked'], entry.key),
          tier = quantity(spell?['tier'], entry.key, 3);
      if (unlocked == true && tier == 0 ||
          unlocked == false && tier != null && tier > 0) {
        throw FormatException('Magia discordante: ${entry.key}');
      }
      for (var i = 0; i < entry.value.length; i++) {
        complete(
          'magic',
          entry.value[i],
          unlocked == false
              ? false
              : unlocked == null || tier == null
              ? null
              : i < (tier as int),
          'magic.${entry.key}.tier',
          (spell?['confidence'] ?? 'unknown') as String,
        );
      }
    }
    for (final name in [
      'Dumbo',
      'Bambi',
      'Genie',
      'Tinker Bell',
      'Mushu',
      'Simba',
    ]) {
      final summon = find(
        array(slot['summons'], 'Invocazioni'),
        (s) => s['name'] == name,
      );
      complete(
        'magic',
        name,
        flag(summon?['unlocked'], name),
        'summons.$name.unlocked',
        (summon?['confidence'] ?? 'unknown') as String,
      );
    }
    final reports = array(slot['ansem_reports'], 'Rapporti');
    unique(reports, 'number');
    for (var n = 1; n <= 13; n++) {
      final report = find(reports, (r) => r['number'] == n);
      complete(
        'reports',
        'Ansem Report $n',
        flag(report?['unlocked_in_journal'], 'Ansem $n'),
        'ansem_reports.$n.unlocked_in_journal',
        (report?['confidence'] ?? 'unknown') as String,
      );
    }
    final puppies = array(slot['dalmatians']?['groups'], 'Cuccioli');
    unique(puppies, 'start');
    for (var start = 1; start <= 97; start += 3) {
      final puppy = find(
        puppies,
        (p) => p['start'] == start && p['end'] == start + 2,
      );
      complete(
        'dalmatians',
        'Puppies $start - ${start + 1} - ${start + 2}',
        flag(puppy?['rescued'], 'Cuccioli $start'),
        'dalmatians.groups.$start-${start + 2}',
        (puppy?['confidence'] ?? 'unknown') as String,
      );
    }
    const totals = {'Blue': 17, 'Red': 6, 'Green': 9, 'Yellow': 4, 'White': 10};
    for (final e in totals.entries) {
      final counter = find(
        array(slot['trinities']?['by_color'], 'Trinità'),
        (c) => c['color'] == e.key,
      );
      if (counter != null && counter['total'] != e.value) {
        throw const FormatException('Totale Trinità non valido.');
      }
      add(
        'save.trinity.${e.key}',
        quantity(counter?['collected'], e.key, e.value),
        'Trinità ${e.key} / ${e.value}',
        'trinities.by_color.${e.key}',
        (slot['trinities']?['confidence'] ?? 'unknown') as String,
      );
    }
    add(
      'save.postcards',
      quantity(slot['postcards']?['mailed'], 'Cartoline', 10),
      'Cartoline spedite / 10',
      'postcards.mailed',
      (slot['postcards']?['confidence'] ?? 'unknown') as String,
    );
    final chests = array(slot['chests']?['checks'], 'Casse');
    unique(chests, 'code');
    if (chests.length > 1500) throw const FormatException('Troppi forzieri.');
    for (final chest in chests) {
      if (!validQuantity(chest['code'], 9007199254740991) ||
          chest['name'] is! String ||
          chest['world'] is! String) {
        throw const FormatException('Cassa non valida.');
      }
      add(
        'save.chest.${chest['code']}',
        flag(chest['collected'], chest['name'] as String),
        chest['name'] as String,
        'chests.checks.${chest['code']} · ${chest['offset']} bit ${chest['bit']}',
        (chest['confidence'] ?? 'unknown') as String,
      );
    }
    add(
      'settings.level',
      quantity(slot['level'], 'Livello', 100),
      'Livello di Sora',
      'level',
    );
    add(
      'settings.munny',
      quantity(slot['munny'], 'Munny'),
      'Munny salvati',
      'munny',
    );
    for (final name in [
      'Stop',
      'Aerora',
      'Aeroga',
      'Dumbo',
      'Bambi',
      'Mushu',
    ]) {
      add(
        'settings.$name',
        observations['completion.${catalog.lookup('magic', name)['id']}']['value'],
        'Disponibilità $name',
        'magic / summons.$name',
        'derived_mapping',
      );
    }
    final characters = array(slot['characters'], 'Personaggi');
    final sora = find(characters, (c) => c['name'] == 'Sora');
    if (sora?['abilities'] is List) {
      add(
        'settings.Ragnarok',
        (sora?['abilities'] as List).any((a) => a['name'] == 'Ragnarok'),
        'Ragnarok appreso (non equipaggiamento)',
        'characters.Sora.abilities',
      );
    }
    if (slot['shared_abilities'] is List) {
      add(
        'settings.Glide',
        (slot['shared_abilities'] as List).any((a) => a['name'] == 'Glide'),
        'Glide disponibile',
        'shared_abilities',
      );
    }
    final savedAt = date(slot['modified_at']);
    return {
      'id': '${raw['source']['sha256']}:$number:$savedAt',
      'slotNumber': number,
      'source': copyJson(raw['source'] as Json),
      'generatedAt': raw['generated_at'],
      'savedAt': savedAt,
      'level': slot['level'],
      'location': slot['location'] ?? <String, dynamic>{},
      'difficulty': slot['difficulty']?['name'] ?? 'Da verificare',
      'observations': observations,
      'chests': chests
          .map(
            (c) => {
              for (final key in [
                'code',
                'name',
                'world',
                'offset',
                'bit',
                'confidence',
              ])
                key: c[key],
            },
          )
          .toList(),
      'characters': characters,
      'extraItems': slot['extra_item_counts'] ?? <String, dynamic>{},
      'interpretation': raw['interpretation'] ?? <String, dynamic>{},
      'unknownSections': slot['unknown_sections'] ?? <String, dynamic>{},
      'chestCoverage': {
        'mappedTotal': slot['chests']?['mapped_total'],
        'gameTotal': slot['chests']?['game_total'],
        'complete': slot['chests']?['coverage_complete'] ?? false,
      },
      'reportPath': '/KH1FM_Report_Save.md',
    };
  }

  Json legacyOverrides(Json s) {
    final values = Map<String, dynamic>.from(
      (s['manualOverrides']['app'] ?? <String, dynamic>{}) as Json,
    );
    if (s['activeSaveId'] == null) {
      final baseline = catalog.fresh();
      for (final m in catalog.materials) {
        if (s['inventory'][m['id']] != baseline['inventory'][m['id']]) {
          values['inventory.${m['id']}'] = s['inventory'][m['id']];
        }
      }
      final evidenceIds = (catalog.evidence['items'] as List)
          .map((i) => i['id'])
          .toSet();
      for (final e in (s['completion'] as Json).entries) {
        if (e.value == true && !evidenceIds.contains(e.key) ||
            e.value == false ||
            e.value == null) {
          values['completion.${e.key}'] = e.value;
        }
      }
      for (final e in (s['settings'] as Json).entries) {
        if (e.value != null &&
            e.value != '' &&
            !(['Stop', 'Trio Bianco', 'Trio Giallo'].contains(e.key) &&
                (s['appliedEvidence'] as List).isNotEmpty)) {
          values['settings.${e.key}'] = e.value;
        }
      }
      final history = s['transactions'] as List;
      for (var index = 0; index < history.length; index++) {
        final t = history[index];
        if (['save', 'evidence'].contains(t['origin']) ||
            (t['label'] as String).startsWith('Progressi dagli screenshot')) {
          continue;
        }
        final after = index + 1 < history.length
            ? {
                ...history[index + 1]['before'] as Json,
                'saveSnapshots': s['saveSnapshots'],
              }
            : s;
        final before = {
          ...t['before'] as Json,
          'saveSnapshots': s['saveSnapshots'],
        };
        for (final key in changedTargets(before, after)) {
          values[key] = targetValue(s, key);
        }
      }
    }
    return values;
  }

  /// Data dell'ultima modifica manuale di ogni chiave ancora in cronologia.
  Map<String, DateTime> manualEdits(Json s) {
    final history = s['transactions'] as List, edits = <String, DateTime>{};
    for (var index = 0; index < history.length; index++) {
      final t = history[index];
      if (t['origin'] != 'manual') continue;
      final after = index + 1 < history.length
          ? history[index + 1]['before'] as Json
          : s;
      for (final key in changedTargets(t['before'] as Json, after)) {
        edits[key] = DateTime.parse(t['at'] as String);
      }
    }
    return edits;
  }

  Json preview(Json s, Json raw, int number, [Json decisions = const {}]) {
    final snapshot = normalizeSlot(raw, number),
        slotScope = scope(snapshot),
        appOverrides = legacyOverrides(s);
    final overrides = {
      ...appOverrides,
      ...(s['manualOverrides'][slotScope] ?? <String, dynamic>{}) as Json,
    };
    // Una modifica manuale anteriore al salvataggio è superata dal save; ciò
    // che precede la cronologia conservata conta come la sua voce più vecchia.
    final savedAt = DateTime.parse(snapshot['savedAt'] as String),
        history = s['transactions'] as List,
        oldest = history.isEmpty
            ? null
            : DateTime.parse(history.first['at'] as String),
        edits = manualEdits(s);
    final rows = (snapshot['observations'] as Json).entries.map((e) {
      final observation = e.value as Json, before = targetValue(s, e.key);
      final manual = overrides.containsKey(e.key),
          manualValue = overrides[e.key],
          differs = manual && manualValue != observation['value'];
      final historical =
          s['activeSaveId'] == null &&
          e.key.startsWith('completion.') &&
          before == true &&
          observation['value'] != true;
      final conflict = differs || historical;
      final editedAt = edits[e.key] ?? oldest;
      final stale = differs && editedAt != null && editedAt.isBefore(savedAt);
      final kept =
          conflict && (decisions[e.key] ?? (stale ? 'save' : 'keep')) != 'save';
      final after = kept
          ? manual
                ? manualValue
                : before
          : observation['value'];
      return <String, dynamic>{
        'key': e.key,
        ...observation,
        'before': before,
        'after': after,
        'manual': manual,
        'historical': historical,
        'conflict': conflict,
        'kept': kept,
        'changed': before != after,
      };
    }).toList();
    return {
      'snapshot': snapshot,
      'rows': rows,
      'appOverrides': appOverrides,
      'scope': slotScope,
      'changes': rows.where((r) => r['changed'] == true).length,
      'conflicts': rows.where((r) => r['conflict'] == true).length,
    };
  }

  Json apply(Json s, Json raw, int number, [Json decisions = const {}]) {
    validate(raw);
    final p = preview(s, raw, number, decisions),
        snapshot = p['snapshot'] as Json;
    return engine.transact(
      s,
      'Importazione save · slot $number · ${snapshot['savedAt']}',
      (n) {
        n['manualOverrides']['app'] = p['appOverrides'];
        final scoped = Map<String, dynamic>.from(
          (n['manualOverrides'][p['scope']] ?? <String, dynamic>{}) as Json,
        );
        for (final row in (p['rows'] as List).cast<Json>()) {
          writeTarget(n, row['key'] as String, row['after']);
          if (row['kept'] == true) {
            scoped[row['key'] as String] = row['after'];
          } else {
            // Superata dal save o confermata dal save: non serve più.
            scoped.remove(row['key']);
            (n['manualOverrides']['app'] as Json).remove(row['key']);
          }
        }
        n['manualOverrides'][p['scope']] = scoped;
        n['saveSnapshots'][snapshot['id']] = {
          ...snapshot,
          'importedAt': DateTime.now().toUtc().toIso8601String(),
        };
        n['activeSaveId'] = snapshot['id'];
      },
      origin: 'save',
    );
  }

  Json edit(Json s, String id, dynamic value) {
    if (s['activeSaveId'] == null) {
      throw const FormatException('Importa prima uno snapshot.');
    }
    final observation =
        s['saveSnapshots'][s['activeSaveId']]['observations']['save.$id'];
    if (observation == null) {
      throw const FormatException('Campo save non riconosciuto.');
    }
    if (id.startsWith('chest.')) {
      flag(value, id);
    } else {
      quantity(
        value,
        id,
        id == 'postcards'
            ? 10
            : {'Blue': 17, 'Red': 6, 'Green': 9, 'Yellow': 4, 'White': 10}[id
                      .split('.')
                      .last] ??
                  0,
      );
    }
    if (s['saveValues'][id] == value) return s;
    return engine.transact(
      s,
      'Correzione save: ${observation['label']}',
      (n) => n['saveValues'][id] = value,
    );
  }
}
