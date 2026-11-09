#!/usr/bin/env python3
"""Decodifica KHFM_WW.png (PC) in uno snapshot kh1fm-save-snapshot v1.

Le mappature statiche (nomi oggetti, abilità, forzieri, cuccioli) vengono
riprese dallo snapshot di riferimento già verificato; gli offset sono quelli
documentati in KH1FM_Report_Save.md. Il PNG originale viene solo letto.

Uso: python3 scripts/decode-save.py SAVE.png RIFERIMENTO.json USCITA.json
"""
import datetime
import hashlib
import json
import struct
import sys
import unicodedata
import zlib

DIRECTORY, ENTRY, ENTRIES, STRIDE = 0x10, 0x158, 200, 0x16C40
RECORD_LENGTH, CHAR, CHAR_SIZE = 0x16C00, 0x04, 0x74
WORLDS = {1: 'Destiny Islands', 3: 'Traverse Town', 4: 'Wonderland',
          5: 'Deep Jungle', 6: '100 Acre Wood', 7: 'Agrabah', 8: 'Atlantica',
          9: 'Halloween Town', 10: 'Olympus Coliseum', 11: 'Monstro',
          12: 'Neverland', 15: 'Hollow Bastion', 16: 'End of the World'}
DIFFICULTY = {0: 'Beginner', 1: 'Standard', 2: 'Proud'}
FAMILIES = [('Fire', ['Fire', 'Fira', 'Firaga']),
            ('Blizzard', ['Blizzard', 'Blizzara', 'Blizzaga']),
            ('Thunder', ['Thunder', 'Thundara', 'Thundaga']),
            ('Cure', ['Cure', 'Cura', 'Curaga']),
            ('Gravity', ['Gravity', 'Gravira', 'Graviga']),
            ('Stop', ['Stop', 'Stopra', 'Stopga']),
            ('Aero', ['Aero', 'Aerora', 'Aeroga'])]
SUMMONS = ['Dumbo', 'Bambi', 'Genie', 'Tinker Bell', 'Mushu', 'Simba']
SHARED = {1: 'High Jump', 2: 'Mermaid Kick', 3: 'Glide', 4: 'Superglide'}
# Abilità assenti nello snapshot di riferimento (ID da KingdomSaveEditor).
ABILITIES = {7: 'Air Combo Plus', 8: 'Critical Plus', 15: 'Trinity Limit',
             17: 'Vortex', 18: 'Aerial Sweep', 58: 'Gravity Break',
             59: 'Zantetsuken', 61: 'Encounter Plus'}
TRINITY = [('Blue', 0, 17), ('Red', 2, 6), ('Green', 3, 9),
           ('Yellow', 4, 4), ('White', 5, 10)]


def png_payload(data):
    if data[:8] != b'\x89PNG\r\n\x1a\n':
        raise SystemExit('Non è un PNG.')
    pos, payload, valid = 8, None, True
    while pos < len(data):
        length, = struct.unpack_from('>I', data, pos)
        kind = data[pos + 4:pos + 8]
        body = data[pos + 8:pos + 8 + length]
        crc, = struct.unpack_from('>I', data, pos + 8 + length)
        valid &= zlib.crc32(kind + body) & 0xFFFFFFFF == crc
        if kind == b'sqEX':
            payload = body
        pos += 12 + length
    if payload is None:
        raise SystemExit('Chunk sqEX assente.')
    return payload, valid


def directory(sq):
    entries = []
    for i in range(ENTRIES):
        e = bytearray(sq[DIRECTORY + i * ENTRY:DIRECTORY + (i + 1) * ENTRY])
        if i == 0:
            key = e[0xE0:0xF0]
            for j in range(0xF0):
                e[j] ^= key[j % 16]
        name = bytes(e[:0x20]).split(b'\0')[0].decode('ascii', 'replace')
        if name:
            created, modified, length = struct.unpack_from('<QQI', e, 0x40)
            entries.append((i, name, created, modified, length))
    return entries


def stamp(seconds):
    return datetime.datetime.fromtimestamp(seconds).astimezone().isoformat()


