import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/checklist/checklist_page.dart';
import '../features/diary/diary_page.dart';
import '../features/more/backup_page.dart';
import '../features/more/guides_page.dart';
import '../features/more/more_page.dart';
import '../features/more/settings_page.dart';
import '../features/save/save_page.dart';
import '../features/synthesis/synthesis_page.dart';
import 'shell.dart';

/// Sotto-pagine del laboratorio di sintesi: condividono il selettore
/// dell'obiettivo e sono raggiungibili come `/sintesi/<path>`.
enum SynthesisSection {
  dashboard('dashboard', 'Dashboard', Icons.dashboard_outlined),
  inventory('inventario', 'Inventario', Icons.inventory_2_outlined),
  recipes('ricette', 'Ricette', Icons.science_outlined),
  farming('farming', 'Farming', Icons.travel_explore),
  collections('collezionabili', 'Collezionabili', Icons.diamond_outlined),
  planning('piano', 'Piano', Icons.route),
  session('sessione', 'Sessione', Icons.sports_esports_outlined);

  const SynthesisSection(this.path, this.label, this.icon);
  final String path;
  final String label;
  final IconData icon;

  static SynthesisSection? parse(String? path) =>
      values.where((s) => s.path == path).firstOrNull;
}

/// Pagine raccolte sotto "Altro".
enum MoreSection {
  guides('guide', 'Guide', Icons.menu_book),
  settings('preparazione', 'Preparazione', Icons.tune),
  backup('backup', 'Backup', Icons.backup_outlined);

  const MoreSection(this.path, this.label, this.icon);
  final String path;
  final String label;
  final IconData icon;
}

/// Le cinque destinazioni principali, nello stesso ordine dei branch.
enum Destination {
  diary('Diario', Icons.auto_stories_outlined),
  checklist('Checklist', Icons.checklist),
  synthesis('Sintesi', Icons.science_outlined),
  save('Save', Icons.save_outlined),
  more('Altro', Icons.more_horiz);

  const Destination(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Percorsi dell'app: unico punto in cui si costruiscono gli URL.
abstract final class Routes {
  static const diary = '/diario';
  static String checklist([String? category]) => Uri(
    path: '/checklist',
    queryParameters: category == null || category == 'all'
        ? null
        : {'categoria': category},
  ).toString();
  static String synthesis([SynthesisSection s = SynthesisSection.dashboard]) =>
      '/sintesi/${s.path}';
  static const save = '/save';
  static const more = '/altro';
  static String moreSection(MoreSection s) => '/altro/${s.path}';
  static String guide([String? id]) => Uri(
    path: moreSection(MoreSection.guides),
    queryParameters: id == null ? null : {'id': id},
  ).toString();
  static final settings = moreSection(MoreSection.settings);
  static final backup = moreSection(MoreSection.backup);
}

/// Un router per container: nei test ogni `ProviderContainer` riparte da
/// `/diario` invece di ereditare la posizione del test precedente.
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Routes.diary,
    routes: [
      GoRoute(path: '/', redirect: (_, _) => Routes.diary),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.diary, builder: (_, _) => const DiaryPage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/checklist',
                builder: (_, state) => ChecklistPage(
                  category: state.uri.queryParameters['categoria'] ?? 'all',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            initialLocation: Routes.synthesis(),
            routes: [
              GoRoute(
                path: '/sintesi',
                redirect: (_, state) =>
                    state.uri.path == '/sintesi' ? Routes.synthesis() : null,
                routes: [
                  GoRoute(
                    path: ':sezione',
                    redirect: (_, state) =>
                        SynthesisSection.parse(
                              state.pathParameters['sezione'],
                            ) ==
                            null
                        ? Routes.synthesis()
                        : null,
                    builder: (_, state) => SynthesisPage(
                      section: SynthesisSection.parse(
                        state.pathParameters['sezione'],
                      )!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.save, builder: (_, _) => const SavePage()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.more,
                builder: (_, _) => const MorePage(),
                routes: [
                  GoRoute(
                    path: MoreSection.guides.path,
                    builder: (_, state) =>
                        GuidesPage(guide: state.uri.queryParameters['id']),
                  ),
                  GoRoute(
                    path: MoreSection.settings.path,
                    builder: (_, _) => const SettingsPage(),
                  ),
                  GoRoute(
                    path: MoreSection.backup.path,
                    builder: (_, _) => const BackupPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
