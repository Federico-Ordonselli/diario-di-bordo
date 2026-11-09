import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/common.dart';
import '../ui/widgets.dart';
import 'router.dart';

/// Cornice comune: bottom nav su telefono, NavigationRail su schermi larghi.
/// Ogni branch ha il proprio Navigator (e la propria AppBar), qui c'è solo
/// la scelta della destinazione.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  /// Riselezionare la destinazione corrente torna alla sua radice
  /// (es. da `/altro/backup` ad `/altro`).
  void select(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isWide(context)) {
      return Scaffold(
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: select,
          destinations: [
            for (final d in Destination.values)
              NavigationDestination(icon: Icon(d.icon), label: d.label),
          ],
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: true,
              minExtendedWidth: 238,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: select,
              leading: const _Brand(),
              trailing: const Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      '● Offline · nessun account',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                ),
              ),
              destinations: [
                for (final d in Destination.values)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    label: Text(d.label),
                  ),
              ],
            ),
          ),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(8, 16, 8, 24),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.key, color: gold, size: 32),
        SizedBox(width: 12),
        Column(
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
      ],
    ),
  );
}
