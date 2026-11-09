import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/catalog.dart';
import '../domain/engine.dart';
import '../domain/save_adapter.dart';
import '../domain/save_decoder.dart';
import '../domain/validation.dart';
import '../storage/controller.dart';
import '../storage/game_save_locator.dart';
import 'widgets.dart';

const pages = [
  'Diario 100%',
  'Checklist',
  'Guide',
  'Save',
  'Dashboard',
  'Inventario',
  'Ricette',
  'Farming',
  'Collezionabili',
  'Piano',
  'Sessione',
  'Preparazione',
  'Backup',
];
const pageIcons = [
  Icons.auto_stories_outlined,
  Icons.checklist,
  Icons.menu_book,
  Icons.save_outlined,
  Icons.dashboard_outlined,
  Icons.inventory_2_outlined,
  Icons.science_outlined,
  Icons.travel_explore,
  Icons.diamond_outlined,
  Icons.route,
  Icons.sports_esports_outlined,
  Icons.tune,
  Icons.backup_outlined,
];

class DiaryApp extends StatelessWidget {
  const DiaryApp({super.key, required this.controller});
  final ProfileController controller;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Diario di Bordo',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: gold,
        brightness: Brightness.dark,
        primary: gold,
        surface: const Color(0xFF151E30),
      ),
      scaffoldBackgroundColor: const Color(0xFF0D1422),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
      cardTheme: const CardThemeData(color: Color(0xFF151E30), elevation: 0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D1422),
        foregroundColor: Colors.white,
      ),
    ),
    home: DiaryHome(controller: controller),
  );
}

class DiaryHome extends StatefulWidget {
  const DiaryHome({super.key, required this.controller});
  final ProfileController controller;
  @override
  State<DiaryHome> createState() => _DiaryHomeState();
}

class _DiaryHomeState extends State<DiaryHome> {
  ProfileController get controller => widget.controller;
  Catalog get catalog => controller.engine.catalog;
  Engine get engine => controller.engine;
  Json get state => controller.state;
  Json get plan => engine.plan(state);
  int page = 0;
  String category = 'all',
      search = '',
      status = 'all',
      world = '',
      group = '',
      guide = 'materials';
  String inventoryFilter = 'all', recipeFilter = 'all';
  Set<String>? inventorySelection;
  bool showSufficient = false;
  int limit = 40;
  Json? saveRaw, backupCandidate, saveReference;
  String? saveOrigin;
  bool readingSave = false;
  int slot = 1;
  bool staged = false, showUnchanged = false;
  Json decisions = {};
  final scroll = ScrollController();
  final searchText = TextEditingController();
  Future<void> update(Json Function(Json) action) async {
    await controller.commit(action);
  }

