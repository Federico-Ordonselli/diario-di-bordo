import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../application/profile_providers.dart';
import '../../domain/catalog.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';

const _families = [
  'Diario di Grillo',
  'Raccolta',
  'Sfide',
  'Equipaggiamento',
  'Gummiship',
  'Trofei',
];

class DiaryPage extends ConsumerWidget {
  const DiaryPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider).profile;
    final catalog = ref.watch(catalogProvider);
    final count = catalog.summary(state);
    return PageBody(
      title: 'Diario 100%',
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text('IL VIAGGIO VERSO IL 100%', color: gold),
              Text(
                '${count['percent']}%',
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                ),
              ),
              text(
                '${count['done']} voci completate · ${count['remaining']} ancora da completare',
              ),
              LinearProgressIndicator(
                value: (count['done'] as int) / (count['total'] as int),
                minHeight: 8,
              ),
              const SizedBox(height: 16),
              text(
                'La percentuale misura le 794 voci dell’Excel. Trofei e attività sono indipendenti; i dalmata si contano per gruppi di tre.',
                color: muted,
              ),
            ],
          ),
        ),
        heading('Il tuo percorso'),
        for (final family in _families)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(family, color: gold),
                for (final c in catalog.categories.where(
                  (c) => c['family'] == family,
                ))
                  _CategoryTile(c),
              ],
            ),
          ),
        if (state.appliedEvidence.contains(catalog.evidence['id']))
          Panel(
            child: ExpansionTile(
              title: const Text('Screenshot · 21 achievement confermati'),
              children: [
                for (final fact in catalog.evidence['facts'] as List)
                  text(fact as String),
              ],
            ),
          ),
        Panel(
          child: Wrap(
            spacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () => context.go(Routes.guide('tips')),
                icon: const Icon(Icons.menu_book),
                label: const Text('Guide e boss segreti'),
              ),
              OutlinedButton(
                onPressed: () =>
                    ref.exportDocument('KH1_Final_Mix_Sintesi_Tracking.pdf'),
                child: const Text('Esporta dossier PDF'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  const _CategoryTile(this.category);
  final Json category;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = category['id'] as String;
    final summary = ref
        .watch(catalogProvider)
        .summary(ref.watch(profileProvider).profile, id);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(category['label'] as String),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: LinearProgressIndicator(
          value: (summary['done'] as int) / (summary['total'] as int),
        ),
      ),
      trailing: Text('${summary['done']} / ${summary['total']} →'),
      onTap: () => context.go(Routes.checklist(id)),
    );
  }
}