def decode_slot(record, summary, ref, entry):
    reference = ref['slots'][0]
    items = {i['item_id']: (i['name'], i['category'])
             for i in reference['inventory']}
    abilities = {**ABILITIES, **{a['id']: a['name'] for s in ref['slots']
                                 for c in s['characters'] for a in c['abilities']}}
    u8 = lambda o: record[o]
    u32 = lambda o: struct.unpack_from('<I', record, o)[0]
    item = lambda i: {'item_id': i, 'name': items[i][0]}

    inventory = [{'item_id': i, 'name': items[i][0], 'category': items[i][1],
                  'quantity': u8(0x499 + i)} for i in range(256)]
    counts = {i['name']: i['quantity'] for i in inventory}
    materials = {m: counts[m] for m in reference['materials']}

    characters = []
    for index, name in enumerate(['Sora', 'Donald', 'Goofy']):
        c = record[CHAR + index * CHAR_SIZE:CHAR + (index + 1) * CHAR_SIZE]
        accessory_slots, item_slots = c[0x18], c[0x21]
        skills = []
        for slot, raw in enumerate(c[0x40:0x70], 1):
            if raw == 0:
                break
            skills.append({'slot': slot, 'id': raw & 0x7F,
                           'name': abilities.get(raw & 0x7F,
                                                 f'Ability {raw & 0x7F}'),
                           'equipped': bool(raw & 0x80), 'raw_value': raw})
        characters.append({
            'name': name, 'level': c[0x00],
            'exp': struct.unpack_from('<I', c, 0x3C)[0],
            'hp_current': c[0x01], 'hp_base_max': c[0x02],
            'mp_current': c[0x03], 'mp_base_max': c[0x04],
            'ap_base_max': c[0x05], 'strength_base': c[0x06],
            'defense_base': c[0x07], 'weapon': item(c[0x32]),
            'accessories': [{'slot': s + 1, **item(c[0x19 + s])}
                            for s in range(accessory_slots) if c[0x19 + s]],
            'accessory_slots': accessory_slots,
            'carried_items': [{'slot': s + 1, **item(c[0x22 + s])}
                              for s in range(item_slots) if c[0x22 + s]],
            'item_slots': item_slots, 'abilities': skills,
            'confidence': 'mapped'})

    equipped = {c['weapon']['item_id'] for c in characters}
    keyblades = [{**{k: kb[k] for k in ('item_id', 'name')},
                  'owned': counts[kb['name']] > 0 or kb['item_id'] in equipped,
                  'equipped': kb['item_id'] == characters[0]['weapon']['item_id']}
                 for kb in reference['keyblades']]

    unlocked = u8(0x74)
    tiers, mirror = record[0x492:0x499], record[0x1C1E:0x1C25]
    magic = []
    for bit, (family, names) in enumerate(FAMILIES):
        tier = tiers[bit]
        magic.append({'family': family, 'tier': tier,
                      'name': names[tier - 1] if tier else None,
                      'unlocked': bool(unlocked >> bit & 1), 'max_tier': 3,
                      'confidence': 'derived_mapping_cross_checked_mirror'
                      if tiers == mirror else 'derived_mapping'})

    owned = set(record[0x7D0:0x7D7]) - {0xFF}
    summons = [{'id': i, 'name': n, 'unlocked': i in owned,
                'confidence': 'derived_mapping'} for i, n in enumerate(SUMMONS)]
    shared = [{'id': v, 'name': SHARED.get(v, f'Ability {v}')}
              for v in record[0x599:0x59D] if v]

    by_color = [{'color': n, 'collected': u8(0x1C66 + o), 'total': t}
                for n, o, t in TRINITY]

    reports = []
    for n in range(1, 14):
        offset, bit = (0x19C0, 8 - n) if n <= 8 else (0x19C1, 16 - n)
        reports.append({'number': n,
                        'unlocked_in_journal': bool(u8(offset) >> bit & 1),
                        'offset': hex(offset), 'bit': bit,
                        'confidence': 'derived_mapping'})

    flag = lambda o, b: bool(record[int(o, 16)] >> b & 1)
    groups = [{**g, 'rescued': flag(g['offset'], g['bit'])}
              for g in reference['dalmatians']['groups']]
    checks = [{**c, 'collected': flag(c['offset'], c['bit'])}
              for c in reference['chests']['checks']]

    world, room, spawn = u32(0x2040), u32(0x2044), u32(0x2048)
    label = summary[0x14:0x60].split(b'\0')[0].decode('shift_jis', 'replace')
    level, munny = characters[0]['level'], u32(0x1641C)
    return {
        'slot_number': int(entry[1].rsplit('-', 1)[1]),
        'archive_entry_name': entry[1],
        'created_at': stamp(entry[2]), 'modified_at': stamp(entry[3]),
        'difficulty': {'raw_value': u8(0x1642C),
                       'name': DIFFICULTY.get(u8(0x1642C), 'Da verificare')},
        'location': {'world_id': world, 'world': WORLDS.get(world, f'World {world}'),
                     'room_id': room, 'spawn_id': spawn,
                     'save_label': unicodedata.normalize('NFKC', label)},
        'level': level, 'munny': munny, 'exp': characters[0]['exp'],
        'characters': characters, 'inventory': inventory,
        'materials': materials,
        'extra_item_counts': {k: counts[k] for k in reference['extra_item_counts']},
        'keyblades': keyblades, 'magic': magic, 'summons': summons,
        'shared_abilities': shared,
        'trinities': {'by_color': by_color,
                      'collected': sum(c['collected'] for c in by_color),
                      'total': 46, 'individual_marks': None,
                      'confidence': 'derived_mapping'},
        'ansem_reports': reports,
        'postcards': {'mailed': u8(0x1CBF), 'total': 10,
                      'individual_locations': None,
                      'confidence': 'derived_mapping'},
        'dalmatians': {'rescued': 3 * sum(g['rescued'] for g in groups),
                       'total': 99, 'groups': groups},
        'chests': {'opened': sum(c['collected'] for c in checks),
                   'mapped_total': len(checks), 'game_total': None,
                   'coverage_complete': False, 'checks': checks},
        'synthesis': {'recipe_history': None, 'unique_crafted_count': None,
                      'overwrite_existing_manual_history': False},
        'unknown_sections': reference['unknown_sections'],
        'diagnostics': {
            'record_length': entry[4],
            'level_matches_summary': summary[0x08] == level,
            'munny_matches_summary':
                struct.unpack_from('<I', summary, 0x0C)[0] == munny,
            'magic_tiers_match_journal_mirror': tiers == mirror,
            'record_offset_within_sqex':
                DIRECTORY + ENTRIES * ENTRY + entry[0] * STRIDE}}


