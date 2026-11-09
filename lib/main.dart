import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'application/profile_providers.dart';
import 'domain/catalog.dart';
import 'data/database/connection.dart';
import 'data/drift_profile_repository.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    Future<Json> read(String name) async =>
        jsonDecode(await rootBundle.loadString('assets/datasets/$name.json'))
            as Json;
    final data = await Future.wait(
      ['synthesis', 'completion', 'initial-profile'].map(read),
    );
    final catalog = Catalog(data[0], data[1], data[2]);
    final path = await appDatabasePath();
    final repository = DriftProfileRepository(
      openAppDatabase(path),
      location: path,
    );
    final container = ProviderContainer(
      overrides: [
        catalogProvider.overrideWithValue(catalog),
        profileRepositoryProvider.overrideWithValue(repository),
      ],
    );
    await container.read(profileProvider.notifier).initialize();
    debugPrint('Diario di Bordo: archivio ${repository.location}');
    final view = container.read(profileProvider);
    if (!view.blocked) {
      final summary = catalog.summary(view.profile);
      debugPrint(
        'Diario di Bordo: ${summary['done']}/${summary['total']} obiettivi, ${container.read(engineProvider).distinct(view.profile)}/33 sintesi, livello ${view.profile.settings.level ?? '?'}',
      );
    }
    runApp(
      UncontrolledProviderScope(container: container, child: const DiaryApp()),
    );
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
