import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../application/profile_providers.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';
import 'material_widgets.dart';

/// Materiali in deficit e dove farmarli. Con [session] mostra i contatori
/// della sessione e i pulsanti "Raccolto" al posto delle quantità.
class FarmingView extends ConsumerStatefulWidget {
  const FarmingView({super.key, required this.session});
  final bool session;
  @override
  ConsumerState<FarmingView> createState() => _FarmingViewState();
}

class _FarmingViewState extends ConsumerState<FarmingView> {
  String search = '', world = '';
  bool showSufficient = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider).profile;
    final engine = ref.watch(engineProvider);
    final catalog = engine.catalog;
    final p = engine.plan(state);
    final visible = catalog.farming
        .where(
          (f) =>
              (showSufficient || p['rows'][f['material']]['missing'] != 0) &&
              (world.isEmpty || f['world'] == world) &&
              '${catalog.materialsById[f['material']]!['name']} ${f['enemy']} ${f['world']} ${f['area']}'
                  .toLowerCase()
                  .contains(search),
        )
        .toList();
    final worlds =
        catalog.farming.map((f) => f['world'] as String).toSet().toList()
          ..sort();
    final ids = visible.map((f) => f['material'] as String).toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          hint: 'Cerca materiale, nemico o luogo…',
          onChanged: (v) => setState(() => search = v),
        ),
        const SizedBox(height: 16),
        choice('Mondo', world, {
          '': 'Tutti i mondi',
          for (final w in worlds) w: w,
        }, (v) => setState(() => world = v)),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Mostra anche i materiali sufficienti'),
          value: showSufficient,
          onChanged: (v) => setState(() => showSufficient = v),
        ),
        if (widget.session)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading('Raccolte di questa sessione'),
                text(
                  state.session.isEmpty
                      ? 'Nessuna raccolta registrata.'
                      : state.session.entries
                            .map(
                              (e) =>
                                  '${catalog.materialsById[e.key]!['name']} +${e.value}',
                            )
                            .join(' · '),
                ),
                OutlinedButton(
                  onPressed: () => ref.commit(
                    (s) => engine.transact(
                      s,
                      'Nuova sessione',
                      (n) => n['session'] = <String, dynamic>{},
                    ),
                  ),
                  child: const Text('Azzera contatori sessione'),
                ),
                text(
                  'Per Dark Matter e Orichalcum usa Collezionabili se vuoi registrare anche la fonte e ridurre la previsione.',
                  color: muted,
                ),
              ],
            ),
          ),
        for (final id in ids)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading(catalog.materialsById[id]!['name'] as String),
                text(
                  'Mancano: ${display(p['rows'][id]['missing'])}',
                  color: gold,
                ),
                if (widget.session)
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final delta in [1, 5])
                        FilledButton(
                          onPressed: state.inventory[id] == null
                              ? null
                              : () => ref.commit(
                                  (s) => engine.sessionCollect(s, id, delta),
                                ),
                          child: Text('Raccolto +$delta'),
                        ),
                    ],
                  )
                else
                  QuantityControls(id),
                for (final source in visible.where((f) => f['material'] == id))
                  FarmSource(source),
              ],
            ),
          ),
        if (ids.isEmpty) text('Nessun deficit per i filtri selezionati.'),
        OutlinedButton.icon(
          onPressed: () => context.go(Routes.settings),
          icon: const Icon(Icons.tune),
          label: const Text('Preparazione del salvataggio'),
        ),
      ],
    );
  }
}
