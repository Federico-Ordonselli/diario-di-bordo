import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app/router.dart';
import '../application/profile_providers.dart';
import '../domain/catalog.dart';
import 'ref_actions.dart';
import 'widgets.dart';

const wideBreakpoint = 1000.0;
bool isWide(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= wideBreakpoint;

Widget text(String value, {Color? color}) => Padding(
  padding: const EdgeInsets.only(bottom: 10),
  child: Text(value, style: TextStyle(color: color, height: 1.5)),
);

Widget heading(String value) => Padding(
  padding: const EdgeInsets.only(bottom: 14, top: 8),
  child: Text(
    value,
    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
  ),
);

Widget stats(String title, String value, String detail) => SizedBox(
  width: 240,
  child: Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text(title, color: muted),
        Text(value, style: const TextStyle(fontSize: 36, color: gold)),
        text(detail),
      ],
    ),
  ),
);

/// Campo di ricerca: restituisce il testo già normalizzato. Per svuotarlo
/// dall'esterno basta cambiargli `key`.
class SearchField extends StatelessWidget {
  const SearchField({super.key, required this.hint, required this.onChanged});
  final String hint;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      hintText: hint,
    ),
    onChanged: (v) => onChanged(v.toLowerCase().trim()),
  );
}

Widget loadMore(int count, int limit, VoidCallback more) => count > limit
    ? OutlinedButton(
        onPressed: more,
        child: Text('Mostra altre voci (${count - limit} rimanenti)'),
      )
    : const SizedBox.shrink();

/// Link delle guide: esterni (`url`) oppure interni verso una categoria
/// della checklist o una guida.
class LinkButtons extends ConsumerWidget {
  const LinkButtons(this.entries, {super.key});
  final List<dynamic> entries;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: [
      for (final link in entries.cast<Json>())
        TextButton(
          onPressed: () {
            if (link['url'] != null) {
              ref.openExternal(link['url'] as String);
            } else if (link['category'] != null) {
              context.go(Routes.checklist(link['category'] as String));
            } else if (link['guide'] != null) {
              context.go(Routes.guide(link['guide'] as String));
            }
          },
          child: Text(
            '${link['label'] ?? 'Apri guida'} ${link['url'] != null ? '↗' : '→'}',
          ),
        ),
    ],
  );
}

/// Da dove viene un valore: snapshot del save attivo o override manuale.
class Provenance extends ConsumerWidget {
  const Provenance(this.target, {super.key});

  /// Chiave del valore, es. `inventory.potion` o `save.chest.12`.
  final String target;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider).profile;
    final snapshot = state.activeSave;
    final observation = (snapshot?['observations'] as Map?)?[target];
    if (snapshot == null || observation == null) {
      return const SizedBox.shrink();
    }
    final manual =
        state.manualOverrides[snapshot.scope]?.containsKey(target) == true ||
        state.manualOverrides['app']?.containsKey(target) == true;
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        manual
            ? 'Override manuale · confronta con save'
            : 'Dal save · provenienza',
        style: const TextStyle(fontSize: 13, color: muted),
      ),
      children: [
        text(
          '${snapshot.sourceFilename} · slot ${snapshot.slotNumber} · ${snapshot.savedAt}',
        ),
        text(
          'Valore: ${display(observation['value'])} · confidenza: ${observation['confidence']}',
        ),
        text('${observation['path']}'),
      ],
    );
  }
}

/// Struttura di ogni pagina: AppBar su telefono, intestazione con stato
/// dell'archivio e contenuto scorrevole. Durante un salvataggio il contenuto
/// non accetta input (la navigazione sì).
class PageBody extends ConsumerWidget {
  const PageBody({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(profileProvider.select((v) => v.busy));
    final wide = isWide(context);
    return Scaffold(
      appBar: wide ? null : AppBar(title: const Text('Diario di Bordo')),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: busy,
          child: ListView(
            padding: EdgeInsets.all(wide ? 32 : 16),
            children: [
              PageHeader(title: title),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class PageHeader extends ConsumerWidget {
  const PageHeader({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(profileProvider);
    final engine = ref.watch(engineProvider);
    final state = view.profile;
    final overall = engine.catalog.summary(state);
    final wide = isWide(context);
    final active = state.activeSave;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Su telefono il "indietro" è nell'AppBar.
            if (wide && Navigator.of(context).canPop()) const BackButton(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  text('Il tuo viaggio verso il 100%', color: muted),
                ],
              ),
            ),
            if (wide)
              Text(
                '${overall['done']} / ${overall['total']}',
                style: const TextStyle(fontSize: 24, color: gold),
              ),
          ],
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(
              view.busy
                  ? 'Salvataggio…'
                  : view.blocked
                  ? 'Archivio da recuperare'
                  : '● Salvataggio automatico',
              style: const TextStyle(color: muted),
            ),
            OutlinedButton.icon(
              onPressed: view.busy || view.blocked || state.transactions.isEmpty
                  ? null
                  : () => ref.commit(engine.undo),
              icon: const Icon(Icons.undo, size: 18),
              label: const Text('Annulla ultima operazione'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        text(
          '${state.settings.level == null ? 'Profilo locale' : 'Sora · livello ${state.settings.level}'}'
          '${active == null ? '' : ' · ${active['location']['save_label'] ?? 'Luogo da verificare'}'}'
          ' · ${engine.distinct(state)}/33 sintesi',
          color: gold,
        ),
        const SizedBox(height: 8),
        if (view.error != null)
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(view.error!, color: Colors.orangeAccent),
                Wrap(
                  spacing: 12,
                  children: [
                    TextButton(
                      onPressed: ref.read(profileProvider.notifier).initialize,
                      child: const Text('Ricarica archivio'),
                    ),
                    TextButton(
                      onPressed: () => context.go(Routes.backup),
                      child: const Text('Apri Backup'),
                    ),
                    if (!view.blocked)
                      TextButton(
                        onPressed: ref
                            .read(profileProvider.notifier)
                            .dismissError,
                        child: const Text('Chiudi'),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
