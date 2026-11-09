import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_providers.dart';
import '../../domain/catalog.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';

/// −/+/campo/+5/+10/"sconosciuta" per la scorta di un materiale.
class QuantityControls extends ConsumerWidget {
  const QuantityControls(this.id, {super.key});
  final String id;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(profileProvider).profile.inventory[id];
    final engine = ref.watch(engineProvider);
    final name = engine.catalog.materialsById[id]!['name'];
    Future<void> Function()? step(int delta) => value == null
        ? null
        : () => ref.commit((s) => engine.increment(s, id, delta));
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        RepeatButton(
          icon: Icons.remove,
          label: 'Diminuisci $name',
          onPressed: step(-1),
        ),
        SizedBox(
          width: 118,
          child: NumberEditor(
            key: ValueKey('inventory-$id'),
            label: 'Hai',
            value: value,
            stepping: true,
            onSave: (v) => ref.commit((s) => engine.quantity(s, id, v)),
          ),
        ),
        RepeatButton(
          icon: Icons.add,
          label: 'Aumenta $name',
          onPressed: step(1),
        ),
        for (final delta in [5, 10])
          OutlinedButton(onPressed: step(delta), child: Text('+$delta')),
        IconButton(
          tooltip: 'Quantità sconosciuta',
          onPressed: () => ref.commit((s) => engine.quantity(s, id, null)),
          icon: const Icon(Icons.help_outline),
        ),
      ],
    );
  }
}

/// Dove e come si ottiene un materiale (nemico, probabilità, metodo).
class FarmSource extends ConsumerWidget {
  const FarmSource(this.source, {super.key});
  final Json source;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lucky = ref.watch(profileProvider).profile.settings.lucky;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('${source['enemy']} · ${source['world']}'),
          text('${source['area']}', color: muted),
          text('Probabilità base: ${source['rate']}'),
          text('Metodo: ${source['method']}'),
          text('Condizioni: ${source['conditions']}'),
          text('Reset: ${source['reset']}'),
          if (source['enemy'] != 'Bambi')
            text(
              lucky == null
                  ? 'Lucky Strike: abilità attive da verificare.'
                  : 'Lucky Strike: $lucky attivi · ×${[1, 1.5, 2, 2.5][lucky]} sulle probabilità base, massimo 100%. Le garanzie restano condizionate.',
              color: gold,
            ),
          Wrap(
            spacing: 8,
            children: [
              TextButton(
                onPressed: () => ref.openExternal(source['url'] as String),
                child: const Text('Guida dettagliata ↗'),
              ),
              TextButton(
                onPressed: () =>
                    ref.exportDocument('KH1_Final_Mix_Sintesi_Tracking.pdf'),
                child: Text('Dossier · pagina ${source['page']}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Scheda di un materiale: scorta modificabile e tutte le fonti di farming.
Future<void> showMaterialDialog(BuildContext context, String id) =>
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
          child: Consumer(
            builder: (context, ref, _) {
              final catalog = ref.watch(catalogProvider);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: heading(
                            catalog.materialsById[id]!['name'] as String,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    QuantityControls(id),
                    Provenance('inventory.$id'),
                    for (final f in catalog.farming.where(
                      (f) => f['material'] == id,
                    ))
                      FarmSource(f),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
