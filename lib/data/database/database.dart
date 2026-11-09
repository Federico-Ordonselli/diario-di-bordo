import 'dart:convert';
import 'package:drift/drift.dart';
import '../../domain/catalog.dart';
import '../../domain/profile.dart';

part 'database.g.dart';

/// Titolo a cui appartengono le righe finché lo schema non avrà la tabella
/// `games` (v2): ogni tabella del profilo ha già la colonna `game_id`.
const defaultGameId = 'kh1fm';

/// Colonna `game_id`, parte della chiave primaria di ogni tabella del profilo.
mixin GameScoped on Table {
  TextColumn get gameId => text().withDefault(const Constant(defaultGameId))();
}

/// Valore JSON qualsiasi (scalare o `null`) per le tabelle chiave → valore i cui
/// valori hanno tipi misti: impostazioni, contatori del save, override.
class JsonValueConverter extends TypeConverter<Object?, String> {
  const JsonValueConverter();
  @override
  Object? fromSql(String fromDb) => jsonDecode(fromDb);
  @override
  String toSql(Object? value) => jsonEncode(value);
}

/// Oggetto JSON conservato intero (snapshot del save, `before` delle
/// operazioni): strutture profonde che si leggono e scrivono sempre in blocco.
class JsonObjectConverter extends TypeConverter<Json, String> {
  const JsonObjectConverter();
  @override
  Json fromSql(String fromDb) {
    final decoded = jsonDecode(fromDb);
    if (decoded is! Json) throw const FormatException('Non è un oggetto JSON.');
    return decoded;
  }

  @override
  String toSql(Json value) => jsonEncode(value);
}

class CollectionStatusConverter
    extends TypeConverter<CollectionStatus, String> {
  const CollectionStatusConverter();
  @override
  CollectionStatus fromSql(String fromDb) => CollectionStatus.parse(fromDb);
  @override
  String toSql(CollectionStatus value) => value.wire;
}

class PlanModeConverter extends TypeConverter<PlanMode, String> {
  const PlanModeConverter();
  @override
  PlanMode fromSql(String fromDb) => PlanMode.parse(fromDb);
  @override
  String toSql(PlanMode value) => value.wire;
}

/// Una riga per titolo: i campi scalari del profilo più la revisione usata per
/// rilevare scritture concorrenti (concorrenza ottimistica).
@DataClassName('ProfileRow')
class Profiles extends Table with GameScoped {
  IntColumn get schemaVersion => integer()();
  TextColumn get datasetVersion => text()();
  TextColumn get completionDatasetVersion => text().nullable()();
  TextColumn get storyPoint => text().nullable()();
  TextColumn get updatedAt => text()();
  TextColumn get activeSaveId => text().nullable()();
  TextColumn get planMode => text().map(const PlanModeConverter())();
  IntColumn get revision => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {gameId};
}

/// Quantità per materiale; `null` = scorta non confermata.
@DataClassName('InventoryRow')
class Inventory extends Table with GameScoped {
  TextColumn get materialId => text()();
  IntColumn get quantity => integer().nullable()();

  @override
  Set<Column> get primaryKey => {gameId, materialId};
}

/// Voci della checklist; `done` null = stato sconosciuto.
@DataClassName('CompletionRow')
class Completion extends Table with GameScoped {
  TextColumn get itemId => text()();
  BoolColumn get done => boolean().nullable()();

  @override
  Set<Column> get primaryKey => {gameId, itemId};
}

/// Storico per ricetta: `everCrafted` e `craftCount` del profilo.
@DataClassName('RecipeRow')
class Recipes extends Table with GameScoped {
  TextColumn get recipeId => text()();
  BoolColumn get everCrafted => boolean()();
  IntColumn get craftCount => integer().nullable()();

  @override
  Set<Column> get primaryKey => {gameId, recipeId};
}

@DataClassName('CollectionRow')
class Collections extends Table with GameScoped {
  TextColumn get collectionId => text()();
  TextColumn get status => text().map(const CollectionStatusConverter())();

  @override
  Set<Column> get primaryKey => {gameId, collectionId};
}

