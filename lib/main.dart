import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'domain/catalog.dart';
import 'domain/engine.dart';
import 'storage/controller.dart';
import 'storage/profile_store.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Future<Json> read(String name) async =>
        jsonDecode(await rootBundle.loadString('assets/datasets/$name.json'))
            as Json;
    final data = await Future.wait(
      ['synthesis', 'completion', 'evidence', 'initial-profile'].map(read),
    );
    final catalog = Catalog(data[0], data[1], data[2], data[3]);
    final controller = ProfileController(
      Engine(catalog),
      await ProfileStore.open(),
    );
    await controller.initialize();
    debugPrint('Diario KH: archivio ${controller.store.profile.path}');
    if (!controller.blocked) {
      final summary = catalog.summary(controller.state);
      debugPrint(
        'Diario KH: ${summary['done']}/${summary['total']} obiettivi, ${controller.engine.distinct(controller.state)}/33 sintesi, livello ${controller.state['settings']['level'] ?? '?'}',
      );
    }
    runApp(DiaryApp(controller: controller));
  } catch (error) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SelectableText('Impossibile aprire il Diario: $error'),
            ),
          ),
        ),
      ),
    );
  }
}
