import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';
import '../../application/profile_providers.dart';
import '../../domain/catalog.dart';
import '../../ui/common.dart';
import '../../ui/widgets.dart';

/// Guide testuali; la guida scelta sta nell'URL (`?id=`).
class GuidesPage extends ConsumerStatefulWidget {
  const GuidesPage({super.key, this.guide});
  final String? guide;
  @override
  ConsumerState<GuidesPage> createState() => _GuidesPageState();
}

class _GuidesPageState extends ConsumerState<GuidesPage> {
  String search = '';

  @override
  void didUpdateWidget(GuidesPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.guide != widget.guide) search = '';
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    final selected = catalog.guides.firstWhere(
      (g) => g['id'] == (widget.guide ?? 'materials'),
      orElse: () => catalog.guides.first,
    );
    return PageBody(
      title: 'Guide',
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final g in catalog.guides)
              ChoiceChip(
                label: Text(g['label'] as String),
                selected: g['id'] == selected['id'],
                onSelected: (_) => context.go(Routes.guide(g['id'] as String)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SearchField(
          // Una guida nuova riparte con la ricerca vuota.
          key: ValueKey(selected['id']),
          hint: 'Cerca materiale, boss o consiglio…',
          onChanged: (v) => setState(() => search = v),
        ),
        const SizedBox(height: 16),
        for (final section in (selected['sections'] as List).cast<Json>().where(
          (s) => (s['text'] as String).toLowerCase().contains(search),
        ))
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  section['text'] as String,
                  style: const TextStyle(height: 1.6),
                ),
                LinkButtons(section['links'] as List),
                text(
                  'Excel · ${selected['sheet']} · riga ${section['row']}',
                  color: muted,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
