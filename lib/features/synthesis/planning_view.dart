import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_providers.dart';
import '../../domain/profile.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';

const _columns = [
  'Materiale',
  'Costi',
  'Prodotti',
  'Esterni',
  'Hai',
  'Manca',
  'Previsti',
  'Senza fonte',
];

class PlanningView extends ConsumerWidget {
  const PlanningView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider).profile;
    final engine = ref.watch(engineProvider);
    final catalog = engine.catalog;
    final p = engine.plan(state), simulation = engine.simulate(state, p);
    final mode = state.plan.mode;
    final uncovered = p['rows']['orichalcum']['uncovered'] as int?;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(
          'Una creazione per ogni ricetta ancora da completare. Mythril e Dark Matter vengono espansi in base al deficit effettivo.',
          color: muted,
        ),
        if (mode == PlanMode.selected)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Scegli le ricette'),
                for (final r in catalog.recipes)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${r['name']}${state.everCrafted[r['id']] == true ? ' · completata' : ''}',
                    ),
                    value: state.plan.selected.contains(r['id']),
                    onChanged: (v) => ref.commit(
                      (s) => engine.transact(s, 'Selezione: ${r['name']}', (n) {
                        final selected = n.plan.selected;
                        final id = r['id'] as String;
                        if (v == true && !selected.contains(id)) {
                          selected.add(id);
                        } else if (v == false) {
                          selected.remove(id);
                        }
                      }),
                    ),
                  ),
              ],
            ),
          ),
        if (mode != PlanMode.route15)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Ricompense future'),
                text(
                  'Previsioni ancora fuori dall’inventario. Riducile se salti una fonte.',
                ),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    for (final id in ['dark_matter', 'orichalcum'])
                      SizedBox(
                        width: 220,
                        child: NumberEditor(
                          key: ValueKey('rewards-$id'),
                          label: catalog.materialsById[id]!['name'] as String,
                          value: state.plan.rewards[id],
                          nullable: false,
                          onSave: (v) => ref.commit(
                            (s) => engine.transact(
                              s,
                              'Ricompense future',
                              (n) => n.plan.rewards[id] = v!,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                text(
                  'Orichalcum senza fonte: ${display(uncovered)} · ${uncovered == null ? '?' : uncovered * 5000} Munny',
                  color: gold,
                ),
              ],
            ),
          ),
        if (mode == PlanMode.route15)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Percorso fino a 15'),
                for (final id in catalog.route15)
                  text(
                    '${state.everCrafted[id] == true ? '✓' : '○'} ${catalog.recipesById[id]!['name']}',
                  ),
                text(
                  'Incluse 3 Lucid Gem aggiuntive per Gaia Bangle. Evita Angel Bangle durante questo percorso.',
                  color: gold,
                ),
              ],
            ),
          ),
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Produzioni e ordine'),
              text(
                'Mythril: ${p['counts']['mythril']} · Dark Matter: ${p['counts']['dark_matter']} · Creazioni nel piano: ${p['total']}',
              ),
              text(
                simulation['complete'] == true
                    ? 'Sequenza eseguibile'
                    : 'Sequenza ancora incompleta',
                color: gold,
              ),
              text(
                (simulation['steps'] as List).isEmpty
                    ? 'Nessuna creazione eseguibile adesso.'
                    : (simulation['steps'] as List)
                          .map((id) => catalog.recipesById[id]!['name'])
                          .join(' → '),
              ),
              if (simulation['assumesRewards'] == true)
                text(
                  'La simulazione presume recuperate le ricompense future. Le sintesi reali consumano solo le scorte attuali.',
                  color: muted,
                ),
              if ((p['uncertainDependencies'] as List).isNotEmpty)
                text(
                  'Dipendenze sconosciute: ${(p['uncertainDependencies'] as List).map((id) => catalog.materialsById[id]!['name']).join(', ')}. I deficit esatti restano da verificare.',
                  color: gold,
                ),
            ],
          ),
        ),
        heading('Fabbisogno residuo'),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              for (final label in _columns) DataColumn(label: Text(label)),
            ],
            rows: [
              for (final m in catalog.materials.where(
                (m) =>
                    p['rows'][m['id']]['gross'] != 0 ||
                    state.inventory[m['id']] == null,
              ))
                DataRow(
                  cells: [
                    DataCell(Text(m['name'] as String)),
                    for (final value in [
                      p['rows'][m['id']]['gross'],
                      p['rows'][m['id']]['produced'],
                      p['rows'][m['id']]['external'],
                      state.inventory[m['id']],
                      p['rows'][m['id']]['missing'],
                      p['rows'][m['id']]['planned'],
                      p['rows'][m['id']]['uncovered'],
                    ])
                      DataCell(Text(value == null ? '?' : '$value')),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