  void navigate(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      page = index;
      search = '';
      searchText.clear();
      world = '';
      group = '';
      status = 'all';
      limit = 40;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  void openCategory(String id) {
    setState(() => category = id);
    navigate(1);
  }

  void openGuide(String id) {
    setState(() => guide = id);
    navigate(2);
  }

  void report(Object error) {
    controller.showError(error);
  }

  @override
  void initState() {
    super.initState();
    rootBundle.loadString('assets/datasets/analyzed-save.json').then((text) {
      try {
        // Snapshot incluso: fornisce le mappature per decodificare il PNG.
        final raw = SaveAdapter(engine).validate(jsonDecode(text));
        if (mounted) setState(() => saveReference = raw);
      } catch (e) {
        report(e);
      }
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    searchText.dispose();
    super.dispose();
  }

  Future<void> external(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri == null ||
          !['https', 'http'].contains(uri.scheme) ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw const FormatException('Collegamento non disponibile.');
      }
    } catch (e) {
      report(e);
    }
  }

  Future<bool> exportBytes(List<int> bytes, String name, String mime) async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final directory = await getTemporaryDirectory();
        final file = File('${directory.path}/$name');
        await file.writeAsBytes(bytes, flush: true);
        final result = await Share.shareXFiles([
          XFile(file.path, mimeType: mime),
        ], sharePositionOrigin: const Rect.fromLTWH(0, 0, 1, 1));
        return result.status != ShareResultStatus.dismissed;
      }
      final location = await getSaveLocation(suggestedName: name);
      if (location == null) return false;
      await XFile.fromData(
        Uint8List.fromList(bytes),
        mimeType: mime,
        name: name,
      ).saveTo(location.path);
      return true;
    } catch (e) {
      report(e);
      return false;
    }
  }

  Future<bool> exportJson(Json value, String prefix) => exportBytes(
    utf8.encode(const JsonEncoder.withIndent('  ').convert(value)),
    '$prefix-${DateTime.now().toIso8601String().substring(0, 10)}.json',
    'application/json',
  );
  Future<void> document(String name) async {
    try {
      final data = await rootBundle.load('assets/documents/$name');
      await exportBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        name,
        name.endsWith('.pdf') ? 'application/pdf' : 'text/markdown',
      );
    } catch (e) {
      report(e);
    }
  }

  Future<Json?> pickJson() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'JSON',
          extensions: ['json'],
          mimeTypes: ['application/json'],
          uniformTypeIdentifiers: ['public.json'],
        ),
      ],
    );
    if (file == null) return null;
    if (await file.length() > 10 * 1024 * 1024) {
      throw const FormatException('File troppo grande: massimo 10 MB.');
    }
    final data = jsonDecode(await file.readAsString());
    if (data is! Json) {
      throw const FormatException(
        'Il JSON deve contenere un profilo o uno snapshot.',
      );
    }
    return data;
  }

  /// Legge il PNG del gioco (trovato da solo o scelto) e apre l'anteprima.
  /// La decodifica gira in un isolate per non bloccare l'interfaccia.
  Future<void> readGameSave({bool choose = false}) async {
    final reference = saveReference;
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
      final decoded = await _decodeSaveInIsolate(path, reference, name);
      SaveAdapter(engine).validate(decoded);
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
      report(e);
    } finally {
      if (mounted) setState(() => readingSave = false);
    }
  }

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
  Widget searchBox(String hint) => TextField(
    controller: searchText,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      hintText: hint,
    ),
    onChanged: (v) => setState(() {
      search = v.toLowerCase().trim();
      limit = 40;
    }),
  );
  Widget loadMore(int count) => count > limit
      ? OutlinedButton(
          onPressed: () => setState(() => limit += 40),
          child: Text('Mostra altre voci (${count - limit} rimanenti)'),
        )
      : const SizedBox.shrink();
  Widget links(List<dynamic> entries) => Wrap(
    spacing: 8,
    runSpacing: 4,
    children: entries
        .cast<Json>()
        .map(
          (link) => TextButton(
            onPressed: () {
              if (link['url'] != null) {
                external(link['url'] as String);
              } else if (link['category'] != null) {
                openCategory(link['category'] as String);
              } else if (link['guide'] != null) {
                openGuide(link['guide'] as String);
              }
            },
            child: Text(
              '${link['label'] ?? 'Apri guida'} ${link['url'] != null ? '↗' : '→'}',
            ),
          ),
        )
        .toList(),
  );
  Widget provenance(String key) {
    final snapshot = state['saveSnapshots'][state['activeSaveId']];
    final observation = snapshot?['observations']?[key];
    if (observation == null) return const SizedBox.shrink();
    final manual =
        (state['manualOverrides'][scope(snapshot as Json)] as Map?)
                ?.containsKey(key) ==
            true ||
        (state['manualOverrides']['app'] as Map?)?.containsKey(key) == true;
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
          '${snapshot['source']['filename']} · slot ${snapshot['slotNumber']} · ${snapshot['savedAt']}',
        ),
        text(
          'Valore: ${display(observation['value'])} · confidenza: ${observation['confidence']}',
        ),
        text('${observation['path']}'),
      ],
    );
  }

  Widget navigation(bool desktop) => SizedBox(
    width: 238,
    child: Material(
      color: const Color(0xFF111A2A),
      child: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.key, color: gold, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DIARIO',
                          style: TextStyle(
                            fontSize: 22,
                            letterSpacing: 3,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tracker non ufficiale',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (var i = 0; i < pages.length; i++)
                    ListTile(
                      selected: page == i,
                      selectedColor: gold,
                      leading: Icon(pageIcons[i]),
                      title: Text(pages[i]),
                      onTap: () {
                        navigate(i);
                        if (!desktop) Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                '● Offline · nessun account',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) {
      final desktop = MediaQuery.sizeOf(context).width >= 1000;
      final overall = catalog.summary(state);
      final body = ListView(
        controller: scroll,
        padding: EdgeInsets.all(desktop ? 32 : 16),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pages[page],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    text('Il tuo viaggio verso il 100%', color: muted),
                  ],
                ),
              ),
              if (desktop)
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
                controller.busy
                    ? 'Salvataggio…'
                    : controller.blocked
                    ? 'Archivio da recuperare'
                    : '● Salvataggio automatico',
                style: const TextStyle(color: muted),
              ),
              OutlinedButton.icon(
                onPressed:
                    controller.busy ||
                        controller.blocked ||
                        (state['transactions'] as List).isEmpty
                    ? null
                    : () => update(engine.undo),
                icon: const Icon(Icons.undo, size: 18),
                label: const Text('Annulla ultima operazione'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          text(
            '${state['settings']['level'] == null ? 'Profilo locale' : 'Sora · livello ${state['settings']['level']}'}'
            '${state['activeSaveId'] == null ? '' : ' · ${state['saveSnapshots'][state['activeSaveId']]['location']['save_label'] ?? 'Luogo da verificare'}'}'
            ' · ${engine.distinct(state)}/33 sintesi',
            color: gold,
          ),
          const SizedBox(height: 8),
          if (controller.error != null)
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text(controller.error!, color: Colors.orangeAccent),
                  Wrap(
                    spacing: 12,
                    children: [
                      TextButton(
                        onPressed: controller.initialize,
                        child: const Text('Ricarica archivio'),
                      ),
                      TextButton(
                        onPressed: () => navigate(12),
                        child: const Text('Apri Backup'),
                      ),
                      if (!controller.blocked)
                        TextButton(
                          onPressed: controller.dismissError,
                          child: const Text('Chiudi'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          if (page >= 4 && page <= 10) planSelector(),
          ...content(),
        ],
      );
      return Scaffold(
        appBar: desktop ? null : AppBar(title: const Text('Diario di Bordo')),
        drawer: desktop ? null : Drawer(child: navigation(false)),
        body: SafeArea(
          child: Row(
            children: [
              if (desktop) navigation(true),
              Expanded(
                child: AbsorbPointer(absorbing: controller.busy, child: body),
              ),
            ],
          ),
        ),
      );
    },
  );
  List<Widget> content() => switch (page) {
    0 => diary(),
    1 => checklist(),
    2 => guides(),
    3 => saves(),
    4 => dashboard(),
    5 => inventory(),
    6 => recipes(),
    7 => farming(false),
    8 => collections(),
    9 => planning(),
    10 => farming(true),
    11 => settings(),
    12 => backups(),
    _ => diary(),
  };
  Widget planSelector() => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Wrap(
      spacing: 8,
      children: [
        for (final e in {
          'all': 'Tutta la sintesi',
          '15': 'Prime 15',
          'selected': 'Selezionate',
        }.entries)
          ChoiceChip(
            label: Text(e.value),
            selected: state['plan']['mode'] == e.key,
            onSelected: (_) => update(
              (s) => engine.transact(
                s,
                'Obiettivo: ${e.value}',
                (n) => n['plan']['mode'] = e.key,
              ),
            ),
          ),
      ],
    ),
  );
  List<Widget> diary() {
    final count = catalog.summary(state);
    return [
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            text('IL VIAGGIO VERSO IL 100%', color: gold),
            Text(
              '${count['percent']}%',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300),
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
      for (final family in [
        'Diario di Grillo',
        'Raccolta',
        'Sfide',
        'Equipaggiamento',
        'Gummiship',
        'Trofei',
      ])
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              text(family, color: gold),
              for (final c in catalog.categories.where(
                (c) => c['family'] == family,
              ))
                categoryTile(c),
            ],
          ),
        ),
      if ((state['appliedEvidence'] as List).contains(catalog.evidence['id']))
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
              onPressed: () => openGuide('tips'),
              icon: const Icon(Icons.menu_book),
              label: const Text('Guide e boss segreti'),
            ),
            OutlinedButton(
              onPressed: () => document('KH1_Final_Mix_Sintesi_Tracking.pdf'),
              child: const Text('Esporta dossier PDF'),
            ),
          ],
        ),
      ),
    ];
  }

  Widget categoryTile(Json c) {
    final summary = catalog.summary(state, c['id'] as String);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(c['label'] as String),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: LinearProgressIndicator(
          value: (summary['done'] as int) / (summary['total'] as int),
        ),
      ),
      trailing: Text('${summary['done']} / ${summary['total']} →'),
      onTap: () => openCategory(c['id'] as String),
    );
  }

  List<Widget> checklist() {
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
    return [
      searchBox('Cerca nome, requisito, luogo o ricompensa…'),
      const SizedBox(height: 16),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          choice(
            'Categoria',
            category,
            {
              'all': 'Tutte le categorie',
              for (final c in catalog.categories)
                c['id'] as String: c['label'] as String,
            },
            (v) => setState(() {
              category = v;
              world = '';
              group = '';
              limit = 40;
            }),
          ),
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
                links(note['links'] as List),
              ],
            ),
          ),
      for (final item in visible.take(limit)) checklistItem(item),
      if (visible.isEmpty) text('Nessuna voce corrisponde ai filtri.'),
      loadMore(visible.length),
    ];
  }

  Widget checklistItem(Json item) {
    final done = catalog.completed(state, item),
        itemStatus = catalog.status(state, item);
    final categoryData = catalog.categories.firstWhere(
      (c) => c['id'] == item['categoryId'],
    );
    final evidence = (catalog.evidence['items'] as List).where(
      (e) => e['id'] == item['id'],
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
            onChanged: (v) =>
                update((s) => engine.completion(s, item['id'] as String, v)),
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
              (v) => update(
                (s) => engine.completion(
                  s,
                  item['id'] as String,
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
              links(item['links'] as List),
              text(
                'Excel · ${categoryData['sheet']} · riga ${item['row']}',
                color: muted,
              ),
              if ((state['appliedEvidence'] as List).contains(
                    catalog.evidence['id'],
                  ) &&
                  evidence.isNotEmpty)
                text(evidence.first['reason'] as String),
              provenance('completion.${item['id']}'),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> guides() {
    final selected = catalog.guides.firstWhere(
      (g) => g['id'] == guide,
      orElse: () => catalog.guides.first,
    );
    return [
      Wrap(
        spacing: 8,
        children: [
          for (final g in catalog.guides)
            ChoiceChip(
              label: Text(g['label'] as String),
              selected: g['id'] == selected['id'],
              onSelected: (_) => setState(() {
                guide = g['id'] as String;
                search = '';
                searchText.clear();
              }),
            ),
        ],
      ),
      const SizedBox(height: 16),
      searchBox('Cerca materiale, boss o consiglio…'),
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
              links(section['links'] as List),
              text(
                'Excel · ${selected['sheet']} · riga ${section['row']}',
                color: muted,
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> dashboard() {
    final p = plan;
    final ready = catalog.recipes
        .where(
          (r) =>
              state['everCrafted'][r['id']] != true &&
              engine.recipeStatus(state, r)['ready'] == true,
        )
        .toList();
    return [
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
            '${(state['inventory'] as Json).values.where((v) => v == null).length}',
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
            onTap: () => navigate(6),
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
          onTap: () => materialDialog(m['id'] as String),
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
        onPressed: () => navigate(9),
        child: const Text('Apri piano materiali'),
      ),
    ];
  }

  Widget quantityControls(String id) {
    final value = state['inventory'][id] as int?;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        RepeatButton(
          icon: Icons.remove,
          label: 'Diminuisci ${catalog.materialsById[id]!['name']}',
          onPressed: value == null
              ? null
              : () => update((s) => engine.increment(s, id, -1)),
        ),
        SizedBox(
          width: 118,
          child: NumberEditor(
            key: ValueKey('inventory-$id'),
            label: 'Hai',
            value: value,
            stepping: true,
            onSave: (v) => update((s) => engine.quantity(s, id, v)),
          ),
        ),
        RepeatButton(
          icon: Icons.add,
          label: 'Aumenta ${catalog.materialsById[id]!['name']}',
          onPressed: value == null
              ? null
              : () => update((s) => engine.increment(s, id, 1)),
        ),
        for (final delta in [5, 10])
          OutlinedButton(
            onPressed: value == null
                ? null
                : () => update((s) => engine.increment(s, id, delta)),
            child: Text('+$delta'),
          ),
        IconButton(
          tooltip: 'Quantità sconosciuta',
          onPressed: () => update((s) => engine.quantity(s, id, null)),
          icon: const Icon(Icons.help_outline),
        ),
      ],
    );
  }

  List<Widget> inventory() {
    final p = plan;
    final visible = catalog.materials
        .where(
          (m) =>
              (inventorySelection == null ||
                  inventorySelection!.contains(m['id'])) &&
              (m['name'] as String).toLowerCase().contains(search),
        )
        .toList();
    return [
      searchBox('Cerca materiale…'),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        children: [
          for (final e in {
            'all': 'Tutti',
            'missing': 'Mancanti',
            'unknown': 'Da verificare',
            'enough': 'Sufficienti',
          }.entries)
            ChoiceChip(
              label: Text(e.value),
              selected: inventoryFilter == e.key,
              onSelected: (_) => setState(() {
                inventoryFilter = e.key;
                inventorySelection = e.key == 'all'
                    ? null
                    : catalog.materials
                          .where((m) {
                            final row = p['rows'][m['id']];
                            return e.key == 'missing'
                                ? row['missing'] != null && row['missing'] > 0
                                : e.key == 'unknown'
                                ? row['unknown'] == true
                                : row['sufficient'] == true;
                          })
                          .map((m) => m['id'] as String)
                          .toSet();
              }),
            ),
        ],
      ),
      const SizedBox(height: 12),
      text(
        'Vuoto = quantità sconosciuta. Le ricompense future restano fuori dalle scorte.',
        color: muted,
      ),
      for (final m in visible)
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () => materialDialog(m['id'] as String),
                child: Text(
                  m['name'] as String,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              text(
                'Piano: ${p['rows'][m['id']]['external']} · Manca: ${display(p['rows'][m['id']]['missing'])} · Senza fonte: ${display(p['rows'][m['id']]['uncovered'])}',
                color: muted,
              ),
              quantityControls(m['id'] as String),
              provenance('inventory.${m['id']}'),
            ],
          ),
        ),
    ];
  }

  Future<void> materialDialog(String id) => showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => SingleChildScrollView(
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
                quantityControls(id),
                provenance('inventory.$id'),
                for (final f in catalog.farming.where(
                  (f) => f['material'] == id,
                ))
                  farmSource(f),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  List<Widget> recipes() {
    final visible = catalog.recipes.where((r) {
      final rs = engine.recipeStatus(state, r),
          done = state['everCrafted'][r['id']] == true;
      return (r['name'] as String).toLowerCase().contains(search) &&
          (recipeFilter == 'all' ||
              recipeFilter == 'todo' && !done ||
              recipeFilter == 'done' && done ||
              recipeFilter == 'ready' && rs['ready'] == true);
    }).toList();
    return [
      searchBox('Cerca ricetta…'),
      const SizedBox(height: 12),
      choice('Stato', recipeFilter, {
        'all': 'Tutte le ricette',
        'todo': 'Da sintetizzare',
        'done': 'Già sintetizzate',
        'ready': 'Pronte adesso',
      }, (v) => setState(() => recipeFilter = v)),
      const SizedBox(height: 16),
      for (final r in visible) recipeCard(r),
    ];
  }

  Widget recipeCard(Json r) {
    final rs = engine.recipeStatus(state, r),
        done = state['everCrafted'][r['id']] == true;
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('${r['name']} ${done ? '✓' : ''}'),
          text(
            'Gruppo ${r['group']} · ${rs['unlocked'] == true ? 'Sbloccato' : 'Bloccato'} · Creazioni: ${display(state['craftCount'][r['id']])}',
            color: muted,
          ),
          for (final e in (r['costs'] as Json).entries)
            text(
              '${catalog.materialsById[e.key]!['name']} × ${e.value} · hai ${display(state['inventory'][e.key])}',
            ),
          if (r['output'] != null)
            text('Produce 1 ${r['name']} nell’inventario.', color: gold),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: rs['ready'] == true
                    ? () => update((s) => engine.craft(s, r['id'] as String))
                    : null,
                icon: const Icon(Icons.science),
                label: const Text('Sintetizza adesso'),
              ),
              OutlinedButton(
                onPressed: done
                    ? null
                    : () => update(
                        (s) => engine.markCrafted(s, r['id'] as String),
                      ),
                child: const Text('Segna già sintetizzato'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget farmSource(Json source) {
    final lucky = state['settings']['lucky'] as int?;
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
                onPressed: () => external(source['url'] as String),
                child: const Text('Guida dettagliata ↗'),
              ),
              TextButton(
                onPressed: () => document('KH1_Final_Mix_Sintesi_Tracking.pdf'),
                child: Text('Dossier · pagina ${source['page']}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> farming(bool session) {
    final p = plan;
    final visible = catalog.farming
        .where(
          (f) =>
              (showSufficient || p['rows'][f['material']]['missing'] != 0) &&
              (world.isEmpty || f['world'] == world) &&
              '${catalog.materialsById[f['material']]!['name']} ${f['enemy']} ${f['world']} ${f['area']}'
                  .toLowerCase()
                  .contains(search),
        )
        .toList();
    final worlds =
        catalog.farming.map((f) => f['world'] as String).toSet().toList()
          ..sort();
    final ids = visible.map((f) => f['material'] as String).toSet();
    return [
      searchBox('Cerca materiale, nemico o luogo…'),
      const SizedBox(height: 16),
      choice('Mondo', world, {
        '': 'Tutti i mondi',
        for (final w in worlds) w: w,
      }, (v) => setState(() => world = v)),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Mostra anche i materiali sufficienti'),
        value: showSufficient,
        onChanged: (v) => setState(() => showSufficient = v),
      ),
      if (session)
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Raccolte di questa sessione'),
              text(
                (state['session'] as Json).isEmpty
                    ? 'Nessuna raccolta registrata.'
                    : (state['session'] as Json).entries
                          .map(
                            (e) =>
                                '${catalog.materialsById[e.key]!['name']} +${e.value}',
                          )
                          .join(' · '),
              ),
              OutlinedButton(
                onPressed: () => update(
                  (s) => engine.transact(
                    s,
                    'Nuova sessione',
                    (n) => n['session'] = <String, dynamic>{},
                  ),
                ),
                child: const Text('Azzera contatori sessione'),
              ),
              text(
                'Per Dark Matter e Orichalcum usa Collezionabili se vuoi registrare anche la fonte e ridurre la previsione.',
                color: muted,
              ),
            ],
          ),
        ),
      for (final id in ids)
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(catalog.materialsById[id]!['name'] as String),
              text(
                'Mancano: ${display(p['rows'][id]['missing'])}',
                color: gold,
              ),
              if (session)
                Wrap(
                  spacing: 8,
                  children: [
                    for (final delta in [1, 5])
                      FilledButton(
                        onPressed: state['inventory'][id] == null
                            ? null
                            : () => update(
                                (s) => engine.sessionCollect(s, id, delta),
                              ),
                        child: Text('Raccolto +$delta'),
                      ),
                  ],
                )
              else
                quantityControls(id),
              for (final source in visible.where((f) => f['material'] == id))
                farmSource(source),
            ],
          ),
        ),
      if (ids.isEmpty) text('Nessun deficit per i filtri selezionati.'),
      OutlinedButton.icon(
        onPressed: () => navigate(11),
        icon: const Icon(Icons.tune),
        label: const Text('Preparazione del salvataggio'),
      ),
    ];
  }

  List<Widget> collections() {
    final sources = catalog.collections
        .where(
          (c) =>
              '${c['world']} ${c['area']} ${c['material']} ${c['requirement']}'
                  .toLowerCase()
                  .contains(search) &&
              (status == 'all' || state['collections'][c['id']] == status),
        )
        .toList();
    return [
      text(
        '“Già raccolto” corregge lo storico. “Raccolto adesso” aggiunge 1 alla scorta e riduce di 1 la ricompensa futura.',
        color: muted,
      ),
      searchBox('Cerca fonte o mondo…'),
      const SizedBox(height: 16),
      choice('Stato fonte', status, {
        'all': 'Tutte le fonti',
        'unknown': 'Da verificare',
        'collected': 'Raccolte',
        'not_collected': 'Non raccolte',
      }, (v) => setState(() => status = v)),
      const SizedBox(height: 16),
      for (final c in sources)
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading(
                '${catalog.materialsById[c['material']]!['name']} · ${c['world']}',
              ),
              for (final e in c.entries.where(
                (e) => !['id', 'material', 'world', 'url'].contains(e.key),
              ))
                text('${e.key}: ${e.value}'),
              text(
                'Stato: ${{'unknown': 'Da verificare', 'collected': 'Raccolto', 'not_collected': 'Non raccolto'}[state['collections'][c['id']]]}',
                color: gold,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed:
                        state['collections'][c['id']] == 'collected' ||
                            state['inventory'][c['material']] == null
                        ? null
                        : () => update(
                            (s) =>
                                engine.collect(s, c['id'] as String, now: true),
                          ),
                    child: const Text('Raccolto adesso'),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        update((s) => engine.collect(s, c['id'] as String)),
                    child: const Text('Già raccolto'),
                  ),
                  TextButton(
                    onPressed: () => update(
                      (s) => engine.collect(
                        s,
                        c['id'] as String,
                        status: 'not_collected',
                      ),
                    ),
                    child: const Text('Non raccolto'),
                  ),
                  TextButton(
                    onPressed: () => update(
                      (s) => engine.collect(
                        s,
                        c['id'] as String,
                        status: 'unknown',
                      ),
                    ),
                    child: const Text('Da verificare'),
                  ),
                ],
              ),
              if (c['url'] != null)
                TextButton(
                  onPressed: () => external(c['url'] as String),
                  child: const Text('Guida ↗'),
                ),
            ],
          ),
        ),
    ];
  }

  List<Widget> planning() {
    final p = plan, simulation = engine.simulate(state, plan);
    return [
      text(
        'Una creazione per ogni ricetta ancora da completare. Mythril e Dark Matter vengono espansi in base al deficit effettivo.',
        color: muted,
      ),
      if (state['plan']['mode'] == 'selected')
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Scegli le ricette'),
              for (final r in catalog.recipes)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${r['name']}${state['everCrafted'][r['id']] == true ? ' · completata' : ''}',
                  ),
                  value: (state['plan']['selected'] as List).contains(r['id']),
                  onChanged: (v) => update(
                    (s) => engine.transact(s, 'Selezione: ${r['name']}', (n) {
                      final selected = n['plan']['selected'] as List;
                      if (v == true && !selected.contains(r['id'])) {
                        selected.add(r['id']);
                      } else if (v == false) {
                        selected.remove(r['id']);
                      }
                    }),
                  ),
                ),
            ],
          ),
        ),
      if (state['plan']['mode'] != '15')
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Ricompense future'),
              text(
                'Previsioni ancora fuori dall’inventario. Riducile se salti una fonte.',
              ),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final id in ['dark_matter', 'orichalcum'])
                    SizedBox(
                      width: 220,
                      child: NumberEditor(
                        key: ValueKey('rewards-$id'),
                        label: catalog.materialsById[id]!['name'] as String,
                        value: state['plan']['rewards'][id] as int,
                        nullable: false,
                        onSave: (v) => update(
                          (s) => engine.transact(
                            s,
                            'Ricompense future',
                            (n) => n['plan']['rewards'][id] = v,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              text(
                'Orichalcum senza fonte: ${display(p['rows']['orichalcum']['uncovered'])} · ${p['rows']['orichalcum']['uncovered'] == null ? '?' : (p['rows']['orichalcum']['uncovered'] as int) * 5000} Munny',
                color: gold,
              ),
            ],
          ),
        ),
      if (state['plan']['mode'] == '15')
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Percorso fino a 15'),
              for (final id in catalog.route15)
                text(
                  '${state['everCrafted'][id] == true ? '✓' : '○'} ${catalog.recipesById[id]!['name']}',
                ),
              text(
                'Incluse 3 Lucid Gem aggiuntive per Gaia Bangle. Evita Angel Bangle durante questo percorso.',
                color: gold,
              ),
            ],
          ),
        ),
      Panel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('Produzioni e ordine'),
            text(
              'Mythril: ${p['counts']['mythril']} · Dark Matter: ${p['counts']['dark_matter']} · Creazioni nel piano: ${p['total']}',
            ),
            text(
              simulation['complete'] == true
                  ? 'Sequenza eseguibile'
                  : 'Sequenza ancora incompleta',
              color: gold,
            ),
            text(
              (simulation['steps'] as List).isEmpty
                  ? 'Nessuna creazione eseguibile adesso.'
                  : (simulation['steps'] as List)
                        .map((id) => catalog.recipesById[id]!['name'])
                        .join(' → '),
            ),
            if (simulation['assumesRewards'] == true)
              text(
                'La simulazione presume recuperate le ricompense future. Le sintesi reali consumano solo le scorte attuali.',
                color: muted,
              ),
            if ((p['uncertainDependencies'] as List).isNotEmpty)
              text(
                'Dipendenze sconosciute: ${(p['uncertainDependencies'] as List).map((id) => catalog.materialsById[id]!['name']).join(', ')}. I deficit esatti restano da verificare.',
                color: gold,
              ),
          ],
        ),
      ),
      heading('Fabbisogno residuo'),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            for (final label in [
              'Materiale',
              'Costi',
              'Prodotti',
              'Esterni',
              'Hai',
              'Manca',
              'Previsti',
              'Senza fonte',
            ])
              DataColumn(label: Text(label)),
          ],
          rows: [
            for (final m in catalog.materials.where(
              (m) =>
                  p['rows'][m['id']]['gross'] != 0 ||
                  state['inventory'][m['id']] == null,
            ))
              DataRow(
                cells: [
                  DataCell(Text(m['name'] as String)),
                  for (final value in [
                    p['rows'][m['id']]['gross'],
                    p['rows'][m['id']]['produced'],
                    p['rows'][m['id']]['external'],
                    state['inventory'][m['id']],
                    p['rows'][m['id']]['missing'],
                    p['rows'][m['id']]['planned'],
                    p['rows'][m['id']]['uncovered'],
                  ])
                    DataCell(Text(value == null ? '?' : '$value')),
                ],
              ),
          ],
        ),
      ),
    ];
  }

  List<Widget> settings() => [
    text(
      'Questi dati descrivono la preparazione del farming. Le abilità sconosciute non vengono considerate disponibili.',
      color: muted,
    ),
    Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('Salvataggio e abilità'),
          EditionEditor(
            value: state['settings']['edition'] as String,
            onSave: (v) => update(
              (s) => engine.transact(
                s,
                'Piattaforma',
                (n) => n['settings']['edition'] = v,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final e in {
                'level': 'Livello di Sora',
                'mp': 'MP massimi',
                'lucky': 'Lucky Strike attivi (0–3)',
                'munny': 'Munny attuali',
              }.entries)
                SizedBox(
                  width: 250,
                  child: NumberEditor(
                    key: ValueKey('settings-${e.key}'),
                    label: e.value,
                    value: state['settings'][e.key] as int?,
                    max: e.key == 'lucky' ? 3 : 999999,
                    onSave: (v) => update(
                      (s) => engine.transact(
                        s,
                        e.value,
                        (n) => n['settings'][e.key] = v,
                      ),
                    ),
                  ),
                ),
              for (final key in [
                'Stop',
                'Aerora',
                'Aeroga',
                'Ragnarok',
                'Glide',
                'Dumbo',
                'Bambi',
                'Mushu',
                'Trio Bianco',
                'Trio Giallo',
              ])
                SizedBox(
                  width: 250,
                  child: choice(
                    key,
                    state['settings'][key] == null
                        ? 'unknown'
                        : '${state['settings'][key]}',
                    {
                      'unknown': 'Da verificare',
                      'true': 'Disponibile',
                      'false': 'Non disponibile',
                    },
                    (v) => update(
                      (s) => engine.transact(
                        s,
                        'Disponibilità $key',
                        (n) => n['settings'][key] = v == 'unknown'
                            ? null
                            : v == 'true',
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          text(
            'Pink Agaricus: verifica MP elevati, Stop, Ragnarok e le differenze tra edizioni.',
            color: gold,
          ),
          for (final key in (state['settings'] as Json).keys)
            provenance('settings.$key'),
        ],
      ),
    ),
  ];
  List<Widget> saves() {
    final adapter = SaveAdapter(engine), raw = saveRaw;
    final preview = raw == null || !staged
        ? null
        : adapter.preview(state, raw, slot, decisions);
    final active = state['saveSnapshots'][state['activeSaveId']] as Json?;
    final chests = ((active?['chests'] ?? []) as List)
        .cast<Json>()
        .where(
          (c) =>
              (world.isEmpty || c['world'] == world) &&
              (c['name'] as String).toLowerCase().contains(search) &&
              (status == 'all' ||
                  (status == 'unknown'
                      ? state['saveValues']['chest.${c['code']}'] == null
                      : state['saveValues']['chest.${c['code']}'] ==
                            (status == 'done'))),
        )
        .toList();
    return [
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
                  onPressed: saveReference == null || readingSave
                      ? null
                      : () => readGameSave(),
                  icon: readingSave
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('Leggi il save dal gioco'),
                ),
                OutlinedButton.icon(
                  onPressed: saveReference == null || readingSave
                      ? null
                      : () => readGameSave(choose: true),
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Apri save PNG'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final selected = await pickJson();
                      if (selected == null) return;
                      adapter.validate(selected);
                      setState(() {
                        saveRaw = selected;
                        saveOrigin = null;
                        slot =
                            (selected['slots'] as List).first['slot_number']
                                as int;
                        staged = false;
                        decisions = {};
                      });
                    } catch (e) {
                      report(e);
                    }
                  },
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
      if (preview != null)
        Panel(
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
                (r) =>
                    showUnchanged ||
                    r['changed'] == true ||
                    r['conflict'] == true,
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
                      text(
                        '${row['path']} · ${row['confidence']}',
                        color: muted,
                      ),
                      if (row['conflict'] == true)
                        choice(
                          'Conflitto',
                          row['kept'] == true ? 'keep' : 'save',
                          {'keep': 'Mantieni modifica app', 'save': 'Usa save'},
                          (v) => setState(
                            () => decisions[row['key'] as String] = v,
                          ),
                        ),
                    ],
                  ),
                ),
              Wrap(
                spacing: 12,
                children: [
                  FilledButton(
                    onPressed: () async {
                      final current = state;
                      if (!await exportJson(
                        current,
                        'kh1fm-prima-importazione',
                      )) {
                        return;
                      }
                      if (!identical(current, state)) {
                        report(
                          'Il profilo è cambiato: ricontrolla l’anteprima.',
                        );
                        return;
                      }
                      if (await controller.commit(
                            (s) => adapter.apply(s, raw!, slot, decisions),
                            importing: true,
                          ) &&
                          mounted) {
                        setState(() => staged = false);
                      }
                    },
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
        ),
      if (active == null)
        text('Nessuno snapshot importato.')
      else ...[
        Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              heading('Snapshot attivo · slot ${active['slotNumber']}'),
              text(
                '${active['location']['world']} / ${active['location']['save_label']} · livello ${active['level']} · ${active['difficulty']}',
              ),
              text(
                'Salvato: ${active['savedAt']}\nAnalizzato: ${active['generatedAt']}\nImportato: ${active['importedAt']}',
              ),
              SelectableText(
                'Fonte: ${active['source']['filename']}\nSHA-256: ${active['source']['sha256']}',
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
                    onPressed: () => document('KH1FM_Report_Save.md'),
                    child: const Text('Esporta report originale'),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Statistiche, equipaggiamento e abilità'),
                children: [
                  for (final character
                      in (active['characters'] as List).cast<Json>())
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
        ),
        heading('Trinità e cartoline · contatori del save'),
        text(
          'I contatori non identificano le singole voci dell’Excel.',
          color: muted,
        ),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final e in {
              'trinity.Blue': 17,
              'trinity.Red': 6,
              'trinity.Green': 9,
              'trinity.Yellow': 4,
              'trinity.White': 10,
              'postcards': 10,
            }.entries)
              SizedBox(
                width: 250,
                child: Column(
                  children: [
                    NumberEditor(
                      key: ValueKey('save-${e.key}'),
                      label: '${e.key} / ${e.value}',
                      value: state['saveValues'][e.key] as int?,
                      max: e.value,
                      onSave: (v) => update((s) => adapter.edit(s, e.key, v)),
                    ),
                    provenance('save.${e.key}'),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        heading('Casse mappate'),
        text(
          'Mappatura parziale: ${active['chestCoverage']['mappedTotal'] ?? '?'} casse. Restano separate dai 268 tesori dell’Excel.',
          color: muted,
        ),
        searchBox('Cerca cassa…'),
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
                for (final c in (active['chests'] as List).cast<Json>())
                  c['world'] as String: c['world'] as String,
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
                  state['saveValues']['chest.${c['code']}'] == null
                      ? 'unknown'
                      : '${state['saveValues']['chest.${c['code']}']}',
                  {
                    'true': 'Aperta',
                    'false': 'Non aperta',
                    'unknown': 'Da verificare',
                  },
                  (v) => update(
                    (s) => adapter.edit(
                      s,
                      'chest.${c['code']}',
                      v == 'unknown' ? null : v == 'true',
                    ),
                  ),
                ),
                provenance('save.chest.${c['code']}'),
              ],
            ),
          ),
        loadMore(chests.length),
        heading('Snapshot archiviati'),
        for (final s in (state['saveSnapshots'] as Json).values.cast<Json>())
          text(
            'Slot ${s['slotNumber']} · ${s['savedAt']} · ${s['location']['world']} / ${s['location']['save_label']}',
          ),
      ],
    ];
  }

  List<Widget> backups() => [
    Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('Conserva i tuoi progressi'),
          text(
            'Il backup JSON include inventario, checklist, piano, cronologia, snapshot e override. Compatibile con i backup della precedente app.',
          ),
          SelectableText(
            'Archivio: ${controller.store.directory.path}',
            style: const TextStyle(color: muted),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () => exportJson(state, 'kh1fm-backup'),
                icon: const Icon(Icons.download),
                label: const Text('Esporta backup JSON'),
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    if (!await controller.store.backup.exists()) {
                      throw const FormatException('Nessun backup precedente.');
                    }
                    final bytes = await controller.store.backup.readAsBytes();
                    await exportBytes(
                      bytes,
                      'kh1fm-backup-precedente.json',
                      'application/json',
                    );
                  } catch (e) {
                    report(e);
                  }
                },
                child: const Text('Esporta backup precedente'),
              ),
            ],
          ),
        ],
      ),
    ),
    Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          heading('Importa e ripristina'),
          text(
            'Scegli un backup della vecchia app oppure data/profile.json. Prima della sostituzione viene esportata e conservata una copia del profilo attuale.',
          ),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                final raw = await pickJson();
                if (raw == null) return;
                final candidate = ProfileValidator(catalog).validate(raw);
                if (mounted) setState(() => backupCandidate = candidate);
              } catch (e) {
                report(e);
              }
            },
            icon: const Icon(Icons.file_open),
            label: const Text('Scegli backup JSON'),
          ),
          if (backupCandidate != null) ...[
            heading('Anteprima importazione'),
            text(
              'Checklist: ${catalog.summary(backupCandidate!)['done']} / 794\nSintesi: ${engine.distinct(backupCandidate!)} / 33\nOperazioni annullabili: ${(backupCandidate!['transactions'] as List).length}\nSnapshot: ${(backupCandidate!['saveSnapshots'] as Json).length}',
            ),
            Wrap(
              spacing: 12,
              children: [
                FilledButton(
                  onPressed: () async {
                    final candidate = backupCandidate!, current = state;
                    if (!await exportJson(
                      current,
                      'kh1fm-prima-importazione',
                    )) {
                      return;
                    }
                    if (!identical(current, state)) {
                      report('Il profilo è cambiato: ricontrolla l’anteprima.');
                      return;
                    }
                    if (await controller.commit(
                          (_) => copyJson(candidate),
                          importing: true,
                        ) &&
                        mounted) {
                      setState(() => backupCandidate = null);
                    }
                  },
                  child: const Text('Crea backup e sostituisci i dati'),
                ),
                TextButton(
                  onPressed: () => setState(() => backupCandidate = null),
                  child: const Text('Annulla anteprima'),
                ),
              ],
            ),
          ],
        ],
      ),
    ),
    heading('Cronologia'),
    for (final t in (state['transactions'] as List).reversed.take(20))
      ListTile(
        leading: const Icon(Icons.history),
        title: Text(t['label'] as String),
        subtitle: Text(t['at'] as String),
      ),
    text(
      'La cronologia conserva fino a 100 operazioni. Le scritture fallite non aggiornano i dati visualizzati.',
      color: muted,
    ),
  ];
}

/// Top-level di proposito: una closure creata in un metodo di State
/// condivide il contesto con `this`, e l'isolate rifiuterebbe di copiarlo.
Future<Json> _decodeSaveInIsolate(String path, Json reference, String name) =>
    Isolate.run(
      () => decodeSave(File(path).readAsBytesSync(), reference, filename: name),
    );
