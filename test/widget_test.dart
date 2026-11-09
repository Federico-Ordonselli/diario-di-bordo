import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/application/profile_providers.dart';
import 'package:diario_bordo/app/app.dart';
import 'package:diario_bordo/app/router.dart';
import 'package:diario_bordo/ui/widgets.dart';
import 'fakes.dart';
import 'test_catalog.dart';

/// App avviata su un profilo importato (con snapshot del save attivo).
Future<ProviderContainer> importedApp(WidgetTester tester, Size size) async {
  final c = profileContainer(
    testCatalog(),
    InMemoryProfileRepository(jsonEncode(fixture()['imported'])),
  );
  await c.read(profileProvider.notifier).initialize();
  expect(c.read(profileProvider).blocked, false);
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  await tester.pumpWidget(
    UncontrolledProviderScope(container: c, child: const DiaryApp()),
  );
  await tester.pumpAndSettle();
  return c;
}

Future<void> closeApp(WidgetTester tester, ProviderContainer c) async {
  await tester.pumpWidget(const SizedBox());
  c.dispose();
  tester.view.resetPhysicalSize();
  tester.view.resetDevicePixelRatio();
}

void main() {
  testWidgets('Il diario si adatta a desktop e telefono senza overflow', (
    tester,
  ) async {
    final c = profileContainer(testCatalog(), InMemoryProfileRepository());
    try {
      for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        await tester.pumpWidget(
          UncontrolledProviderScope(container: c, child: const DiaryApp()),
        );
        await tester.pumpAndSettle();
        expect(find.text('IL VIAGGIO VERSO IL 100%'), findsOneWidget);
        expect(tester.takeException(), null);
      }
    } finally {
      await tester.pumpWidget(const SizedBox());
      c.dispose();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
  for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
    final wide = size.width >= 1000;
    testWidgets('Tutti i percorsi si aprono a ${size.width.toInt()}px', (
      tester,
    ) async {
      final c = await importedApp(tester, size);
      try {
        final router = c.read(routerProvider);
        final locations = {
          Routes.diary: 'Diario 100%',
          Routes.checklist(): 'Checklist',
          for (final s in SynthesisSection.values) Routes.synthesis(s): s.label,
          Routes.save: 'Save',
          Routes.more: 'Altro',
          for (final s in MoreSection.values) Routes.moreSection(s): s.label,
        };
        for (final MapEntry(key: location, value: title) in locations.entries) {
          router.go(location);
          await tester.pumpAndSettle();
          expect(tester.takeException(), null, reason: location);
          expect(router.state.uri.toString(), location);
          expect(find.text(title), findsWidgets, reason: location);
        }
      } finally {
        await closeApp(tester, c);
      }
    });
    testWidgets('Le 5 destinazioni si toccano a ${size.width.toInt()}px', (
      tester,
    ) async {
      final c = await importedApp(tester, size);
      try {
        final router = c.read(routerProvider);
        final nav = find.byType(wide ? NavigationRail : NavigationBar);
        expect(nav, findsOneWidget);
        Future<void> tap(Destination d) async {
          await tester.tap(
            find.descendant(of: nav, matching: find.text(d.label)),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), null, reason: d.label);
        }

        for (final d in Destination.values) {
          await tap(d);
        }
        expect(router.state.uri.toString(), Routes.more);
        // Dentro "Altro" si scende in una pagina e la si risale col tasto
        // indietro (AppBar su telefono, intestazione su desktop).
        await tester.tap(find.widgetWithText(ListTile, 'Backup'));
        await tester.pumpAndSettle();
        expect(router.state.uri.toString(), Routes.backup);
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(router.state.uri.toString(), Routes.more);
        // Ogni branch ricorda dov'era: la Sintesi riapre l'ultima sezione.
        router.go(Routes.synthesis(SynthesisSection.planning));
        await tester.pumpAndSettle();
        await tap(Destination.diary);
        await tap(Destination.synthesis);
        expect(
          router.state.uri.toString(),
          Routes.synthesis(SynthesisSection.planning),
        );
        // Riselezionare la destinazione corrente torna alla sua radice.
        await tap(Destination.synthesis);
        expect(router.state.uri.toString(), Routes.synthesis());
      } finally {
        await closeApp(tester, c);
      }
    });
  }
  testWidgets('Una categoria del diario apre la checklist già filtrata', (
    tester,
  ) async {
    final c = await importedApp(tester, const Size(390, 844));
    try {
      final router = c.read(routerProvider);
      final tile = find.widgetWithText(ListTile, 'Rapporti di Ansem');
      await tester.scrollUntilVisible(
        tile,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(tile);
      await tester.pumpAndSettle();
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), Routes.checklist('reports'));
      expect(find.text('Rapporti di Ansem'), findsWidgets);
      expect(find.text('Tutte le categorie'), findsNothing);
      expect(tester.takeException(), null);
    } finally {
      await closeApp(tester, c);
    }
  });
  testWidgets('Un clic sull’incremento registra una sola operazione', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepeatButton(
            icon: Icons.add,
            label: 'Aumenta',
            onPressed: () async {
              count++;
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(count, 1);
  });
  testWidgets('Pressione prolungata ripete e si ferma al rilascio', (
    tester,
  ) async {
    var count = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepeatButton(
            icon: Icons.add,
            label: 'Aumenta',
            onPressed: () async {
              count++;
            },
          ),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(IconButton)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(count, greaterThan(1));
    await gesture.up();
    await tester.pump();
    final stopped = count;
    await tester.pump(const Duration(seconds: 1));
    expect(count, stopped);
  });
}
