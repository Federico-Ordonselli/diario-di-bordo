import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/profile_providers.dart';
import '../../domain/catalog.dart';
import '../../domain/profile.dart';
import '../../domain/save_adapter.dart';
import '../../storage/game_save_locator.dart';
import '../../ui/common.dart';
import '../../ui/ref_actions.dart';
import '../../ui/widgets.dart';
import 'save_reference.dart';

/// Import del save del gioco (PNG o snapshot JSON) con anteprima e conflitti,
/// più la consultazione dello snapshot attivo.
class SavePage extends ConsumerStatefulWidget {
  const SavePage({super.key});
  @override
  ConsumerState<SavePage> createState() => _SavePageState();
}

class _SavePageState extends ConsumerState<SavePage> {
  Json? saveRaw;
  String? saveOrigin;
  bool readingSave = false;
  int slot = 1;
  bool staged = false, showUnchanged = false;
  Json decisions = {};

  SaveAdapter get adapter => SaveAdapter(ref.read(engineProvider));

  @override
  void initState() {
    super.initState();
    ref.listenManual(saveReferenceProvider, (_, next) {
      if (next case AsyncError(:final error)) ref.report(error);
    });
  }

  /// Legge il PNG del gioco (trovato da solo o scelto) e apre l'anteprima.
  /// La decodifica gira in un isolate per non bloccare l'interfaccia.
  Future<void> readGameSave({bool choose = false}) async {
    final reference = ref.read(saveReferenceProvider).value;
    if (reference == null || readingSave) return;
    setState(() => readingSave = true);
    try {
      final found = GameSaveLocator.find();
      final String path;
      if (choose) {
        final picked = await openFile(
          initialDirectory: found?.parent.path,
          acceptedTypeGroups: [
            const XTypeGroup(
              label: 'Save PNG',
              extensions: ['png'],
              mimeTypes: ['image/png'],
            ),
          ],
        );
        if (picked == null) return;
        path = picked.path;
      } else if (found == null) {
        throw const FormatException(
          'Save del gioco non trovato. Usa “Apri save PNG” oppure imposta KH_SAVE_PATH.',
        );
      } else {
        path = found.path;
      }
      final modified = File(path).lastModifiedSync();
      final name = path.split(Platform.pathSeparator).last;
      final decoded = await decodeSaveInIsolate(path, reference, name);
      adapter.validate(decoded);
      if (!mounted) return;
      setState(() {
        saveRaw = decoded;
        slot = decoded['recommended_slot'] as int;
        staged = true;
        decisions = {};
        saveOrigin =
            '$path · file modificato ${modified.toString().substring(0, 19)}';
      });
    } catch (e) {
      ref.report(e);
    } finally {
      if (mounted) setState(() => readingSave = false);
    }
  }

  Future<void> openSnapshot() async {
    try {
      final selected = await pickJson();
      if (selected == null) return;
      adapter.validate(selected);
      setState(() {
        saveRaw = selected;
        saveOrigin = null;
        slot = (selected['slots'] as List).first['slot_number'] as int;
        staged = false;
        decisions = {};
      });
    } catch (e) {
      ref.report(e);
    }
  }

  Future<void> apply(Json raw) async {
    final current = ref.read(profileProvider).profile;
    if (!await ref.exportJson(current, 'kh1fm-prima-importazione')) return;
    if (!identical(current, ref.read(profileProvider).profile)) {
      ref.report('Il profilo è cambiato: ricontrolla l’anteprima.');
      return;
    }
    if (await ref.commit(
          (s) => adapter.apply(s, raw, slot, decisions),
          importing: true,
        ) &&
        mounted) {
      setState(() => staged = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileProvider).profile;
    final ready = ref.watch(saveReferenceProvider).hasValue && !readingSave;
    final raw = saveRaw;
    final preview = raw == null || !staged
        ? null
        : adapter.preview(state, raw, slot, decisions);
    final active = state.activeSave;
    return PageBody(
      title: 'Save',
      children: [
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Importa il salvataggio'),
              text(
                'Legge il save del gioco e confronta un solo slot. Nessun dato viene importato senza conferma.',
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: ready ? () => readGameSave() : null,
                    icon: readingSave
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: const Text('Leggi il save dal gioco'),
                  ),
                  OutlinedButton.icon(
                    onPressed: ready ? () => readGameSave(choose: true) : null,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Apri save PNG'),
                  ),
                  OutlinedButton.icon(
                    onPressed: openSnapshot,
                    icon: const Icon(Icons.file_open),
                    label: const Text('Apri snapshot JSON'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (raw != null) ...[
                if (saveOrigin != null) text(saveOrigin!, color: muted),
                if (raw['source']['sha256'] == active?['source']?['sha256'])
                  text('Questo save è già stato importato.', color: gold),
                choice(
                  'Slot del salvataggio',
                  '$slot',
                  {
                    for (final s in (raw['slots'] as List).cast<Json>())
                      '${s['slot_number']}':
                          'Slot ${s['slot_number']} · livello ${display(s['level'])}',
                  },
                  (v) => setState(() {
                    slot = int.parse(v);
                    staged = false;
                    decisions = {};
                  }),
                ),
                const SizedBox(height: 12),
                for (final s in (raw['slots'] as List).cast<Json>())
                  text(
                    'Slot ${s['slot_number']} · ${s['location']?['world']} / ${s['location']?['save_label']} · ${s['modified_at']}',
                    color: muted,
                  ),
                text(
                  'Origine: ${raw['source']['filename']} · analisi ${raw['generated_at']}',
                  color: muted,
                ),
                FilledButton(
                  onPressed: () => setState(() => staged = true),
                  child: Text('Confronta slot $slot con l’app'),
                ),
              ],
            ],
          ),
        ),
        if (preview != null) _preview(raw!, preview),
        if (active == null)
          text('Nessuno snapshot importato.')
        else ...[
          _ActiveSnapshot(active),
          const _Counters(),
          const SizedBox(height: 16),
          _ChestList(active),
          heading('Snapshot archiviati'),
          for (final s in state.saveSnapshots.values)
            text(
              'Slot ${s.slotNumber} · ${s.savedAt} · ${s['location']['world']} / ${s['location']['save_label']}',
            ),
        ],
      ],
    );
  }

