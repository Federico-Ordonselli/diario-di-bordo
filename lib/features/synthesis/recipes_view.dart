import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_providers.dart';
import '../../domain/catalog.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';

class RecipesView extends ConsumerStatefulWidget {
  const RecipesView({super.key});
  @override
  ConsumerState<RecipesView> createState() => _RecipesViewState();
}

class _RecipesViewState extends ConsumerState<RecipesView> {
  String search = '', filter = 'all';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider).profile;
    final engine = ref.watch(engineProvider);
    final visible = engine.catalog.recipes.where((r) {
      final rs = engine.recipeStatus(state, r),
          done = state.everCrafted[r['id']] == true;
      return (r['name'] as String).toLowerCase().contains(search) &&
          (filter == 'all' ||
              filter == 'todo' && !done ||
              filter == 'done' && done ||
              filter == 'ready' && rs['ready'] == true);
    }).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchField(
          hint: 'Cerca ricetta…',
          onChanged: (v) => setState(() => search = v),
        ),
        const SizedBox(height: 12),
        choice('Stato', filter, {
          'all': 'Tutte le ricette',
          'todo': 'Da sintetizzare',
          'done': 'Già sintetizzate',
          'ready': 'Pronte adesso',
        }, (v) => setState(() => filter = v)),
        const SizedBox(height: 16),
        for (final r in visible) RecipeCard(r),
      ],
    );
  }
}

class RecipeCard extends ConsumerWidget {
  const RecipeCard(this.recipe, {super.key});
  final Json recipe;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider).profile;
    final engine = ref.watch(engineProvider);
    final id = recipe['id'] as String;
    final rs = engine.recipeStatus(state, recipe),
        done = state.everCrafted[id] == true;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('${recipe['name']} ${done ? '✓' : ''}'),
          text(
            'Gruppo ${recipe['group']} · ${rs['unlocked'] == true ? 'Sbloccato' : 'Bloccato'} · Creazioni: ${display(state.craftCount[id])}',
            color: muted,
          ),
          for (final e in (recipe['costs'] as Json).entries)
            text(
              '${engine.catalog.materialsById[e.key]!['name']} × ${e.value} · hai ${display(state.inventory[e.key])}',
            ),
          if (recipe['output'] != null)
            text('Produce 1 ${recipe['name']} nell’inventario.', color: gold),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: rs['ready'] == true
                    ? () => ref.commit((s) => engine.craft(s, id))
                    : null,
                icon: const Icon(Icons.science),
                label: const Text('Sintetizza adesso'),
              ),
              OutlinedButton(
                onPressed: done
                    ? null
                    : () => ref.commit((s) => engine.markCrafted(s, id)),
                child: const Text('Segna già sintetizzato'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
