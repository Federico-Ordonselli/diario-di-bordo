import 'package:drift_flutter/drift_flutter.dart';
import 'database.dart';

/// Database dell'app nella cartella di supporto della piattaforma.
AppDatabase openAppDatabase() =>
    AppDatabase(driftDatabase(name: 'diario_bordo'));
