#!/usr/bin/env python3
"""Genera il report Markdown di uno snapshot kh1fm-save-snapshot v1.

Uso: python3 scripts/save-report.py SNAPSHOT.json USCITA.md [SINTESI ...]
Le ricette indicate dopo l'uscita sono quelle confermate dall'utente: lo
storico della sintesi non è decodificato dal save.
"""
import sys
import json

NON_MATERIAL = {'material', 'info', 'unused'}
WORLD_ORDER = ['Traverse Town', 'Wonderland', 'Olympus Coliseum', 'Deep Jungle',
               '100 Acre Wood', 'Agrabah', 'Monstro', 'Atlantica',
               'Halloween Town', 'Neverland', 'Hollow Bastion',
               'End of the World']


def yes(value):
    return 'Sì' if value else 'No'


def table(headers, rows):
    lines = ['| ' + ' | '.join(headers) + ' |',
             '| ' + ' | '.join('---' for _ in headers) + ' |']
    lines += ['| ' + ' | '.join(str(c) for c in row) + ' |' for row in rows]
    return '\n'.join(lines)


def number(value):
    return f'{value:,}'.replace(',', '.')


def slot_report(s, confirmed):
    out = []
    missing_kb = [k['name'] for k in s['keyblades'] if not k['owned']]
    missing_reports = [str(r['number']) for r in s['ansem_reports']
                       if not r['unlocked_in_journal']]
    missing_summons = [x['name'] for x in s['summons'] if not x['unlocked']]
    closed = [c for c in s['chests']['checks'] if not c['collected']]
    tri = s['trinities']
    reports_done = 13 - len(missing_reports)
    sora = s['characters'][0]
    out.append(f"## Progresso leggibile dello slot {s['slot_number']}\n")
    out.append(table(['Voce', 'Risultato'], [
        ['Sora', f"Livello {s['level']}; {number(s['exp'])} EXP; {number(s['munny'])} Munny"],
        ['Keyblade equipaggiato', sora['weapon']['name']],
        ['Cuccioli', f"{s['dalmatians']['rescued']}/99, dai flag dei 33 forzieri originali"],
        ['Trinità', f"{tri['collected']}/46"],
        ['Diari di Ansem', f"{reports_done}/13" + (f"; mancano {', '.join(missing_reports)}" if missing_reports else '')],
        ['Invocazioni', f"{6 - len(missing_summons)}/6" + (f"; manca {', '.join(missing_summons)}" if missing_summons else '')],
        ['Cartoline spedite', f"{s['postcards']['mailed']}/10"],
        ['Keyblade della collezione normale/FM', f"{18 - len(missing_kb)}/18"],
        ['Forzieri della mappatura utilizzata', f"{s['chests']['opened']}/{s['chests']['mapped_total']} aperti; {len(closed)} non risultano aperti"],
        ['Sintesi storica', 'Non decodificata' + (f"; confermate dall’utente: {', '.join(confirmed)}" if confirmed else '')],
    ]))
    out.append('\nQuesti rapporti descrivono singole categorie. Non equivalgono a una percentuale complessiva di completamento del gioco.\n')

    out.append('## Inventario materiali\n')
    out.append('34 materiali usati nella sintesi; gli zeri sono letti dal save e non sono valori mancanti.\n')
    out.append(table(['Materiale', 'Quantità'],
                     sorted(s['materials'].items())))
    extra = ', '.join(f'{k}: {v}' for k, v in s['extra_item_counts'].items())
    if extra:
        out.append(f'\nNon ingredienti delle 33 ricette Final Mix: {extra}.\n')

    out.append('## Magie\n')
    out.append(table(['Famiglia', 'Magia attuale', 'Livello', 'Livello massimo'],
                     [[m['family'], m['name'] or '—', m['tier'], m['max_tier']]
                      for m in s['magic']]))
    weak = [m['family'] for m in s['magic'] if m['tier'] < m['max_tier']]
    out.append('\n' + (f"Da potenziare: {', '.join(weak)}." if weak else 'Tutte le magie sono al terzo livello.') + '\n')

    out.append('## Invocazioni\n')
    out.append(table(['Invocazione', 'Sbloccata'],
                     [[x['name'], yes(x['unlocked'])] for x in s['summons']]))
    out.append('\n## Trinità\n')
    out.append(table(['Colore', 'Attivate', 'Totale', 'Mancanti'],
                     [[c['color'], c['collected'], c['total'], c['total'] - c['collected']]
                      for c in tri['by_color']]))
    out.append('\nI contatori per colore non identificano i singoli marchi.\n')

    out.append('## Diari di Ansem\n')
    out.append(table(['Diario', 'Visibile/sbloccato nel diario'],
                     [[r['number'], yes(r['unlocked_in_journal'])] for r in s['ansem_reports']]))
    out.append('\nL’assenza di un diario non viene trasformata in un flag di boss non sconfitto.\n')

    out.append('## Keyblade\n')
    out.append(table(['Keyblade', 'Posseduto', 'Equipaggiato'],
                     [[k['name'], yes(k['owned']), 'Sì' if k['equipped'] else '']
                      for k in s['keyblades']]))
    if missing_kb:
        out.append(f"\nMancanti nella collezione salvata: {', '.join(missing_kb)}.\n")

    out.append(f'## {len(closed)} forzieri da controllare\n')
    out.append('Nomi inglesi per mantenerli confrontabili con guide e database. Stato ottenuto dal flag della cassa; vongole di Atlantica e premi degli eventi non inclusi.\n')
    rank = {w: i for i, w in enumerate(WORLD_ORDER)}
    out.append(table(['Mondo', 'Forziere'],
                     [[c['world'], c['name']] for c in
                      sorted(closed, key=lambda c: rank.get(c['world'], 99))]))

    out.append('\n## Personaggi, equipaggiamento e abilità\n')
    out.append('HP, MP, AP, forza e difesa sono i campi base del salvataggio; i valori in gioco possono differire per effetto dell’equipaggiamento.\n')
    for c in s['characters']:
        out.append(f"### {c['name']}\n")
        out.append(table(['Dato', 'Valore'], [
            ['Livello', c['level']], ['EXP', c['exp']],
            ['HP attuali / massimo base', f"{c['hp_current']} / {c['hp_base_max']}"],
            ['MP attuali / massimo base', f"{c['mp_current']} / {c['mp_base_max']}"],
            ['AP base', c['ap_base_max']], ['Forza base', c['strength_base']],
            ['Difesa base', c['defense_base']], ['Arma', c['weapon']['name']],
            ['Accessori', ', '.join(a['name'] for a in c['accessories']) or 'Nessuno'],
            ['Oggetti portati', ', '.join(i['name'] for i in c['carried_items']) or 'Nessuno'],
        ]))
        out.append('')
        out.append(table(['Slot', 'Abilità', 'Equipaggiata'],
                         [[a['slot'], a['name'], yes(a['equipped'])] for a in c['abilities']]))
        out.append('')
    out.append('Abilità condivise: ' + ', '.join(a['name'] for a in s['shared_abilities']) + '.\n')

    out.append('## Inventario non materiale con quantità positive\n')
    out.append(table(['Oggetto', 'Categoria', 'Quantità nel save'],
                     [[i['name'], i['category'], i['quantity']] for i in s['inventory']
                      if i['quantity'] and i['category'] not in NON_MATERIAL]))
    return '\n'.join(out)


