// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _datasetVersionMeta = const VerificationMeta(
    'datasetVersion',
  );
  @override
  late final GeneratedColumn<String> datasetVersion = GeneratedColumn<String>(
    'dataset_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completionDatasetVersionMeta =
      const VerificationMeta('completionDatasetVersion');
  @override
  late final GeneratedColumn<String> completionDatasetVersion =
      GeneratedColumn<String>(
        'completion_dataset_version',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _storyPointMeta = const VerificationMeta(
    'storyPoint',
  );
  @override
  late final GeneratedColumn<String> storyPoint = GeneratedColumn<String>(
    'story_point',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeSaveIdMeta = const VerificationMeta(
    'activeSaveId',
  );
  @override
  late final GeneratedColumn<String> activeSaveId = GeneratedColumn<String>(
    'active_save_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PlanMode, String> planMode =
      GeneratedColumn<String>(
        'plan_mode',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PlanMode>($ProfilesTable.$converterplanMode);
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    schemaVersion,
    datasetVersion,
    completionDatasetVersion,
    storyPoint,
    updatedAt,
    activeSaveId,
    planMode,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('dataset_version')) {
      context.handle(
        _datasetVersionMeta,
        datasetVersion.isAcceptableOrUnknown(
          data['dataset_version']!,
          _datasetVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_datasetVersionMeta);
    }
    if (data.containsKey('completion_dataset_version')) {
      context.handle(
        _completionDatasetVersionMeta,
        completionDatasetVersion.isAcceptableOrUnknown(
          data['completion_dataset_version']!,
          _completionDatasetVersionMeta,
        ),
      );
    }
    if (data.containsKey('story_point')) {
      context.handle(
        _storyPointMeta,
        storyPoint.isAcceptableOrUnknown(data['story_point']!, _storyPointMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('active_save_id')) {
      context.handle(
        _activeSaveIdMeta,
        activeSaveId.isAcceptableOrUnknown(
          data['active_save_id']!,
          _activeSaveIdMeta,
        ),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      datasetVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dataset_version'],
      )!,
      completionDatasetVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completion_dataset_version'],
      ),
      storyPoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_point'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      activeSaveId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_save_id'],
      ),
      planMode: $ProfilesTable.$converterplanMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}plan_mode'],
        )!,
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  static TypeConverter<PlanMode, String> $converterplanMode =
      const PlanModeConverter();
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  final String gameId;
  final int schemaVersion;
  final String datasetVersion;
  final String? completionDatasetVersion;
  final String? storyPoint;
  final String updatedAt;
  final String? activeSaveId;
  final PlanMode planMode;
  final int revision;
  const ProfileRow({
    required this.gameId,
    required this.schemaVersion,
    required this.datasetVersion,
    this.completionDatasetVersion,
    this.storyPoint,
    required this.updatedAt,
    this.activeSaveId,
    required this.planMode,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['dataset_version'] = Variable<String>(datasetVersion);
    if (!nullToAbsent || completionDatasetVersion != null) {
      map['completion_dataset_version'] = Variable<String>(
        completionDatasetVersion,
      );
    }
    if (!nullToAbsent || storyPoint != null) {
      map['story_point'] = Variable<String>(storyPoint);
    }
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || activeSaveId != null) {
      map['active_save_id'] = Variable<String>(activeSaveId);
    }
    {
      map['plan_mode'] = Variable<String>(
        $ProfilesTable.$converterplanMode.toSql(planMode),
      );
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      gameId: Value(gameId),
      schemaVersion: Value(schemaVersion),
      datasetVersion: Value(datasetVersion),
      completionDatasetVersion: completionDatasetVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(completionDatasetVersion),
      storyPoint: storyPoint == null && nullToAbsent
          ? const Value.absent()
          : Value(storyPoint),
      updatedAt: Value(updatedAt),
      activeSaveId: activeSaveId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeSaveId),
      planMode: Value(planMode),
      revision: Value(revision),
    );
  }

  factory ProfileRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      datasetVersion: serializer.fromJson<String>(json['datasetVersion']),
      completionDatasetVersion: serializer.fromJson<String?>(
        json['completionDatasetVersion'],
      ),
      storyPoint: serializer.fromJson<String?>(json['storyPoint']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      activeSaveId: serializer.fromJson<String?>(json['activeSaveId']),
      planMode: serializer.fromJson<PlanMode>(json['planMode']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'datasetVersion': serializer.toJson<String>(datasetVersion),
      'completionDatasetVersion': serializer.toJson<String?>(
        completionDatasetVersion,
      ),
      'storyPoint': serializer.toJson<String?>(storyPoint),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'activeSaveId': serializer.toJson<String?>(activeSaveId),
      'planMode': serializer.toJson<PlanMode>(planMode),
      'revision': serializer.toJson<int>(revision),
    };
  }

  ProfileRow copyWith({
    String? gameId,
    int? schemaVersion,
    String? datasetVersion,
    Value<String?> completionDatasetVersion = const Value.absent(),
    Value<String?> storyPoint = const Value.absent(),
    String? updatedAt,
    Value<String?> activeSaveId = const Value.absent(),
    PlanMode? planMode,
    int? revision,
  }) => ProfileRow(
    gameId: gameId ?? this.gameId,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    datasetVersion: datasetVersion ?? this.datasetVersion,
    completionDatasetVersion: completionDatasetVersion.present
        ? completionDatasetVersion.value
        : this.completionDatasetVersion,
    storyPoint: storyPoint.present ? storyPoint.value : this.storyPoint,
    updatedAt: updatedAt ?? this.updatedAt,
    activeSaveId: activeSaveId.present ? activeSaveId.value : this.activeSaveId,
    planMode: planMode ?? this.planMode,
    revision: revision ?? this.revision,
  );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      datasetVersion: data.datasetVersion.present
          ? data.datasetVersion.value
          : this.datasetVersion,
      completionDatasetVersion: data.completionDatasetVersion.present
          ? data.completionDatasetVersion.value
          : this.completionDatasetVersion,
      storyPoint: data.storyPoint.present
          ? data.storyPoint.value
          : this.storyPoint,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      activeSaveId: data.activeSaveId.present
          ? data.activeSaveId.value
          : this.activeSaveId,
      planMode: data.planMode.present ? data.planMode.value : this.planMode,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('gameId: $gameId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('datasetVersion: $datasetVersion, ')
          ..write('completionDatasetVersion: $completionDatasetVersion, ')
          ..write('storyPoint: $storyPoint, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('activeSaveId: $activeSaveId, ')
          ..write('planMode: $planMode, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    gameId,
    schemaVersion,
    datasetVersion,
    completionDatasetVersion,
    storyPoint,
    updatedAt,
    activeSaveId,
    planMode,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.gameId == this.gameId &&
          other.schemaVersion == this.schemaVersion &&
          other.datasetVersion == this.datasetVersion &&
          other.completionDatasetVersion == this.completionDatasetVersion &&
          other.storyPoint == this.storyPoint &&
          other.updatedAt == this.updatedAt &&
          other.activeSaveId == this.activeSaveId &&
          other.planMode == this.planMode &&
          other.revision == this.revision);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> gameId;
  final Value<int> schemaVersion;
  final Value<String> datasetVersion;
  final Value<String?> completionDatasetVersion;
  final Value<String?> storyPoint;
  final Value<String> updatedAt;
  final Value<String?> activeSaveId;
  final Value<PlanMode> planMode;
  final Value<int> revision;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.gameId = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.datasetVersion = const Value.absent(),
    this.completionDatasetVersion = const Value.absent(),
    this.storyPoint = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.activeSaveId = const Value.absent(),
    this.planMode = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.gameId = const Value.absent(),
    required int schemaVersion,
    required String datasetVersion,
    this.completionDatasetVersion = const Value.absent(),
    this.storyPoint = const Value.absent(),
    required String updatedAt,
    this.activeSaveId = const Value.absent(),
    required PlanMode planMode,
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : schemaVersion = Value(schemaVersion),
       datasetVersion = Value(datasetVersion),
       updatedAt = Value(updatedAt),
       planMode = Value(planMode);
  static Insertable<ProfileRow> custom({
    Expression<String>? gameId,
    Expression<int>? schemaVersion,
    Expression<String>? datasetVersion,
    Expression<String>? completionDatasetVersion,
    Expression<String>? storyPoint,
    Expression<String>? updatedAt,
    Expression<String>? activeSaveId,
    Expression<String>? planMode,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (datasetVersion != null) 'dataset_version': datasetVersion,
      if (completionDatasetVersion != null)
        'completion_dataset_version': completionDatasetVersion,
      if (storyPoint != null) 'story_point': storyPoint,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (activeSaveId != null) 'active_save_id': activeSaveId,
      if (planMode != null) 'plan_mode': planMode,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? gameId,
    Value<int>? schemaVersion,
    Value<String>? datasetVersion,
    Value<String?>? completionDatasetVersion,
    Value<String?>? storyPoint,
    Value<String>? updatedAt,
    Value<String?>? activeSaveId,
    Value<PlanMode>? planMode,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      gameId: gameId ?? this.gameId,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      datasetVersion: datasetVersion ?? this.datasetVersion,
      completionDatasetVersion:
          completionDatasetVersion ?? this.completionDatasetVersion,
      storyPoint: storyPoint ?? this.storyPoint,
      updatedAt: updatedAt ?? this.updatedAt,
      activeSaveId: activeSaveId ?? this.activeSaveId,
      planMode: planMode ?? this.planMode,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (datasetVersion.present) {
      map['dataset_version'] = Variable<String>(datasetVersion.value);
    }
    if (completionDatasetVersion.present) {
      map['completion_dataset_version'] = Variable<String>(
        completionDatasetVersion.value,
      );
    }
    if (storyPoint.present) {
      map['story_point'] = Variable<String>(storyPoint.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (activeSaveId.present) {
      map['active_save_id'] = Variable<String>(activeSaveId.value);
    }
    if (planMode.present) {
      map['plan_mode'] = Variable<String>(
        $ProfilesTable.$converterplanMode.toSql(planMode.value),
      );
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('datasetVersion: $datasetVersion, ')
          ..write('completionDatasetVersion: $completionDatasetVersion, ')
          ..write('storyPoint: $storyPoint, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('activeSaveId: $activeSaveId, ')
          ..write('planMode: $planMode, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryTable extends Inventory
    with TableInfo<$InventoryTable, InventoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _materialIdMeta = const VerificationMeta(
    'materialId',
  );
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
    'material_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, materialId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('material_id')) {
      context.handle(
        _materialIdMeta,
        materialId.isAcceptableOrUnknown(data['material_id']!, _materialIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, materialId};
  @override
  InventoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      materialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      ),
    );
  }

  @override
  $InventoryTable createAlias(String alias) {
    return $InventoryTable(attachedDatabase, alias);
  }
}

class InventoryRow extends DataClass implements Insertable<InventoryRow> {
  final String gameId;
  final String materialId;
  final int? quantity;
  const InventoryRow({
    required this.gameId,
    required this.materialId,
    this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['material_id'] = Variable<String>(materialId);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<int>(quantity);
    }
    return map;
  }

  InventoryCompanion toCompanion(bool nullToAbsent) {
    return InventoryCompanion(
      gameId: Value(gameId),
      materialId: Value(materialId),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
    );
  }

  factory InventoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      materialId: serializer.fromJson<String>(json['materialId']),
      quantity: serializer.fromJson<int?>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'materialId': serializer.toJson<String>(materialId),
      'quantity': serializer.toJson<int?>(quantity),
    };
  }

  InventoryRow copyWith({
    String? gameId,
    String? materialId,
    Value<int?> quantity = const Value.absent(),
  }) => InventoryRow(
    gameId: gameId ?? this.gameId,
    materialId: materialId ?? this.materialId,
    quantity: quantity.present ? quantity.value : this.quantity,
  );
  InventoryRow copyWithCompanion(InventoryCompanion data) {
    return InventoryRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      materialId: data.materialId.present
          ? data.materialId.value
          : this.materialId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryRow(')
          ..write('gameId: $gameId, ')
          ..write('materialId: $materialId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, materialId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryRow &&
          other.gameId == this.gameId &&
          other.materialId == this.materialId &&
          other.quantity == this.quantity);
}

class InventoryCompanion extends UpdateCompanion<InventoryRow> {
  final Value<String> gameId;
  final Value<String> materialId;
  final Value<int?> quantity;
  final Value<int> rowid;
  const InventoryCompanion({
    this.gameId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryCompanion.insert({
    this.gameId = const Value.absent(),
    required String materialId,
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : materialId = Value(materialId);
  static Insertable<InventoryRow> custom({
    Expression<String>? gameId,
    Expression<String>? materialId,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (materialId != null) 'material_id': materialId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryCompanion copyWith({
    Value<String>? gameId,
    Value<String>? materialId,
    Value<int?>? quantity,
    Value<int>? rowid,
  }) {
    return InventoryCompanion(
      gameId: gameId ?? this.gameId,
      materialId: materialId ?? this.materialId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryCompanion(')
          ..write('gameId: $gameId, ')
          ..write('materialId: $materialId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompletionTable extends Completion
    with TableInfo<$CompletionTable, CompletionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompletionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doneMeta = const VerificationMeta('done');
  @override
  late final GeneratedColumn<bool> done = GeneratedColumn<bool>(
    'done',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("done" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, itemId, done];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'completion';
  @override
  VerificationContext validateIntegrity(
    Insertable<CompletionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('done')) {
      context.handle(
        _doneMeta,
        done.isAcceptableOrUnknown(data['done']!, _doneMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, itemId};
  @override
  CompletionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CompletionRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      done: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}done'],
      ),
    );
  }

  @override
  $CompletionTable createAlias(String alias) {
    return $CompletionTable(attachedDatabase, alias);
  }
}

class CompletionRow extends DataClass implements Insertable<CompletionRow> {
  final String gameId;
  final String itemId;
  final bool? done;
  const CompletionRow({required this.gameId, required this.itemId, this.done});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['item_id'] = Variable<String>(itemId);
    if (!nullToAbsent || done != null) {
      map['done'] = Variable<bool>(done);
    }
    return map;
  }

  CompletionCompanion toCompanion(bool nullToAbsent) {
    return CompletionCompanion(
      gameId: Value(gameId),
      itemId: Value(itemId),
      done: done == null && nullToAbsent ? const Value.absent() : Value(done),
    );
  }

  factory CompletionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CompletionRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      done: serializer.fromJson<bool?>(json['done']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'itemId': serializer.toJson<String>(itemId),
      'done': serializer.toJson<bool?>(done),
    };
  }

  CompletionRow copyWith({
    String? gameId,
    String? itemId,
    Value<bool?> done = const Value.absent(),
  }) => CompletionRow(
    gameId: gameId ?? this.gameId,
    itemId: itemId ?? this.itemId,
    done: done.present ? done.value : this.done,
  );
  CompletionRow copyWithCompanion(CompletionCompanion data) {
    return CompletionRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      done: data.done.present ? data.done.value : this.done,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CompletionRow(')
          ..write('gameId: $gameId, ')
          ..write('itemId: $itemId, ')
          ..write('done: $done')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, itemId, done);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CompletionRow &&
          other.gameId == this.gameId &&
          other.itemId == this.itemId &&
          other.done == this.done);
}

class CompletionCompanion extends UpdateCompanion<CompletionRow> {
  final Value<String> gameId;
  final Value<String> itemId;
  final Value<bool?> done;
  final Value<int> rowid;
  const CompletionCompanion({
    this.gameId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompletionCompanion.insert({
    this.gameId = const Value.absent(),
    required String itemId,
    this.done = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId);
  static Insertable<CompletionRow> custom({
    Expression<String>? gameId,
    Expression<String>? itemId,
    Expression<bool>? done,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (itemId != null) 'item_id': itemId,
      if (done != null) 'done': done,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompletionCompanion copyWith({
    Value<String>? gameId,
    Value<String>? itemId,
    Value<bool?>? done,
    Value<int>? rowid,
  }) {
    return CompletionCompanion(
      gameId: gameId ?? this.gameId,
      itemId: itemId ?? this.itemId,
      done: done ?? this.done,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (done.present) {
      map['done'] = Variable<bool>(done.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompletionCompanion(')
          ..write('gameId: $gameId, ')
          ..write('itemId: $itemId, ')
          ..write('done: $done, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTable extends Recipes with TableInfo<$RecipesTable, RecipeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _everCraftedMeta = const VerificationMeta(
    'everCrafted',
  );
  @override
  late final GeneratedColumn<bool> everCrafted = GeneratedColumn<bool>(
    'ever_crafted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ever_crafted" IN (0, 1))',
    ),
  );
  static const VerificationMeta _craftCountMeta = const VerificationMeta(
    'craftCount',
  );
  @override
  late final GeneratedColumn<int> craftCount = GeneratedColumn<int>(
    'craft_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    recipeId,
    everCrafted,
    craftCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('ever_crafted')) {
      context.handle(
        _everCraftedMeta,
        everCrafted.isAcceptableOrUnknown(
          data['ever_crafted']!,
          _everCraftedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_everCraftedMeta);
    }
    if (data.containsKey('craft_count')) {
      context.handle(
        _craftCountMeta,
        craftCount.isAcceptableOrUnknown(data['craft_count']!, _craftCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, recipeId};
  @override
  RecipeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipeRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
      everCrafted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ever_crafted'],
      )!,
      craftCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}craft_count'],
      ),
    );
  }

  @override
  $RecipesTable createAlias(String alias) {
    return $RecipesTable(attachedDatabase, alias);
  }
}

class RecipeRow extends DataClass implements Insertable<RecipeRow> {
  final String gameId;
  final String recipeId;
  final bool everCrafted;
  final int? craftCount;
  const RecipeRow({
    required this.gameId,
    required this.recipeId,
    required this.everCrafted,
    this.craftCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['recipe_id'] = Variable<String>(recipeId);
    map['ever_crafted'] = Variable<bool>(everCrafted);
    if (!nullToAbsent || craftCount != null) {
      map['craft_count'] = Variable<int>(craftCount);
    }
    return map;
  }

  RecipesCompanion toCompanion(bool nullToAbsent) {
    return RecipesCompanion(
      gameId: Value(gameId),
      recipeId: Value(recipeId),
      everCrafted: Value(everCrafted),
      craftCount: craftCount == null && nullToAbsent
          ? const Value.absent()
          : Value(craftCount),
    );
  }

  factory RecipeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipeRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      everCrafted: serializer.fromJson<bool>(json['everCrafted']),
      craftCount: serializer.fromJson<int?>(json['craftCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'recipeId': serializer.toJson<String>(recipeId),
      'everCrafted': serializer.toJson<bool>(everCrafted),
      'craftCount': serializer.toJson<int?>(craftCount),
    };
  }

  RecipeRow copyWith({
    String? gameId,
    String? recipeId,
    bool? everCrafted,
    Value<int?> craftCount = const Value.absent(),
  }) => RecipeRow(
    gameId: gameId ?? this.gameId,
    recipeId: recipeId ?? this.recipeId,
    everCrafted: everCrafted ?? this.everCrafted,
    craftCount: craftCount.present ? craftCount.value : this.craftCount,
  );
  RecipeRow copyWithCompanion(RecipesCompanion data) {
    return RecipeRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      everCrafted: data.everCrafted.present
          ? data.everCrafted.value
          : this.everCrafted,
      craftCount: data.craftCount.present
          ? data.craftCount.value
          : this.craftCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipeRow(')
          ..write('gameId: $gameId, ')
          ..write('recipeId: $recipeId, ')
          ..write('everCrafted: $everCrafted, ')
          ..write('craftCount: $craftCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, recipeId, everCrafted, craftCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipeRow &&
          other.gameId == this.gameId &&
          other.recipeId == this.recipeId &&
          other.everCrafted == this.everCrafted &&
          other.craftCount == this.craftCount);
}

class RecipesCompanion extends UpdateCompanion<RecipeRow> {
  final Value<String> gameId;
  final Value<String> recipeId;
  final Value<bool> everCrafted;
  final Value<int?> craftCount;
  final Value<int> rowid;
  const RecipesCompanion({
    this.gameId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.everCrafted = const Value.absent(),
    this.craftCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesCompanion.insert({
    this.gameId = const Value.absent(),
    required String recipeId,
    required bool everCrafted,
    this.craftCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : recipeId = Value(recipeId),
       everCrafted = Value(everCrafted);
  static Insertable<RecipeRow> custom({
    Expression<String>? gameId,
    Expression<String>? recipeId,
    Expression<bool>? everCrafted,
    Expression<int>? craftCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (everCrafted != null) 'ever_crafted': everCrafted,
      if (craftCount != null) 'craft_count': craftCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesCompanion copyWith({
    Value<String>? gameId,
    Value<String>? recipeId,
    Value<bool>? everCrafted,
    Value<int?>? craftCount,
    Value<int>? rowid,
  }) {
    return RecipesCompanion(
      gameId: gameId ?? this.gameId,
      recipeId: recipeId ?? this.recipeId,
      everCrafted: everCrafted ?? this.everCrafted,
      craftCount: craftCount ?? this.craftCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (everCrafted.present) {
      map['ever_crafted'] = Variable<bool>(everCrafted.value);
    }
    if (craftCount.present) {
      map['craft_count'] = Variable<int>(craftCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecipesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('recipeId: $recipeId, ')
          ..write('everCrafted: $everCrafted, ')
          ..write('craftCount: $craftCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, CollectionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CollectionStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CollectionStatus>($CollectionsTable.$converterstatus);
  @override
  List<GeneratedColumn> get $columns => [gameId, collectionId, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, collectionId};
  @override
  CollectionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      status: $CollectionsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }

  static TypeConverter<CollectionStatus, String> $converterstatus =
      const CollectionStatusConverter();
}

class CollectionRow extends DataClass implements Insertable<CollectionRow> {
  final String gameId;
  final String collectionId;
  final CollectionStatus status;
  const CollectionRow({
    required this.gameId,
    required this.collectionId,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['collection_id'] = Variable<String>(collectionId);
    {
      map['status'] = Variable<String>(
        $CollectionsTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      gameId: Value(gameId),
      collectionId: Value(collectionId),
      status: Value(status),
    );
  }

  factory CollectionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      status: serializer.fromJson<CollectionStatus>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'collectionId': serializer.toJson<String>(collectionId),
      'status': serializer.toJson<CollectionStatus>(status),
    };
  }

  CollectionRow copyWith({
    String? gameId,
    String? collectionId,
    CollectionStatus? status,
  }) => CollectionRow(
    gameId: gameId ?? this.gameId,
    collectionId: collectionId ?? this.collectionId,
    status: status ?? this.status,
  );
  CollectionRow copyWithCompanion(CollectionsCompanion data) {
    return CollectionRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionRow(')
          ..write('gameId: $gameId, ')
          ..write('collectionId: $collectionId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, collectionId, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionRow &&
          other.gameId == this.gameId &&
          other.collectionId == this.collectionId &&
          other.status == this.status);
}

class CollectionsCompanion extends UpdateCompanion<CollectionRow> {
  final Value<String> gameId;
  final Value<String> collectionId;
  final Value<CollectionStatus> status;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.gameId = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    this.gameId = const Value.absent(),
    required String collectionId,
    required CollectionStatus status,
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       status = Value(status);
  static Insertable<CollectionRow> custom({
    Expression<String>? gameId,
    Expression<String>? collectionId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (collectionId != null) 'collection_id': collectionId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? gameId,
    Value<String>? collectionId,
    Value<CollectionStatus>? status,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      gameId: gameId ?? this.gameId,
      collectionId: collectionId ?? this.collectionId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CollectionsTable.$converterstatus.toSql(status.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('collectionId: $collectionId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayerSettingsTable extends PlayerSettings
    with TableInfo<$PlayerSettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Object?, String> value =
      GeneratedColumn<String>(
        'value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Object?>($PlayerSettingsTable.$convertervalue);
  @override
  List<GeneratedColumn> get $columns => [gameId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: $PlayerSettingsTable.$convertervalue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}value'],
        )!,
      ),
    );
  }

  @override
  $PlayerSettingsTable createAlias(String alias) {
    return $PlayerSettingsTable(attachedDatabase, alias);
  }

  static TypeConverter<Object?, String> $convertervalue =
      const JsonValueConverter();
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String gameId;
  final String key;
  final Object? value;
  const SettingRow({required this.gameId, required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(
        $PlayerSettingsTable.$convertervalue.toSql(value),
      );
    }
    return map;
  }

  PlayerSettingsCompanion toCompanion(bool nullToAbsent) {
    return PlayerSettingsCompanion(
      gameId: Value(gameId),
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<Object?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<Object?>(value),
    };
  }

  SettingRow copyWith({
    String? gameId,
    String? key,
    Value<Object?> value = const Value.absent(),
  }) => SettingRow(
    gameId: gameId ?? this.gameId,
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SettingRow copyWithCompanion(PlayerSettingsCompanion data) {
    return SettingRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('gameId: $gameId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.gameId == this.gameId &&
          other.key == this.key &&
          other.value == this.value);
}

class PlayerSettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> gameId;
  final Value<String> key;
  final Value<Object?> value;
  final Value<int> rowid;
  const PlayerSettingsCompanion({
    this.gameId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayerSettingsCompanion.insert({
    this.gameId = const Value.absent(),
    required String key,
    required Object? value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? gameId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayerSettingsCompanion copyWith({
    Value<String>? gameId,
    Value<String>? key,
    Value<Object?>? value,
    Value<int>? rowid,
  }) {
    return PlayerSettingsCompanion(
      gameId: gameId ?? this.gameId,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(
        $PlayerSettingsTable.$convertervalue.toSql(value.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerSettingsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaveValuesTable extends SaveValues
    with TableInfo<$SaveValuesTable, SaveValueRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaveValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Object?, String> value =
      GeneratedColumn<String>(
        'value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Object?>($SaveValuesTable.$convertervalue);
  @override
  List<GeneratedColumn> get $columns => [gameId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'save_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaveValueRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, key};
  @override
  SaveValueRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaveValueRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: $SaveValuesTable.$convertervalue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}value'],
        )!,
      ),
    );
  }

  @override
  $SaveValuesTable createAlias(String alias) {
    return $SaveValuesTable(attachedDatabase, alias);
  }

  static TypeConverter<Object?, String> $convertervalue =
      const JsonValueConverter();
}

class SaveValueRow extends DataClass implements Insertable<SaveValueRow> {
  final String gameId;
  final String key;
  final Object? value;
  const SaveValueRow({required this.gameId, required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(
        $SaveValuesTable.$convertervalue.toSql(value),
      );
    }
    return map;
  }

  SaveValuesCompanion toCompanion(bool nullToAbsent) {
    return SaveValuesCompanion(
      gameId: Value(gameId),
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SaveValueRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaveValueRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<Object?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<Object?>(value),
    };
  }

  SaveValueRow copyWith({
    String? gameId,
    String? key,
    Value<Object?> value = const Value.absent(),
  }) => SaveValueRow(
    gameId: gameId ?? this.gameId,
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SaveValueRow copyWithCompanion(SaveValuesCompanion data) {
    return SaveValueRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaveValueRow(')
          ..write('gameId: $gameId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveValueRow &&
          other.gameId == this.gameId &&
          other.key == this.key &&
          other.value == this.value);
}

class SaveValuesCompanion extends UpdateCompanion<SaveValueRow> {
  final Value<String> gameId;
  final Value<String> key;
  final Value<Object?> value;
  final Value<int> rowid;
  const SaveValuesCompanion({
    this.gameId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaveValuesCompanion.insert({
    this.gameId = const Value.absent(),
    required String key,
    required Object? value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SaveValueRow> custom({
    Expression<String>? gameId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaveValuesCompanion copyWith({
    Value<String>? gameId,
    Value<String>? key,
    Value<Object?>? value,
    Value<int>? rowid,
  }) {
    return SaveValuesCompanion(
      gameId: gameId ?? this.gameId,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(
        $SaveValuesTable.$convertervalue.toSql(value.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaveValuesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OverrideScopesTable extends OverrideScopes
    with TableInfo<$OverrideScopesTable, OverrideScopeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OverrideScopesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, scope];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'override_scopes';
  @override
  VerificationContext validateIntegrity(
    Insertable<OverrideScopeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, scope};
  @override
  OverrideScopeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OverrideScopeRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
    );
  }

  @override
  $OverrideScopesTable createAlias(String alias) {
    return $OverrideScopesTable(attachedDatabase, alias);
  }
}

class OverrideScopeRow extends DataClass
    implements Insertable<OverrideScopeRow> {
  final String gameId;
  final String scope;
  const OverrideScopeRow({required this.gameId, required this.scope});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['scope'] = Variable<String>(scope);
    return map;
  }

  OverrideScopesCompanion toCompanion(bool nullToAbsent) {
    return OverrideScopesCompanion(gameId: Value(gameId), scope: Value(scope));
  }

  factory OverrideScopeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OverrideScopeRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      scope: serializer.fromJson<String>(json['scope']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'scope': serializer.toJson<String>(scope),
    };
  }

  OverrideScopeRow copyWith({String? gameId, String? scope}) =>
      OverrideScopeRow(
        gameId: gameId ?? this.gameId,
        scope: scope ?? this.scope,
      );
  OverrideScopeRow copyWithCompanion(OverrideScopesCompanion data) {
    return OverrideScopeRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      scope: data.scope.present ? data.scope.value : this.scope,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OverrideScopeRow(')
          ..write('gameId: $gameId, ')
          ..write('scope: $scope')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, scope);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OverrideScopeRow &&
          other.gameId == this.gameId &&
          other.scope == this.scope);
}

class OverrideScopesCompanion extends UpdateCompanion<OverrideScopeRow> {
  final Value<String> gameId;
  final Value<String> scope;
  final Value<int> rowid;
  const OverrideScopesCompanion({
    this.gameId = const Value.absent(),
    this.scope = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OverrideScopesCompanion.insert({
    this.gameId = const Value.absent(),
    required String scope,
    this.rowid = const Value.absent(),
  }) : scope = Value(scope);
  static Insertable<OverrideScopeRow> custom({
    Expression<String>? gameId,
    Expression<String>? scope,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (scope != null) 'scope': scope,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OverrideScopesCompanion copyWith({
    Value<String>? gameId,
    Value<String>? scope,
    Value<int>? rowid,
  }) {
    return OverrideScopesCompanion(
      gameId: gameId ?? this.gameId,
      scope: scope ?? this.scope,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OverrideScopesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('scope: $scope, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ManualOverridesTable extends ManualOverrides
    with TableInfo<$ManualOverridesTable, ManualOverrideRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManualOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Object?, String> value =
      GeneratedColumn<String>(
        'value',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Object?>($ManualOverridesTable.$convertervalue);
  @override
  List<GeneratedColumn> get $columns => [gameId, scope, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manual_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<ManualOverrideRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, scope, key};
  @override
  ManualOverrideRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ManualOverrideRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: $ManualOverridesTable.$convertervalue.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}value'],
        )!,
      ),
    );
  }

  @override
  $ManualOverridesTable createAlias(String alias) {
    return $ManualOverridesTable(attachedDatabase, alias);
  }

  static TypeConverter<Object?, String> $convertervalue =
      const JsonValueConverter();
}

class ManualOverrideRow extends DataClass
    implements Insertable<ManualOverrideRow> {
  final String gameId;
  final String scope;
  final String key;
  final Object? value;
  const ManualOverrideRow({
    required this.gameId,
    required this.scope,
    required this.key,
    this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['scope'] = Variable<String>(scope);
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(
        $ManualOverridesTable.$convertervalue.toSql(value),
      );
    }
    return map;
  }

  ManualOverridesCompanion toCompanion(bool nullToAbsent) {
    return ManualOverridesCompanion(
      gameId: Value(gameId),
      scope: Value(scope),
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory ManualOverrideRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ManualOverrideRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      scope: serializer.fromJson<String>(json['scope']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<Object?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'scope': serializer.toJson<String>(scope),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<Object?>(value),
    };
  }

  ManualOverrideRow copyWith({
    String? gameId,
    String? scope,
    String? key,
    Value<Object?> value = const Value.absent(),
  }) => ManualOverrideRow(
    gameId: gameId ?? this.gameId,
    scope: scope ?? this.scope,
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  ManualOverrideRow copyWithCompanion(ManualOverridesCompanion data) {
    return ManualOverrideRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      scope: data.scope.present ? data.scope.value : this.scope,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ManualOverrideRow(')
          ..write('gameId: $gameId, ')
          ..write('scope: $scope, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, scope, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ManualOverrideRow &&
          other.gameId == this.gameId &&
          other.scope == this.scope &&
          other.key == this.key &&
          other.value == this.value);
}

class ManualOverridesCompanion extends UpdateCompanion<ManualOverrideRow> {
  final Value<String> gameId;
  final Value<String> scope;
  final Value<String> key;
  final Value<Object?> value;
  final Value<int> rowid;
  const ManualOverridesCompanion({
    this.gameId = const Value.absent(),
    this.scope = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManualOverridesCompanion.insert({
    this.gameId = const Value.absent(),
    required String scope,
    required String key,
    required Object? value,
    this.rowid = const Value.absent(),
  }) : scope = Value(scope),
       key = Value(key),
       value = Value(value);
  static Insertable<ManualOverrideRow> custom({
    Expression<String>? gameId,
    Expression<String>? scope,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (scope != null) 'scope': scope,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManualOverridesCompanion copyWith({
    Value<String>? gameId,
    Value<String>? scope,
    Value<String>? key,
    Value<Object?>? value,
    Value<int>? rowid,
  }) {
    return ManualOverridesCompanion(
      gameId: gameId ?? this.gameId,
      scope: scope ?? this.scope,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(
        $ManualOverridesTable.$convertervalue.toSql(value.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManualOverridesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('scope: $scope, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanRecipesTable extends PlanRecipes
    with TableInfo<$PlanRecipesTable, PlanRecipeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _recipeIdMeta = const VerificationMeta(
    'recipeId',
  );
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
    'recipe_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, recipeId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRecipeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('recipe_id')) {
      context.handle(
        _recipeIdMeta,
        recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, recipeId};
  @override
  PlanRecipeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRecipeRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      recipeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipe_id'],
      )!,
    );
  }

  @override
  $PlanRecipesTable createAlias(String alias) {
    return $PlanRecipesTable(attachedDatabase, alias);
  }
}

class PlanRecipeRow extends DataClass implements Insertable<PlanRecipeRow> {
  final String gameId;
  final String recipeId;
  const PlanRecipeRow({required this.gameId, required this.recipeId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['recipe_id'] = Variable<String>(recipeId);
    return map;
  }

  PlanRecipesCompanion toCompanion(bool nullToAbsent) {
    return PlanRecipesCompanion(
      gameId: Value(gameId),
      recipeId: Value(recipeId),
    );
  }

  factory PlanRecipeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRecipeRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'recipeId': serializer.toJson<String>(recipeId),
    };
  }

  PlanRecipeRow copyWith({String? gameId, String? recipeId}) => PlanRecipeRow(
    gameId: gameId ?? this.gameId,
    recipeId: recipeId ?? this.recipeId,
  );
  PlanRecipeRow copyWithCompanion(PlanRecipesCompanion data) {
    return PlanRecipeRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRecipeRow(')
          ..write('gameId: $gameId, ')
          ..write('recipeId: $recipeId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, recipeId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRecipeRow &&
          other.gameId == this.gameId &&
          other.recipeId == this.recipeId);
}

class PlanRecipesCompanion extends UpdateCompanion<PlanRecipeRow> {
  final Value<String> gameId;
  final Value<String> recipeId;
  final Value<int> rowid;
  const PlanRecipesCompanion({
    this.gameId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanRecipesCompanion.insert({
    this.gameId = const Value.absent(),
    required String recipeId,
    this.rowid = const Value.absent(),
  }) : recipeId = Value(recipeId);
  static Insertable<PlanRecipeRow> custom({
    Expression<String>? gameId,
    Expression<String>? recipeId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanRecipesCompanion copyWith({
    Value<String>? gameId,
    Value<String>? recipeId,
    Value<int>? rowid,
  }) {
    return PlanRecipesCompanion(
      gameId: gameId ?? this.gameId,
      recipeId: recipeId ?? this.recipeId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanRecipesCompanion(')
          ..write('gameId: $gameId, ')
          ..write('recipeId: $recipeId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanRewardsTable extends PlanRewards
    with TableInfo<$PlanRewardsTable, PlanRewardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanRewardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _materialIdMeta = const VerificationMeta(
    'materialId',
  );
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
    'material_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, materialId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_rewards';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRewardRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('material_id')) {
      context.handle(
        _materialIdMeta,
        materialId.isAcceptableOrUnknown(data['material_id']!, _materialIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, materialId};
  @override
  PlanRewardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRewardRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      materialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $PlanRewardsTable createAlias(String alias) {
    return $PlanRewardsTable(attachedDatabase, alias);
  }
}

class PlanRewardRow extends DataClass implements Insertable<PlanRewardRow> {
  final String gameId;
  final String materialId;
  final int quantity;
  const PlanRewardRow({
    required this.gameId,
    required this.materialId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['material_id'] = Variable<String>(materialId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  PlanRewardsCompanion toCompanion(bool nullToAbsent) {
    return PlanRewardsCompanion(
      gameId: Value(gameId),
      materialId: Value(materialId),
      quantity: Value(quantity),
    );
  }

  factory PlanRewardRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRewardRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      materialId: serializer.fromJson<String>(json['materialId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'materialId': serializer.toJson<String>(materialId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  PlanRewardRow copyWith({String? gameId, String? materialId, int? quantity}) =>
      PlanRewardRow(
        gameId: gameId ?? this.gameId,
        materialId: materialId ?? this.materialId,
        quantity: quantity ?? this.quantity,
      );
  PlanRewardRow copyWithCompanion(PlanRewardsCompanion data) {
    return PlanRewardRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      materialId: data.materialId.present
          ? data.materialId.value
          : this.materialId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRewardRow(')
          ..write('gameId: $gameId, ')
          ..write('materialId: $materialId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, materialId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRewardRow &&
          other.gameId == this.gameId &&
          other.materialId == this.materialId &&
          other.quantity == this.quantity);
}

class PlanRewardsCompanion extends UpdateCompanion<PlanRewardRow> {
  final Value<String> gameId;
  final Value<String> materialId;
  final Value<int> quantity;
  final Value<int> rowid;
  const PlanRewardsCompanion({
    this.gameId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanRewardsCompanion.insert({
    this.gameId = const Value.absent(),
    required String materialId,
    required int quantity,
    this.rowid = const Value.absent(),
  }) : materialId = Value(materialId),
       quantity = Value(quantity);
  static Insertable<PlanRewardRow> custom({
    Expression<String>? gameId,
    Expression<String>? materialId,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (materialId != null) 'material_id': materialId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanRewardsCompanion copyWith({
    Value<String>? gameId,
    Value<String>? materialId,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return PlanRewardsCompanion(
      gameId: gameId ?? this.gameId,
      materialId: materialId ?? this.materialId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanRewardsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('materialId: $materialId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionMaterialsTable extends SessionMaterials
    with TableInfo<$SessionMaterialsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionMaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _materialIdMeta = const VerificationMeta(
    'materialId',
  );
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
    'material_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, materialId, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('material_id')) {
      context.handle(
        _materialIdMeta,
        materialId.isAcceptableOrUnknown(data['material_id']!, _materialIdMeta),
      );
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, materialId};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      materialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $SessionMaterialsTable createAlias(String alias) {
    return $SessionMaterialsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final String gameId;
  final String materialId;
  final int quantity;
  const SessionRow({
    required this.gameId,
    required this.materialId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['material_id'] = Variable<String>(materialId);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  SessionMaterialsCompanion toCompanion(bool nullToAbsent) {
    return SessionMaterialsCompanion(
      gameId: Value(gameId),
      materialId: Value(materialId),
      quantity: Value(quantity),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      materialId: serializer.fromJson<String>(json['materialId']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'materialId': serializer.toJson<String>(materialId),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  SessionRow copyWith({String? gameId, String? materialId, int? quantity}) =>
      SessionRow(
        gameId: gameId ?? this.gameId,
        materialId: materialId ?? this.materialId,
        quantity: quantity ?? this.quantity,
      );
  SessionRow copyWithCompanion(SessionMaterialsCompanion data) {
    return SessionRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      materialId: data.materialId.present
          ? data.materialId.value
          : this.materialId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('gameId: $gameId, ')
          ..write('materialId: $materialId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, materialId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.gameId == this.gameId &&
          other.materialId == this.materialId &&
          other.quantity == this.quantity);
}

class SessionMaterialsCompanion extends UpdateCompanion<SessionRow> {
  final Value<String> gameId;
  final Value<String> materialId;
  final Value<int> quantity;
  final Value<int> rowid;
  const SessionMaterialsCompanion({
    this.gameId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionMaterialsCompanion.insert({
    this.gameId = const Value.absent(),
    required String materialId,
    required int quantity,
    this.rowid = const Value.absent(),
  }) : materialId = Value(materialId),
       quantity = Value(quantity);
  static Insertable<SessionRow> custom({
    Expression<String>? gameId,
    Expression<String>? materialId,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (materialId != null) 'material_id': materialId,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionMaterialsCompanion copyWith({
    Value<String>? gameId,
    Value<String>? materialId,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return SessionMaterialsCompanion(
      gameId: gameId ?? this.gameId,
      materialId: materialId ?? this.materialId,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionMaterialsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('materialId: $materialId, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppliedEvidenceTable extends AppliedEvidence
    with TableInfo<$AppliedEvidenceTable, AppliedEvidenceRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppliedEvidenceTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _evidenceIdMeta = const VerificationMeta(
    'evidenceId',
  );
  @override
  late final GeneratedColumn<String> evidenceId = GeneratedColumn<String>(
    'evidence_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, evidenceId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'applied_evidence';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppliedEvidenceRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('evidence_id')) {
      context.handle(
        _evidenceIdMeta,
        evidenceId.isAcceptableOrUnknown(data['evidence_id']!, _evidenceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_evidenceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, evidenceId};
  @override
  AppliedEvidenceRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppliedEvidenceRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      evidenceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_id'],
      )!,
    );
  }

  @override
  $AppliedEvidenceTable createAlias(String alias) {
    return $AppliedEvidenceTable(attachedDatabase, alias);
  }
}

class AppliedEvidenceRow extends DataClass
    implements Insertable<AppliedEvidenceRow> {
  final String gameId;
  final String evidenceId;
  const AppliedEvidenceRow({required this.gameId, required this.evidenceId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['evidence_id'] = Variable<String>(evidenceId);
    return map;
  }

  AppliedEvidenceCompanion toCompanion(bool nullToAbsent) {
    return AppliedEvidenceCompanion(
      gameId: Value(gameId),
      evidenceId: Value(evidenceId),
    );
  }

  factory AppliedEvidenceRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppliedEvidenceRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      evidenceId: serializer.fromJson<String>(json['evidenceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'evidenceId': serializer.toJson<String>(evidenceId),
    };
  }

  AppliedEvidenceRow copyWith({String? gameId, String? evidenceId}) =>
      AppliedEvidenceRow(
        gameId: gameId ?? this.gameId,
        evidenceId: evidenceId ?? this.evidenceId,
      );
  AppliedEvidenceRow copyWithCompanion(AppliedEvidenceCompanion data) {
    return AppliedEvidenceRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      evidenceId: data.evidenceId.present
          ? data.evidenceId.value
          : this.evidenceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppliedEvidenceRow(')
          ..write('gameId: $gameId, ')
          ..write('evidenceId: $evidenceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, evidenceId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppliedEvidenceRow &&
          other.gameId == this.gameId &&
          other.evidenceId == this.evidenceId);
}

class AppliedEvidenceCompanion extends UpdateCompanion<AppliedEvidenceRow> {
  final Value<String> gameId;
  final Value<String> evidenceId;
  final Value<int> rowid;
  const AppliedEvidenceCompanion({
    this.gameId = const Value.absent(),
    this.evidenceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppliedEvidenceCompanion.insert({
    this.gameId = const Value.absent(),
    required String evidenceId,
    this.rowid = const Value.absent(),
  }) : evidenceId = Value(evidenceId);
  static Insertable<AppliedEvidenceRow> custom({
    Expression<String>? gameId,
    Expression<String>? evidenceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (evidenceId != null) 'evidence_id': evidenceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppliedEvidenceCompanion copyWith({
    Value<String>? gameId,
    Value<String>? evidenceId,
    Value<int>? rowid,
  }) {
    return AppliedEvidenceCompanion(
      gameId: gameId ?? this.gameId,
      evidenceId: evidenceId ?? this.evidenceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (evidenceId.present) {
      map['evidence_id'] = Variable<String>(evidenceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppliedEvidenceCompanion(')
          ..write('gameId: $gameId, ')
          ..write('evidenceId: $evidenceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaveSnapshotsTable extends SaveSnapshots
    with TableInfo<$SaveSnapshotsTable, SaveSnapshotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaveSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotNumberMeta = const VerificationMeta(
    'slotNumber',
  );
  @override
  late final GeneratedColumn<int> slotNumber = GeneratedColumn<int>(
    'slot_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<String> savedAt = GeneratedColumn<String>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceFilenameMeta = const VerificationMeta(
    'sourceFilename',
  );
  @override
  late final GeneratedColumn<String> sourceFilename = GeneratedColumn<String>(
    'source_filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Json, String> data =
      GeneratedColumn<String>(
        'data',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Json>($SaveSnapshotsTable.$converterdata);
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    id,
    slotNumber,
    savedAt,
    sourceFilename,
    data,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'save_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaveSnapshotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slot_number')) {
      context.handle(
        _slotNumberMeta,
        slotNumber.isAcceptableOrUnknown(data['slot_number']!, _slotNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_slotNumberMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    if (data.containsKey('source_filename')) {
      context.handle(
        _sourceFilenameMeta,
        sourceFilename.isAcceptableOrUnknown(
          data['source_filename']!,
          _sourceFilenameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceFilenameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId, id};
  @override
  SaveSnapshotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaveSnapshotRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      slotNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_number'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}saved_at'],
      )!,
      sourceFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_filename'],
      )!,
      data: $SaveSnapshotsTable.$converterdata.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}data'],
        )!,
      ),
    );
  }

  @override
  $SaveSnapshotsTable createAlias(String alias) {
    return $SaveSnapshotsTable(attachedDatabase, alias);
  }

  static TypeConverter<Json, String> $converterdata =
      const JsonObjectConverter();
}

class SaveSnapshotRow extends DataClass implements Insertable<SaveSnapshotRow> {
  final String gameId;
  final String id;
  final int slotNumber;
  final String savedAt;
  final String sourceFilename;
  final Json data;
  const SaveSnapshotRow({
    required this.gameId,
    required this.id,
    required this.slotNumber,
    required this.savedAt,
    required this.sourceFilename,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['id'] = Variable<String>(id);
    map['slot_number'] = Variable<int>(slotNumber);
    map['saved_at'] = Variable<String>(savedAt);
    map['source_filename'] = Variable<String>(sourceFilename);
    {
      map['data'] = Variable<String>(
        $SaveSnapshotsTable.$converterdata.toSql(data),
      );
    }
    return map;
  }

  SaveSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return SaveSnapshotsCompanion(
      gameId: Value(gameId),
      id: Value(id),
      slotNumber: Value(slotNumber),
      savedAt: Value(savedAt),
      sourceFilename: Value(sourceFilename),
      data: Value(data),
    );
  }

  factory SaveSnapshotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaveSnapshotRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      id: serializer.fromJson<String>(json['id']),
      slotNumber: serializer.fromJson<int>(json['slotNumber']),
      savedAt: serializer.fromJson<String>(json['savedAt']),
      sourceFilename: serializer.fromJson<String>(json['sourceFilename']),
      data: serializer.fromJson<Json>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'id': serializer.toJson<String>(id),
      'slotNumber': serializer.toJson<int>(slotNumber),
      'savedAt': serializer.toJson<String>(savedAt),
      'sourceFilename': serializer.toJson<String>(sourceFilename),
      'data': serializer.toJson<Json>(data),
    };
  }

  SaveSnapshotRow copyWith({
    String? gameId,
    String? id,
    int? slotNumber,
    String? savedAt,
    String? sourceFilename,
    Json? data,
  }) => SaveSnapshotRow(
    gameId: gameId ?? this.gameId,
    id: id ?? this.id,
    slotNumber: slotNumber ?? this.slotNumber,
    savedAt: savedAt ?? this.savedAt,
    sourceFilename: sourceFilename ?? this.sourceFilename,
    data: data ?? this.data,
  );
  SaveSnapshotRow copyWithCompanion(SaveSnapshotsCompanion data) {
    return SaveSnapshotRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      id: data.id.present ? data.id.value : this.id,
      slotNumber: data.slotNumber.present
          ? data.slotNumber.value
          : this.slotNumber,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
      sourceFilename: data.sourceFilename.present
          ? data.sourceFilename.value
          : this.sourceFilename,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaveSnapshotRow(')
          ..write('gameId: $gameId, ')
          ..write('id: $id, ')
          ..write('slotNumber: $slotNumber, ')
          ..write('savedAt: $savedAt, ')
          ..write('sourceFilename: $sourceFilename, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(gameId, id, slotNumber, savedAt, sourceFilename, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaveSnapshotRow &&
          other.gameId == this.gameId &&
          other.id == this.id &&
          other.slotNumber == this.slotNumber &&
          other.savedAt == this.savedAt &&
          other.sourceFilename == this.sourceFilename &&
          other.data == this.data);
}

class SaveSnapshotsCompanion extends UpdateCompanion<SaveSnapshotRow> {
  final Value<String> gameId;
  final Value<String> id;
  final Value<int> slotNumber;
  final Value<String> savedAt;
  final Value<String> sourceFilename;
  final Value<Json> data;
  final Value<int> rowid;
  const SaveSnapshotsCompanion({
    this.gameId = const Value.absent(),
    this.id = const Value.absent(),
    this.slotNumber = const Value.absent(),
    this.savedAt = const Value.absent(),
    this.sourceFilename = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaveSnapshotsCompanion.insert({
    this.gameId = const Value.absent(),
    required String id,
    required int slotNumber,
    required String savedAt,
    required String sourceFilename,
    required Json data,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       slotNumber = Value(slotNumber),
       savedAt = Value(savedAt),
       sourceFilename = Value(sourceFilename),
       data = Value(data);
  static Insertable<SaveSnapshotRow> custom({
    Expression<String>? gameId,
    Expression<String>? id,
    Expression<int>? slotNumber,
    Expression<String>? savedAt,
    Expression<String>? sourceFilename,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (id != null) 'id': id,
      if (slotNumber != null) 'slot_number': slotNumber,
      if (savedAt != null) 'saved_at': savedAt,
      if (sourceFilename != null) 'source_filename': sourceFilename,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaveSnapshotsCompanion copyWith({
    Value<String>? gameId,
    Value<String>? id,
    Value<int>? slotNumber,
    Value<String>? savedAt,
    Value<String>? sourceFilename,
    Value<Json>? data,
    Value<int>? rowid,
  }) {
    return SaveSnapshotsCompanion(
      gameId: gameId ?? this.gameId,
      id: id ?? this.id,
      slotNumber: slotNumber ?? this.slotNumber,
      savedAt: savedAt ?? this.savedAt,
      sourceFilename: sourceFilename ?? this.sourceFilename,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slotNumber.present) {
      map['slot_number'] = Variable<int>(slotNumber.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<String>(savedAt.value);
    }
    if (sourceFilename.present) {
      map['source_filename'] = Variable<String>(sourceFilename.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(
        $SaveSnapshotsTable.$converterdata.toSql(data.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaveSnapshotsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('id: $id, ')
          ..write('slotNumber: $slotNumber, ')
          ..write('savedAt: $savedAt, ')
          ..write('sourceFilename: $sourceFilename, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileTransactionsTable extends ProfileTransactions
    with TableInfo<$ProfileTransactionsTable, TransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionOrigin, String>
  origin =
      GeneratedColumn<String>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionOrigin>(
        $ProfileTransactionsTable.$converterorigin,
      );
  @override
  late final GeneratedColumnWithTypeConverter<Json, String> before =
      GeneratedColumn<String>(
        'before',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Json>($ProfileTransactionsTable.$converterbefore);
  @override
  List<GeneratedColumn> get $columns => [
    gameId,
    seq,
    label,
    at,
    origin,
    before,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  TransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
      origin: $ProfileTransactionsTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origin'],
        )!,
      ),
      before: $ProfileTransactionsTable.$converterbefore.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}before'],
        )!,
      ),
    );
  }

  @override
  $ProfileTransactionsTable createAlias(String alias) {
    return $ProfileTransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionOrigin, String, String>
  $converterorigin = const EnumNameConverter<TransactionOrigin>(
    TransactionOrigin.values,
  );
  static TypeConverter<Json, String> $converterbefore =
      const JsonObjectConverter();
}

class TransactionRow extends DataClass implements Insertable<TransactionRow> {
  final String gameId;
  final int seq;
  final String label;
  final String at;
  final TransactionOrigin origin;
  final Json before;
  const TransactionRow({
    required this.gameId,
    required this.seq,
    required this.label,
    required this.at,
    required this.origin,
    required this.before,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['seq'] = Variable<int>(seq);
    map['label'] = Variable<String>(label);
    map['at'] = Variable<String>(at);
    {
      map['origin'] = Variable<String>(
        $ProfileTransactionsTable.$converterorigin.toSql(origin),
      );
    }
    {
      map['before'] = Variable<String>(
        $ProfileTransactionsTable.$converterbefore.toSql(before),
      );
    }
    return map;
  }

  ProfileTransactionsCompanion toCompanion(bool nullToAbsent) {
    return ProfileTransactionsCompanion(
      gameId: Value(gameId),
      seq: Value(seq),
      label: Value(label),
      at: Value(at),
      origin: Value(origin),
      before: Value(before),
    );
  }

  factory TransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      seq: serializer.fromJson<int>(json['seq']),
      label: serializer.fromJson<String>(json['label']),
      at: serializer.fromJson<String>(json['at']),
      origin: $ProfileTransactionsTable.$converterorigin.fromJson(
        serializer.fromJson<String>(json['origin']),
      ),
      before: serializer.fromJson<Json>(json['before']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'seq': serializer.toJson<int>(seq),
      'label': serializer.toJson<String>(label),
      'at': serializer.toJson<String>(at),
      'origin': serializer.toJson<String>(
        $ProfileTransactionsTable.$converterorigin.toJson(origin),
      ),
      'before': serializer.toJson<Json>(before),
    };
  }

  TransactionRow copyWith({
    String? gameId,
    int? seq,
    String? label,
    String? at,
    TransactionOrigin? origin,
    Json? before,
  }) => TransactionRow(
    gameId: gameId ?? this.gameId,
    seq: seq ?? this.seq,
    label: label ?? this.label,
    at: at ?? this.at,
    origin: origin ?? this.origin,
    before: before ?? this.before,
  );
  TransactionRow copyWithCompanion(ProfileTransactionsCompanion data) {
    return TransactionRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      seq: data.seq.present ? data.seq.value : this.seq,
      label: data.label.present ? data.label.value : this.label,
      at: data.at.present ? data.at.value : this.at,
      origin: data.origin.present ? data.origin.value : this.origin,
      before: data.before.present ? data.before.value : this.before,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRow(')
          ..write('gameId: $gameId, ')
          ..write('seq: $seq, ')
          ..write('label: $label, ')
          ..write('at: $at, ')
          ..write('origin: $origin, ')
          ..write('before: $before')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, seq, label, at, origin, before);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRow &&
          other.gameId == this.gameId &&
          other.seq == this.seq &&
          other.label == this.label &&
          other.at == this.at &&
          other.origin == this.origin &&
          other.before == this.before);
}

class ProfileTransactionsCompanion extends UpdateCompanion<TransactionRow> {
  final Value<String> gameId;
  final Value<int> seq;
  final Value<String> label;
  final Value<String> at;
  final Value<TransactionOrigin> origin;
  final Value<Json> before;
  const ProfileTransactionsCompanion({
    this.gameId = const Value.absent(),
    this.seq = const Value.absent(),
    this.label = const Value.absent(),
    this.at = const Value.absent(),
    this.origin = const Value.absent(),
    this.before = const Value.absent(),
  });
  ProfileTransactionsCompanion.insert({
    this.gameId = const Value.absent(),
    this.seq = const Value.absent(),
    required String label,
    required String at,
    required TransactionOrigin origin,
    required Json before,
  }) : label = Value(label),
       at = Value(at),
       origin = Value(origin),
       before = Value(before);
  static Insertable<TransactionRow> custom({
    Expression<String>? gameId,
    Expression<int>? seq,
    Expression<String>? label,
    Expression<String>? at,
    Expression<String>? origin,
    Expression<String>? before,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (seq != null) 'seq': seq,
      if (label != null) 'label': label,
      if (at != null) 'at': at,
      if (origin != null) 'origin': origin,
      if (before != null) 'before': before,
    });
  }

  ProfileTransactionsCompanion copyWith({
    Value<String>? gameId,
    Value<int>? seq,
    Value<String>? label,
    Value<String>? at,
    Value<TransactionOrigin>? origin,
    Value<Json>? before,
  }) {
    return ProfileTransactionsCompanion(
      gameId: gameId ?? this.gameId,
      seq: seq ?? this.seq,
      label: label ?? this.label,
      at: at ?? this.at,
      origin: origin ?? this.origin,
      before: before ?? this.before,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(
        $ProfileTransactionsTable.$converterorigin.toSql(origin.value),
      );
    }
    if (before.present) {
      map['before'] = Variable<String>(
        $ProfileTransactionsTable.$converterbefore.toSql(before.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileTransactionsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('seq: $seq, ')
          ..write('label: $label, ')
          ..write('at: $at, ')
          ..write('origin: $origin, ')
          ..write('before: $before')
          ..write(')'))
        .toString();
  }
}

class $BackupsTable extends Backups with TableInfo<$BackupsTable, BackupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultGameId),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [gameId, createdAt, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backups';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {gameId};
  @override
  BackupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupRow(
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
    );
  }

  @override
  $BackupsTable createAlias(String alias) {
    return $BackupsTable(attachedDatabase, alias);
  }
}

class BackupRow extends DataClass implements Insertable<BackupRow> {
  final String gameId;
  final String createdAt;
  final String content;
  const BackupRow({
    required this.gameId,
    required this.createdAt,
    required this.content,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['game_id'] = Variable<String>(gameId);
    map['created_at'] = Variable<String>(createdAt);
    map['content'] = Variable<String>(content);
    return map;
  }

  BackupsCompanion toCompanion(bool nullToAbsent) {
    return BackupsCompanion(
      gameId: Value(gameId),
      createdAt: Value(createdAt),
      content: Value(content),
    );
  }

  factory BackupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupRow(
      gameId: serializer.fromJson<String>(json['gameId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'gameId': serializer.toJson<String>(gameId),
      'createdAt': serializer.toJson<String>(createdAt),
      'content': serializer.toJson<String>(content),
    };
  }

  BackupRow copyWith({String? gameId, String? createdAt, String? content}) =>
      BackupRow(
        gameId: gameId ?? this.gameId,
        createdAt: createdAt ?? this.createdAt,
        content: content ?? this.content,
      );
  BackupRow copyWithCompanion(BackupsCompanion data) {
    return BackupRow(
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      content: data.content.present ? data.content.value : this.content,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupRow(')
          ..write('gameId: $gameId, ')
          ..write('createdAt: $createdAt, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(gameId, createdAt, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupRow &&
          other.gameId == this.gameId &&
          other.createdAt == this.createdAt &&
          other.content == this.content);
}

class BackupsCompanion extends UpdateCompanion<BackupRow> {
  final Value<String> gameId;
  final Value<String> createdAt;
  final Value<String> content;
  final Value<int> rowid;
  const BackupsCompanion({
    this.gameId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupsCompanion.insert({
    this.gameId = const Value.absent(),
    required String createdAt,
    required String content,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       content = Value(content);
  static Insertable<BackupRow> custom({
    Expression<String>? gameId,
    Expression<String>? createdAt,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (gameId != null) 'game_id': gameId,
      if (createdAt != null) 'created_at': createdAt,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupsCompanion copyWith({
    Value<String>? gameId,
    Value<String>? createdAt,
    Value<String>? content,
    Value<int>? rowid,
  }) {
    return BackupsCompanion(
      gameId: gameId ?? this.gameId,
      createdAt: createdAt ?? this.createdAt,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BackupsCompanion(')
          ..write('gameId: $gameId, ')
          ..write('createdAt: $createdAt, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $InventoryTable inventory = $InventoryTable(this);
  late final $CompletionTable completion = $CompletionTable(this);
  late final $RecipesTable recipes = $RecipesTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $PlayerSettingsTable playerSettings = $PlayerSettingsTable(this);
  late final $SaveValuesTable saveValues = $SaveValuesTable(this);
  late final $OverrideScopesTable overrideScopes = $OverrideScopesTable(this);
  late final $ManualOverridesTable manualOverrides = $ManualOverridesTable(
    this,
  );
  late final $PlanRecipesTable planRecipes = $PlanRecipesTable(this);
  late final $PlanRewardsTable planRewards = $PlanRewardsTable(this);
  late final $SessionMaterialsTable sessionMaterials = $SessionMaterialsTable(
    this,
  );
  late final $AppliedEvidenceTable appliedEvidence = $AppliedEvidenceTable(
    this,
  );
  late final $SaveSnapshotsTable saveSnapshots = $SaveSnapshotsTable(this);
  late final $ProfileTransactionsTable profileTransactions =
      $ProfileTransactionsTable(this);
  late final $BackupsTable backups = $BackupsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    inventory,
    completion,
    recipes,
    collections,
    playerSettings,
    saveValues,
    overrideScopes,
    manualOverrides,
    planRecipes,
    planRewards,
    sessionMaterials,
    appliedEvidence,
    saveSnapshots,
    profileTransactions,
    backups,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> gameId,
      required int schemaVersion,
      required String datasetVersion,
      Value<String?> completionDatasetVersion,
      Value<String?> storyPoint,
      required String updatedAt,
      Value<String?> activeSaveId,
      required PlanMode planMode,
      Value<int> revision,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> gameId,
      Value<int> schemaVersion,
      Value<String> datasetVersion,
      Value<String?> completionDatasetVersion,
      Value<String?> storyPoint,
      Value<String> updatedAt,
      Value<String?> activeSaveId,
      Value<PlanMode> planMode,
      Value<int> revision,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datasetVersion => $composableBuilder(
    column: $table.datasetVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get completionDatasetVersion => $composableBuilder(
    column: $table.completionDatasetVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storyPoint => $composableBuilder(
    column: $table.storyPoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeSaveId => $composableBuilder(
    column: $table.activeSaveId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PlanMode, PlanMode, String> get planMode =>
      $composableBuilder(
        column: $table.planMode,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datasetVersion => $composableBuilder(
    column: $table.datasetVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completionDatasetVersion => $composableBuilder(
    column: $table.completionDatasetVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storyPoint => $composableBuilder(
    column: $table.storyPoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeSaveId => $composableBuilder(
    column: $table.activeSaveId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get planMode => $composableBuilder(
    column: $table.planMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get datasetVersion => $composableBuilder(
    column: $table.datasetVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get completionDatasetVersion => $composableBuilder(
    column: $table.completionDatasetVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get storyPoint => $composableBuilder(
    column: $table.storyPoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get activeSaveId => $composableBuilder(
    column: $table.activeSaveId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PlanMode, String> get planMode =>
      $composableBuilder(column: $table.planMode, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          ProfileRow,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (
            ProfileRow,
            BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>,
          ),
          ProfileRow,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> datasetVersion = const Value.absent(),
                Value<String?> completionDatasetVersion = const Value.absent(),
                Value<String?> storyPoint = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String?> activeSaveId = const Value.absent(),
                Value<PlanMode> planMode = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                gameId: gameId,
                schemaVersion: schemaVersion,
                datasetVersion: datasetVersion,
                completionDatasetVersion: completionDatasetVersion,
                storyPoint: storyPoint,
                updatedAt: updatedAt,
                activeSaveId: activeSaveId,
                planMode: planMode,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required int schemaVersion,
                required String datasetVersion,
                Value<String?> completionDatasetVersion = const Value.absent(),
                Value<String?> storyPoint = const Value.absent(),
                required String updatedAt,
                Value<String?> activeSaveId = const Value.absent(),
                required PlanMode planMode,
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                gameId: gameId,
                schemaVersion: schemaVersion,
                datasetVersion: datasetVersion,
                completionDatasetVersion: completionDatasetVersion,
                storyPoint: storyPoint,
                updatedAt: updatedAt,
                activeSaveId: activeSaveId,
                planMode: planMode,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfilesTable, ProfileRow>(table),
                  BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      ProfileRow,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (ProfileRow, BaseReferences<_$AppDatabase, $ProfilesTable, ProfileRow>),
      ProfileRow,
      PrefetchHooks Function()
    >;
typedef $$InventoryTableCreateCompanionBuilder =
    InventoryCompanion Function({
      Value<String> gameId,
      required String materialId,
      Value<int?> quantity,
      Value<int> rowid,
    });
typedef $$InventoryTableUpdateCompanionBuilder =
    InventoryCompanion Function({
      Value<String> gameId,
      Value<String> materialId,
      Value<int?> quantity,
      Value<int> rowid,
    });

class $$InventoryTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryTable> {
  $$InventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$InventoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryTable,
          InventoryRow,
          $$InventoryTableFilterComposer,
          $$InventoryTableOrderingComposer,
          $$InventoryTableAnnotationComposer,
          $$InventoryTableCreateCompanionBuilder,
          $$InventoryTableUpdateCompanionBuilder,
          (
            InventoryRow,
            BaseReferences<_$AppDatabase, $InventoryTable, InventoryRow>,
          ),
          InventoryRow,
          PrefetchHooks Function()
        > {
  $$InventoryTableTableManager(_$AppDatabase db, $InventoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> materialId = const Value.absent(),
                Value<int?> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryCompanion(
                gameId: gameId,
                materialId: materialId,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String materialId,
                Value<int?> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryCompanion.insert(
                gameId: gameId,
                materialId: materialId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InventoryTable, InventoryRow>(table),
                  BaseReferences<_$AppDatabase, $InventoryTable, InventoryRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryTable,
      InventoryRow,
      $$InventoryTableFilterComposer,
      $$InventoryTableOrderingComposer,
      $$InventoryTableAnnotationComposer,
      $$InventoryTableCreateCompanionBuilder,
      $$InventoryTableUpdateCompanionBuilder,
      (
        InventoryRow,
        BaseReferences<_$AppDatabase, $InventoryTable, InventoryRow>,
      ),
      InventoryRow,
      PrefetchHooks Function()
    >;
typedef $$CompletionTableCreateCompanionBuilder =
    CompletionCompanion Function({
      Value<String> gameId,
      required String itemId,
      Value<bool?> done,
      Value<int> rowid,
    });
typedef $$CompletionTableUpdateCompanionBuilder =
    CompletionCompanion Function({
      Value<String> gameId,
      Value<String> itemId,
      Value<bool?> done,
      Value<int> rowid,
    });

class $$CompletionTableFilterComposer
    extends Composer<_$AppDatabase, $CompletionTable> {
  $$CompletionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompletionTableOrderingComposer
    extends Composer<_$AppDatabase, $CompletionTable> {
  $$CompletionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get done => $composableBuilder(
    column: $table.done,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompletionTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompletionTable> {
  $$CompletionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<bool> get done =>
      $composableBuilder(column: $table.done, builder: (column) => column);
}

class $$CompletionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompletionTable,
          CompletionRow,
          $$CompletionTableFilterComposer,
          $$CompletionTableOrderingComposer,
          $$CompletionTableAnnotationComposer,
          $$CompletionTableCreateCompanionBuilder,
          $$CompletionTableUpdateCompanionBuilder,
          (
            CompletionRow,
            BaseReferences<_$AppDatabase, $CompletionTable, CompletionRow>,
          ),
          CompletionRow,
          PrefetchHooks Function()
        > {
  $$CompletionTableTableManager(_$AppDatabase db, $CompletionTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompletionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompletionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompletionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<bool?> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionCompanion(
                gameId: gameId,
                itemId: itemId,
                done: done,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String itemId,
                Value<bool?> done = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompletionCompanion.insert(
                gameId: gameId,
                itemId: itemId,
                done: done,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CompletionTable, CompletionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CompletionTable,
                    CompletionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompletionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompletionTable,
      CompletionRow,
      $$CompletionTableFilterComposer,
      $$CompletionTableOrderingComposer,
      $$CompletionTableAnnotationComposer,
      $$CompletionTableCreateCompanionBuilder,
      $$CompletionTableUpdateCompanionBuilder,
      (
        CompletionRow,
        BaseReferences<_$AppDatabase, $CompletionTable, CompletionRow>,
      ),
      CompletionRow,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableCreateCompanionBuilder =
    RecipesCompanion Function({
      Value<String> gameId,
      required String recipeId,
      required bool everCrafted,
      Value<int?> craftCount,
      Value<int> rowid,
    });
typedef $$RecipesTableUpdateCompanionBuilder =
    RecipesCompanion Function({
      Value<String> gameId,
      Value<String> recipeId,
      Value<bool> everCrafted,
      Value<int?> craftCount,
      Value<int> rowid,
    });

class $$RecipesTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get everCrafted => $composableBuilder(
    column: $table.everCrafted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get craftCount => $composableBuilder(
    column: $table.craftCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get everCrafted => $composableBuilder(
    column: $table.everCrafted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get craftCount => $composableBuilder(
    column: $table.craftCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTable> {
  $$RecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<bool> get everCrafted => $composableBuilder(
    column: $table.everCrafted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get craftCount => $composableBuilder(
    column: $table.craftCount,
    builder: (column) => column,
  );
}

class $$RecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTable,
          RecipeRow,
          $$RecipesTableFilterComposer,
          $$RecipesTableOrderingComposer,
          $$RecipesTableAnnotationComposer,
          $$RecipesTableCreateCompanionBuilder,
          $$RecipesTableUpdateCompanionBuilder,
          (RecipeRow, BaseReferences<_$AppDatabase, $RecipesTable, RecipeRow>),
          RecipeRow,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableManager(_$AppDatabase db, $RecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<bool> everCrafted = const Value.absent(),
                Value<int?> craftCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion(
                gameId: gameId,
                recipeId: recipeId,
                everCrafted: everCrafted,
                craftCount: craftCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String recipeId,
                required bool everCrafted,
                Value<int?> craftCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesCompanion.insert(
                gameId: gameId,
                recipeId: recipeId,
                everCrafted: everCrafted,
                craftCount: craftCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecipesTable, RecipeRow>(table),
                  BaseReferences<_$AppDatabase, $RecipesTable, RecipeRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTable,
      RecipeRow,
      $$RecipesTableFilterComposer,
      $$RecipesTableOrderingComposer,
      $$RecipesTableAnnotationComposer,
      $$RecipesTableCreateCompanionBuilder,
      $$RecipesTableUpdateCompanionBuilder,
      (RecipeRow, BaseReferences<_$AppDatabase, $RecipesTable, RecipeRow>),
      RecipeRow,
      PrefetchHooks Function()
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> gameId,
      required String collectionId,
      required CollectionStatus status,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> gameId,
      Value<String> collectionId,
      Value<CollectionStatus> status,
      Value<int> rowid,
    });

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CollectionStatus, CollectionStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<CollectionStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          CollectionRow,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (
            CollectionRow,
            BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
          ),
          CollectionRow,
          PrefetchHooks Function()
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<CollectionStatus> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                gameId: gameId,
                collectionId: collectionId,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String collectionId,
                required CollectionStatus status,
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                gameId: gameId,
                collectionId: collectionId,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CollectionsTable, CollectionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CollectionsTable,
                    CollectionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      CollectionRow,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (
        CollectionRow,
        BaseReferences<_$AppDatabase, $CollectionsTable, CollectionRow>,
      ),
      CollectionRow,
      PrefetchHooks Function()
    >;
typedef $$PlayerSettingsTableCreateCompanionBuilder =
    PlayerSettingsCompanion Function({
      Value<String> gameId,
      required String key,
      required Object? value,
      Value<int> rowid,
    });
typedef $$PlayerSettingsTableUpdateCompanionBuilder =
    PlayerSettingsCompanion Function({
      Value<String> gameId,
      Value<String> key,
      Value<Object?> value,
      Value<int> rowid,
    });

class $$PlayerSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerSettingsTable> {
  $$PlayerSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Object?, Object, String> get value =>
      $composableBuilder(
        column: $table.value,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$PlayerSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerSettingsTable> {
  $$PlayerSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerSettingsTable> {
  $$PlayerSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Object?, String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$PlayerSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerSettingsTable,
          SettingRow,
          $$PlayerSettingsTableFilterComposer,
          $$PlayerSettingsTableOrderingComposer,
          $$PlayerSettingsTableAnnotationComposer,
          $$PlayerSettingsTableCreateCompanionBuilder,
          $$PlayerSettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $PlayerSettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$PlayerSettingsTableTableManager(
    _$AppDatabase db,
    $PlayerSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<Object?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayerSettingsCompanion(
                gameId: gameId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String key,
                required Object? value,
                Value<int> rowid = const Value.absent(),
              }) => PlayerSettingsCompanion.insert(
                gameId: gameId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayerSettingsTable, SettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlayerSettingsTable,
                    SettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerSettingsTable,
      SettingRow,
      $$PlayerSettingsTableFilterComposer,
      $$PlayerSettingsTableOrderingComposer,
      $$PlayerSettingsTableAnnotationComposer,
      $$PlayerSettingsTableCreateCompanionBuilder,
      $$PlayerSettingsTableUpdateCompanionBuilder,
      (
        SettingRow,
        BaseReferences<_$AppDatabase, $PlayerSettingsTable, SettingRow>,
      ),
      SettingRow,
      PrefetchHooks Function()
    >;
typedef $$SaveValuesTableCreateCompanionBuilder =
    SaveValuesCompanion Function({
      Value<String> gameId,
      required String key,
      required Object? value,
      Value<int> rowid,
    });
typedef $$SaveValuesTableUpdateCompanionBuilder =
    SaveValuesCompanion Function({
      Value<String> gameId,
      Value<String> key,
      Value<Object?> value,
      Value<int> rowid,
    });

class $$SaveValuesTableFilterComposer
    extends Composer<_$AppDatabase, $SaveValuesTable> {
  $$SaveValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Object?, Object, String> get value =>
      $composableBuilder(
        column: $table.value,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$SaveValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $SaveValuesTable> {
  $$SaveValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaveValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaveValuesTable> {
  $$SaveValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Object?, String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SaveValuesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaveValuesTable,
          SaveValueRow,
          $$SaveValuesTableFilterComposer,
          $$SaveValuesTableOrderingComposer,
          $$SaveValuesTableAnnotationComposer,
          $$SaveValuesTableCreateCompanionBuilder,
          $$SaveValuesTableUpdateCompanionBuilder,
          (
            SaveValueRow,
            BaseReferences<_$AppDatabase, $SaveValuesTable, SaveValueRow>,
          ),
          SaveValueRow,
          PrefetchHooks Function()
        > {
  $$SaveValuesTableTableManager(_$AppDatabase db, $SaveValuesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaveValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaveValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaveValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<Object?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaveValuesCompanion(
                gameId: gameId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String key,
                required Object? value,
                Value<int> rowid = const Value.absent(),
              }) => SaveValuesCompanion.insert(
                gameId: gameId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaveValuesTable, SaveValueRow>(table),
                  BaseReferences<_$AppDatabase, $SaveValuesTable, SaveValueRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaveValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaveValuesTable,
      SaveValueRow,
      $$SaveValuesTableFilterComposer,
      $$SaveValuesTableOrderingComposer,
      $$SaveValuesTableAnnotationComposer,
      $$SaveValuesTableCreateCompanionBuilder,
      $$SaveValuesTableUpdateCompanionBuilder,
      (
        SaveValueRow,
        BaseReferences<_$AppDatabase, $SaveValuesTable, SaveValueRow>,
      ),
      SaveValueRow,
      PrefetchHooks Function()
    >;
typedef $$OverrideScopesTableCreateCompanionBuilder =
    OverrideScopesCompanion Function({
      Value<String> gameId,
      required String scope,
      Value<int> rowid,
    });
typedef $$OverrideScopesTableUpdateCompanionBuilder =
    OverrideScopesCompanion Function({
      Value<String> gameId,
      Value<String> scope,
      Value<int> rowid,
    });

class $$OverrideScopesTableFilterComposer
    extends Composer<_$AppDatabase, $OverrideScopesTable> {
  $$OverrideScopesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OverrideScopesTableOrderingComposer
    extends Composer<_$AppDatabase, $OverrideScopesTable> {
  $$OverrideScopesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OverrideScopesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OverrideScopesTable> {
  $$OverrideScopesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);
}

class $$OverrideScopesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OverrideScopesTable,
          OverrideScopeRow,
          $$OverrideScopesTableFilterComposer,
          $$OverrideScopesTableOrderingComposer,
          $$OverrideScopesTableAnnotationComposer,
          $$OverrideScopesTableCreateCompanionBuilder,
          $$OverrideScopesTableUpdateCompanionBuilder,
          (
            OverrideScopeRow,
            BaseReferences<
              _$AppDatabase,
              $OverrideScopesTable,
              OverrideScopeRow
            >,
          ),
          OverrideScopeRow,
          PrefetchHooks Function()
        > {
  $$OverrideScopesTableTableManager(
    _$AppDatabase db,
    $OverrideScopesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OverrideScopesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OverrideScopesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OverrideScopesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OverrideScopesCompanion(
                gameId: gameId,
                scope: scope,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String scope,
                Value<int> rowid = const Value.absent(),
              }) => OverrideScopesCompanion.insert(
                gameId: gameId,
                scope: scope,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OverrideScopesTable, OverrideScopeRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OverrideScopesTable,
                    OverrideScopeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OverrideScopesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OverrideScopesTable,
      OverrideScopeRow,
      $$OverrideScopesTableFilterComposer,
      $$OverrideScopesTableOrderingComposer,
      $$OverrideScopesTableAnnotationComposer,
      $$OverrideScopesTableCreateCompanionBuilder,
      $$OverrideScopesTableUpdateCompanionBuilder,
      (
        OverrideScopeRow,
        BaseReferences<_$AppDatabase, $OverrideScopesTable, OverrideScopeRow>,
      ),
      OverrideScopeRow,
      PrefetchHooks Function()
    >;
typedef $$ManualOverridesTableCreateCompanionBuilder =
    ManualOverridesCompanion Function({
      Value<String> gameId,
      required String scope,
      required String key,
      required Object? value,
      Value<int> rowid,
    });
typedef $$ManualOverridesTableUpdateCompanionBuilder =
    ManualOverridesCompanion Function({
      Value<String> gameId,
      Value<String> scope,
      Value<String> key,
      Value<Object?> value,
      Value<int> rowid,
    });

class $$ManualOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $ManualOverridesTable> {
  $$ManualOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Object?, Object, String> get value =>
      $composableBuilder(
        column: $table.value,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ManualOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $ManualOverridesTable> {
  $$ManualOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ManualOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManualOverridesTable> {
  $$ManualOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Object?, String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$ManualOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ManualOverridesTable,
          ManualOverrideRow,
          $$ManualOverridesTableFilterComposer,
          $$ManualOverridesTableOrderingComposer,
          $$ManualOverridesTableAnnotationComposer,
          $$ManualOverridesTableCreateCompanionBuilder,
          $$ManualOverridesTableUpdateCompanionBuilder,
          (
            ManualOverrideRow,
            BaseReferences<
              _$AppDatabase,
              $ManualOverridesTable,
              ManualOverrideRow
            >,
          ),
          ManualOverrideRow,
          PrefetchHooks Function()
        > {
  $$ManualOverridesTableTableManager(
    _$AppDatabase db,
    $ManualOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManualOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManualOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManualOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<Object?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ManualOverridesCompanion(
                gameId: gameId,
                scope: scope,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String scope,
                required String key,
                required Object? value,
                Value<int> rowid = const Value.absent(),
              }) => ManualOverridesCompanion.insert(
                gameId: gameId,
                scope: scope,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ManualOverridesTable, ManualOverrideRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ManualOverridesTable,
                    ManualOverrideRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ManualOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ManualOverridesTable,
      ManualOverrideRow,
      $$ManualOverridesTableFilterComposer,
      $$ManualOverridesTableOrderingComposer,
      $$ManualOverridesTableAnnotationComposer,
      $$ManualOverridesTableCreateCompanionBuilder,
      $$ManualOverridesTableUpdateCompanionBuilder,
      (
        ManualOverrideRow,
        BaseReferences<_$AppDatabase, $ManualOverridesTable, ManualOverrideRow>,
      ),
      ManualOverrideRow,
      PrefetchHooks Function()
    >;
typedef $$PlanRecipesTableCreateCompanionBuilder =
    PlanRecipesCompanion Function({
      Value<String> gameId,
      required String recipeId,
      Value<int> rowid,
    });
typedef $$PlanRecipesTableUpdateCompanionBuilder =
    PlanRecipesCompanion Function({
      Value<String> gameId,
      Value<String> recipeId,
      Value<int> rowid,
    });

class $$PlanRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanRecipesTable> {
  $$PlanRecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanRecipesTable> {
  $$PlanRecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipeId => $composableBuilder(
    column: $table.recipeId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanRecipesTable> {
  $$PlanRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);
}

class $$PlanRecipesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanRecipesTable,
          PlanRecipeRow,
          $$PlanRecipesTableFilterComposer,
          $$PlanRecipesTableOrderingComposer,
          $$PlanRecipesTableAnnotationComposer,
          $$PlanRecipesTableCreateCompanionBuilder,
          $$PlanRecipesTableUpdateCompanionBuilder,
          (
            PlanRecipeRow,
            BaseReferences<_$AppDatabase, $PlanRecipesTable, PlanRecipeRow>,
          ),
          PlanRecipeRow,
          PrefetchHooks Function()
        > {
  $$PlanRecipesTableTableManager(_$AppDatabase db, $PlanRecipesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> recipeId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanRecipesCompanion(
                gameId: gameId,
                recipeId: recipeId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String recipeId,
                Value<int> rowid = const Value.absent(),
              }) => PlanRecipesCompanion.insert(
                gameId: gameId,
                recipeId: recipeId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanRecipesTable, PlanRecipeRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlanRecipesTable,
                    PlanRecipeRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanRecipesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanRecipesTable,
      PlanRecipeRow,
      $$PlanRecipesTableFilterComposer,
      $$PlanRecipesTableOrderingComposer,
      $$PlanRecipesTableAnnotationComposer,
      $$PlanRecipesTableCreateCompanionBuilder,
      $$PlanRecipesTableUpdateCompanionBuilder,
      (
        PlanRecipeRow,
        BaseReferences<_$AppDatabase, $PlanRecipesTable, PlanRecipeRow>,
      ),
      PlanRecipeRow,
      PrefetchHooks Function()
    >;
typedef $$PlanRewardsTableCreateCompanionBuilder =
    PlanRewardsCompanion Function({
      Value<String> gameId,
      required String materialId,
      required int quantity,
      Value<int> rowid,
    });
typedef $$PlanRewardsTableUpdateCompanionBuilder =
    PlanRewardsCompanion Function({
      Value<String> gameId,
      Value<String> materialId,
      Value<int> quantity,
      Value<int> rowid,
    });

class $$PlanRewardsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanRewardsTable> {
  $$PlanRewardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanRewardsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanRewardsTable> {
  $$PlanRewardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanRewardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanRewardsTable> {
  $$PlanRewardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$PlanRewardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanRewardsTable,
          PlanRewardRow,
          $$PlanRewardsTableFilterComposer,
          $$PlanRewardsTableOrderingComposer,
          $$PlanRewardsTableAnnotationComposer,
          $$PlanRewardsTableCreateCompanionBuilder,
          $$PlanRewardsTableUpdateCompanionBuilder,
          (
            PlanRewardRow,
            BaseReferences<_$AppDatabase, $PlanRewardsTable, PlanRewardRow>,
          ),
          PlanRewardRow,
          PrefetchHooks Function()
        > {
  $$PlanRewardsTableTableManager(_$AppDatabase db, $PlanRewardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanRewardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanRewardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanRewardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> materialId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanRewardsCompanion(
                gameId: gameId,
                materialId: materialId,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String materialId,
                required int quantity,
                Value<int> rowid = const Value.absent(),
              }) => PlanRewardsCompanion.insert(
                gameId: gameId,
                materialId: materialId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanRewardsTable, PlanRewardRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlanRewardsTable,
                    PlanRewardRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanRewardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanRewardsTable,
      PlanRewardRow,
      $$PlanRewardsTableFilterComposer,
      $$PlanRewardsTableOrderingComposer,
      $$PlanRewardsTableAnnotationComposer,
      $$PlanRewardsTableCreateCompanionBuilder,
      $$PlanRewardsTableUpdateCompanionBuilder,
      (
        PlanRewardRow,
        BaseReferences<_$AppDatabase, $PlanRewardsTable, PlanRewardRow>,
      ),
      PlanRewardRow,
      PrefetchHooks Function()
    >;
typedef $$SessionMaterialsTableCreateCompanionBuilder =
    SessionMaterialsCompanion Function({
      Value<String> gameId,
      required String materialId,
      required int quantity,
      Value<int> rowid,
    });
typedef $$SessionMaterialsTableUpdateCompanionBuilder =
    SessionMaterialsCompanion Function({
      Value<String> gameId,
      Value<String> materialId,
      Value<int> quantity,
      Value<int> rowid,
    });

class $$SessionMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionMaterialsTable> {
  $$SessionMaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionMaterialsTable> {
  $$SessionMaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionMaterialsTable> {
  $$SessionMaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$SessionMaterialsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionMaterialsTable,
          SessionRow,
          $$SessionMaterialsTableFilterComposer,
          $$SessionMaterialsTableOrderingComposer,
          $$SessionMaterialsTableAnnotationComposer,
          $$SessionMaterialsTableCreateCompanionBuilder,
          $$SessionMaterialsTableUpdateCompanionBuilder,
          (
            SessionRow,
            BaseReferences<_$AppDatabase, $SessionMaterialsTable, SessionRow>,
          ),
          SessionRow,
          PrefetchHooks Function()
        > {
  $$SessionMaterialsTableTableManager(
    _$AppDatabase db,
    $SessionMaterialsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionMaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionMaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> materialId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionMaterialsCompanion(
                gameId: gameId,
                materialId: materialId,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String materialId,
                required int quantity,
                Value<int> rowid = const Value.absent(),
              }) => SessionMaterialsCompanion.insert(
                gameId: gameId,
                materialId: materialId,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionMaterialsTable, SessionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SessionMaterialsTable,
                    SessionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionMaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionMaterialsTable,
      SessionRow,
      $$SessionMaterialsTableFilterComposer,
      $$SessionMaterialsTableOrderingComposer,
      $$SessionMaterialsTableAnnotationComposer,
      $$SessionMaterialsTableCreateCompanionBuilder,
      $$SessionMaterialsTableUpdateCompanionBuilder,
      (
        SessionRow,
        BaseReferences<_$AppDatabase, $SessionMaterialsTable, SessionRow>,
      ),
      SessionRow,
      PrefetchHooks Function()
    >;
typedef $$AppliedEvidenceTableCreateCompanionBuilder =
    AppliedEvidenceCompanion Function({
      Value<String> gameId,
      required String evidenceId,
      Value<int> rowid,
    });
typedef $$AppliedEvidenceTableUpdateCompanionBuilder =
    AppliedEvidenceCompanion Function({
      Value<String> gameId,
      Value<String> evidenceId,
      Value<int> rowid,
    });

class $$AppliedEvidenceTableFilterComposer
    extends Composer<_$AppDatabase, $AppliedEvidenceTable> {
  $$AppliedEvidenceTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceId => $composableBuilder(
    column: $table.evidenceId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppliedEvidenceTableOrderingComposer
    extends Composer<_$AppDatabase, $AppliedEvidenceTable> {
  $$AppliedEvidenceTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceId => $composableBuilder(
    column: $table.evidenceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppliedEvidenceTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppliedEvidenceTable> {
  $$AppliedEvidenceTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get evidenceId => $composableBuilder(
    column: $table.evidenceId,
    builder: (column) => column,
  );
}

class $$AppliedEvidenceTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppliedEvidenceTable,
          AppliedEvidenceRow,
          $$AppliedEvidenceTableFilterComposer,
          $$AppliedEvidenceTableOrderingComposer,
          $$AppliedEvidenceTableAnnotationComposer,
          $$AppliedEvidenceTableCreateCompanionBuilder,
          $$AppliedEvidenceTableUpdateCompanionBuilder,
          (
            AppliedEvidenceRow,
            BaseReferences<
              _$AppDatabase,
              $AppliedEvidenceTable,
              AppliedEvidenceRow
            >,
          ),
          AppliedEvidenceRow,
          PrefetchHooks Function()
        > {
  $$AppliedEvidenceTableTableManager(
    _$AppDatabase db,
    $AppliedEvidenceTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppliedEvidenceTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppliedEvidenceTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppliedEvidenceTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> evidenceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppliedEvidenceCompanion(
                gameId: gameId,
                evidenceId: evidenceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String evidenceId,
                Value<int> rowid = const Value.absent(),
              }) => AppliedEvidenceCompanion.insert(
                gameId: gameId,
                evidenceId: evidenceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppliedEvidenceTable, AppliedEvidenceRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppliedEvidenceTable,
                    AppliedEvidenceRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppliedEvidenceTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppliedEvidenceTable,
      AppliedEvidenceRow,
      $$AppliedEvidenceTableFilterComposer,
      $$AppliedEvidenceTableOrderingComposer,
      $$AppliedEvidenceTableAnnotationComposer,
      $$AppliedEvidenceTableCreateCompanionBuilder,
      $$AppliedEvidenceTableUpdateCompanionBuilder,
      (
        AppliedEvidenceRow,
        BaseReferences<
          _$AppDatabase,
          $AppliedEvidenceTable,
          AppliedEvidenceRow
        >,
      ),
      AppliedEvidenceRow,
      PrefetchHooks Function()
    >;
typedef $$SaveSnapshotsTableCreateCompanionBuilder =
    SaveSnapshotsCompanion Function({
      Value<String> gameId,
      required String id,
      required int slotNumber,
      required String savedAt,
      required String sourceFilename,
      required Json data,
      Value<int> rowid,
    });
typedef $$SaveSnapshotsTableUpdateCompanionBuilder =
    SaveSnapshotsCompanion Function({
      Value<String> gameId,
      Value<String> id,
      Value<int> slotNumber,
      Value<String> savedAt,
      Value<String> sourceFilename,
      Value<Json> data,
      Value<int> rowid,
    });

class $$SaveSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $SaveSnapshotsTable> {
  $$SaveSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get slotNumber => $composableBuilder(
    column: $table.slotNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Json, Json, String> get data =>
      $composableBuilder(
        column: $table.data,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$SaveSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaveSnapshotsTable> {
  $$SaveSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get slotNumber => $composableBuilder(
    column: $table.slotNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaveSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaveSnapshotsTable> {
  $$SaveSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get slotNumber => $composableBuilder(
    column: $table.slotNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  GeneratedColumn<String> get sourceFilename => $composableBuilder(
    column: $table.sourceFilename,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Json, String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$SaveSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaveSnapshotsTable,
          SaveSnapshotRow,
          $$SaveSnapshotsTableFilterComposer,
          $$SaveSnapshotsTableOrderingComposer,
          $$SaveSnapshotsTableAnnotationComposer,
          $$SaveSnapshotsTableCreateCompanionBuilder,
          $$SaveSnapshotsTableUpdateCompanionBuilder,
          (
            SaveSnapshotRow,
            BaseReferences<_$AppDatabase, $SaveSnapshotsTable, SaveSnapshotRow>,
          ),
          SaveSnapshotRow,
          PrefetchHooks Function()
        > {
  $$SaveSnapshotsTableTableManager(_$AppDatabase db, $SaveSnapshotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaveSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaveSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaveSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> slotNumber = const Value.absent(),
                Value<String> savedAt = const Value.absent(),
                Value<String> sourceFilename = const Value.absent(),
                Value<Json> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaveSnapshotsCompanion(
                gameId: gameId,
                id: id,
                slotNumber: slotNumber,
                savedAt: savedAt,
                sourceFilename: sourceFilename,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String id,
                required int slotNumber,
                required String savedAt,
                required String sourceFilename,
                required Json data,
                Value<int> rowid = const Value.absent(),
              }) => SaveSnapshotsCompanion.insert(
                gameId: gameId,
                id: id,
                slotNumber: slotNumber,
                savedAt: savedAt,
                sourceFilename: sourceFilename,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SaveSnapshotsTable, SaveSnapshotRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SaveSnapshotsTable,
                    SaveSnapshotRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaveSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaveSnapshotsTable,
      SaveSnapshotRow,
      $$SaveSnapshotsTableFilterComposer,
      $$SaveSnapshotsTableOrderingComposer,
      $$SaveSnapshotsTableAnnotationComposer,
      $$SaveSnapshotsTableCreateCompanionBuilder,
      $$SaveSnapshotsTableUpdateCompanionBuilder,
      (
        SaveSnapshotRow,
        BaseReferences<_$AppDatabase, $SaveSnapshotsTable, SaveSnapshotRow>,
      ),
      SaveSnapshotRow,
      PrefetchHooks Function()
    >;
typedef $$ProfileTransactionsTableCreateCompanionBuilder =
    ProfileTransactionsCompanion Function({
      Value<String> gameId,
      Value<int> seq,
      required String label,
      required String at,
      required TransactionOrigin origin,
      required Json before,
    });
typedef $$ProfileTransactionsTableUpdateCompanionBuilder =
    ProfileTransactionsCompanion Function({
      Value<String> gameId,
      Value<int> seq,
      Value<String> label,
      Value<String> at,
      Value<TransactionOrigin> origin,
      Value<Json> before,
    });

class $$ProfileTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileTransactionsTable> {
  $$ProfileTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionOrigin, TransactionOrigin, String>
  get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Json, Json, String> get before =>
      $composableBuilder(
        column: $table.before,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$ProfileTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileTransactionsTable> {
  $$ProfileTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get before => $composableBuilder(
    column: $table.before,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileTransactionsTable> {
  $$ProfileTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionOrigin, String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Json, String> get before =>
      $composableBuilder(column: $table.before, builder: (column) => column);
}

class $$ProfileTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileTransactionsTable,
          TransactionRow,
          $$ProfileTransactionsTableFilterComposer,
          $$ProfileTransactionsTableOrderingComposer,
          $$ProfileTransactionsTableAnnotationComposer,
          $$ProfileTransactionsTableCreateCompanionBuilder,
          $$ProfileTransactionsTableUpdateCompanionBuilder,
          (
            TransactionRow,
            BaseReferences<
              _$AppDatabase,
              $ProfileTransactionsTable,
              TransactionRow
            >,
          ),
          TransactionRow,
          PrefetchHooks Function()
        > {
  $$ProfileTransactionsTableTableManager(
    _$AppDatabase db,
    $ProfileTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProfileTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> at = const Value.absent(),
                Value<TransactionOrigin> origin = const Value.absent(),
                Value<Json> before = const Value.absent(),
              }) => ProfileTransactionsCompanion(
                gameId: gameId,
                seq: seq,
                label: label,
                at: at,
                origin: origin,
                before: before,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                required String label,
                required String at,
                required TransactionOrigin origin,
                required Json before,
              }) => ProfileTransactionsCompanion.insert(
                gameId: gameId,
                seq: seq,
                label: label,
                at: at,
                origin: origin,
                before: before,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ProfileTransactionsTable, TransactionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ProfileTransactionsTable,
                    TransactionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileTransactionsTable,
      TransactionRow,
      $$ProfileTransactionsTableFilterComposer,
      $$ProfileTransactionsTableOrderingComposer,
      $$ProfileTransactionsTableAnnotationComposer,
      $$ProfileTransactionsTableCreateCompanionBuilder,
      $$ProfileTransactionsTableUpdateCompanionBuilder,
      (
        TransactionRow,
        BaseReferences<
          _$AppDatabase,
          $ProfileTransactionsTable,
          TransactionRow
        >,
      ),
      TransactionRow,
      PrefetchHooks Function()
    >;
typedef $$BackupsTableCreateCompanionBuilder =
    BackupsCompanion Function({
      Value<String> gameId,
      required String createdAt,
      required String content,
      Value<int> rowid,
    });
typedef $$BackupsTableUpdateCompanionBuilder =
    BackupsCompanion Function({
      Value<String> gameId,
      Value<String> createdAt,
      Value<String> content,
      Value<int> rowid,
    });

class $$BackupsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupsTable> {
  $$BackupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupsTable> {
  $$BackupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupsTable> {
  $$BackupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);
}

class $$BackupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupsTable,
          BackupRow,
          $$BackupsTableFilterComposer,
          $$BackupsTableOrderingComposer,
          $$BackupsTableAnnotationComposer,
          $$BackupsTableCreateCompanionBuilder,
          $$BackupsTableUpdateCompanionBuilder,
          (BackupRow, BaseReferences<_$AppDatabase, $BackupsTable, BackupRow>),
          BackupRow,
          PrefetchHooks Function()
        > {
  $$BackupsTableTableManager(_$AppDatabase db, $BackupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupsCompanion(
                gameId: gameId,
                createdAt: createdAt,
                content: content,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> gameId = const Value.absent(),
                required String createdAt,
                required String content,
                Value<int> rowid = const Value.absent(),
              }) => BackupsCompanion.insert(
                gameId: gameId,
                createdAt: createdAt,
                content: content,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BackupsTable, BackupRow>(table),
                  BaseReferences<_$AppDatabase, $BackupsTable, BackupRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BackupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupsTable,
      BackupRow,
      $$BackupsTableFilterComposer,
      $$BackupsTableOrderingComposer,
      $$BackupsTableAnnotationComposer,
      $$BackupsTableCreateCompanionBuilder,
      $$BackupsTableUpdateCompanionBuilder,
      (BackupRow, BaseReferences<_$AppDatabase, $BackupsTable, BackupRow>),
      BackupRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$InventoryTableTableManager get inventory =>
      $$InventoryTableTableManager(_db, _db.inventory);
  $$CompletionTableTableManager get completion =>
      $$CompletionTableTableManager(_db, _db.completion);
  $$RecipesTableTableManager get recipes =>
      $$RecipesTableTableManager(_db, _db.recipes);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$PlayerSettingsTableTableManager get playerSettings =>
      $$PlayerSettingsTableTableManager(_db, _db.playerSettings);
  $$SaveValuesTableTableManager get saveValues =>
      $$SaveValuesTableTableManager(_db, _db.saveValues);
  $$OverrideScopesTableTableManager get overrideScopes =>
      $$OverrideScopesTableTableManager(_db, _db.overrideScopes);
  $$ManualOverridesTableTableManager get manualOverrides =>
      $$ManualOverridesTableTableManager(_db, _db.manualOverrides);
  $$PlanRecipesTableTableManager get planRecipes =>
      $$PlanRecipesTableTableManager(_db, _db.planRecipes);
  $$PlanRewardsTableTableManager get planRewards =>
      $$PlanRewardsTableTableManager(_db, _db.planRewards);
  $$SessionMaterialsTableTableManager get sessionMaterials =>
      $$SessionMaterialsTableTableManager(_db, _db.sessionMaterials);
  $$AppliedEvidenceTableTableManager get appliedEvidence =>
      $$AppliedEvidenceTableTableManager(_db, _db.appliedEvidence);
  $$SaveSnapshotsTableTableManager get saveSnapshots =>
      $$SaveSnapshotsTableTableManager(_db, _db.saveSnapshots);
  $$ProfileTransactionsTableTableManager get profileTransactions =>
      $$ProfileTransactionsTableTableManager(_db, _db.profileTransactions);
  $$BackupsTableTableManager get backups =>
      $$BackupsTableTableManager(_db, _db.backups);
}
