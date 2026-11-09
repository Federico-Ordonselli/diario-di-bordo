import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'catalog.dart';

/// Decodifica il PNG del gioco (KHFM_WW.png, PC) in uno snapshot
/// kh1fm-save-snapshot v1, come scripts/decode-save.py.
///
/// [reference] è uno snapshot già analizzato: fornisce le mappature statiche
/// (nomi oggetti, abilità, forzieri, cuccioli). Il file viene solo letto.
Json decodeSave(
  List<int> bytes,
  Json reference, {
  String filename = 'KHFM_WW.png',
}) {
  final data = Uint8List.fromList(bytes);
  final (payload, crcValid) = _pngPayload(data);
  final entries = _directory(payload);
  final slots = <Json>[];
  for (final entry in entries) {
    if (entry.name.contains('/') || entry.length != _recordLength) continue;
    final number = entry.name.split('-').last;
    final system = entries.where((e) => e.name == '-$number/system.bin');
    if (system.isEmpty) throw FormatException('Riepilogo assente: $number');
    slots.add(
      _slot(
        _record(payload, entry.index, _recordLength),
        _record(payload, system.first.index, system.first.length),
        reference,
        entry,
      ),
    );
  }
  if (slots.isEmpty) throw const FormatException('Nessuno slot nel save.');
  slots.sort(
    (a, b) => (a['slot_number'] as int).compareTo(b['slot_number'] as int),
  );
  final latest = slots.reduce(
    (a, b) =>
        (a['modified_at'] as String).compareTo(b['modified_at'] as String) >= 0
        ? a
        : b,
  );
  return {
    'schema': 'kh1fm-save-snapshot',
    'schema_version': 1,
    'generated_at': DateTime.now().toUtc().toIso8601String(),
    'game': reference['game'],
    'platform': reference['platform'],
    'source': {
      'filename': filename,
      'size_bytes': data.length,
      'sha256': sha256.convert(data).toString(),
      'png_crc_valid': crcValid,
      'source_save_modified': false,
    },
    'interpretation': {
      ...reference['interpretation'] as Json,
      'synthesis_history':
          'Possessing a crafted item is not a complete synthesis-history flag; recipe history is not decoded.',
    },
    'recommended_slot': latest['slot_number'],
    'slots': slots,
    'sources': reference['sources'],
  };
}

const _directoryStart = 0x10, _entrySize = 0x158, _entries = 200;
const _stride = 0x16C40, _recordLength = 0x16C00;
const _characterStart = 0x04, _characterSize = 0x74;
const _worlds = {
  1: 'Destiny Islands',
  3: 'Traverse Town',
  4: 'Wonderland',
  5: 'Deep Jungle',
  6: '100 Acre Wood',
  7: 'Agrabah',
  8: 'Atlantica',
  9: 'Halloween Town',
  10: 'Olympus Coliseum',
  11: 'Monstro',
  12: 'Neverland',
  15: 'Hollow Bastion',
  16: 'End of the World',
};
const _difficulty = {0: 'Beginner', 1: 'Standard', 2: 'Proud'};
const _families = [
  ('Fire', ['Fire', 'Fira', 'Firaga']),
  ('Blizzard', ['Blizzard', 'Blizzara', 'Blizzaga']),
  ('Thunder', ['Thunder', 'Thundara', 'Thundaga']),
  ('Cure', ['Cure', 'Cura', 'Curaga']),
  ('Gravity', ['Gravity', 'Gravira', 'Graviga']),
  ('Stop', ['Stop', 'Stopra', 'Stopga']),
  ('Aero', ['Aero', 'Aerora', 'Aeroga']),
];
const _summons = ['Dumbo', 'Bambi', 'Genie', 'Tinker Bell', 'Mushu', 'Simba'];
const _shared = {
  1: 'High Jump',
  2: 'Mermaid Kick',
  3: 'Glide',
  4: 'Superglide',
};
// Abilità assenti nello snapshot di riferimento (ID da KingdomSaveEditor).
const _abilities = {
  7: 'Air Combo Plus',
  8: 'Critical Plus',
  15: 'Trinity Limit',
  17: 'Vortex',
  18: 'Aerial Sweep',
  58: 'Gravity Break',
  59: 'Zantetsuken',
  61: 'Encounter Plus',
};
const _trinity = [
  ('Blue', 0, 17),
  ('Red', 2, 6),
  ('Green', 3, 9),
  ('Yellow', 4, 4),
  ('White', 5, 10),
];