  Widget _preview(Json raw, Json preview) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Anteprima · slot $slot'),
        text(
          '${preview['changes']} valori cambieranno · ${preview['conflicts']} conflitti.',
        ),
        text(
          'Le modifiche manuali successive al salvataggio restano prioritarie; quelle precedenti cedono al save. Gli zeri sono confermati; null indica “Da verificare”. Inventari diversi non vengono sommati.',
          color: muted,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Mostra anche i valori invariati'),
          value: showUnchanged,
          onChanged: (v) => setState(() => showUnchanged = v),
        ),
        for (final row in (preview['rows'] as List).cast<Json>().where(
          (r) => showUnchanged || r['changed'] == true || r['conflict'] == true,
        ))
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text(row['label'] as String, color: gold),
                text(
                  'App: ${display(row['before'])} · Save: ${display(row['value'])} → Dopo: ${display(row['after'])}',
                ),
                text('${row['path']} · ${row['confidence']}', color: muted),
                if (row['conflict'] == true)
                  choice(
                    'Conflitto',
                    row['kept'] == true ? 'keep' : 'save',
                    {'keep': 'Mantieni modifica app', 'save': 'Usa save'},
                    (v) => setState(() => decisions[row['key'] as String] = v),
                  ),
              ],
            ),
          ),
        Wrap(
          spacing: 12,
          children: [
            FilledButton(
              onPressed: () => apply(raw),
              child: Text('Crea backup e importa slot $slot'),
            ),
            TextButton(
              onPressed: () => setState(() => staged = false),
              child: const Text('Chiudi anteprima'),
            ),
          ],
        ),
      ],
    ),
  );
}

class _ActiveSnapshot extends ConsumerWidget {
  const _ActiveSnapshot(this.active);
  final SaveSnapshot active;
  @override
  Widget build(BuildContext context, WidgetRef ref) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Snapshot attivo · slot ${active.slotNumber}'),
        text(
          '${active['location']['world']} / ${active['location']['save_label']} · livello ${active['level']} · ${active['difficulty']}',
        ),
        text(
          'Salvato: ${active.savedAt}\nAnalizzato: ${active['generatedAt']}\nImportato: ${active['importedAt']}',
        ),
        SelectableText(
          'Fonte: ${active.sourceFilename}\nSHA-256: ${active['source']['sha256']}',
        ),
        text(
          'Il luogo indica l’ultimo salvataggio, non il punto più avanzato della storia. Il possesso attuale non ricostruisce lo storico delle sintesi.',
          color: muted,
        ),
        ExpansionTile(
          title: const Text('Interpretazione e limiti'),
          children: [
            for (final e in (active['interpretation'] as Json).entries)
              text('${e.key}: ${e.value}'),
            TextButton(
              onPressed: () => ref.exportDocument('KH1FM_Report_Save.md'),
              child: const Text('Esporta report originale'),
            ),
          ],
        ),
        ExpansionTile(
          title: const Text('Statistiche, equipaggiamento e abilità'),
          children: [
            for (final character in (active['characters'] as List).cast<Json>())
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  heading(character['name'] as String),
                  text(
                    'Livello ${display(character['level'])} · MP base ${display(character['mp_base_max'])} · arma ${character['weapon']?['name'] ?? 'Da verificare'}',
                  ),
                  text(
                    'Accessori: ${((character['accessories'] ?? []) as List).map((a) => a['name']).join(', ')}',
                  ),
                  text(
                    'Oggetti portati: ${((character['carried_items'] ?? []) as List).map((a) => a['name']).join(', ')}',
                  ),
                  text(
                    'Abilità: ${((character['abilities'] ?? []) as List).map((a) => '${a['name']}${a['equipped'] == true ? ' (equipaggiata)' : ''}').join(', ')}',
                  ),
                ],
              ),
            text(
              'I massimi base non vengono copiati nei MP del farming: l’equipaggiamento può modificarli.',
              color: muted,
            ),
            for (final e in (active['extraItems'] as Json).entries)
              text('${e.key}: ${display(e.value)}'),
          ],
        ),
        ExpansionTile(
          title: const Text('Sezioni non decodificate'),
          children: [
            text('Le checklist non mappate sono conservate.'),
            for (final key in (active['unknownSections'] as Json).keys)
              text('$key: da verificare, nessuna spunta azzerata.'),
          ],
        ),
      ],
    ),
  );
}

