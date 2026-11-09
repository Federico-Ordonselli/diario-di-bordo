import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_providers.dart';
import '../../domain/profile.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';

const _statusLabels = {
  CollectionStatus.unknown: 'Da verificare',
  CollectionStatus.collected: 'Raccolto',
  CollectionStatus.notCollected: 'Non raccolto',
};

class CollectionsView extends ConsumerStatefulWidget {
  const CollectionsView({super.key});
  @override
  ConsumerState<CollectionsView> createState() => _CollectionsViewState();
}

class _CollectionsViewState extends ConsumerState<CollectionsView> {
  String search = '', status = 'all';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider).profile;
    final engine = ref.watch(engineProvider);
    final catalog = engine.catalog;
    final sources = catalog.collections
        .where(
          (c) =>
              '${c['world']} ${c['area']} ${c['material']} ${c['requirement']}'
                  .toLowerCase()
                  .contains(search) &&
              (status == 'all' ||
                  state.collection(c['id'] as String).wire == status),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(
          '“Già raccolto” corregge lo storico. “Raccolto adesso” aggiunge 1 alla scorta e riduce di 1 la ricompensa futura.',
          color: muted,
        ),
        SearchField(
          hint: 'Cerca fonte o mondo…',
          onChanged: (v) => setState(() => search = v),
        ),
        const SizedBox(height: 16),
        choice('Stato fonte', status, {
          'all': 'Tutte le fonti',
          'unknown': 'Da verificare',
          'collected': 'Raccolte',
          'not_collected': 'Non raccolte',
        }, (v) => setState(() => status = v)),
        const SizedBox(height: 16),
        for (final c in sources)
          Builder(
            builder: (context) {
              final id = c['id'] as String;
              final current = state.collection(id);
              Future<bool> mark(CollectionStatus s) =>
                  ref.commit((p) => engine.collect(p, id, status: s.wire));
              return Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading(
                      '${catalog.materialsById[c['material']]!['name']} · ${c['world']}',
                    ),
                    for (final e in c.entries.where(
                      (e) =>
                          !['id', 'material', 'world', 'url'].contains(e.key),
                    ))
                      text('${e.key}: ${e.value}'),
                    text('Stato: ${_statusLabels[current]}', color: gold),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed:
                              current == CollectionStatus.collected ||
                                  state.inventory[c['material']] == null
                              ? null
                              : () => ref.commit(
                                  (p) => engine.collect(p, id, now: true),
                                ),
                          child: const Text('Raccolto adesso'),
                        ),
                        OutlinedButton(
                          onPressed: () => mark(CollectionStatus.collected),
                          child: const Text('Già raccolto'),
                        ),
                        TextButton(
                          onPressed: () => mark(CollectionStatus.notCollected),
                          child: const Text('Non raccolto'),
                        ),
                        TextButton(
                          onPressed: () => mark(CollectionStatus.unknown),
                          child: const Text('Da verificare'),
                        ),
                      ],
                    ),
                    if (c['url'] != null)
                      TextButton(
                        onPressed: () => ref.openExternal(c['url'] as String),
                        child: const Text('Guida ↗'),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
