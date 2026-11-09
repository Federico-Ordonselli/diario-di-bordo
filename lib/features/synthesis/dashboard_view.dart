import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../application/profile_providers.dart';
import '../../ui/common.dart';
import '../../ui/widgets.dart';
import 'material_widgets.dart';

class DashboardView extends ConsumerWidget {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider).profile;
    final engine = ref.watch(engineProvider);
    final catalog = engine.catalog;
    final p = engine.plan(state);
    final ready = catalog.recipes
        .where(
          (r) =>
              state.everCrafted[r['id']] != true &&
              engine.recipeStatus(state, r)['ready'] == true,
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          children: [
            stats(
              'Sintesi completate',
              '${engine.distinct(state)} / 33',
              'Ricette diverse, non creazioni totali',
            ),
            stats(
              'Pronte adesso',
              '${ready.length}',
              'Scorte confermate e gruppo sbloccato',
            ),
            stats(
              'Quantità sconosciute',
              '${state.inventory.values.where((v) => v == null).length}',
              'Conferma le scorte in Inventario',
            ),
          ],
        ),
        heading('Il prossimo passo'),
        if (ready.isEmpty)
          text(
            'Raccogli i materiali mancanti o verifica le quantità sconosciute.',
          ),
        for (final r in ready)
          Panel(
            child: ListTile(
              title: Text(r['name'] as String),
              subtitle: Text('Gruppo ${r['group']}'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () =>
                  context.go(Routes.synthesis(SynthesisSection.recipes)),
            ),
          ),
        heading('Da recuperare'),
        for (final m in catalog.materials.where(
          (m) => p['rows'][m['id']]['missing'] != 0,
        ))
          ListTile(
            title: Text(m['name'] as String),
            subtitle: Text('Mancano ${display(p['rows'][m['id']]['missing'])}'),
            trailing: const Icon(Icons.travel_explore),
            onTap: () => showMaterialDialog(context, m['id'] as String),
          ),
        heading('Gruppi del laboratorio'),
        Wrap(
          spacing: 8,
          children: [
            for (var g = 1; g <= 6; g++)
              Chip(
                avatar: Icon(
                  engine.unlocked(state, g)
                      ? Icons.lock_open
                      : Icons.lock_outline,
                  size: 18,
                ),
                label: Text('Gruppo $g'),
              ),
          ],
        ),
        text(
          'Gruppi II–V: 3, 9, 15 e 21 ricette dei gruppi precedenti; VI: tutte le prime 30.',
          color: muted,
        ),
        FilledButton(
          onPressed: () =>
              context.go(Routes.synthesis(SynthesisSection.planning)),
          child: const Text('Apri piano materiali'),
        ),
      ],
    );
  }
}
