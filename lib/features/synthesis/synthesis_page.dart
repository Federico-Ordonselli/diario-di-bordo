import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../application/profile_providers.dart';
import '../../domain/profile.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import 'collections_view.dart';
import 'dashboard_view.dart';
import 'farming_view.dart';
import 'inventory_view.dart';
import 'planning_view.dart';
import 'recipes_view.dart';

/// Laboratorio di sintesi: schede in alto (`/sintesi/<sezione>`) e
/// selettore dell'obiettivo condiviso da tutte le sezioni.
class SynthesisPage extends StatelessWidget {
  const SynthesisPage({super.key, required this.section});
  final SynthesisSection section;
  @override
  Widget build(BuildContext context) => PageBody(
    title: section.label,
    children: [
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            for (final s in SynthesisSection.values)
              ChoiceChip(
                avatar: Icon(s.icon, size: 18),
                label: Text(s.label),
                selected: s == section,
                onSelected: (_) => context.go(Routes.synthesis(s)),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      const _PlanSelector(),
      // Chiave per sezione: Farming e Sessione condividono il widget ma non
      // i filtri.
      KeyedSubtree(
        key: ValueKey(section),
        child: switch (section) {
          SynthesisSection.dashboard => const DashboardView(),
          SynthesisSection.inventory => const InventoryView(),
          SynthesisSection.recipes => const RecipesView(),
          SynthesisSection.farming => const FarmingView(session: false),
          SynthesisSection.collections => const CollectionsView(),
          SynthesisSection.planning => const PlanningView(),
          SynthesisSection.session => const FarmingView(session: true),
        },
      ),
    ],
  );
}

const _modeLabels = {
  PlanMode.all: 'Tutta la sintesi',
  PlanMode.route15: 'Prime 15',
  PlanMode.selected: 'Selezionate',
};

class _PlanSelector extends ConsumerWidget {
  const _PlanSelector();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(profileProvider).profile.plan.mode;
    final engine = ref.watch(engineProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Wrap(
        spacing: 8,
        children: [
          for (final e in _modeLabels.entries)
            ChoiceChip(
              label: Text(e.value),
              selected: mode == e.key,
              onSelected: (_) => ref.commit(
                (s) => engine.transact(
                  s,
                  'Obiettivo: ${e.value}',
                  (n) => n.plan.mode = e.key,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