class _Entry {
  _Entry(this.index, this.name, this.created, this.modified, this.length);
  final int index, created, modified, length;
  final String name;
}

final _crcTable = List<int>.generate(256, (n) {
  var c = n;
  for (var k = 0; k < 8; k++) {
    c = c & 1 != 0 ? 0xEDB88320 ^ (c >>> 1) : c >>> 1;
  }
  return c;
});

int _crc32(Uint8List data, int start, int end) {
  var c = 0xFFFFFFFF;
  for (var i = start; i < end; i++) {
    c = _crcTable[(c ^ data[i]) & 0xFF] ^ (c >>> 8);
  }
  return c ^ 0xFFFFFFFF;
}

(Uint8List, bool) _pngPayload(Uint8List data) {
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  if (data.length < 8 ||
      !List.generate(8, (i) => data[i] == signature[i]).every((v) => v)) {
    throw const FormatException('Il file non è un PNG.');
  }
  final view = ByteData.sublistView(data);
  var position = 8, valid = true;
  Uint8List? payload;
  while (position + 12 <= data.length) {
    final length = view.getUint32(position);
    final end = position + 8 + length;
    if (end + 4 > data.length) throw const FormatException('PNG troncato.');
    valid &= _crc32(data, position + 4, end) == view.getUint32(end);
    if (String.fromCharCodes(data, position + 4, position + 8) == 'sqEX') {
      payload = Uint8List.sublistView(data, position + 8, end);
    }
    position = end + 4;
  }
  if (payload == null) {
    throw const FormatException('Il PNG non contiene dati di salvataggio.');
  }
  return (payload, valid);
}

List<_Entry> _directory(Uint8List payload) {
  if (payload.length < _directoryStart + _entries * _entrySize) {
    throw const FormatException('Directory del save incompleta.');
  }
  final entries = <_Entry>[];
  for (var i = 0; i < _entries; i++) {
    final start = _directoryStart + i * _entrySize;
    final e = Uint8List.fromList(payload.sublist(start, start + _entrySize));
    if (i == 0) {
      final key = e.sublist(0xE0, 0xF0);
      for (var j = 0; j < 0xF0; j++) {
        e[j] ^= key[j % 16];
      }
    }
    final nameEnd = e.indexOf(0);
    final name = String.fromCharCodes(
      e.sublist(0, nameEnd < 0 || nameEnd > 0x20 ? 0x20 : nameEnd),
    );
    if (name.isEmpty) continue;
    final view = ByteData.sublistView(e);
    entries.add(
      _Entry(
        i,
        name,
        view.getUint64(0x40, Endian.little),
        view.getUint64(0x48, Endian.little),
        view.getUint32(0x50, Endian.little),
      ),
    );
  }
  return entries;
}

Uint8List _record(Uint8List payload, int index, int length) {
  final start = _directoryStart + _entries * _entrySize + index * _stride;
  if (start + length > payload.length) {
    throw const FormatException('Record del save troncato.');
  }
  return Uint8List.sublistView(payload, start, start + length);
}