def main(png, reference, output):
    data = open(png, 'rb').read()
    ref = json.load(open(reference))
    sq, valid = png_payload(data)
    entries = directory(sq)
    base = DIRECTORY + ENTRIES * ENTRY
    slots = []
    for entry in entries:
        if '/' in entry[1] or entry[4] != RECORD_LENGTH:
            continue
        system = next(e for e in entries
                      if e[1] == f"-{entry[1].rsplit('-', 1)[1]}/system.bin")
        record = sq[base + entry[0] * STRIDE:][:RECORD_LENGTH]
        summary = sq[base + system[0] * STRIDE:][:system[4]]
        slots.append(decode_slot(record, summary, ref, entry))
    slots.sort(key=lambda s: s['slot_number'])
    snapshot = {
        'schema': 'kh1fm-save-snapshot', 'schema_version': 1,
        'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'game': ref['game'], 'platform': ref['platform'],
        'source': {'filename': png.rsplit('/', 1)[-1], 'size_bytes': len(data),
                   'sha256': hashlib.sha256(data).hexdigest(),
                   'png_crc_valid': valid, 'source_save_modified': False},
        'interpretation': {**ref['interpretation'],
                           'synthesis_history': 'Possessing a crafted item is not a complete synthesis-history flag; recipe history is not decoded.'},
        'recommended_slot': max(slots, key=lambda s: s['modified_at'])['slot_number'],
        'slots': slots, 'sources': ref['sources']}
    with open(output, 'w') as f:
        json.dump(snapshot, f, ensure_ascii=False, indent=2)


if __name__ == '__main__':
    main(*sys.argv[1:4])