def main(snapshot, output, *confirmed):
    raw = json.load(open(snapshot))
    src = raw['source']
    out = ['# Analisi salvataggio KH1 Final Mix\n',
           f"Snapshot estratto da {src['filename']} (SHA-256 `{src['sha256']}`) con `scripts/decode-save.py`. Il salvataggio originale non è stato modificato; i progressi successivi al salvataggio non sono inclusi.\n",
           '## Slot trovati\n',
           table(['Slot', 'Ultima modifica, ora italiana', 'Livello', 'Difficoltà', 'Luogo', 'Munny'],
                 [[s['slot_number'], s['modified_at'], s['level'], s['difficulty']['name'],
                   f"{s['location']['world']} / {s['location']['save_label']}", s['munny']]
                  for s in raw['slots']]),
           f"\n**Slot di riferimento: {raw['recommended_slot']}**, il più recente.\n"]
    for s in raw['slots']:
        out.append(slot_report(s, list(confirmed)))
    out.append('\n## Cosa resta da verificare per il 100%\n')
    out.append('- Storico completo delle 33 ricette: non è nel save; vale lo storico dell’app.\n'
               '- Singole Trinità, coppe del Colosseo, boss opzionali, serrature dei mondi.\n'
               '- Minigiochi, Bosco dei 100 Acri, missioni e progetti Gummi.\n'
               '- Trofei/achievement Steam e finali.\n\n'
               'Nel JSON queste sezioni sono null, non false: non azzerano le checklist manuali.\n')
    out.append('## Verifiche eseguite\n')
    for s in raw['slots']:
        d = s['diagnostics']
        out.append(f"- Slot {s['slot_number']}: CRC PNG {'validi' if src['png_crc_valid'] else 'NON validi'}; "
                   f"livello {'coincide' if d['level_matches_summary'] else 'NON coincide'} e Munny "
                   f"{'coincidono' if d['munny_matches_summary'] else 'NON coincidono'} con system.bin; "
                   f"livelli magie {'uguali' if d['magic_tiers_match_journal_mirror'] else 'DIVERSI'} nella copia del diario.")
    out.append('- Nessun confronto in gioco eseguito: i campi derivati mantengono la loro confidenza esplicita.\n')
    out.append('## Fonti\n')
    out += [f"- [{x['name']}]({x['url']})" for x in raw['sources']]
    with open(output, 'w') as f:
        f.write('\n'.join(out) + '\n')


if __name__ == '__main__':
    main(*sys.argv[1:])