const _counters = {
  'trinity.Blue': 17,
  'trinity.Red': 6,
  'trinity.Green': 9,
  'trinity.Yellow': 4,
  'trinity.White': 10,
  'postcards': 10,
};

class _Counters extends ConsumerWidget {
  const _Counters();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final values = ref.watch(profileProvider).profile.saveValues;
    final adapter = SaveAdapter(ref.watch(engineProvider));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Trinità e cartoline · contatori del save'),
        text(
          'I contatori non identificano le singole voci dell’Excel.',
          color: muted,
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final e in _counters.entries)
              SizedBox(
                width: 250,
                child: Column(
                  children: [
                    NumberEditor(
                      key: ValueKey('save-${e.key}'),
                      label: '${e.key} / ${e.value}',
                      value: values[e.key] as int?,
                      max: e.value,
                      onSave: (v) =>
                          ref.commit((s) => adapter.edit(s, e.key, v)),
                    ),
                    Provenance('save.${e.key}'),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Casse mappate dello snapshot attivo, con filtri locali.
class _ChestList extends ConsumerStatefulWidget {
  const _ChestList(this.active);
  final SaveSnapshot active;
  @override
  ConsumerState<_ChestList> createState() => _ChestListState();
}

class _ChestListState extends ConsumerState<_ChestList> {
  String search = '', world = '', status = 'all';
  int limit = 40;

  @override
  Widget build(BuildContext context) {
    final values = ref.watch(profileProvider).profile.saveValues;
    final adapter = SaveAdapter(ref.watch(engineProvider));
    final all = ((widget.active['chests'] ?? []) as List).cast<Json>();
    final chests = all
        .where(
          (c) =>
              (world.isEmpty || c['world'] == world) &&
              (c['name'] as String).toLowerCase().contains(search) &&
              (status == 'all' ||
                  (status == 'unknown'
                      ? values['chest.${c['code']}'] == null
                      : values['chest.${c['code']}'] == (status == 'done'))),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heading('Casse mappate'),
        text(
          'Mappatura parziale: ${widget.active['chestCoverage']['mappedTotal'] ?? '?'} casse. Restano separate dai 268 tesori dell’Excel.',
          color: muted,
        ),
        SearchField(
          hint: 'Cerca cassa…',
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
            choice(
              'Mondo',
              world,
              {
                '': 'Tutti i mondi',
                for (final c in all) c['world'] as String: c['world'] as String,
              },
              (v) => setState(() {
                world = v;
                limit = 40;
              }),
            ),
            choice(
              'Stato cassa',
              status,
              {
                'all': 'Tutti gli stati',
                'done': 'Aperte',
                'todo': 'Non aperte',
                'unknown': 'Da verificare',
              },
              (v) => setState(() {
                status = v;
                limit = 40;
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        text('${chests.length} casse trovate'),
        for (final c in chests.take(limit))
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                heading(c['name'] as String),
                text('${c['world']} · ID ${c['code']}'),
                choice(
                  'Stato',
                  values['chest.${c['code']}'] == null
                      ? 'unknown'
                      : '${values['chest.${c['code']}']}',
                  {
                    'true': 'Aperta',
                    'false': 'Non aperta',
                    'unknown': 'Da verificare',
                  },
                  (v) => ref.commit(
                    (s) => adapter.edit(
                      s,
                      'chest.${c['code']}',
                      v == 'unknown' ? null : v == 'true',
                    ),
                  ),
                ),
                Provenance('save.chest.${c['code']}'),
              ],
            ),
          ),
        loadMore(chests.length, limit, () => setState(() => limit += 40)),
      ],
    );
  }
}