/// Data locale con offset esplicito, come la mostra il diario.
String _stamp(int seconds) {
  final t = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  String two(int v) => v.toString().padLeft(2, '0');
  final offset = t.timeZoneOffset, minutes = offset.inMinutes.abs();
  return '${t.year}-${two(t.month)}-${two(t.day)}T${two(t.hour)}:${two(t.minute)}:${two(t.second)}'
      '${offset.isNegative ? '-' : '+'}${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// Il nome del punto di salvataggio è in Shift-JIS a larghezza piena; basta
/// la parte latina, convertita come farebbe la normalizzazione NFKC.
String _label(Uint8List summary) {
  final out = StringBuffer();
  for (var i = 0x14; i < 0x60 && summary[i] != 0;) {
    final b = summary[i];
    if (b < 0x80) {
      out.writeCharCode(b);
      i++;
      continue;
    }
    if (i + 1 >= 0x60) break;
    final code = b << 8 | summary[i + 1];
    i += 2;
    out.write(switch (code) {
      0x8140 => ' ',
      >= 0x824F && <= 0x8258 => String.fromCharCode(0x30 + code - 0x824F),
      >= 0x8260 && <= 0x8279 => String.fromCharCode(0x41 + code - 0x8260),
      >= 0x8281 && <= 0x829A => String.fromCharCode(0x61 + code - 0x8281),
      0x8143 => ',',
      0x8144 => '.',
      0x8146 => ':',
      0x8148 => '?',
      0x8149 => '!',
      0x815E => '/',
      0x8165 => '‘',
      0x8166 => '’',
      0x8169 => '(',
      0x816A => ')',
      0x817C => '−',
      0x8195 => '&',
      _ => '�',
    });
  }
  return out.toString();
}

Json _slot(Uint8List record, Uint8List summary, Json ref, _Entry entry) {
  final reference = (ref['slots'] as List).first as Json;
  final items = {
    for (final i in (reference['inventory'] as List).cast<Json>())
      i['item_id'] as int: i,
  };
  final abilities = {
    ..._abilities,
    for (final s in (ref['slots'] as List).cast<Json>())
      for (final c in (s['characters'] as List).cast<Json>())
        for (final a in (c['abilities'] as List).cast<Json>())
          a['id'] as int: a['name'] as String,
  };
  final view = ByteData.sublistView(record);
  int u32(int offset) => view.getUint32(offset, Endian.little);
  String itemName(int id) => (items[id]?['name'] ?? 'Item $id') as String;
  Json item(int id) => {'item_id': id, 'name': itemName(id)};

  final inventory = [
    for (var i = 0; i < 256; i++)
      {
        'item_id': i,
        'name': itemName(i),
        'category': items[i]?['category'] ?? 'unknown',
        'quantity': record[0x499 + i],
      },
  ];
  final counts = {for (final i in inventory) i['name']: i['quantity'] as int};

  final characters = <Json>[];
  for (final (index, name) in ['Sora', 'Donald', 'Goofy'].indexed) {
    final start = _characterStart + index * _characterSize;
    final c = Uint8List.sublistView(record, start, start + _characterSize);
    final accessorySlots = c[0x18], itemSlots = c[0x21];
    final skills = <Json>[];
    for (var slot = 1; slot <= 0x30; slot++) {
      final raw = c[0x3F + slot];
      if (raw == 0) break;
      skills.add({
        'slot': slot,
        'id': raw & 0x7F,
        'name': abilities[raw & 0x7F] ?? 'Ability ${raw & 0x7F}',
        'equipped': raw & 0x80 != 0,
        'raw_value': raw,
      });
    }
    characters.add({
      'name': name,
      'level': c[0x00],
      'exp': ByteData.sublistView(c).getUint32(0x3C, Endian.little),
      'hp_current': c[0x01],
      'hp_base_max': c[0x02],
      'mp_current': c[0x03],
      'mp_base_max': c[0x04],
      'ap_base_max': c[0x05],
      'strength_base': c[0x06],
      'defense_base': c[0x07],
      'weapon': item(c[0x32]),
      'accessories': [
        for (var s = 0; s < accessorySlots; s++)
          if (c[0x19 + s] != 0) {'slot': s + 1, ...item(c[0x19 + s])},
      ],
      'accessory_slots': accessorySlots,
      'carried_items': [
        for (var s = 0; s < itemSlots; s++)
          if (c[0x22 + s] != 0) {'slot': s + 1, ...item(c[0x22 + s])},
      ],
      'item_slots': itemSlots,
      'abilities': skills,
      'confidence': 'mapped',
    });
  }

  final weapons = {
    for (final c in characters) (c['weapon'] as Json)['item_id'],
  };
  final soraWeapon = (characters.first['weapon'] as Json)['item_id'];
  final keyblades = [
    for (final k in (reference['keyblades'] as List).cast<Json>())
      {
        'item_id': k['item_id'],
        'name': k['name'],
        'owned': (counts[k['name']] ?? 0) > 0 || weapons.contains(k['item_id']),
        'equipped': k['item_id'] == soraWeapon,
      },
  ];

  final unlocked = record[0x74];
  final tiers = record.sublist(0x492, 0x499),
      mirror = record.sublist(0x1C1E, 0x1C25);
  final mirrored = List.generate(
    7,
    (i) => tiers[i] == mirror[i],
  ).every((v) => v);
  final magic = [
    for (final (bit, (family, names)) in _families.indexed)
      {
        'family': family,
        'tier': tiers[bit],
        'name': tiers[bit] > 0 && tiers[bit] <= 3
            ? names[tiers[bit] - 1]
            : null,
        'unlocked': unlocked >> bit & 1 == 1,
        'max_tier': 3,
        'confidence': mirrored
            ? 'derived_mapping_cross_checked_mirror'
            : 'derived_mapping',
      },
  ];

  final owned = record.sublist(0x7D0, 0x7D7).toSet()..remove(0xFF);
  final byColor = [
    for (final (color, offset, total) in _trinity)
      {'color': color, 'collected': record[0x1C66 + offset], 'total': total},
  ];
  bool flag(String offset, int bit) =>
      record[int.parse(offset.substring(2), radix: 16)] >> bit & 1 == 1;
  final groups = [
    for (final g
        in ((reference['dalmatians'] as Json)['groups'] as List).cast<Json>())
      {...g, 'rescued': flag(g['offset'] as String, g['bit'] as int)},
  ];
  final checks = [
    for (final c
        in ((reference['chests'] as Json)['checks'] as List).cast<Json>())
      {...c, 'collected': flag(c['offset'] as String, c['bit'] as int)},
  ];

  final world = u32(0x2040), level = characters.first['level'] as int;
  final munny = u32(0x1641C), difficulty = record[0x1642C];
  final summaryView = ByteData.sublistView(summary);
  return {
    'slot_number': int.parse(entry.name.split('-').last),
    'archive_entry_name': entry.name,
    'created_at': _stamp(entry.created),
    'modified_at': _stamp(entry.modified),
    'difficulty': {
      'raw_value': difficulty,
      'name': _difficulty[difficulty] ?? 'Da verificare',
    },
    'location': {
      'world_id': world,
      'world': _worlds[world] ?? 'World $world',
      'room_id': u32(0x2044),
      'spawn_id': u32(0x2048),
      'save_label': _label(summary),
    },
    'level': level,
    'munny': munny,
    'exp': characters.first['exp'],
    'characters': characters,
    'inventory': inventory,
    'materials': {
      for (final m in (reference['materials'] as Json).keys) m: counts[m],
    },
    'extra_item_counts': {
      for (final k in (reference['extra_item_counts'] as Json).keys)
        k: counts[k],
    },
    'keyblades': keyblades,
    'magic': magic,
    'summons': [
      for (final (i, name) in _summons.indexed)
        {
          'id': i,
          'name': name,
          'unlocked': owned.contains(i),
          'confidence': 'derived_mapping',
        },
    ],
    'shared_abilities': [
      for (final v in record.sublist(0x599, 0x59D))
        if (v != 0) {'id': v, 'name': _shared[v] ?? 'Ability $v'},
    ],
    'trinities': {
      'by_color': byColor,
      'collected': byColor.fold<int>(0, (n, c) => n + (c['collected'] as int)),
      'total': 46,
      'individual_marks': null,
      'confidence': 'derived_mapping',
    },
    'ansem_reports': [
      for (var n = 1; n <= 13; n++)
        {
          'number': n,
          'unlocked_in_journal':
              record[n <= 8 ? 0x19C0 : 0x19C1] >> (n <= 8 ? 8 - n : 16 - n) &
                  1 ==
              1,
          'offset': n <= 8 ? '0x19c0' : '0x19c1',
          'bit': n <= 8 ? 8 - n : 16 - n,
          'confidence': 'derived_mapping',
        },
    ],
    'postcards': {
      'mailed': record[0x1CBF],
      'total': 10,
      'individual_locations': null,
      'confidence': 'derived_mapping',
    },
    'dalmatians': {
      'rescued': 3 * groups.where((g) => g['rescued'] == true).length,
      'total': 99,
      'groups': groups,
    },
    'chests': {
      'opened': checks.where((c) => c['collected'] == true).length,
      'mapped_total': checks.length,
      'game_total': null,
      'coverage_complete': false,
      'checks': checks,
    },
    'synthesis': {
      'recipe_history': null,
      'unique_crafted_count': null,
      'overwrite_existing_manual_history': false,
    },
    'unknown_sections': reference['unknown_sections'],
    'diagnostics': {
      'record_length': entry.length,
      'level_matches_summary': summary[0x08] == level,
      'munny_matches_summary':
          summaryView.getUint32(0x0C, Endian.little) == munny,
      'magic_tiers_match_journal_mirror': mirrored,
      'record_offset_within_sqex':
          _directoryStart + _entries * _entrySize + entry.index * _stride,
    },
  };
}