/// Impostazioni del giocatore: edizione, livello… e sblocchi on/off.
@DataClassName('SettingRow')
class PlayerSettings extends Table with GameScoped {
  TextColumn get key => text()();
  TextColumn get value => text().map(const JsonValueConverter())();

  @override
  Set<Column> get primaryKey => {gameId, key};
}

/// Contatori letti dal save (`chest.N`, `postcards`, `trinity.Colore`).
@DataClassName('SaveValueRow')
class SaveValues extends Table with GameScoped {
  TextColumn get key => text()();
  TextColumn get value => text().map(const JsonValueConverter())();

  @override
  Set<Column> get primaryKey => {gameId, key};
}

/// Ambiti degli override (`app`, `file#slot:N`): tabella a sé perché un ambito
/// può esistere anche senza override.
@DataClassName('OverrideScopeRow')
class OverrideScopes extends Table with GameScoped {
  TextColumn get scope => text()();

  @override
  Set<Column> get primaryKey => {gameId, scope};
}

@DataClassName('ManualOverrideRow')
class ManualOverrides extends Table with GameScoped {
  TextColumn get scope => text()();
  TextColumn get key => text()();
  TextColumn get value => text().map(const JsonValueConverter())();

  @override
  Set<Column> get primaryKey => {gameId, scope, key};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (game_id, scope) REFERENCES override_scopes (game_id, scope) '
        'ON DELETE CASCADE',
  ];
}

/// Ricette scelte nel piano (modalità `selected`), in ordine di inserimento.
@DataClassName('PlanRecipeRow')
class PlanRecipes extends Table with GameScoped {
  TextColumn get recipeId => text()();

  @override
  Set<Column> get primaryKey => {gameId, recipeId};
}

/// Materiali attesi da ricompense (`dark_matter`, `orichalcum`).
@DataClassName('PlanRewardRow')
class PlanRewards extends Table with GameScoped {
  TextColumn get materialId => text()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {gameId, materialId};
}

/// Raccolta della sessione corrente.
@DataClassName('SessionRow')
class SessionMaterials extends Table with GameScoped {
  TextColumn get materialId => text()();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {gameId, materialId};
}

@DataClassName('AppliedEvidenceRow')
class AppliedEvidence extends Table with GameScoped {
  TextColumn get evidenceId => text()();

  @override
  Set<Column> get primaryKey => {gameId, evidenceId};
}

/// Snapshot del save importati: il documento resta JSON (struttura profonda e
/// immutabile dopo l'import), con a fianco le colonne utili alle query.
@DataClassName('SaveSnapshotRow')
class SaveSnapshots extends Table with GameScoped {
  TextColumn get id => text()();
  IntColumn get slotNumber => integer()();
  TextColumn get savedAt => text()();
  TextColumn get sourceFilename => text()();
  TextColumn get data => text().map(const JsonObjectConverter())();

  @override
  Set<Column> get primaryKey => {gameId, id};
}

/// Cronologia per l'annullamento; `before` è lo stato precedente in JSON.
/// L'ordine è quello di `seq` (autoincrement).
@DataClassName('TransactionRow')
class ProfileTransactions extends Table with GameScoped {
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get label => text()();
  TextColumn get at => text()();
  TextColumn get origin => textEnum<TransactionOrigin>()();
  TextColumn get before => text().map(const JsonObjectConverter())();
}

/// Copia del profilo (JSON) conservata prima dell'ultima importazione.
@DataClassName('BackupRow')
class Backups extends Table with GameScoped {
  TextColumn get createdAt => text()();
  TextColumn get content => text()();

  @override
  Set<Column> get primaryKey => {gameId};
}

/// Schema del database. Resta Dart puro (niente Flutter): `drift_dev schema
/// dump` deve poterlo eseguire. L'apertura su dispositivo è in `connection.dart`.
@DriftDatabase(
  tables: [
    Profiles,
    Inventory,
    Completion,
    Recipes,
    Collections,
    PlayerSettings,
    SaveValues,
    OverrideScopes,
    ManualOverrides,
    PlanRecipes,
    PlanRewards,
    SessionMaterials,
    AppliedEvidence,
    SaveSnapshots,
    ProfileTransactions,
    Backups,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) => customStatement('PRAGMA foreign_keys = ON'),
  );
}
