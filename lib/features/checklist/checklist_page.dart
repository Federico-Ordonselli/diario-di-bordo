import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../application/profile_providers.dart';
import '../../domain/catalog.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';

/// Checklist del 100%. La categoria sta nell'URL (`?categoria=`), così il
/// diario e i link delle guide possono aprirla già filtrata; gli altri
/// filtri sono stato locale della pagina.
class ChecklistPage extends ConsumerStatefulWidget {
  const ChecklistPage({super.key, this.category = 'all'});
  final String category;
  @override
  ConsumerState<ChecklistPage> createState() => _ChecklistPageState();
}

class _ChecklistPageState extends ConsumerState<ChecklistPage> {
  String search = '', status = 'all', world = '', group = '';
  int limit = 40;

  @override
  void didUpdateWidget(ChecklistPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Mondi e gruppi dipendono dalla categoria.
    if (oldWidget.category != widget.category) {
      world = '';
      group = '';
      limit = 40;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider).profile;
    final catalog = ref.watch(catalogProvider);
    final category = widget.category;
    final pool = catalog.items
        .where((i) => category == 'all' || i['categoryId'] == category)
        .toList();
    final worlds = pool
        .map((i) => i['world'] as String)
        .where((w) => w.isNotEmpty)
        .toSet();
    final groups = pool
        .map((i) => i['group'] as String)
        .where((g) => g.isNotEmpty)
        .toSet();
    final visible = pool
        .where(
          (i) =>
              (status == 'all' || catalog.status(state, i) == status) &&
              (world.isEmpty || i['world'] == world) &&
              (group.isEmpty || i['group'] == group) &&
              '${i['title']} ${i['categoryLabel']} ${i['group']} ${(i['fields'] as Json).values.join(' ')} ${(i['comments'] as List).join(' ')}'
                  .toLowerCase()
                  .contains(search),
        )
        .toList();
    final selected = catalog.categories.where((c) => c['id'] == category);
    return PageBody(
      title: 'Checklist',
      children: [
        SearchField(
          hint: 'Cerca nome, requisito, luogo o ricompensa…',
          onChanged: (v) => setState(() {
            search = v;
            limit = 40;
          }),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            choice('Categoria', category, {
              'all': 'Tutte le categorie',
              for (final c in catalog.categories)
                c['id'] as String: c['label'] as String,
            }, (v) => context.go(Routes.checklist(v))),
            choice(
              'Stato',
              status,
              {
                'all': 'Tutti gli stati',
                'todo': 'Da completare',
                'done': 'Completati',
                'unknown': 'Da verificare',
              },
              (v) => setState(() {
                status = v;
                limit = 40;
              }),
            ),
            if (worlds.isNotEmpty)
              choice(
                'Mondo',
                world,
                {'': 'Tutti i mondi', for (final w in worlds) w: w},
                (v) => setState(() {
                  world = v;
                  limit = 40;
                }),
              ),
            if (groups.length > 1)
              choice(
                'Gruppo',
                group,
                {'': 'Tutti i gruppi', for (final g in groups) g: g},
                (v) => setState(() {
                  group = v;
                  limit = 40;
                }),
              ),
          ],
        ),
        const SizedBox(height: 16),
        text('${visible.length} voci trovate'),
        if (category == 'synthesis')
          text(
            'Le spunte correggono lo storico senza consumare materiali. Per creare usa Ricette.',
            color: gold,
          ),
        if (selected.isNotEmpty)
          for (final note
              in (selected.first['notes'] as List? ?? []).cast<Json>())
            Panel(
              child: ExpansionTile(
                title: const Text('Nota della guida'),
                children: [
                  text(note['text'] as String),
                  LinkButtons(note['links'] as List),
                ],
              ),
            ),
        for (final item in visible.take(limit)) ChecklistItem(item),
        if (visible.isEmpty) text('Nessuna voce corrisponde ai filtri.'),
        loadMore(visible.length, limit, () => setState(() => limit += 40)),
      ],
    );
  }
}

class ChecklistItem extends ConsumerWidget {
  const ChecklistItem(this.item, {super.key});
  final Json item;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider).profile;
    final engine = ref.watch(engineProvider);
    final catalog = engine.catalog;
    final id = item['id'] as String;
    final done = catalog.completed(state, item),
        itemStatus = catalog.status(state, item);
    final categoryData = catalog.categories.firstWhere(
      (c) => c['id'] == item['categoryId'],
    );
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: done,
            title: Text(item['title'] as String),
            subtitle: Text(
              '${item['categoryLabel']} · ${item['world']} ${item['group']}',
              style: const TextStyle(color: muted),
            ),
            onChanged: (v) => ref.commit((s) => engine.completion(s, id, v)),
          ),
          if (item['recipeId'] == null)
            choice(
              'Stato',
              itemStatus,
              {
                'done': 'Completato',
                'todo': 'Da completare',
                'unknown': 'Da verificare',
              },
              (v) => ref.commit(
                (s) => engine.completion(
                  s,
                  id,
                  v == 'unknown' ? null : v == 'done',
                ),
              ),
            ),
          ExpansionTile(
            tilePadding: EdgeInsets.zero,
            title: const Text('Requisiti, ricompense e fonti'),
            children: [
              for (final column
                  in (categoryData['columns'] as List).cast<Json>())
                if ('${item['fields'][column['key']] ?? ''}'.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: text(
                      '${column['label']}: ${item['fields'][column['key']]}',
                    ),
                  ),
              for (final comment in item['comments'] as List)
                text(comment as String, color: gold),
              LinkButtons(item['links'] as List),
              text(
                'Checklist di origine · ${categoryData['sheet']} · riga ${item['row']}',
                color: muted,
              ),
              Provenance('completion.$id'),
            ],
          ),
        ],
      ),
    );
  }
}
