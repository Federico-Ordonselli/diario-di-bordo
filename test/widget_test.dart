import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:diario_bordo/domain/engine.dart';
import 'package:diario_bordo/storage/controller.dart';
import 'package:diario_bordo/ui/app.dart';
import 'package:diario_bordo/ui/widgets.dart';
import 'fakes.dart';
import 'test_catalog.dart';

void main() {
  testWidgets('Il diario si adatta a desktop e telefono senza overflow', (
    tester,
  ) async {
    final c = ProfileController(
      Engine(testCatalog()),
      InMemoryProfileRepository(),
    );
    try {
      for (final size in [const Size(1440, 1000), const Size(390, 844)]) {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        await tester.pumpWidget(DiaryApp(controller: c));
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
    testWidgets('Navigazione in tutte le sezioni a ${size.width.toInt()}px', (
      tester,
    ) async {
      final c = ProfileController(
        Engine(testCatalog()),
        InMemoryProfileRepository(),
      );
      c.state = fixture()['imported'];
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      try {
        await tester.pumpWidget(DiaryApp(controller: c));
        await tester.pumpAndSettle();
        for (final label in pages) {
          if (size.width < 1000) {
            await tester.tap(find.byIcon(Icons.menu));
            await tester.pumpAndSettle();
          }
          final destination = find.widgetWithText(ListTile, label);
          final navScroll = size.width < 1000
              ? find
                    .descendant(
                      of: find.byType(Drawer),
                      matching: find.byType(Scrollable),
                    )
                    .first
              : find.byType(Scrollable).first;
          await tester.scrollUntilVisible(
            destination,
            200,
            scrollable: navScroll,
          );
          await tester.pumpAndSettle();
          await tester.tap(destination);
          await tester.pumpAndSettle();
          expect(tester.takeException(), null, reason: label);
        }
      } finally {
        await tester.pumpWidget(const SizedBox());
        c.dispose();
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      }
    });
  }
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
