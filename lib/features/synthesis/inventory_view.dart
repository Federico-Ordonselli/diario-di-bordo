import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_providers.dart';
import '../../ui/common.dart';
import '../../ui/widgets.dart';
import 'material_widgets.dart';

const _filters = {
  'all': 'Tutti',
  'missing': 'Mancanti',
  'unknown': 'Da verificare',
  'enough': 'Sufficienti',
};

class InventoryView extends ConsumerStatefulWidget {
  const InventoryView({super.key});
  @override
  ConsumerState<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends ConsumerState<InventoryView> {
  String search = '', filter = 'all';

  /// Materiali che soddisfacevano il filtro quando è stato scelto: la lista
  /// non cambia sotto le dita mentre si modificano le quantità.
  Set<String>? selection;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider).profile;
    final engine = ref.watch(engineProvider);
    final catalog = engine.catalog;
    final p = engine.plan(state);
    final visible = catalog.materials
        .where(
          (m) =>
              (selection == null || selection!.contains(m['id'])) &&
              (m['name'] as String).toLowerCase().contains(search),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          hint: 'Cerca materiale…',
          onChanged: (v) => setState(() => search = v),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final e in _filters.entries)
              ChoiceChip(
                label: Text(e.value),
                selected: filter == e.key,
                onSelected: (_) => setState(() {
                  filter = e.key;
                  selection = e.key == 'all'
                      ? null
                      : catalog.materials
                            .where((m) {
                              final row = p['rows'][m['id']];
                              return e.key == 'missing'
                                  ? row['missing'] != null && row['missing'] > 0
                                  : e.key == 'unknown'
                                  ? row['unknown'] == true
                                  : row['sufficient'] == true;
                            })
                            .map((m) => m['id'] as String)
                            .toSet();
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),
        text(
          'Vuoto = quantità sconosciuta. Le ricompense future restano fuori dalle scorte.',
          color: muted,
        ),
        for (final m in visible)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                  onPressed: () =>
                      showMaterialDialog(context, m['id'] as String),
                  child: Text(
                    m['name'] as String,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                text(
                  'Piano: ${p['rows'][m['id']]['external']} · Manca: ${display(p['rows'][m['id']]['missing'])} · Senza fonte: ${display(p['rows'][m['id']]['uncovered'])}',
                  color: muted,
                ),
                QuantityControls(m['id'] as String),
                Provenance('inventory.${m['id']}'),
              ],
            ),
          ),
      ],
    );
  }
}
