import 'catalog.dart';

/// Entità tipizzate del profilo.
///
/// Sono *extension types* sopra il JSON persistito: a runtime restano la stessa
/// `Map` (nessuna copia, nessuna conversione), ma il compilatore espone campi
/// tipizzati. Implementano [Json], quindi il codice non ancora migrato che usa
/// `profile['chiave']` continua a funzionare: la migrazione è incrementale.
/// I getter di mappe/liste restituiscono viste (`cast`) che scrivono sulla
/// struttura originale.

enum CollectionStatus {
  unknown('unknown'),
  collected('collected'),
  notCollected('not_collected');

  const CollectionStatus(this.wire);
  final String wire;
  static CollectionStatus parse(String value) => values.firstWhere(
    (s) => s.wire == value,
    orElse: () => throw const FormatException('Stato non valido.'),
  );
}

enum PlanMode {
  all('all'),
  route15('15'),
  selected('selected');

  const PlanMode(this.wire);
  final String wire;
  static PlanMode parse(String value) => values.firstWhere(
    (m) => m.wire == value,
    orElse: () => throw const FormatException('Piano non valido.'),
  );
}

enum TransactionOrigin {
  manual,
  save,
  evidence;

  static TransactionOrigin parse(String value) => values.byName(value);
}

extension type Profile(Json json) implements Json {
  static const currentSchemaVersion = 2;

  int get schemaVersion => json['schemaVersion'] as int;
  String get datasetVersion => json['datasetVersion'] as String;
  String? get completionDatasetVersion =>
      json['completionDatasetVersion'] as String?;
  String? get storyPoint => json['storyPoint'] as String?;
  String get updatedAt => json['updatedAt'] as String;
  set updatedAt(String value) => json['updatedAt'] = value;

  /// Quantità per materiale; `null` = scorta non ancora confermata.
  Map<String, int?> get inventory =>
      (json['inventory'] as Map).cast<String, int?>();

  /// Ricette sintetizzate almeno una volta.
  Map<String, bool> get everCrafted =>
      (json['everCrafted'] as Map).cast<String, bool>();

  /// Numero di sintesi; `null` = sconosciuto.
  Map<String, int?> get craftCount =>
      (json['craftCount'] as Map).cast<String, int?>();

  /// Voci checklist; chiave presente con valore `null` = stato sconosciuto.
  Map<String, bool?> get completion =>
      (json['completion'] as Map).cast<String, bool?>();

  CollectionStatus collection(String id) =>
      CollectionStatus.parse(json['collections'][id] as String);
  void setCollection(String id, CollectionStatus status) =>
      json['collections'][id] = status.wire;

  Plan get plan => Plan(json['plan'] as Json);
  Settings get settings => Settings(json['settings'] as Json);

  /// Raccolta della sessione corrente per materiale.
  Map<String, int> get session => (json['session'] as Map).cast<String, int>();

  List<String> get appliedEvidence =>
      (json['appliedEvidence'] as List).cast<String>();

  String? get activeSaveId => json['activeSaveId'] as String?;
  set activeSaveId(String? value) => json['activeSaveId'] = value;
  SaveSnapshot? get activeSave => activeSaveId == null
      ? null
      : SaveSnapshot(json['saveSnapshots'][activeSaveId] as Json);
  Map<String, SaveSnapshot> get saveSnapshots =>
      (json['saveSnapshots'] as Map).cast<String, SaveSnapshot>();

  /// Contatori letti dal save (`chest.N`, `postcards`, `trinity.Colore`).
  Map<String, dynamic> get saveValues => json['saveValues'] as Json;

  /// Override manuali per ambito (`app` o `file#slot:N`) → chiave → valore.
  Map<String, Json> get manualOverrides =>
      (json['manualOverrides'] as Map).cast<String, Json>();

  List<ProfileTransaction> get transactions =>
      (json['transactions'] as List).cast<ProfileTransaction>();
  set transactions(List<ProfileTransaction> value) =>
      json['transactions'] = value;
}

extension type Plan(Json json) implements Json {
  PlanMode get mode => PlanMode.parse(json['mode'] as String);
  set mode(PlanMode value) => json['mode'] = value.wire;
  List<String> get selected => (json['selected'] as List).cast<String>();

  /// Materiali attesi da ricompense: `dark_matter`, `orichalcum`.
  Map<String, int> get rewards => (json['rewards'] as Map).cast<String, int>();
}

extension type Settings(Json json) implements Json {
  String get edition => json['edition'] as String;
  int? get level => json['level'] as int?;
  int? get mp => json['mp'] as int?;
  int? get lucky => json['lucky'] as int?;
  int? get munny => json['munny'] as int?;

  /// Sblocchi on/off (magie, abilità, trii…); `null` = sconosciuto.
  bool? flag(String name) => json[name] as bool?;
  void setFlag(String name, bool? value) => json[name] = value;
}

extension type SaveSnapshot(Json json) implements Json {
  String get id => json['id'] as String;
  int get slotNumber => json['slotNumber'] as int;
  String get savedAt => json['savedAt'] as String;
  String get sourceFilename => json['source']['filename'] as String;

  /// Ambito usato dagli override manuali: `file#slot:N`.
  String get scope => '$sourceFilename#slot:$slotNumber';
  Map<String, Observation> get observations =>
      (json['observations'] as Map).cast<String, Observation>();
  List<dynamic> get chests => json['chests'] as List;
}

extension type Observation(Json json) implements Json {
  dynamic get value => json['value'];
  String get label => json['label'] as String;
  String get path => json['path'] as String;
}

extension type ProfileTransaction(Json json) implements Json {
  String get label => json['label'] as String;
  String get at => json['at'] as String;
  TransactionOrigin get origin =>
      TransactionOrigin.parse(json['origin'] as String);

  /// Stato precedente, senza `transactions` né `saveSnapshots`.
  Json get before => json['before'] as Json;
}
