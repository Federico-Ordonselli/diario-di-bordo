import 'dart:io';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'database.dart';

/// Percorso del database: cartella di supporto della piattaforma, oppure
/// `KH_DATA_DIR` (solo sviluppo desktop, per provare su un archivio separato).
Future<String> appDatabasePath({Map<String, String>? environment}) async {
  final configured = (environment ?? Platform.environment)['KH_DATA_DIR'];
  final directory = Directory(
    configured != null && configured.isNotEmpty
        ? configured
        : (await getApplicationSupportDirectory()).path,
  );
  await directory.create(recursive: true);
  return '${directory.path}${Platform.pathSeparator}diario_bordo.sqlite';
}

/// Database dell'app nel file [path] (vedi [appDatabasePath]).
AppDatabase openAppDatabase(String path) => AppDatabase(
  driftDatabase(
    name: 'diario_bordo',
    native: DriftNativeOptions(databasePath: () async => path),
  ),
);
