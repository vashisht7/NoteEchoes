// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_database.dart';

// ignore_for_file: type=lint
class $AiNoteAnalysisTableTable extends AiNoteAnalysisTable
    with TableInfo<$AiNoteAnalysisTableTable, AiNoteAnalysisTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiNoteAnalysisTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceHashMeta = const VerificationMeta(
    'sourceHash',
  );
  @override
  late final GeneratedColumn<String> sourceHash = GeneratedColumn<String>(
    'source_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectedLanguageMeta = const VerificationMeta(
    'detectedLanguage',
  );
  @override
  late final GeneratedColumn<String> detectedLanguage = GeneratedColumn<String>(
    'detected_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generatedTitleMeta = const VerificationMeta(
    'generatedTitle',
  );
  @override
  late final GeneratedColumn<String> generatedTitle = GeneratedColumn<String>(
    'generated_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _englishRetrievalSummaryMeta =
      const VerificationMeta('englishRetrievalSummary');
  @override
  late final GeneratedColumn<String> englishRetrievalSummary =
      GeneratedColumn<String>(
        'english_retrieval_summary',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _topicsJsonMeta = const VerificationMeta(
    'topicsJson',
  );
  @override
  late final GeneratedColumn<String> topicsJson = GeneratedColumn<String>(
    'topics_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _peopleJsonMeta = const VerificationMeta(
    'peopleJson',
  );
  @override
  late final GeneratedColumn<String> peopleJson = GeneratedColumn<String>(
    'people_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _placesJsonMeta = const VerificationMeta(
    'placesJson',
  );
  @override
  late final GeneratedColumn<String> placesJson = GeneratedColumn<String>(
    'places_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _suggestedTagsJsonMeta = const VerificationMeta(
    'suggestedTagsJson',
  );
  @override
  late final GeneratedColumn<String> suggestedTagsJson =
      GeneratedColumn<String>(
        'suggested_tags_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actionItemsJsonMeta = const VerificationMeta(
    'actionItemsJson',
  );
  @override
  late final GeneratedColumn<String> actionItemsJson = GeneratedColumn<String>(
    'action_items_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventsJsonMeta = const VerificationMeta(
    'eventsJson',
  );
  @override
  late final GeneratedColumn<String> eventsJson = GeneratedColumn<String>(
    'events_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remindersJsonMeta = const VerificationMeta(
    'remindersJson',
  );
  @override
  late final GeneratedColumn<String> remindersJson = GeneratedColumn<String>(
    'reminders_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _travelDetailsJsonMeta = const VerificationMeta(
    'travelDetailsJson',
  );
  @override
  late final GeneratedColumn<String> travelDetailsJson =
      GeneratedColumn<String>(
        'travel_details_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    noteId,
    modelVersion,
    sourceHash,
    detectedLanguage,
    generatedTitle,
    summary,
    englishRetrievalSummary,
    topicsJson,
    peopleJson,
    placesJson,
    suggestedTagsJson,
    actionItemsJson,
    eventsJson,
    remindersJson,
    travelDetailsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_note_analysis';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiNoteAnalysisTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('source_hash')) {
      context.handle(
        _sourceHashMeta,
        sourceHash.isAcceptableOrUnknown(data['source_hash']!, _sourceHashMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceHashMeta);
    }
    if (data.containsKey('detected_language')) {
      context.handle(
        _detectedLanguageMeta,
        detectedLanguage.isAcceptableOrUnknown(
          data['detected_language']!,
          _detectedLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectedLanguageMeta);
    }
    if (data.containsKey('generated_title')) {
      context.handle(
        _generatedTitleMeta,
        generatedTitle.isAcceptableOrUnknown(
          data['generated_title']!,
          _generatedTitleMeta,
        ),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('english_retrieval_summary')) {
      context.handle(
        _englishRetrievalSummaryMeta,
        englishRetrievalSummary.isAcceptableOrUnknown(
          data['english_retrieval_summary']!,
          _englishRetrievalSummaryMeta,
        ),
      );
    }
    if (data.containsKey('topics_json')) {
      context.handle(
        _topicsJsonMeta,
        topicsJson.isAcceptableOrUnknown(data['topics_json']!, _topicsJsonMeta),
      );
    }
    if (data.containsKey('people_json')) {
      context.handle(
        _peopleJsonMeta,
        peopleJson.isAcceptableOrUnknown(data['people_json']!, _peopleJsonMeta),
      );
    }
    if (data.containsKey('places_json')) {
      context.handle(
        _placesJsonMeta,
        placesJson.isAcceptableOrUnknown(data['places_json']!, _placesJsonMeta),
      );
    }
    if (data.containsKey('suggested_tags_json')) {
      context.handle(
        _suggestedTagsJsonMeta,
        suggestedTagsJson.isAcceptableOrUnknown(
          data['suggested_tags_json']!,
          _suggestedTagsJsonMeta,
        ),
      );
    }
    if (data.containsKey('action_items_json')) {
      context.handle(
        _actionItemsJsonMeta,
        actionItemsJson.isAcceptableOrUnknown(
          data['action_items_json']!,
          _actionItemsJsonMeta,
        ),
      );
    }
    if (data.containsKey('events_json')) {
      context.handle(
        _eventsJsonMeta,
        eventsJson.isAcceptableOrUnknown(data['events_json']!, _eventsJsonMeta),
      );
    }
    if (data.containsKey('reminders_json')) {
      context.handle(
        _remindersJsonMeta,
        remindersJson.isAcceptableOrUnknown(
          data['reminders_json']!,
          _remindersJsonMeta,
        ),
      );
    }
    if (data.containsKey('travel_details_json')) {
      context.handle(
        _travelDetailsJsonMeta,
        travelDetailsJson.isAcceptableOrUnknown(
          data['travel_details_json']!,
          _travelDetailsJsonMeta,
        ),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId};
  @override
  AiNoteAnalysisTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiNoteAnalysisTableData(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      sourceHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_hash'],
      )!,
      detectedLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_language'],
      )!,
      generatedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}generated_title'],
      ),
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      englishRetrievalSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_retrieval_summary'],
      ),
      topicsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topics_json'],
      ),
      peopleJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}people_json'],
      ),
      placesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}places_json'],
      ),
      suggestedTagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_tags_json'],
      ),
      actionItemsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_items_json'],
      ),
      eventsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}events_json'],
      ),
      remindersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminders_json'],
      ),
      travelDetailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}travel_details_json'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AiNoteAnalysisTableTable createAlias(String alias) {
    return $AiNoteAnalysisTableTable(attachedDatabase, alias);
  }
}

class AiNoteAnalysisTableData extends DataClass
    implements Insertable<AiNoteAnalysisTableData> {
  final String noteId;
  final String modelVersion;
  final String sourceHash;
  final String detectedLanguage;
  final String? generatedTitle;
  final String? summary;
  final String? englishRetrievalSummary;
  final String? topicsJson;
  final String? peopleJson;
  final String? placesJson;
  final String? suggestedTagsJson;
  final String? actionItemsJson;
  final String? eventsJson;
  final String? remindersJson;
  final String? travelDetailsJson;
  final int createdAt;
  final int updatedAt;
  const AiNoteAnalysisTableData({
    required this.noteId,
    required this.modelVersion,
    required this.sourceHash,
    required this.detectedLanguage,
    this.generatedTitle,
    this.summary,
    this.englishRetrievalSummary,
    this.topicsJson,
    this.peopleJson,
    this.placesJson,
    this.suggestedTagsJson,
    this.actionItemsJson,
    this.eventsJson,
    this.remindersJson,
    this.travelDetailsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<String>(noteId);
    map['model_version'] = Variable<String>(modelVersion);
    map['source_hash'] = Variable<String>(sourceHash);
    map['detected_language'] = Variable<String>(detectedLanguage);
    if (!nullToAbsent || generatedTitle != null) {
      map['generated_title'] = Variable<String>(generatedTitle);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    if (!nullToAbsent || englishRetrievalSummary != null) {
      map['english_retrieval_summary'] = Variable<String>(
        englishRetrievalSummary,
      );
    }
    if (!nullToAbsent || topicsJson != null) {
      map['topics_json'] = Variable<String>(topicsJson);
    }
    if (!nullToAbsent || peopleJson != null) {
      map['people_json'] = Variable<String>(peopleJson);
    }
    if (!nullToAbsent || placesJson != null) {
      map['places_json'] = Variable<String>(placesJson);
    }
    if (!nullToAbsent || suggestedTagsJson != null) {
      map['suggested_tags_json'] = Variable<String>(suggestedTagsJson);
    }
    if (!nullToAbsent || actionItemsJson != null) {
      map['action_items_json'] = Variable<String>(actionItemsJson);
    }
    if (!nullToAbsent || eventsJson != null) {
      map['events_json'] = Variable<String>(eventsJson);
    }
    if (!nullToAbsent || remindersJson != null) {
      map['reminders_json'] = Variable<String>(remindersJson);
    }
    if (!nullToAbsent || travelDetailsJson != null) {
      map['travel_details_json'] = Variable<String>(travelDetailsJson);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AiNoteAnalysisTableCompanion toCompanion(bool nullToAbsent) {
    return AiNoteAnalysisTableCompanion(
      noteId: Value(noteId),
      modelVersion: Value(modelVersion),
      sourceHash: Value(sourceHash),
      detectedLanguage: Value(detectedLanguage),
      generatedTitle: generatedTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(generatedTitle),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      englishRetrievalSummary: englishRetrievalSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(englishRetrievalSummary),
      topicsJson: topicsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(topicsJson),
      peopleJson: peopleJson == null && nullToAbsent
          ? const Value.absent()
          : Value(peopleJson),
      placesJson: placesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(placesJson),
      suggestedTagsJson: suggestedTagsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedTagsJson),
      actionItemsJson: actionItemsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(actionItemsJson),
      eventsJson: eventsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(eventsJson),
      remindersJson: remindersJson == null && nullToAbsent
          ? const Value.absent()
          : Value(remindersJson),
      travelDetailsJson: travelDetailsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(travelDetailsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AiNoteAnalysisTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiNoteAnalysisTableData(
      noteId: serializer.fromJson<String>(json['noteId']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      sourceHash: serializer.fromJson<String>(json['sourceHash']),
      detectedLanguage: serializer.fromJson<String>(json['detectedLanguage']),
      generatedTitle: serializer.fromJson<String?>(json['generatedTitle']),
      summary: serializer.fromJson<String?>(json['summary']),
      englishRetrievalSummary: serializer.fromJson<String?>(
        json['englishRetrievalSummary'],
      ),
      topicsJson: serializer.fromJson<String?>(json['topicsJson']),
      peopleJson: serializer.fromJson<String?>(json['peopleJson']),
      placesJson: serializer.fromJson<String?>(json['placesJson']),
      suggestedTagsJson: serializer.fromJson<String?>(
        json['suggestedTagsJson'],
      ),
      actionItemsJson: serializer.fromJson<String?>(json['actionItemsJson']),
      eventsJson: serializer.fromJson<String?>(json['eventsJson']),
      remindersJson: serializer.fromJson<String?>(json['remindersJson']),
      travelDetailsJson: serializer.fromJson<String?>(
        json['travelDetailsJson'],
      ),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<String>(noteId),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'sourceHash': serializer.toJson<String>(sourceHash),
      'detectedLanguage': serializer.toJson<String>(detectedLanguage),
      'generatedTitle': serializer.toJson<String?>(generatedTitle),
      'summary': serializer.toJson<String?>(summary),
      'englishRetrievalSummary': serializer.toJson<String?>(
        englishRetrievalSummary,
      ),
      'topicsJson': serializer.toJson<String?>(topicsJson),
      'peopleJson': serializer.toJson<String?>(peopleJson),
      'placesJson': serializer.toJson<String?>(placesJson),
      'suggestedTagsJson': serializer.toJson<String?>(suggestedTagsJson),
      'actionItemsJson': serializer.toJson<String?>(actionItemsJson),
      'eventsJson': serializer.toJson<String?>(eventsJson),
      'remindersJson': serializer.toJson<String?>(remindersJson),
      'travelDetailsJson': serializer.toJson<String?>(travelDetailsJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  AiNoteAnalysisTableData copyWith({
    String? noteId,
    String? modelVersion,
    String? sourceHash,
    String? detectedLanguage,
    Value<String?> generatedTitle = const Value.absent(),
    Value<String?> summary = const Value.absent(),
    Value<String?> englishRetrievalSummary = const Value.absent(),
    Value<String?> topicsJson = const Value.absent(),
    Value<String?> peopleJson = const Value.absent(),
    Value<String?> placesJson = const Value.absent(),
    Value<String?> suggestedTagsJson = const Value.absent(),
    Value<String?> actionItemsJson = const Value.absent(),
    Value<String?> eventsJson = const Value.absent(),
    Value<String?> remindersJson = const Value.absent(),
    Value<String?> travelDetailsJson = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => AiNoteAnalysisTableData(
    noteId: noteId ?? this.noteId,
    modelVersion: modelVersion ?? this.modelVersion,
    sourceHash: sourceHash ?? this.sourceHash,
    detectedLanguage: detectedLanguage ?? this.detectedLanguage,
    generatedTitle: generatedTitle.present
        ? generatedTitle.value
        : this.generatedTitle,
    summary: summary.present ? summary.value : this.summary,
    englishRetrievalSummary: englishRetrievalSummary.present
        ? englishRetrievalSummary.value
        : this.englishRetrievalSummary,
    topicsJson: topicsJson.present ? topicsJson.value : this.topicsJson,
    peopleJson: peopleJson.present ? peopleJson.value : this.peopleJson,
    placesJson: placesJson.present ? placesJson.value : this.placesJson,
    suggestedTagsJson: suggestedTagsJson.present
        ? suggestedTagsJson.value
        : this.suggestedTagsJson,
    actionItemsJson: actionItemsJson.present
        ? actionItemsJson.value
        : this.actionItemsJson,
    eventsJson: eventsJson.present ? eventsJson.value : this.eventsJson,
    remindersJson: remindersJson.present
        ? remindersJson.value
        : this.remindersJson,
    travelDetailsJson: travelDetailsJson.present
        ? travelDetailsJson.value
        : this.travelDetailsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AiNoteAnalysisTableData copyWithCompanion(AiNoteAnalysisTableCompanion data) {
    return AiNoteAnalysisTableData(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      sourceHash: data.sourceHash.present
          ? data.sourceHash.value
          : this.sourceHash,
      detectedLanguage: data.detectedLanguage.present
          ? data.detectedLanguage.value
          : this.detectedLanguage,
      generatedTitle: data.generatedTitle.present
          ? data.generatedTitle.value
          : this.generatedTitle,
      summary: data.summary.present ? data.summary.value : this.summary,
      englishRetrievalSummary: data.englishRetrievalSummary.present
          ? data.englishRetrievalSummary.value
          : this.englishRetrievalSummary,
      topicsJson: data.topicsJson.present
          ? data.topicsJson.value
          : this.topicsJson,
      peopleJson: data.peopleJson.present
          ? data.peopleJson.value
          : this.peopleJson,
      placesJson: data.placesJson.present
          ? data.placesJson.value
          : this.placesJson,
      suggestedTagsJson: data.suggestedTagsJson.present
          ? data.suggestedTagsJson.value
          : this.suggestedTagsJson,
      actionItemsJson: data.actionItemsJson.present
          ? data.actionItemsJson.value
          : this.actionItemsJson,
      eventsJson: data.eventsJson.present
          ? data.eventsJson.value
          : this.eventsJson,
      remindersJson: data.remindersJson.present
          ? data.remindersJson.value
          : this.remindersJson,
      travelDetailsJson: data.travelDetailsJson.present
          ? data.travelDetailsJson.value
          : this.travelDetailsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiNoteAnalysisTableData(')
          ..write('noteId: $noteId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('detectedLanguage: $detectedLanguage, ')
          ..write('generatedTitle: $generatedTitle, ')
          ..write('summary: $summary, ')
          ..write('englishRetrievalSummary: $englishRetrievalSummary, ')
          ..write('topicsJson: $topicsJson, ')
          ..write('peopleJson: $peopleJson, ')
          ..write('placesJson: $placesJson, ')
          ..write('suggestedTagsJson: $suggestedTagsJson, ')
          ..write('actionItemsJson: $actionItemsJson, ')
          ..write('eventsJson: $eventsJson, ')
          ..write('remindersJson: $remindersJson, ')
          ..write('travelDetailsJson: $travelDetailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    noteId,
    modelVersion,
    sourceHash,
    detectedLanguage,
    generatedTitle,
    summary,
    englishRetrievalSummary,
    topicsJson,
    peopleJson,
    placesJson,
    suggestedTagsJson,
    actionItemsJson,
    eventsJson,
    remindersJson,
    travelDetailsJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiNoteAnalysisTableData &&
          other.noteId == this.noteId &&
          other.modelVersion == this.modelVersion &&
          other.sourceHash == this.sourceHash &&
          other.detectedLanguage == this.detectedLanguage &&
          other.generatedTitle == this.generatedTitle &&
          other.summary == this.summary &&
          other.englishRetrievalSummary == this.englishRetrievalSummary &&
          other.topicsJson == this.topicsJson &&
          other.peopleJson == this.peopleJson &&
          other.placesJson == this.placesJson &&
          other.suggestedTagsJson == this.suggestedTagsJson &&
          other.actionItemsJson == this.actionItemsJson &&
          other.eventsJson == this.eventsJson &&
          other.remindersJson == this.remindersJson &&
          other.travelDetailsJson == this.travelDetailsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AiNoteAnalysisTableCompanion
    extends UpdateCompanion<AiNoteAnalysisTableData> {
  final Value<String> noteId;
  final Value<String> modelVersion;
  final Value<String> sourceHash;
  final Value<String> detectedLanguage;
  final Value<String?> generatedTitle;
  final Value<String?> summary;
  final Value<String?> englishRetrievalSummary;
  final Value<String?> topicsJson;
  final Value<String?> peopleJson;
  final Value<String?> placesJson;
  final Value<String?> suggestedTagsJson;
  final Value<String?> actionItemsJson;
  final Value<String?> eventsJson;
  final Value<String?> remindersJson;
  final Value<String?> travelDetailsJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AiNoteAnalysisTableCompanion({
    this.noteId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.sourceHash = const Value.absent(),
    this.detectedLanguage = const Value.absent(),
    this.generatedTitle = const Value.absent(),
    this.summary = const Value.absent(),
    this.englishRetrievalSummary = const Value.absent(),
    this.topicsJson = const Value.absent(),
    this.peopleJson = const Value.absent(),
    this.placesJson = const Value.absent(),
    this.suggestedTagsJson = const Value.absent(),
    this.actionItemsJson = const Value.absent(),
    this.eventsJson = const Value.absent(),
    this.remindersJson = const Value.absent(),
    this.travelDetailsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiNoteAnalysisTableCompanion.insert({
    required String noteId,
    required String modelVersion,
    required String sourceHash,
    required String detectedLanguage,
    this.generatedTitle = const Value.absent(),
    this.summary = const Value.absent(),
    this.englishRetrievalSummary = const Value.absent(),
    this.topicsJson = const Value.absent(),
    this.peopleJson = const Value.absent(),
    this.placesJson = const Value.absent(),
    this.suggestedTagsJson = const Value.absent(),
    this.actionItemsJson = const Value.absent(),
    this.eventsJson = const Value.absent(),
    this.remindersJson = const Value.absent(),
    this.travelDetailsJson = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       modelVersion = Value(modelVersion),
       sourceHash = Value(sourceHash),
       detectedLanguage = Value(detectedLanguage),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AiNoteAnalysisTableData> custom({
    Expression<String>? noteId,
    Expression<String>? modelVersion,
    Expression<String>? sourceHash,
    Expression<String>? detectedLanguage,
    Expression<String>? generatedTitle,
    Expression<String>? summary,
    Expression<String>? englishRetrievalSummary,
    Expression<String>? topicsJson,
    Expression<String>? peopleJson,
    Expression<String>? placesJson,
    Expression<String>? suggestedTagsJson,
    Expression<String>? actionItemsJson,
    Expression<String>? eventsJson,
    Expression<String>? remindersJson,
    Expression<String>? travelDetailsJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (sourceHash != null) 'source_hash': sourceHash,
      if (detectedLanguage != null) 'detected_language': detectedLanguage,
      if (generatedTitle != null) 'generated_title': generatedTitle,
      if (summary != null) 'summary': summary,
      if (englishRetrievalSummary != null)
        'english_retrieval_summary': englishRetrievalSummary,
      if (topicsJson != null) 'topics_json': topicsJson,
      if (peopleJson != null) 'people_json': peopleJson,
      if (placesJson != null) 'places_json': placesJson,
      if (suggestedTagsJson != null) 'suggested_tags_json': suggestedTagsJson,
      if (actionItemsJson != null) 'action_items_json': actionItemsJson,
      if (eventsJson != null) 'events_json': eventsJson,
      if (remindersJson != null) 'reminders_json': remindersJson,
      if (travelDetailsJson != null) 'travel_details_json': travelDetailsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiNoteAnalysisTableCompanion copyWith({
    Value<String>? noteId,
    Value<String>? modelVersion,
    Value<String>? sourceHash,
    Value<String>? detectedLanguage,
    Value<String?>? generatedTitle,
    Value<String?>? summary,
    Value<String?>? englishRetrievalSummary,
    Value<String?>? topicsJson,
    Value<String?>? peopleJson,
    Value<String?>? placesJson,
    Value<String?>? suggestedTagsJson,
    Value<String?>? actionItemsJson,
    Value<String?>? eventsJson,
    Value<String?>? remindersJson,
    Value<String?>? travelDetailsJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AiNoteAnalysisTableCompanion(
      noteId: noteId ?? this.noteId,
      modelVersion: modelVersion ?? this.modelVersion,
      sourceHash: sourceHash ?? this.sourceHash,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      generatedTitle: generatedTitle ?? this.generatedTitle,
      summary: summary ?? this.summary,
      englishRetrievalSummary:
          englishRetrievalSummary ?? this.englishRetrievalSummary,
      topicsJson: topicsJson ?? this.topicsJson,
      peopleJson: peopleJson ?? this.peopleJson,
      placesJson: placesJson ?? this.placesJson,
      suggestedTagsJson: suggestedTagsJson ?? this.suggestedTagsJson,
      actionItemsJson: actionItemsJson ?? this.actionItemsJson,
      eventsJson: eventsJson ?? this.eventsJson,
      remindersJson: remindersJson ?? this.remindersJson,
      travelDetailsJson: travelDetailsJson ?? this.travelDetailsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (sourceHash.present) {
      map['source_hash'] = Variable<String>(sourceHash.value);
    }
    if (detectedLanguage.present) {
      map['detected_language'] = Variable<String>(detectedLanguage.value);
    }
    if (generatedTitle.present) {
      map['generated_title'] = Variable<String>(generatedTitle.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (englishRetrievalSummary.present) {
      map['english_retrieval_summary'] = Variable<String>(
        englishRetrievalSummary.value,
      );
    }
    if (topicsJson.present) {
      map['topics_json'] = Variable<String>(topicsJson.value);
    }
    if (peopleJson.present) {
      map['people_json'] = Variable<String>(peopleJson.value);
    }
    if (placesJson.present) {
      map['places_json'] = Variable<String>(placesJson.value);
    }
    if (suggestedTagsJson.present) {
      map['suggested_tags_json'] = Variable<String>(suggestedTagsJson.value);
    }
    if (actionItemsJson.present) {
      map['action_items_json'] = Variable<String>(actionItemsJson.value);
    }
    if (eventsJson.present) {
      map['events_json'] = Variable<String>(eventsJson.value);
    }
    if (remindersJson.present) {
      map['reminders_json'] = Variable<String>(remindersJson.value);
    }
    if (travelDetailsJson.present) {
      map['travel_details_json'] = Variable<String>(travelDetailsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiNoteAnalysisTableCompanion(')
          ..write('noteId: $noteId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('detectedLanguage: $detectedLanguage, ')
          ..write('generatedTitle: $generatedTitle, ')
          ..write('summary: $summary, ')
          ..write('englishRetrievalSummary: $englishRetrievalSummary, ')
          ..write('topicsJson: $topicsJson, ')
          ..write('peopleJson: $peopleJson, ')
          ..write('placesJson: $placesJson, ')
          ..write('suggestedTagsJson: $suggestedTagsJson, ')
          ..write('actionItemsJson: $actionItemsJson, ')
          ..write('eventsJson: $eventsJson, ')
          ..write('remindersJson: $remindersJson, ')
          ..write('travelDetailsJson: $travelDetailsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TranscriptSegmentsTableTable extends TranscriptSegmentsTable
    with TableInfo<$TranscriptSegmentsTableTable, TranscriptSegmentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TranscriptSegmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMsMeta = const VerificationMeta(
    'startMs',
  );
  @override
  late final GeneratedColumn<int> startMs = GeneratedColumn<int>(
    'start_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endMsMeta = const VerificationMeta('endMs');
  @override
  late final GeneratedColumn<int> endMs = GeneratedColumn<int>(
    'end_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _segmentTextMeta = const VerificationMeta(
    'segmentText',
  );
  @override
  late final GeneratedColumn<String> segmentText = GeneratedColumn<String>(
    'segment_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speakerLabelMeta = const VerificationMeta(
    'speakerLabel',
  );
  @override
  late final GeneratedColumn<String> speakerLabel = GeneratedColumn<String>(
    'speaker_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequence_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    startMs,
    endMs,
    language,
    segmentText,
    confidence,
    speakerLabel,
    sequenceNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transcript_segments';
  @override
  VerificationContext validateIntegrity(
    Insertable<TranscriptSegmentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('start_ms')) {
      context.handle(
        _startMsMeta,
        startMs.isAcceptableOrUnknown(data['start_ms']!, _startMsMeta),
      );
    } else if (isInserting) {
      context.missing(_startMsMeta);
    }
    if (data.containsKey('end_ms')) {
      context.handle(
        _endMsMeta,
        endMs.isAcceptableOrUnknown(data['end_ms']!, _endMsMeta),
      );
    } else if (isInserting) {
      context.missing(_endMsMeta);
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    } else if (isInserting) {
      context.missing(_languageMeta);
    }
    if (data.containsKey('segment_text')) {
      context.handle(
        _segmentTextMeta,
        segmentText.isAcceptableOrUnknown(
          data['segment_text']!,
          _segmentTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_segmentTextMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('speaker_label')) {
      context.handle(
        _speakerLabelMeta,
        speakerLabel.isAcceptableOrUnknown(
          data['speaker_label']!,
          _speakerLabelMeta,
        ),
      );
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequence_number']!,
          _sequenceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceNumberMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TranscriptSegmentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TranscriptSegmentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      startMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_ms'],
      )!,
      endMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_ms'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      segmentText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}segment_text'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      speakerLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}speaker_label'],
      ),
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_number'],
      )!,
    );
  }

  @override
  $TranscriptSegmentsTableTable createAlias(String alias) {
    return $TranscriptSegmentsTableTable(attachedDatabase, alias);
  }
}

class TranscriptSegmentsTableData extends DataClass
    implements Insertable<TranscriptSegmentsTableData> {
  final String id;
  final String noteId;
  final int startMs;
  final int endMs;
  final String language;
  final String segmentText;
  final double confidence;
  final String? speakerLabel;
  final int sequenceNumber;
  const TranscriptSegmentsTableData({
    required this.id,
    required this.noteId,
    required this.startMs,
    required this.endMs,
    required this.language,
    required this.segmentText,
    required this.confidence,
    this.speakerLabel,
    required this.sequenceNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['start_ms'] = Variable<int>(startMs);
    map['end_ms'] = Variable<int>(endMs);
    map['language'] = Variable<String>(language);
    map['segment_text'] = Variable<String>(segmentText);
    map['confidence'] = Variable<double>(confidence);
    if (!nullToAbsent || speakerLabel != null) {
      map['speaker_label'] = Variable<String>(speakerLabel);
    }
    map['sequence_number'] = Variable<int>(sequenceNumber);
    return map;
  }

  TranscriptSegmentsTableCompanion toCompanion(bool nullToAbsent) {
    return TranscriptSegmentsTableCompanion(
      id: Value(id),
      noteId: Value(noteId),
      startMs: Value(startMs),
      endMs: Value(endMs),
      language: Value(language),
      segmentText: Value(segmentText),
      confidence: Value(confidence),
      speakerLabel: speakerLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(speakerLabel),
      sequenceNumber: Value(sequenceNumber),
    );
  }

  factory TranscriptSegmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TranscriptSegmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      startMs: serializer.fromJson<int>(json['startMs']),
      endMs: serializer.fromJson<int>(json['endMs']),
      language: serializer.fromJson<String>(json['language']),
      segmentText: serializer.fromJson<String>(json['segmentText']),
      confidence: serializer.fromJson<double>(json['confidence']),
      speakerLabel: serializer.fromJson<String?>(json['speakerLabel']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'startMs': serializer.toJson<int>(startMs),
      'endMs': serializer.toJson<int>(endMs),
      'language': serializer.toJson<String>(language),
      'segmentText': serializer.toJson<String>(segmentText),
      'confidence': serializer.toJson<double>(confidence),
      'speakerLabel': serializer.toJson<String?>(speakerLabel),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
    };
  }

  TranscriptSegmentsTableData copyWith({
    String? id,
    String? noteId,
    int? startMs,
    int? endMs,
    String? language,
    String? segmentText,
    double? confidence,
    Value<String?> speakerLabel = const Value.absent(),
    int? sequenceNumber,
  }) => TranscriptSegmentsTableData(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    startMs: startMs ?? this.startMs,
    endMs: endMs ?? this.endMs,
    language: language ?? this.language,
    segmentText: segmentText ?? this.segmentText,
    confidence: confidence ?? this.confidence,
    speakerLabel: speakerLabel.present ? speakerLabel.value : this.speakerLabel,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
  );
  TranscriptSegmentsTableData copyWithCompanion(
    TranscriptSegmentsTableCompanion data,
  ) {
    return TranscriptSegmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      startMs: data.startMs.present ? data.startMs.value : this.startMs,
      endMs: data.endMs.present ? data.endMs.value : this.endMs,
      language: data.language.present ? data.language.value : this.language,
      segmentText: data.segmentText.present
          ? data.segmentText.value
          : this.segmentText,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      speakerLabel: data.speakerLabel.present
          ? data.speakerLabel.value
          : this.speakerLabel,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptSegmentsTableData(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('language: $language, ')
          ..write('segmentText: $segmentText, ')
          ..write('confidence: $confidence, ')
          ..write('speakerLabel: $speakerLabel, ')
          ..write('sequenceNumber: $sequenceNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    noteId,
    startMs,
    endMs,
    language,
    segmentText,
    confidence,
    speakerLabel,
    sequenceNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TranscriptSegmentsTableData &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.startMs == this.startMs &&
          other.endMs == this.endMs &&
          other.language == this.language &&
          other.segmentText == this.segmentText &&
          other.confidence == this.confidence &&
          other.speakerLabel == this.speakerLabel &&
          other.sequenceNumber == this.sequenceNumber);
}

class TranscriptSegmentsTableCompanion
    extends UpdateCompanion<TranscriptSegmentsTableData> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<int> startMs;
  final Value<int> endMs;
  final Value<String> language;
  final Value<String> segmentText;
  final Value<double> confidence;
  final Value<String?> speakerLabel;
  final Value<int> sequenceNumber;
  final Value<int> rowid;
  const TranscriptSegmentsTableCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.startMs = const Value.absent(),
    this.endMs = const Value.absent(),
    this.language = const Value.absent(),
    this.segmentText = const Value.absent(),
    this.confidence = const Value.absent(),
    this.speakerLabel = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TranscriptSegmentsTableCompanion.insert({
    required String id,
    required String noteId,
    required int startMs,
    required int endMs,
    required String language,
    required String segmentText,
    required double confidence,
    this.speakerLabel = const Value.absent(),
    required int sequenceNumber,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       startMs = Value(startMs),
       endMs = Value(endMs),
       language = Value(language),
       segmentText = Value(segmentText),
       confidence = Value(confidence),
       sequenceNumber = Value(sequenceNumber);
  static Insertable<TranscriptSegmentsTableData> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<int>? startMs,
    Expression<int>? endMs,
    Expression<String>? language,
    Expression<String>? segmentText,
    Expression<double>? confidence,
    Expression<String>? speakerLabel,
    Expression<int>? sequenceNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (startMs != null) 'start_ms': startMs,
      if (endMs != null) 'end_ms': endMs,
      if (language != null) 'language': language,
      if (segmentText != null) 'segment_text': segmentText,
      if (confidence != null) 'confidence': confidence,
      if (speakerLabel != null) 'speaker_label': speakerLabel,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TranscriptSegmentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<int>? startMs,
    Value<int>? endMs,
    Value<String>? language,
    Value<String>? segmentText,
    Value<double>? confidence,
    Value<String?>? speakerLabel,
    Value<int>? sequenceNumber,
    Value<int>? rowid,
  }) {
    return TranscriptSegmentsTableCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      startMs: startMs ?? this.startMs,
      endMs: endMs ?? this.endMs,
      language: language ?? this.language,
      segmentText: segmentText ?? this.segmentText,
      confidence: confidence ?? this.confidence,
      speakerLabel: speakerLabel ?? this.speakerLabel,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (startMs.present) {
      map['start_ms'] = Variable<int>(startMs.value);
    }
    if (endMs.present) {
      map['end_ms'] = Variable<int>(endMs.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (segmentText.present) {
      map['segment_text'] = Variable<String>(segmentText.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (speakerLabel.present) {
      map['speaker_label'] = Variable<String>(speakerLabel.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TranscriptSegmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('startMs: $startMs, ')
          ..write('endMs: $endMs, ')
          ..write('language: $language, ')
          ..write('segmentText: $segmentText, ')
          ..write('confidence: $confidence, ')
          ..write('speakerLabel: $speakerLabel, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTableTable extends DocumentsTable
    with TableInfo<$DocumentsTableTable, DocumentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notebookIdMeta = const VerificationMeta(
    'notebookId',
  );
  @override
  late final GeneratedColumn<String> notebookId = GeneratedColumn<String>(
    'notebook_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _processingStateMeta = const VerificationMeta(
    'processingState',
  );
  @override
  late final GeneratedColumn<String> processingState = GeneratedColumn<String>(
    'processing_state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _processingErrorMeta = const VerificationMeta(
    'processingError',
  );
  @override
  late final GeneratedColumn<String> processingError = GeneratedColumn<String>(
    'processing_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<int> importedAt = GeneratedColumn<int>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    notebookId,
    localPath,
    sha256,
    title,
    pageCount,
    processingState,
    processingError,
    importedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('notebook_id')) {
      context.handle(
        _notebookIdMeta,
        notebookId.isAcceptableOrUnknown(data['notebook_id']!, _notebookIdMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('processing_state')) {
      context.handle(
        _processingStateMeta,
        processingState.isAcceptableOrUnknown(
          data['processing_state']!,
          _processingStateMeta,
        ),
      );
    }
    if (data.containsKey('processing_error')) {
      context.handle(
        _processingErrorMeta,
        processingError.isAcceptableOrUnknown(
          data['processing_error']!,
          _processingErrorMeta,
        ),
      );
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      notebookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notebook_id'],
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      processingState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}processing_state'],
      )!,
      processingError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}processing_error'],
      ),
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}imported_at'],
      )!,
    );
  }

  @override
  $DocumentsTableTable createAlias(String alias) {
    return $DocumentsTableTable(attachedDatabase, alias);
  }
}

class DocumentsTableData extends DataClass
    implements Insertable<DocumentsTableData> {
  final String id;
  final String? notebookId;
  final String localPath;
  final String sha256;
  final String title;
  final int? pageCount;
  final String processingState;
  final String? processingError;
  final int importedAt;
  const DocumentsTableData({
    required this.id,
    this.notebookId,
    required this.localPath,
    required this.sha256,
    required this.title,
    this.pageCount,
    required this.processingState,
    this.processingError,
    required this.importedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || notebookId != null) {
      map['notebook_id'] = Variable<String>(notebookId);
    }
    map['local_path'] = Variable<String>(localPath);
    map['sha256'] = Variable<String>(sha256);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    map['processing_state'] = Variable<String>(processingState);
    if (!nullToAbsent || processingError != null) {
      map['processing_error'] = Variable<String>(processingError);
    }
    map['imported_at'] = Variable<int>(importedAt);
    return map;
  }

  DocumentsTableCompanion toCompanion(bool nullToAbsent) {
    return DocumentsTableCompanion(
      id: Value(id),
      notebookId: notebookId == null && nullToAbsent
          ? const Value.absent()
          : Value(notebookId),
      localPath: Value(localPath),
      sha256: Value(sha256),
      title: Value(title),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      processingState: Value(processingState),
      processingError: processingError == null && nullToAbsent
          ? const Value.absent()
          : Value(processingError),
      importedAt: Value(importedAt),
    );
  }

  factory DocumentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentsTableData(
      id: serializer.fromJson<String>(json['id']),
      notebookId: serializer.fromJson<String?>(json['notebookId']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sha256: serializer.fromJson<String>(json['sha256']),
      title: serializer.fromJson<String>(json['title']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      processingState: serializer.fromJson<String>(json['processingState']),
      processingError: serializer.fromJson<String?>(json['processingError']),
      importedAt: serializer.fromJson<int>(json['importedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'notebookId': serializer.toJson<String?>(notebookId),
      'localPath': serializer.toJson<String>(localPath),
      'sha256': serializer.toJson<String>(sha256),
      'title': serializer.toJson<String>(title),
      'pageCount': serializer.toJson<int?>(pageCount),
      'processingState': serializer.toJson<String>(processingState),
      'processingError': serializer.toJson<String?>(processingError),
      'importedAt': serializer.toJson<int>(importedAt),
    };
  }

  DocumentsTableData copyWith({
    String? id,
    Value<String?> notebookId = const Value.absent(),
    String? localPath,
    String? sha256,
    String? title,
    Value<int?> pageCount = const Value.absent(),
    String? processingState,
    Value<String?> processingError = const Value.absent(),
    int? importedAt,
  }) => DocumentsTableData(
    id: id ?? this.id,
    notebookId: notebookId.present ? notebookId.value : this.notebookId,
    localPath: localPath ?? this.localPath,
    sha256: sha256 ?? this.sha256,
    title: title ?? this.title,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    processingState: processingState ?? this.processingState,
    processingError: processingError.present
        ? processingError.value
        : this.processingError,
    importedAt: importedAt ?? this.importedAt,
  );
  DocumentsTableData copyWithCompanion(DocumentsTableCompanion data) {
    return DocumentsTableData(
      id: data.id.present ? data.id.value : this.id,
      notebookId: data.notebookId.present
          ? data.notebookId.value
          : this.notebookId,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      title: data.title.present ? data.title.value : this.title,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      processingState: data.processingState.present
          ? data.processingState.value
          : this.processingState,
      processingError: data.processingError.present
          ? data.processingError.value
          : this.processingError,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsTableData(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('localPath: $localPath, ')
          ..write('sha256: $sha256, ')
          ..write('title: $title, ')
          ..write('pageCount: $pageCount, ')
          ..write('processingState: $processingState, ')
          ..write('processingError: $processingError, ')
          ..write('importedAt: $importedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    notebookId,
    localPath,
    sha256,
    title,
    pageCount,
    processingState,
    processingError,
    importedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentsTableData &&
          other.id == this.id &&
          other.notebookId == this.notebookId &&
          other.localPath == this.localPath &&
          other.sha256 == this.sha256 &&
          other.title == this.title &&
          other.pageCount == this.pageCount &&
          other.processingState == this.processingState &&
          other.processingError == this.processingError &&
          other.importedAt == this.importedAt);
}

class DocumentsTableCompanion extends UpdateCompanion<DocumentsTableData> {
  final Value<String> id;
  final Value<String?> notebookId;
  final Value<String> localPath;
  final Value<String> sha256;
  final Value<String> title;
  final Value<int?> pageCount;
  final Value<String> processingState;
  final Value<String?> processingError;
  final Value<int> importedAt;
  final Value<int> rowid;
  const DocumentsTableCompanion({
    this.id = const Value.absent(),
    this.notebookId = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sha256 = const Value.absent(),
    this.title = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.processingState = const Value.absent(),
    this.processingError = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentsTableCompanion.insert({
    required String id,
    this.notebookId = const Value.absent(),
    required String localPath,
    required String sha256,
    required String title,
    this.pageCount = const Value.absent(),
    this.processingState = const Value.absent(),
    this.processingError = const Value.absent(),
    required int importedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localPath = Value(localPath),
       sha256 = Value(sha256),
       title = Value(title),
       importedAt = Value(importedAt);
  static Insertable<DocumentsTableData> custom({
    Expression<String>? id,
    Expression<String>? notebookId,
    Expression<String>? localPath,
    Expression<String>? sha256,
    Expression<String>? title,
    Expression<int>? pageCount,
    Expression<String>? processingState,
    Expression<String>? processingError,
    Expression<int>? importedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (notebookId != null) 'notebook_id': notebookId,
      if (localPath != null) 'local_path': localPath,
      if (sha256 != null) 'sha256': sha256,
      if (title != null) 'title': title,
      if (pageCount != null) 'page_count': pageCount,
      if (processingState != null) 'processing_state': processingState,
      if (processingError != null) 'processing_error': processingError,
      if (importedAt != null) 'imported_at': importedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? notebookId,
    Value<String>? localPath,
    Value<String>? sha256,
    Value<String>? title,
    Value<int?>? pageCount,
    Value<String>? processingState,
    Value<String?>? processingError,
    Value<int>? importedAt,
    Value<int>? rowid,
  }) {
    return DocumentsTableCompanion(
      id: id ?? this.id,
      notebookId: notebookId ?? this.notebookId,
      localPath: localPath ?? this.localPath,
      sha256: sha256 ?? this.sha256,
      title: title ?? this.title,
      pageCount: pageCount ?? this.pageCount,
      processingState: processingState ?? this.processingState,
      processingError: processingError ?? this.processingError,
      importedAt: importedAt ?? this.importedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (notebookId.present) {
      map['notebook_id'] = Variable<String>(notebookId.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (processingState.present) {
      map['processing_state'] = Variable<String>(processingState.value);
    }
    if (processingError.present) {
      map['processing_error'] = Variable<String>(processingError.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<int>(importedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsTableCompanion(')
          ..write('id: $id, ')
          ..write('notebookId: $notebookId, ')
          ..write('localPath: $localPath, ')
          ..write('sha256: $sha256, ')
          ..write('title: $title, ')
          ..write('pageCount: $pageCount, ')
          ..write('processingState: $processingState, ')
          ..write('processingError: $processingError, ')
          ..write('importedAt: $importedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DocumentChunksTableTable extends DocumentChunksTable
    with TableInfo<$DocumentChunksTableTable, DocumentChunksTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentChunksTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
    'document_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageStartMeta = const VerificationMeta(
    'pageStart',
  );
  @override
  late final GeneratedColumn<int> pageStart = GeneratedColumn<int>(
    'page_start',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageEndMeta = const VerificationMeta(
    'pageEnd',
  );
  @override
  late final GeneratedColumn<int> pageEnd = GeneratedColumn<int>(
    'page_end',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<String> chapter = GeneratedColumn<String>(
    'chapter',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _originalTextMeta = const VerificationMeta(
    'originalText',
  );
  @override
  late final GeneratedColumn<String> originalText = GeneratedColumn<String>(
    'original_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _englishRetrievalTextMeta =
      const VerificationMeta('englishRetrievalText');
  @override
  late final GeneratedColumn<String> englishRetrievalText =
      GeneratedColumn<String>(
        'english_retrieval_text',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _keywordsMeta = const VerificationMeta(
    'keywords',
  );
  @override
  late final GeneratedColumn<String> keywords = GeneratedColumn<String>(
    'keywords',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tokenEstimateMeta = const VerificationMeta(
    'tokenEstimate',
  );
  @override
  late final GeneratedColumn<int> tokenEstimate = GeneratedColumn<int>(
    'token_estimate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceOrderMeta = const VerificationMeta(
    'sourceOrder',
  );
  @override
  late final GeneratedColumn<int> sourceOrder = GeneratedColumn<int>(
    'source_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    documentId,
    pageStart,
    pageEnd,
    chapter,
    originalText,
    englishRetrievalText,
    keywords,
    tokenEstimate,
    sourceOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_chunks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentChunksTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('page_start')) {
      context.handle(
        _pageStartMeta,
        pageStart.isAcceptableOrUnknown(data['page_start']!, _pageStartMeta),
      );
    } else if (isInserting) {
      context.missing(_pageStartMeta);
    }
    if (data.containsKey('page_end')) {
      context.handle(
        _pageEndMeta,
        pageEnd.isAcceptableOrUnknown(data['page_end']!, _pageEndMeta),
      );
    } else if (isInserting) {
      context.missing(_pageEndMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    }
    if (data.containsKey('original_text')) {
      context.handle(
        _originalTextMeta,
        originalText.isAcceptableOrUnknown(
          data['original_text']!,
          _originalTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_originalTextMeta);
    }
    if (data.containsKey('english_retrieval_text')) {
      context.handle(
        _englishRetrievalTextMeta,
        englishRetrievalText.isAcceptableOrUnknown(
          data['english_retrieval_text']!,
          _englishRetrievalTextMeta,
        ),
      );
    }
    if (data.containsKey('keywords')) {
      context.handle(
        _keywordsMeta,
        keywords.isAcceptableOrUnknown(data['keywords']!, _keywordsMeta),
      );
    }
    if (data.containsKey('token_estimate')) {
      context.handle(
        _tokenEstimateMeta,
        tokenEstimate.isAcceptableOrUnknown(
          data['token_estimate']!,
          _tokenEstimateMeta,
        ),
      );
    }
    if (data.containsKey('source_order')) {
      context.handle(
        _sourceOrderMeta,
        sourceOrder.isAcceptableOrUnknown(
          data['source_order']!,
          _sourceOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentChunksTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentChunksTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_id'],
      )!,
      pageStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_start'],
      )!,
      pageEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_end'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter'],
      ),
      originalText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_text'],
      )!,
      englishRetrievalText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}english_retrieval_text'],
      ),
      keywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}keywords'],
      ),
      tokenEstimate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_estimate'],
      ),
      sourceOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_order'],
      )!,
    );
  }

  @override
  $DocumentChunksTableTable createAlias(String alias) {
    return $DocumentChunksTableTable(attachedDatabase, alias);
  }
}

class DocumentChunksTableData extends DataClass
    implements Insertable<DocumentChunksTableData> {
  final String id;
  final String documentId;
  final int pageStart;
  final int pageEnd;
  final String? chapter;
  final String originalText;
  final String? englishRetrievalText;
  final String? keywords;
  final int? tokenEstimate;
  final int sourceOrder;
  const DocumentChunksTableData({
    required this.id,
    required this.documentId,
    required this.pageStart,
    required this.pageEnd,
    this.chapter,
    required this.originalText,
    this.englishRetrievalText,
    this.keywords,
    this.tokenEstimate,
    required this.sourceOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['document_id'] = Variable<String>(documentId);
    map['page_start'] = Variable<int>(pageStart);
    map['page_end'] = Variable<int>(pageEnd);
    if (!nullToAbsent || chapter != null) {
      map['chapter'] = Variable<String>(chapter);
    }
    map['original_text'] = Variable<String>(originalText);
    if (!nullToAbsent || englishRetrievalText != null) {
      map['english_retrieval_text'] = Variable<String>(englishRetrievalText);
    }
    if (!nullToAbsent || keywords != null) {
      map['keywords'] = Variable<String>(keywords);
    }
    if (!nullToAbsent || tokenEstimate != null) {
      map['token_estimate'] = Variable<int>(tokenEstimate);
    }
    map['source_order'] = Variable<int>(sourceOrder);
    return map;
  }

  DocumentChunksTableCompanion toCompanion(bool nullToAbsent) {
    return DocumentChunksTableCompanion(
      id: Value(id),
      documentId: Value(documentId),
      pageStart: Value(pageStart),
      pageEnd: Value(pageEnd),
      chapter: chapter == null && nullToAbsent
          ? const Value.absent()
          : Value(chapter),
      originalText: Value(originalText),
      englishRetrievalText: englishRetrievalText == null && nullToAbsent
          ? const Value.absent()
          : Value(englishRetrievalText),
      keywords: keywords == null && nullToAbsent
          ? const Value.absent()
          : Value(keywords),
      tokenEstimate: tokenEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenEstimate),
      sourceOrder: Value(sourceOrder),
    );
  }

  factory DocumentChunksTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentChunksTableData(
      id: serializer.fromJson<String>(json['id']),
      documentId: serializer.fromJson<String>(json['documentId']),
      pageStart: serializer.fromJson<int>(json['pageStart']),
      pageEnd: serializer.fromJson<int>(json['pageEnd']),
      chapter: serializer.fromJson<String?>(json['chapter']),
      originalText: serializer.fromJson<String>(json['originalText']),
      englishRetrievalText: serializer.fromJson<String?>(
        json['englishRetrievalText'],
      ),
      keywords: serializer.fromJson<String?>(json['keywords']),
      tokenEstimate: serializer.fromJson<int?>(json['tokenEstimate']),
      sourceOrder: serializer.fromJson<int>(json['sourceOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'documentId': serializer.toJson<String>(documentId),
      'pageStart': serializer.toJson<int>(pageStart),
      'pageEnd': serializer.toJson<int>(pageEnd),
      'chapter': serializer.toJson<String?>(chapter),
      'originalText': serializer.toJson<String>(originalText),
      'englishRetrievalText': serializer.toJson<String?>(englishRetrievalText),
      'keywords': serializer.toJson<String?>(keywords),
      'tokenEstimate': serializer.toJson<int?>(tokenEstimate),
      'sourceOrder': serializer.toJson<int>(sourceOrder),
    };
  }

  DocumentChunksTableData copyWith({
    String? id,
    String? documentId,
    int? pageStart,
    int? pageEnd,
    Value<String?> chapter = const Value.absent(),
    String? originalText,
    Value<String?> englishRetrievalText = const Value.absent(),
    Value<String?> keywords = const Value.absent(),
    Value<int?> tokenEstimate = const Value.absent(),
    int? sourceOrder,
  }) => DocumentChunksTableData(
    id: id ?? this.id,
    documentId: documentId ?? this.documentId,
    pageStart: pageStart ?? this.pageStart,
    pageEnd: pageEnd ?? this.pageEnd,
    chapter: chapter.present ? chapter.value : this.chapter,
    originalText: originalText ?? this.originalText,
    englishRetrievalText: englishRetrievalText.present
        ? englishRetrievalText.value
        : this.englishRetrievalText,
    keywords: keywords.present ? keywords.value : this.keywords,
    tokenEstimate: tokenEstimate.present
        ? tokenEstimate.value
        : this.tokenEstimate,
    sourceOrder: sourceOrder ?? this.sourceOrder,
  );
  DocumentChunksTableData copyWithCompanion(DocumentChunksTableCompanion data) {
    return DocumentChunksTableData(
      id: data.id.present ? data.id.value : this.id,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      pageStart: data.pageStart.present ? data.pageStart.value : this.pageStart,
      pageEnd: data.pageEnd.present ? data.pageEnd.value : this.pageEnd,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      originalText: data.originalText.present
          ? data.originalText.value
          : this.originalText,
      englishRetrievalText: data.englishRetrievalText.present
          ? data.englishRetrievalText.value
          : this.englishRetrievalText,
      keywords: data.keywords.present ? data.keywords.value : this.keywords,
      tokenEstimate: data.tokenEstimate.present
          ? data.tokenEstimate.value
          : this.tokenEstimate,
      sourceOrder: data.sourceOrder.present
          ? data.sourceOrder.value
          : this.sourceOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentChunksTableData(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd, ')
          ..write('chapter: $chapter, ')
          ..write('originalText: $originalText, ')
          ..write('englishRetrievalText: $englishRetrievalText, ')
          ..write('keywords: $keywords, ')
          ..write('tokenEstimate: $tokenEstimate, ')
          ..write('sourceOrder: $sourceOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    documentId,
    pageStart,
    pageEnd,
    chapter,
    originalText,
    englishRetrievalText,
    keywords,
    tokenEstimate,
    sourceOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentChunksTableData &&
          other.id == this.id &&
          other.documentId == this.documentId &&
          other.pageStart == this.pageStart &&
          other.pageEnd == this.pageEnd &&
          other.chapter == this.chapter &&
          other.originalText == this.originalText &&
          other.englishRetrievalText == this.englishRetrievalText &&
          other.keywords == this.keywords &&
          other.tokenEstimate == this.tokenEstimate &&
          other.sourceOrder == this.sourceOrder);
}

class DocumentChunksTableCompanion
    extends UpdateCompanion<DocumentChunksTableData> {
  final Value<String> id;
  final Value<String> documentId;
  final Value<int> pageStart;
  final Value<int> pageEnd;
  final Value<String?> chapter;
  final Value<String> originalText;
  final Value<String?> englishRetrievalText;
  final Value<String?> keywords;
  final Value<int?> tokenEstimate;
  final Value<int> sourceOrder;
  final Value<int> rowid;
  const DocumentChunksTableCompanion({
    this.id = const Value.absent(),
    this.documentId = const Value.absent(),
    this.pageStart = const Value.absent(),
    this.pageEnd = const Value.absent(),
    this.chapter = const Value.absent(),
    this.originalText = const Value.absent(),
    this.englishRetrievalText = const Value.absent(),
    this.keywords = const Value.absent(),
    this.tokenEstimate = const Value.absent(),
    this.sourceOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentChunksTableCompanion.insert({
    required String id,
    required String documentId,
    required int pageStart,
    required int pageEnd,
    this.chapter = const Value.absent(),
    required String originalText,
    this.englishRetrievalText = const Value.absent(),
    this.keywords = const Value.absent(),
    this.tokenEstimate = const Value.absent(),
    required int sourceOrder,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       documentId = Value(documentId),
       pageStart = Value(pageStart),
       pageEnd = Value(pageEnd),
       originalText = Value(originalText),
       sourceOrder = Value(sourceOrder);
  static Insertable<DocumentChunksTableData> custom({
    Expression<String>? id,
    Expression<String>? documentId,
    Expression<int>? pageStart,
    Expression<int>? pageEnd,
    Expression<String>? chapter,
    Expression<String>? originalText,
    Expression<String>? englishRetrievalText,
    Expression<String>? keywords,
    Expression<int>? tokenEstimate,
    Expression<int>? sourceOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (documentId != null) 'document_id': documentId,
      if (pageStart != null) 'page_start': pageStart,
      if (pageEnd != null) 'page_end': pageEnd,
      if (chapter != null) 'chapter': chapter,
      if (originalText != null) 'original_text': originalText,
      if (englishRetrievalText != null)
        'english_retrieval_text': englishRetrievalText,
      if (keywords != null) 'keywords': keywords,
      if (tokenEstimate != null) 'token_estimate': tokenEstimate,
      if (sourceOrder != null) 'source_order': sourceOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentChunksTableCompanion copyWith({
    Value<String>? id,
    Value<String>? documentId,
    Value<int>? pageStart,
    Value<int>? pageEnd,
    Value<String?>? chapter,
    Value<String>? originalText,
    Value<String?>? englishRetrievalText,
    Value<String?>? keywords,
    Value<int?>? tokenEstimate,
    Value<int>? sourceOrder,
    Value<int>? rowid,
  }) {
    return DocumentChunksTableCompanion(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      pageStart: pageStart ?? this.pageStart,
      pageEnd: pageEnd ?? this.pageEnd,
      chapter: chapter ?? this.chapter,
      originalText: originalText ?? this.originalText,
      englishRetrievalText: englishRetrievalText ?? this.englishRetrievalText,
      keywords: keywords ?? this.keywords,
      tokenEstimate: tokenEstimate ?? this.tokenEstimate,
      sourceOrder: sourceOrder ?? this.sourceOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (pageStart.present) {
      map['page_start'] = Variable<int>(pageStart.value);
    }
    if (pageEnd.present) {
      map['page_end'] = Variable<int>(pageEnd.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<String>(chapter.value);
    }
    if (originalText.present) {
      map['original_text'] = Variable<String>(originalText.value);
    }
    if (englishRetrievalText.present) {
      map['english_retrieval_text'] = Variable<String>(
        englishRetrievalText.value,
      );
    }
    if (keywords.present) {
      map['keywords'] = Variable<String>(keywords.value);
    }
    if (tokenEstimate.present) {
      map['token_estimate'] = Variable<int>(tokenEstimate.value);
    }
    if (sourceOrder.present) {
      map['source_order'] = Variable<int>(sourceOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentChunksTableCompanion(')
          ..write('id: $id, ')
          ..write('documentId: $documentId, ')
          ..write('pageStart: $pageStart, ')
          ..write('pageEnd: $pageEnd, ')
          ..write('chapter: $chapter, ')
          ..write('originalText: $originalText, ')
          ..write('englishRetrievalText: $englishRetrievalText, ')
          ..write('keywords: $keywords, ')
          ..write('tokenEstimate: $tokenEstimate, ')
          ..write('sourceOrder: $sourceOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuggestedActionsTableTable extends SuggestedActionsTable
    with TableInfo<$SuggestedActionsTableTable, SuggestedActionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuggestedActionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detailsJsonMeta = const VerificationMeta(
    'detailsJson',
  );
  @override
  late final GeneratedColumn<String> detailsJson = GeneratedColumn<String>(
    'details_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _evidenceTextMeta = const VerificationMeta(
    'evidenceText',
  );
  @override
  late final GeneratedColumn<String> evidenceText = GeneratedColumn<String>(
    'evidence_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceStartMsMeta = const VerificationMeta(
    'sourceStartMs',
  );
  @override
  late final GeneratedColumn<int> sourceStartMs = GeneratedColumn<int>(
    'source_start_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceEndMsMeta = const VerificationMeta(
    'sourceEndMs',
  );
  @override
  late final GeneratedColumn<int> sourceEndMs = GeneratedColumn<int>(
    'source_end_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourcePageMeta = const VerificationMeta(
    'sourcePage',
  );
  @override
  late final GeneratedColumn<int> sourcePage = GeneratedColumn<int>(
    'source_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    actionType,
    title,
    detailsJson,
    evidenceText,
    sourceStartMs,
    sourceEndMs,
    sourcePage,
    confidence,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suggested_actions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuggestedActionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('details_json')) {
      context.handle(
        _detailsJsonMeta,
        detailsJson.isAcceptableOrUnknown(
          data['details_json']!,
          _detailsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detailsJsonMeta);
    }
    if (data.containsKey('evidence_text')) {
      context.handle(
        _evidenceTextMeta,
        evidenceText.isAcceptableOrUnknown(
          data['evidence_text']!,
          _evidenceTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_evidenceTextMeta);
    }
    if (data.containsKey('source_start_ms')) {
      context.handle(
        _sourceStartMsMeta,
        sourceStartMs.isAcceptableOrUnknown(
          data['source_start_ms']!,
          _sourceStartMsMeta,
        ),
      );
    }
    if (data.containsKey('source_end_ms')) {
      context.handle(
        _sourceEndMsMeta,
        sourceEndMs.isAcceptableOrUnknown(
          data['source_end_ms']!,
          _sourceEndMsMeta,
        ),
      );
    }
    if (data.containsKey('source_page')) {
      context.handle(
        _sourcePageMeta,
        sourcePage.isAcceptableOrUnknown(data['source_page']!, _sourcePageMeta),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SuggestedActionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuggestedActionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      detailsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}details_json'],
      )!,
      evidenceText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}evidence_text'],
      )!,
      sourceStartMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_start_ms'],
      ),
      sourceEndMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_end_ms'],
      ),
      sourcePage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_page'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SuggestedActionsTableTable createAlias(String alias) {
    return $SuggestedActionsTableTable(attachedDatabase, alias);
  }
}

class SuggestedActionsTableData extends DataClass
    implements Insertable<SuggestedActionsTableData> {
  final String id;
  final String noteId;
  final String actionType;
  final String title;
  final String detailsJson;
  final String evidenceText;
  final int? sourceStartMs;
  final int? sourceEndMs;
  final int? sourcePage;
  final double confidence;
  final String status;
  final int createdAt;
  const SuggestedActionsTableData({
    required this.id,
    required this.noteId,
    required this.actionType,
    required this.title,
    required this.detailsJson,
    required this.evidenceText,
    this.sourceStartMs,
    this.sourceEndMs,
    this.sourcePage,
    required this.confidence,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['action_type'] = Variable<String>(actionType);
    map['title'] = Variable<String>(title);
    map['details_json'] = Variable<String>(detailsJson);
    map['evidence_text'] = Variable<String>(evidenceText);
    if (!nullToAbsent || sourceStartMs != null) {
      map['source_start_ms'] = Variable<int>(sourceStartMs);
    }
    if (!nullToAbsent || sourceEndMs != null) {
      map['source_end_ms'] = Variable<int>(sourceEndMs);
    }
    if (!nullToAbsent || sourcePage != null) {
      map['source_page'] = Variable<int>(sourcePage);
    }
    map['confidence'] = Variable<double>(confidence);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SuggestedActionsTableCompanion toCompanion(bool nullToAbsent) {
    return SuggestedActionsTableCompanion(
      id: Value(id),
      noteId: Value(noteId),
      actionType: Value(actionType),
      title: Value(title),
      detailsJson: Value(detailsJson),
      evidenceText: Value(evidenceText),
      sourceStartMs: sourceStartMs == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceStartMs),
      sourceEndMs: sourceEndMs == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceEndMs),
      sourcePage: sourcePage == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePage),
      confidence: Value(confidence),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory SuggestedActionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuggestedActionsTableData(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      actionType: serializer.fromJson<String>(json['actionType']),
      title: serializer.fromJson<String>(json['title']),
      detailsJson: serializer.fromJson<String>(json['detailsJson']),
      evidenceText: serializer.fromJson<String>(json['evidenceText']),
      sourceStartMs: serializer.fromJson<int?>(json['sourceStartMs']),
      sourceEndMs: serializer.fromJson<int?>(json['sourceEndMs']),
      sourcePage: serializer.fromJson<int?>(json['sourcePage']),
      confidence: serializer.fromJson<double>(json['confidence']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'actionType': serializer.toJson<String>(actionType),
      'title': serializer.toJson<String>(title),
      'detailsJson': serializer.toJson<String>(detailsJson),
      'evidenceText': serializer.toJson<String>(evidenceText),
      'sourceStartMs': serializer.toJson<int?>(sourceStartMs),
      'sourceEndMs': serializer.toJson<int?>(sourceEndMs),
      'sourcePage': serializer.toJson<int?>(sourcePage),
      'confidence': serializer.toJson<double>(confidence),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  SuggestedActionsTableData copyWith({
    String? id,
    String? noteId,
    String? actionType,
    String? title,
    String? detailsJson,
    String? evidenceText,
    Value<int?> sourceStartMs = const Value.absent(),
    Value<int?> sourceEndMs = const Value.absent(),
    Value<int?> sourcePage = const Value.absent(),
    double? confidence,
    String? status,
    int? createdAt,
  }) => SuggestedActionsTableData(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    actionType: actionType ?? this.actionType,
    title: title ?? this.title,
    detailsJson: detailsJson ?? this.detailsJson,
    evidenceText: evidenceText ?? this.evidenceText,
    sourceStartMs: sourceStartMs.present
        ? sourceStartMs.value
        : this.sourceStartMs,
    sourceEndMs: sourceEndMs.present ? sourceEndMs.value : this.sourceEndMs,
    sourcePage: sourcePage.present ? sourcePage.value : this.sourcePage,
    confidence: confidence ?? this.confidence,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  SuggestedActionsTableData copyWithCompanion(
    SuggestedActionsTableCompanion data,
  ) {
    return SuggestedActionsTableData(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      title: data.title.present ? data.title.value : this.title,
      detailsJson: data.detailsJson.present
          ? data.detailsJson.value
          : this.detailsJson,
      evidenceText: data.evidenceText.present
          ? data.evidenceText.value
          : this.evidenceText,
      sourceStartMs: data.sourceStartMs.present
          ? data.sourceStartMs.value
          : this.sourceStartMs,
      sourceEndMs: data.sourceEndMs.present
          ? data.sourceEndMs.value
          : this.sourceEndMs,
      sourcePage: data.sourcePage.present
          ? data.sourcePage.value
          : this.sourcePage,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuggestedActionsTableData(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('actionType: $actionType, ')
          ..write('title: $title, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('evidenceText: $evidenceText, ')
          ..write('sourceStartMs: $sourceStartMs, ')
          ..write('sourceEndMs: $sourceEndMs, ')
          ..write('sourcePage: $sourcePage, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    noteId,
    actionType,
    title,
    detailsJson,
    evidenceText,
    sourceStartMs,
    sourceEndMs,
    sourcePage,
    confidence,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuggestedActionsTableData &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.actionType == this.actionType &&
          other.title == this.title &&
          other.detailsJson == this.detailsJson &&
          other.evidenceText == this.evidenceText &&
          other.sourceStartMs == this.sourceStartMs &&
          other.sourceEndMs == this.sourceEndMs &&
          other.sourcePage == this.sourcePage &&
          other.confidence == this.confidence &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class SuggestedActionsTableCompanion
    extends UpdateCompanion<SuggestedActionsTableData> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<String> actionType;
  final Value<String> title;
  final Value<String> detailsJson;
  final Value<String> evidenceText;
  final Value<int?> sourceStartMs;
  final Value<int?> sourceEndMs;
  final Value<int?> sourcePage;
  final Value<double> confidence;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> rowid;
  const SuggestedActionsTableCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.actionType = const Value.absent(),
    this.title = const Value.absent(),
    this.detailsJson = const Value.absent(),
    this.evidenceText = const Value.absent(),
    this.sourceStartMs = const Value.absent(),
    this.sourceEndMs = const Value.absent(),
    this.sourcePage = const Value.absent(),
    this.confidence = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuggestedActionsTableCompanion.insert({
    required String id,
    required String noteId,
    required String actionType,
    required String title,
    required String detailsJson,
    required String evidenceText,
    this.sourceStartMs = const Value.absent(),
    this.sourceEndMs = const Value.absent(),
    this.sourcePage = const Value.absent(),
    required double confidence,
    this.status = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       actionType = Value(actionType),
       title = Value(title),
       detailsJson = Value(detailsJson),
       evidenceText = Value(evidenceText),
       confidence = Value(confidence),
       createdAt = Value(createdAt);
  static Insertable<SuggestedActionsTableData> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<String>? actionType,
    Expression<String>? title,
    Expression<String>? detailsJson,
    Expression<String>? evidenceText,
    Expression<int>? sourceStartMs,
    Expression<int>? sourceEndMs,
    Expression<int>? sourcePage,
    Expression<double>? confidence,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (actionType != null) 'action_type': actionType,
      if (title != null) 'title': title,
      if (detailsJson != null) 'details_json': detailsJson,
      if (evidenceText != null) 'evidence_text': evidenceText,
      if (sourceStartMs != null) 'source_start_ms': sourceStartMs,
      if (sourceEndMs != null) 'source_end_ms': sourceEndMs,
      if (sourcePage != null) 'source_page': sourcePage,
      if (confidence != null) 'confidence': confidence,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuggestedActionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<String>? actionType,
    Value<String>? title,
    Value<String>? detailsJson,
    Value<String>? evidenceText,
    Value<int?>? sourceStartMs,
    Value<int?>? sourceEndMs,
    Value<int?>? sourcePage,
    Value<double>? confidence,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return SuggestedActionsTableCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      actionType: actionType ?? this.actionType,
      title: title ?? this.title,
      detailsJson: detailsJson ?? this.detailsJson,
      evidenceText: evidenceText ?? this.evidenceText,
      sourceStartMs: sourceStartMs ?? this.sourceStartMs,
      sourceEndMs: sourceEndMs ?? this.sourceEndMs,
      sourcePage: sourcePage ?? this.sourcePage,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (detailsJson.present) {
      map['details_json'] = Variable<String>(detailsJson.value);
    }
    if (evidenceText.present) {
      map['evidence_text'] = Variable<String>(evidenceText.value);
    }
    if (sourceStartMs.present) {
      map['source_start_ms'] = Variable<int>(sourceStartMs.value);
    }
    if (sourceEndMs.present) {
      map['source_end_ms'] = Variable<int>(sourceEndMs.value);
    }
    if (sourcePage.present) {
      map['source_page'] = Variable<int>(sourcePage.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuggestedActionsTableCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('actionType: $actionType, ')
          ..write('title: $title, ')
          ..write('detailsJson: $detailsJson, ')
          ..write('evidenceText: $evidenceText, ')
          ..write('sourceStartMs: $sourceStartMs, ')
          ..write('sourceEndMs: $sourceEndMs, ')
          ..write('sourcePage: $sourcePage, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalMemoriesTableTable extends PersonalMemoriesTable
    with TableInfo<$PersonalMemoriesTableTable, PersonalMemoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalMemoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceNoteIdMeta = const VerificationMeta(
    'sourceNoteId',
  );
  @override
  late final GeneratedColumn<String> sourceNoteId = GeneratedColumn<String>(
    'source_note_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userConfirmedMeta = const VerificationMeta(
    'userConfirmed',
  );
  @override
  late final GeneratedColumn<int> userConfirmed = GeneratedColumn<int>(
    'user_confirmed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    value,
    sourceNoteId,
    userConfirmed,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalMemoriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('source_note_id')) {
      context.handle(
        _sourceNoteIdMeta,
        sourceNoteId.isAcceptableOrUnknown(
          data['source_note_id']!,
          _sourceNoteIdMeta,
        ),
      );
    }
    if (data.containsKey('user_confirmed')) {
      context.handle(
        _userConfirmedMeta,
        userConfirmed.isAcceptableOrUnknown(
          data['user_confirmed']!,
          _userConfirmedMeta,
        ),
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
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalMemoriesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalMemoriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      sourceNoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_note_id'],
      ),
      userConfirmed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_confirmed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $PersonalMemoriesTableTable createAlias(String alias) {
    return $PersonalMemoriesTableTable(attachedDatabase, alias);
  }
}

class PersonalMemoriesTableData extends DataClass
    implements Insertable<PersonalMemoriesTableData> {
  final String id;
  final String type;
  final String value;
  final String? sourceNoteId;
  final int userConfirmed;
  final int createdAt;
  final int? deletedAt;
  const PersonalMemoriesTableData({
    required this.id,
    required this.type,
    required this.value,
    this.sourceNoteId,
    required this.userConfirmed,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || sourceNoteId != null) {
      map['source_note_id'] = Variable<String>(sourceNoteId);
    }
    map['user_confirmed'] = Variable<int>(userConfirmed);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    return map;
  }

  PersonalMemoriesTableCompanion toCompanion(bool nullToAbsent) {
    return PersonalMemoriesTableCompanion(
      id: Value(id),
      type: Value(type),
      value: Value(value),
      sourceNoteId: sourceNoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceNoteId),
      userConfirmed: Value(userConfirmed),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory PersonalMemoriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalMemoriesTableData(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<String>(json['value']),
      sourceNoteId: serializer.fromJson<String?>(json['sourceNoteId']),
      userConfirmed: serializer.fromJson<int>(json['userConfirmed']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      deletedAt: serializer.fromJson<int?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<String>(value),
      'sourceNoteId': serializer.toJson<String?>(sourceNoteId),
      'userConfirmed': serializer.toJson<int>(userConfirmed),
      'createdAt': serializer.toJson<int>(createdAt),
      'deletedAt': serializer.toJson<int?>(deletedAt),
    };
  }

  PersonalMemoriesTableData copyWith({
    String? id,
    String? type,
    String? value,
    Value<String?> sourceNoteId = const Value.absent(),
    int? userConfirmed,
    int? createdAt,
    Value<int?> deletedAt = const Value.absent(),
  }) => PersonalMemoriesTableData(
    id: id ?? this.id,
    type: type ?? this.type,
    value: value ?? this.value,
    sourceNoteId: sourceNoteId.present ? sourceNoteId.value : this.sourceNoteId,
    userConfirmed: userConfirmed ?? this.userConfirmed,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  PersonalMemoriesTableData copyWithCompanion(
    PersonalMemoriesTableCompanion data,
  ) {
    return PersonalMemoriesTableData(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      sourceNoteId: data.sourceNoteId.present
          ? data.sourceNoteId.value
          : this.sourceNoteId,
      userConfirmed: data.userConfirmed.present
          ? data.userConfirmed.value
          : this.userConfirmed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalMemoriesTableData(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('sourceNoteId: $sourceNoteId, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    value,
    sourceNoteId,
    userConfirmed,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalMemoriesTableData &&
          other.id == this.id &&
          other.type == this.type &&
          other.value == this.value &&
          other.sourceNoteId == this.sourceNoteId &&
          other.userConfirmed == this.userConfirmed &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class PersonalMemoriesTableCompanion
    extends UpdateCompanion<PersonalMemoriesTableData> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> value;
  final Value<String?> sourceNoteId;
  final Value<int> userConfirmed;
  final Value<int> createdAt;
  final Value<int?> deletedAt;
  final Value<int> rowid;
  const PersonalMemoriesTableCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.sourceNoteId = const Value.absent(),
    this.userConfirmed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalMemoriesTableCompanion.insert({
    required String id,
    required String type,
    required String value,
    this.sourceNoteId = const Value.absent(),
    this.userConfirmed = const Value.absent(),
    required int createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       value = Value(value),
       createdAt = Value(createdAt);
  static Insertable<PersonalMemoriesTableData> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? value,
    Expression<String>? sourceNoteId,
    Expression<int>? userConfirmed,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (sourceNoteId != null) 'source_note_id': sourceNoteId,
      if (userConfirmed != null) 'user_confirmed': userConfirmed,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalMemoriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? value,
    Value<String?>? sourceNoteId,
    Value<int>? userConfirmed,
    Value<int>? createdAt,
    Value<int?>? deletedAt,
    Value<int>? rowid,
  }) {
    return PersonalMemoriesTableCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      sourceNoteId: sourceNoteId ?? this.sourceNoteId,
      userConfirmed: userConfirmed ?? this.userConfirmed,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (sourceNoteId.present) {
      map['source_note_id'] = Variable<String>(sourceNoteId.value);
    }
    if (userConfirmed.present) {
      map['user_confirmed'] = Variable<int>(userConfirmed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalMemoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('sourceNoteId: $sourceNoteId, ')
          ..write('userConfirmed: $userConfirmed, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiJobsTableTable extends AiJobsTable
    with TableInfo<$AiJobsTableTable, AiJobsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiJobsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobTypeMeta = const VerificationMeta(
    'jobType',
  );
  @override
  late final GeneratedColumn<String> jobType = GeneratedColumn<String>(
    'job_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdMeta = const VerificationMeta(
    'sourceId',
  );
  @override
  late final GeneratedColumn<String> sourceId = GeneratedColumn<String>(
    'source_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceHashMeta = const VerificationMeta(
    'sourceHash',
  );
  @override
  late final GeneratedColumn<String> sourceHash = GeneratedColumn<String>(
    'source_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    jobType,
    sourceId,
    sourceHash,
    modelVersion,
    status,
    progress,
    attemptCount,
    errorCode,
    createdAt,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiJobsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('job_type')) {
      context.handle(
        _jobTypeMeta,
        jobType.isAcceptableOrUnknown(data['job_type']!, _jobTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_jobTypeMeta);
    }
    if (data.containsKey('source_id')) {
      context.handle(
        _sourceIdMeta,
        sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdMeta);
    }
    if (data.containsKey('source_hash')) {
      context.handle(
        _sourceHashMeta,
        sourceHash.isAcceptableOrUnknown(data['source_hash']!, _sourceHashMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceHashMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
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
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiJobsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiJobsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      jobType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_type'],
      )!,
      sourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_id'],
      )!,
      sourceHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_hash'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $AiJobsTableTable createAlias(String alias) {
    return $AiJobsTableTable(attachedDatabase, alias);
  }
}

class AiJobsTableData extends DataClass implements Insertable<AiJobsTableData> {
  final String id;
  final String jobType;
  final String sourceId;
  final String sourceHash;
  final String modelVersion;
  final String status;
  final double progress;
  final int attemptCount;
  final String? errorCode;
  final int createdAt;
  final int? startedAt;
  final int? completedAt;
  const AiJobsTableData({
    required this.id,
    required this.jobType,
    required this.sourceId,
    required this.sourceHash,
    required this.modelVersion,
    required this.status,
    required this.progress,
    required this.attemptCount,
    this.errorCode,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['job_type'] = Variable<String>(jobType);
    map['source_id'] = Variable<String>(sourceId);
    map['source_hash'] = Variable<String>(sourceHash);
    map['model_version'] = Variable<String>(modelVersion);
    map['status'] = Variable<String>(status);
    map['progress'] = Variable<double>(progress);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }

  AiJobsTableCompanion toCompanion(bool nullToAbsent) {
    return AiJobsTableCompanion(
      id: Value(id),
      jobType: Value(jobType),
      sourceId: Value(sourceId),
      sourceHash: Value(sourceHash),
      modelVersion: Value(modelVersion),
      status: Value(status),
      progress: Value(progress),
      attemptCount: Value(attemptCount),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      createdAt: Value(createdAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory AiJobsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiJobsTableData(
      id: serializer.fromJson<String>(json['id']),
      jobType: serializer.fromJson<String>(json['jobType']),
      sourceId: serializer.fromJson<String>(json['sourceId']),
      sourceHash: serializer.fromJson<String>(json['sourceHash']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      status: serializer.fromJson<String>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      startedAt: serializer.fromJson<int?>(json['startedAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jobType': serializer.toJson<String>(jobType),
      'sourceId': serializer.toJson<String>(sourceId),
      'sourceHash': serializer.toJson<String>(sourceHash),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'status': serializer.toJson<String>(status),
      'progress': serializer.toJson<double>(progress),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'errorCode': serializer.toJson<String?>(errorCode),
      'createdAt': serializer.toJson<int>(createdAt),
      'startedAt': serializer.toJson<int?>(startedAt),
      'completedAt': serializer.toJson<int?>(completedAt),
    };
  }

  AiJobsTableData copyWith({
    String? id,
    String? jobType,
    String? sourceId,
    String? sourceHash,
    String? modelVersion,
    String? status,
    double? progress,
    int? attemptCount,
    Value<String?> errorCode = const Value.absent(),
    int? createdAt,
    Value<int?> startedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
  }) => AiJobsTableData(
    id: id ?? this.id,
    jobType: jobType ?? this.jobType,
    sourceId: sourceId ?? this.sourceId,
    sourceHash: sourceHash ?? this.sourceHash,
    modelVersion: modelVersion ?? this.modelVersion,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    attemptCount: attemptCount ?? this.attemptCount,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    createdAt: createdAt ?? this.createdAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  AiJobsTableData copyWithCompanion(AiJobsTableCompanion data) {
    return AiJobsTableData(
      id: data.id.present ? data.id.value : this.id,
      jobType: data.jobType.present ? data.jobType.value : this.jobType,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourceHash: data.sourceHash.present
          ? data.sourceHash.value
          : this.sourceHash,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiJobsTableData(')
          ..write('id: $id, ')
          ..write('jobType: $jobType, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    jobType,
    sourceId,
    sourceHash,
    modelVersion,
    status,
    progress,
    attemptCount,
    errorCode,
    createdAt,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiJobsTableData &&
          other.id == this.id &&
          other.jobType == this.jobType &&
          other.sourceId == this.sourceId &&
          other.sourceHash == this.sourceHash &&
          other.modelVersion == this.modelVersion &&
          other.status == this.status &&
          other.progress == this.progress &&
          other.attemptCount == this.attemptCount &&
          other.errorCode == this.errorCode &&
          other.createdAt == this.createdAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class AiJobsTableCompanion extends UpdateCompanion<AiJobsTableData> {
  final Value<String> id;
  final Value<String> jobType;
  final Value<String> sourceId;
  final Value<String> sourceHash;
  final Value<String> modelVersion;
  final Value<String> status;
  final Value<double> progress;
  final Value<int> attemptCount;
  final Value<String?> errorCode;
  final Value<int> createdAt;
  final Value<int?> startedAt;
  final Value<int?> completedAt;
  final Value<int> rowid;
  const AiJobsTableCompanion({
    this.id = const Value.absent(),
    this.jobType = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourceHash = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiJobsTableCompanion.insert({
    required String id,
    required String jobType,
    required String sourceId,
    required String sourceHash,
    required String modelVersion,
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.errorCode = const Value.absent(),
    required int createdAt,
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       jobType = Value(jobType),
       sourceId = Value(sourceId),
       sourceHash = Value(sourceHash),
       modelVersion = Value(modelVersion),
       createdAt = Value(createdAt);
  static Insertable<AiJobsTableData> custom({
    Expression<String>? id,
    Expression<String>? jobType,
    Expression<String>? sourceId,
    Expression<String>? sourceHash,
    Expression<String>? modelVersion,
    Expression<String>? status,
    Expression<double>? progress,
    Expression<int>? attemptCount,
    Expression<String>? errorCode,
    Expression<int>? createdAt,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jobType != null) 'job_type': jobType,
      if (sourceId != null) 'source_id': sourceId,
      if (sourceHash != null) 'source_hash': sourceHash,
      if (modelVersion != null) 'model_version': modelVersion,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (errorCode != null) 'error_code': errorCode,
      if (createdAt != null) 'created_at': createdAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiJobsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? jobType,
    Value<String>? sourceId,
    Value<String>? sourceHash,
    Value<String>? modelVersion,
    Value<String>? status,
    Value<double>? progress,
    Value<int>? attemptCount,
    Value<String?>? errorCode,
    Value<int>? createdAt,
    Value<int?>? startedAt,
    Value<int?>? completedAt,
    Value<int>? rowid,
  }) {
    return AiJobsTableCompanion(
      id: id ?? this.id,
      jobType: jobType ?? this.jobType,
      sourceId: sourceId ?? this.sourceId,
      sourceHash: sourceHash ?? this.sourceHash,
      modelVersion: modelVersion ?? this.modelVersion,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      attemptCount: attemptCount ?? this.attemptCount,
      errorCode: errorCode ?? this.errorCode,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jobType.present) {
      map['job_type'] = Variable<String>(jobType.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<String>(sourceId.value);
    }
    if (sourceHash.present) {
      map['source_hash'] = Variable<String>(sourceHash.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiJobsTableCompanion(')
          ..write('id: $id, ')
          ..write('jobType: $jobType, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ModelInstallationsTableTable extends ModelInstallationsTable
    with TableInfo<$ModelInstallationsTableTable, ModelInstallationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ModelInstallationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedSha256Meta = const VerificationMeta(
    'expectedSha256',
  );
  @override
  late final GeneratedColumn<String> expectedSha256 = GeneratedColumn<String>(
    'expected_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualSha256Meta = const VerificationMeta(
    'actualSha256',
  );
  @override
  late final GeneratedColumn<String> actualSha256 = GeneratedColumn<String>(
    'actual_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _installationStateMeta = const VerificationMeta(
    'installationState',
  );
  @override
  late final GeneratedColumn<String> installationState =
      GeneratedColumn<String>(
        'installation_state',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('not_installed'),
      );
  static const VerificationMeta _installedAtMeta = const VerificationMeta(
    'installedAt',
  );
  @override
  late final GeneratedColumn<int> installedAt = GeneratedColumn<int>(
    'installed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    modelId,
    version,
    localPath,
    expectedSha256,
    actualSha256,
    sizeBytes,
    installationState,
    installedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'model_installations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ModelInstallationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('expected_sha256')) {
      context.handle(
        _expectedSha256Meta,
        expectedSha256.isAcceptableOrUnknown(
          data['expected_sha256']!,
          _expectedSha256Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedSha256Meta);
    }
    if (data.containsKey('actual_sha256')) {
      context.handle(
        _actualSha256Meta,
        actualSha256.isAcceptableOrUnknown(
          data['actual_sha256']!,
          _actualSha256Meta,
        ),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('installation_state')) {
      context.handle(
        _installationStateMeta,
        installationState.isAcceptableOrUnknown(
          data['installation_state']!,
          _installationStateMeta,
        ),
      );
    }
    if (data.containsKey('installed_at')) {
      context.handle(
        _installedAtMeta,
        installedAt.isAcceptableOrUnknown(
          data['installed_at']!,
          _installedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {modelId};
  @override
  ModelInstallationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ModelInstallationsTableData(
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      expectedSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expected_sha256'],
      )!,
      actualSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actual_sha256'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      installationState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}installation_state'],
      )!,
      installedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installed_at'],
      ),
    );
  }

  @override
  $ModelInstallationsTableTable createAlias(String alias) {
    return $ModelInstallationsTableTable(attachedDatabase, alias);
  }
}

class ModelInstallationsTableData extends DataClass
    implements Insertable<ModelInstallationsTableData> {
  final String modelId;
  final String version;
  final String localPath;
  final String expectedSha256;
  final String? actualSha256;
  final int sizeBytes;
  final String installationState;
  final int? installedAt;
  const ModelInstallationsTableData({
    required this.modelId,
    required this.version,
    required this.localPath,
    required this.expectedSha256,
    this.actualSha256,
    required this.sizeBytes,
    required this.installationState,
    this.installedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['model_id'] = Variable<String>(modelId);
    map['version'] = Variable<String>(version);
    map['local_path'] = Variable<String>(localPath);
    map['expected_sha256'] = Variable<String>(expectedSha256);
    if (!nullToAbsent || actualSha256 != null) {
      map['actual_sha256'] = Variable<String>(actualSha256);
    }
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['installation_state'] = Variable<String>(installationState);
    if (!nullToAbsent || installedAt != null) {
      map['installed_at'] = Variable<int>(installedAt);
    }
    return map;
  }

  ModelInstallationsTableCompanion toCompanion(bool nullToAbsent) {
    return ModelInstallationsTableCompanion(
      modelId: Value(modelId),
      version: Value(version),
      localPath: Value(localPath),
      expectedSha256: Value(expectedSha256),
      actualSha256: actualSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(actualSha256),
      sizeBytes: Value(sizeBytes),
      installationState: Value(installationState),
      installedAt: installedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(installedAt),
    );
  }

  factory ModelInstallationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ModelInstallationsTableData(
      modelId: serializer.fromJson<String>(json['modelId']),
      version: serializer.fromJson<String>(json['version']),
      localPath: serializer.fromJson<String>(json['localPath']),
      expectedSha256: serializer.fromJson<String>(json['expectedSha256']),
      actualSha256: serializer.fromJson<String?>(json['actualSha256']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      installationState: serializer.fromJson<String>(json['installationState']),
      installedAt: serializer.fromJson<int?>(json['installedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'modelId': serializer.toJson<String>(modelId),
      'version': serializer.toJson<String>(version),
      'localPath': serializer.toJson<String>(localPath),
      'expectedSha256': serializer.toJson<String>(expectedSha256),
      'actualSha256': serializer.toJson<String?>(actualSha256),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'installationState': serializer.toJson<String>(installationState),
      'installedAt': serializer.toJson<int?>(installedAt),
    };
  }

  ModelInstallationsTableData copyWith({
    String? modelId,
    String? version,
    String? localPath,
    String? expectedSha256,
    Value<String?> actualSha256 = const Value.absent(),
    int? sizeBytes,
    String? installationState,
    Value<int?> installedAt = const Value.absent(),
  }) => ModelInstallationsTableData(
    modelId: modelId ?? this.modelId,
    version: version ?? this.version,
    localPath: localPath ?? this.localPath,
    expectedSha256: expectedSha256 ?? this.expectedSha256,
    actualSha256: actualSha256.present ? actualSha256.value : this.actualSha256,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    installationState: installationState ?? this.installationState,
    installedAt: installedAt.present ? installedAt.value : this.installedAt,
  );
  ModelInstallationsTableData copyWithCompanion(
    ModelInstallationsTableCompanion data,
  ) {
    return ModelInstallationsTableData(
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      version: data.version.present ? data.version.value : this.version,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      expectedSha256: data.expectedSha256.present
          ? data.expectedSha256.value
          : this.expectedSha256,
      actualSha256: data.actualSha256.present
          ? data.actualSha256.value
          : this.actualSha256,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      installationState: data.installationState.present
          ? data.installationState.value
          : this.installationState,
      installedAt: data.installedAt.present
          ? data.installedAt.value
          : this.installedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ModelInstallationsTableData(')
          ..write('modelId: $modelId, ')
          ..write('version: $version, ')
          ..write('localPath: $localPath, ')
          ..write('expectedSha256: $expectedSha256, ')
          ..write('actualSha256: $actualSha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('installationState: $installationState, ')
          ..write('installedAt: $installedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    modelId,
    version,
    localPath,
    expectedSha256,
    actualSha256,
    sizeBytes,
    installationState,
    installedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ModelInstallationsTableData &&
          other.modelId == this.modelId &&
          other.version == this.version &&
          other.localPath == this.localPath &&
          other.expectedSha256 == this.expectedSha256 &&
          other.actualSha256 == this.actualSha256 &&
          other.sizeBytes == this.sizeBytes &&
          other.installationState == this.installationState &&
          other.installedAt == this.installedAt);
}

class ModelInstallationsTableCompanion
    extends UpdateCompanion<ModelInstallationsTableData> {
  final Value<String> modelId;
  final Value<String> version;
  final Value<String> localPath;
  final Value<String> expectedSha256;
  final Value<String?> actualSha256;
  final Value<int> sizeBytes;
  final Value<String> installationState;
  final Value<int?> installedAt;
  final Value<int> rowid;
  const ModelInstallationsTableCompanion({
    this.modelId = const Value.absent(),
    this.version = const Value.absent(),
    this.localPath = const Value.absent(),
    this.expectedSha256 = const Value.absent(),
    this.actualSha256 = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.installationState = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ModelInstallationsTableCompanion.insert({
    required String modelId,
    required String version,
    required String localPath,
    required String expectedSha256,
    this.actualSha256 = const Value.absent(),
    required int sizeBytes,
    this.installationState = const Value.absent(),
    this.installedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : modelId = Value(modelId),
       version = Value(version),
       localPath = Value(localPath),
       expectedSha256 = Value(expectedSha256),
       sizeBytes = Value(sizeBytes);
  static Insertable<ModelInstallationsTableData> custom({
    Expression<String>? modelId,
    Expression<String>? version,
    Expression<String>? localPath,
    Expression<String>? expectedSha256,
    Expression<String>? actualSha256,
    Expression<int>? sizeBytes,
    Expression<String>? installationState,
    Expression<int>? installedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (modelId != null) 'model_id': modelId,
      if (version != null) 'version': version,
      if (localPath != null) 'local_path': localPath,
      if (expectedSha256 != null) 'expected_sha256': expectedSha256,
      if (actualSha256 != null) 'actual_sha256': actualSha256,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (installationState != null) 'installation_state': installationState,
      if (installedAt != null) 'installed_at': installedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ModelInstallationsTableCompanion copyWith({
    Value<String>? modelId,
    Value<String>? version,
    Value<String>? localPath,
    Value<String>? expectedSha256,
    Value<String?>? actualSha256,
    Value<int>? sizeBytes,
    Value<String>? installationState,
    Value<int?>? installedAt,
    Value<int>? rowid,
  }) {
    return ModelInstallationsTableCompanion(
      modelId: modelId ?? this.modelId,
      version: version ?? this.version,
      localPath: localPath ?? this.localPath,
      expectedSha256: expectedSha256 ?? this.expectedSha256,
      actualSha256: actualSha256 ?? this.actualSha256,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      installationState: installationState ?? this.installationState,
      installedAt: installedAt ?? this.installedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (expectedSha256.present) {
      map['expected_sha256'] = Variable<String>(expectedSha256.value);
    }
    if (actualSha256.present) {
      map['actual_sha256'] = Variable<String>(actualSha256.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (installationState.present) {
      map['installation_state'] = Variable<String>(installationState.value);
    }
    if (installedAt.present) {
      map['installed_at'] = Variable<int>(installedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ModelInstallationsTableCompanion(')
          ..write('modelId: $modelId, ')
          ..write('version: $version, ')
          ..write('localPath: $localPath, ')
          ..write('expectedSha256: $expectedSha256, ')
          ..write('actualSha256: $actualSha256, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('installationState: $installationState, ')
          ..write('installedAt: $installedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteEmbeddingsTableTable extends NoteEmbeddingsTable
    with TableInfo<$NoteEmbeddingsTableTable, NoteEmbeddingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteEmbeddingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelVersionMeta = const VerificationMeta(
    'modelVersion',
  );
  @override
  late final GeneratedColumn<String> modelVersion = GeneratedColumn<String>(
    'model_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceHashMeta = const VerificationMeta(
    'sourceHash',
  );
  @override
  late final GeneratedColumn<String> sourceHash = GeneratedColumn<String>(
    'source_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vectorMeta = const VerificationMeta('vector');
  @override
  late final GeneratedColumn<Uint8List> vector = GeneratedColumn<Uint8List>(
    'vector',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dimensionsMeta = const VerificationMeta(
    'dimensions',
  );
  @override
  late final GeneratedColumn<int> dimensions = GeneratedColumn<int>(
    'dimensions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    noteId,
    modelVersion,
    sourceHash,
    vector,
    dimensions,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_embeddings';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteEmbeddingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('model_version')) {
      context.handle(
        _modelVersionMeta,
        modelVersion.isAcceptableOrUnknown(
          data['model_version']!,
          _modelVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_modelVersionMeta);
    }
    if (data.containsKey('source_hash')) {
      context.handle(
        _sourceHashMeta,
        sourceHash.isAcceptableOrUnknown(data['source_hash']!, _sourceHashMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceHashMeta);
    }
    if (data.containsKey('vector')) {
      context.handle(
        _vectorMeta,
        vector.isAcceptableOrUnknown(data['vector']!, _vectorMeta),
      );
    } else if (isInserting) {
      context.missing(_vectorMeta);
    }
    if (data.containsKey('dimensions')) {
      context.handle(
        _dimensionsMeta,
        dimensions.isAcceptableOrUnknown(data['dimensions']!, _dimensionsMeta),
      );
    } else if (isInserting) {
      context.missing(_dimensionsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId};
  @override
  NoteEmbeddingsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteEmbeddingsTableData(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      modelVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_version'],
      )!,
      sourceHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_hash'],
      )!,
      vector: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}vector'],
      )!,
      dimensions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dimensions'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NoteEmbeddingsTableTable createAlias(String alias) {
    return $NoteEmbeddingsTableTable(attachedDatabase, alias);
  }
}

class NoteEmbeddingsTableData extends DataClass
    implements Insertable<NoteEmbeddingsTableData> {
  final String noteId;
  final String modelVersion;
  final String sourceHash;
  final Uint8List vector;
  final int dimensions;
  final int updatedAt;
  const NoteEmbeddingsTableData({
    required this.noteId,
    required this.modelVersion,
    required this.sourceHash,
    required this.vector,
    required this.dimensions,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<String>(noteId);
    map['model_version'] = Variable<String>(modelVersion);
    map['source_hash'] = Variable<String>(sourceHash);
    map['vector'] = Variable<Uint8List>(vector);
    map['dimensions'] = Variable<int>(dimensions);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  NoteEmbeddingsTableCompanion toCompanion(bool nullToAbsent) {
    return NoteEmbeddingsTableCompanion(
      noteId: Value(noteId),
      modelVersion: Value(modelVersion),
      sourceHash: Value(sourceHash),
      vector: Value(vector),
      dimensions: Value(dimensions),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteEmbeddingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteEmbeddingsTableData(
      noteId: serializer.fromJson<String>(json['noteId']),
      modelVersion: serializer.fromJson<String>(json['modelVersion']),
      sourceHash: serializer.fromJson<String>(json['sourceHash']),
      vector: serializer.fromJson<Uint8List>(json['vector']),
      dimensions: serializer.fromJson<int>(json['dimensions']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<String>(noteId),
      'modelVersion': serializer.toJson<String>(modelVersion),
      'sourceHash': serializer.toJson<String>(sourceHash),
      'vector': serializer.toJson<Uint8List>(vector),
      'dimensions': serializer.toJson<int>(dimensions),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  NoteEmbeddingsTableData copyWith({
    String? noteId,
    String? modelVersion,
    String? sourceHash,
    Uint8List? vector,
    int? dimensions,
    int? updatedAt,
  }) => NoteEmbeddingsTableData(
    noteId: noteId ?? this.noteId,
    modelVersion: modelVersion ?? this.modelVersion,
    sourceHash: sourceHash ?? this.sourceHash,
    vector: vector ?? this.vector,
    dimensions: dimensions ?? this.dimensions,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteEmbeddingsTableData copyWithCompanion(NoteEmbeddingsTableCompanion data) {
    return NoteEmbeddingsTableData(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      modelVersion: data.modelVersion.present
          ? data.modelVersion.value
          : this.modelVersion,
      sourceHash: data.sourceHash.present
          ? data.sourceHash.value
          : this.sourceHash,
      vector: data.vector.present ? data.vector.value : this.vector,
      dimensions: data.dimensions.present
          ? data.dimensions.value
          : this.dimensions,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteEmbeddingsTableData(')
          ..write('noteId: $noteId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('vector: $vector, ')
          ..write('dimensions: $dimensions, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    noteId,
    modelVersion,
    sourceHash,
    $driftBlobEquality.hash(vector),
    dimensions,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteEmbeddingsTableData &&
          other.noteId == this.noteId &&
          other.modelVersion == this.modelVersion &&
          other.sourceHash == this.sourceHash &&
          $driftBlobEquality.equals(other.vector, this.vector) &&
          other.dimensions == this.dimensions &&
          other.updatedAt == this.updatedAt);
}

class NoteEmbeddingsTableCompanion
    extends UpdateCompanion<NoteEmbeddingsTableData> {
  final Value<String> noteId;
  final Value<String> modelVersion;
  final Value<String> sourceHash;
  final Value<Uint8List> vector;
  final Value<int> dimensions;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const NoteEmbeddingsTableCompanion({
    this.noteId = const Value.absent(),
    this.modelVersion = const Value.absent(),
    this.sourceHash = const Value.absent(),
    this.vector = const Value.absent(),
    this.dimensions = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteEmbeddingsTableCompanion.insert({
    required String noteId,
    required String modelVersion,
    required String sourceHash,
    required Uint8List vector,
    required int dimensions,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       modelVersion = Value(modelVersion),
       sourceHash = Value(sourceHash),
       vector = Value(vector),
       dimensions = Value(dimensions),
       updatedAt = Value(updatedAt);
  static Insertable<NoteEmbeddingsTableData> custom({
    Expression<String>? noteId,
    Expression<String>? modelVersion,
    Expression<String>? sourceHash,
    Expression<Uint8List>? vector,
    Expression<int>? dimensions,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (modelVersion != null) 'model_version': modelVersion,
      if (sourceHash != null) 'source_hash': sourceHash,
      if (vector != null) 'vector': vector,
      if (dimensions != null) 'dimensions': dimensions,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteEmbeddingsTableCompanion copyWith({
    Value<String>? noteId,
    Value<String>? modelVersion,
    Value<String>? sourceHash,
    Value<Uint8List>? vector,
    Value<int>? dimensions,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return NoteEmbeddingsTableCompanion(
      noteId: noteId ?? this.noteId,
      modelVersion: modelVersion ?? this.modelVersion,
      sourceHash: sourceHash ?? this.sourceHash,
      vector: vector ?? this.vector,
      dimensions: dimensions ?? this.dimensions,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (modelVersion.present) {
      map['model_version'] = Variable<String>(modelVersion.value);
    }
    if (sourceHash.present) {
      map['source_hash'] = Variable<String>(sourceHash.value);
    }
    if (vector.present) {
      map['vector'] = Variable<Uint8List>(vector.value);
    }
    if (dimensions.present) {
      map['dimensions'] = Variable<int>(dimensions.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteEmbeddingsTableCompanion(')
          ..write('noteId: $noteId, ')
          ..write('modelVersion: $modelVersion, ')
          ..write('sourceHash: $sourceHash, ')
          ..write('vector: $vector, ')
          ..write('dimensions: $dimensions, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteRelationshipsTableTable extends NoteRelationshipsTable
    with TableInfo<$NoteRelationshipsTableTable, NoteRelationshipsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteRelationshipsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sourceNoteIdMeta = const VerificationMeta(
    'sourceNoteId',
  );
  @override
  late final GeneratedColumn<String> sourceNoteId = GeneratedColumn<String>(
    'source_note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetNoteIdMeta = const VerificationMeta(
    'targetNoteId',
  );
  @override
  late final GeneratedColumn<String> targetNoteId = GeneratedColumn<String>(
    'target_note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _similarityMeta = const VerificationMeta(
    'similarity',
  );
  @override
  late final GeneratedColumn<double> similarity = GeneratedColumn<double>(
    'similarity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('suggested'),
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sourceNoteId,
    targetNoteId,
    similarity,
    status,
    explanation,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_relationships';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRelationshipsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('source_note_id')) {
      context.handle(
        _sourceNoteIdMeta,
        sourceNoteId.isAcceptableOrUnknown(
          data['source_note_id']!,
          _sourceNoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceNoteIdMeta);
    }
    if (data.containsKey('target_note_id')) {
      context.handle(
        _targetNoteIdMeta,
        targetNoteId.isAcceptableOrUnknown(
          data['target_note_id']!,
          _targetNoteIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetNoteIdMeta);
    }
    if (data.containsKey('similarity')) {
      context.handle(
        _similarityMeta,
        similarity.isAcceptableOrUnknown(data['similarity']!, _similarityMeta),
      );
    } else if (isInserting) {
      context.missing(_similarityMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sourceNoteId, targetNoteId};
  @override
  NoteRelationshipsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRelationshipsTableData(
      sourceNoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_note_id'],
      )!,
      targetNoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_note_id'],
      )!,
      similarity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}similarity'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NoteRelationshipsTableTable createAlias(String alias) {
    return $NoteRelationshipsTableTable(attachedDatabase, alias);
  }
}

class NoteRelationshipsTableData extends DataClass
    implements Insertable<NoteRelationshipsTableData> {
  final String sourceNoteId;
  final String targetNoteId;
  final double similarity;
  final String status;
  final String? explanation;
  final int updatedAt;
  const NoteRelationshipsTableData({
    required this.sourceNoteId,
    required this.targetNoteId,
    required this.similarity,
    required this.status,
    this.explanation,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['source_note_id'] = Variable<String>(sourceNoteId);
    map['target_note_id'] = Variable<String>(targetNoteId);
    map['similarity'] = Variable<double>(similarity);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  NoteRelationshipsTableCompanion toCompanion(bool nullToAbsent) {
    return NoteRelationshipsTableCompanion(
      sourceNoteId: Value(sourceNoteId),
      targetNoteId: Value(targetNoteId),
      similarity: Value(similarity),
      status: Value(status),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteRelationshipsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRelationshipsTableData(
      sourceNoteId: serializer.fromJson<String>(json['sourceNoteId']),
      targetNoteId: serializer.fromJson<String>(json['targetNoteId']),
      similarity: serializer.fromJson<double>(json['similarity']),
      status: serializer.fromJson<String>(json['status']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sourceNoteId': serializer.toJson<String>(sourceNoteId),
      'targetNoteId': serializer.toJson<String>(targetNoteId),
      'similarity': serializer.toJson<double>(similarity),
      'status': serializer.toJson<String>(status),
      'explanation': serializer.toJson<String?>(explanation),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  NoteRelationshipsTableData copyWith({
    String? sourceNoteId,
    String? targetNoteId,
    double? similarity,
    String? status,
    Value<String?> explanation = const Value.absent(),
    int? updatedAt,
  }) => NoteRelationshipsTableData(
    sourceNoteId: sourceNoteId ?? this.sourceNoteId,
    targetNoteId: targetNoteId ?? this.targetNoteId,
    similarity: similarity ?? this.similarity,
    status: status ?? this.status,
    explanation: explanation.present ? explanation.value : this.explanation,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteRelationshipsTableData copyWithCompanion(
    NoteRelationshipsTableCompanion data,
  ) {
    return NoteRelationshipsTableData(
      sourceNoteId: data.sourceNoteId.present
          ? data.sourceNoteId.value
          : this.sourceNoteId,
      targetNoteId: data.targetNoteId.present
          ? data.targetNoteId.value
          : this.targetNoteId,
      similarity: data.similarity.present
          ? data.similarity.value
          : this.similarity,
      status: data.status.present ? data.status.value : this.status,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRelationshipsTableData(')
          ..write('sourceNoteId: $sourceNoteId, ')
          ..write('targetNoteId: $targetNoteId, ')
          ..write('similarity: $similarity, ')
          ..write('status: $status, ')
          ..write('explanation: $explanation, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    sourceNoteId,
    targetNoteId,
    similarity,
    status,
    explanation,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRelationshipsTableData &&
          other.sourceNoteId == this.sourceNoteId &&
          other.targetNoteId == this.targetNoteId &&
          other.similarity == this.similarity &&
          other.status == this.status &&
          other.explanation == this.explanation &&
          other.updatedAt == this.updatedAt);
}

class NoteRelationshipsTableCompanion
    extends UpdateCompanion<NoteRelationshipsTableData> {
  final Value<String> sourceNoteId;
  final Value<String> targetNoteId;
  final Value<double> similarity;
  final Value<String> status;
  final Value<String?> explanation;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const NoteRelationshipsTableCompanion({
    this.sourceNoteId = const Value.absent(),
    this.targetNoteId = const Value.absent(),
    this.similarity = const Value.absent(),
    this.status = const Value.absent(),
    this.explanation = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteRelationshipsTableCompanion.insert({
    required String sourceNoteId,
    required String targetNoteId,
    required double similarity,
    this.status = const Value.absent(),
    this.explanation = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : sourceNoteId = Value(sourceNoteId),
       targetNoteId = Value(targetNoteId),
       similarity = Value(similarity),
       updatedAt = Value(updatedAt);
  static Insertable<NoteRelationshipsTableData> custom({
    Expression<String>? sourceNoteId,
    Expression<String>? targetNoteId,
    Expression<double>? similarity,
    Expression<String>? status,
    Expression<String>? explanation,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sourceNoteId != null) 'source_note_id': sourceNoteId,
      if (targetNoteId != null) 'target_note_id': targetNoteId,
      if (similarity != null) 'similarity': similarity,
      if (status != null) 'status': status,
      if (explanation != null) 'explanation': explanation,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteRelationshipsTableCompanion copyWith({
    Value<String>? sourceNoteId,
    Value<String>? targetNoteId,
    Value<double>? similarity,
    Value<String>? status,
    Value<String?>? explanation,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return NoteRelationshipsTableCompanion(
      sourceNoteId: sourceNoteId ?? this.sourceNoteId,
      targetNoteId: targetNoteId ?? this.targetNoteId,
      similarity: similarity ?? this.similarity,
      status: status ?? this.status,
      explanation: explanation ?? this.explanation,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sourceNoteId.present) {
      map['source_note_id'] = Variable<String>(sourceNoteId.value);
    }
    if (targetNoteId.present) {
      map['target_note_id'] = Variable<String>(targetNoteId.value);
    }
    if (similarity.present) {
      map['similarity'] = Variable<double>(similarity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteRelationshipsTableCompanion(')
          ..write('sourceNoteId: $sourceNoteId, ')
          ..write('targetNoteId: $targetNoteId, ')
          ..write('similarity: $similarity, ')
          ..write('status: $status, ')
          ..write('explanation: $explanation, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TopicClustersTableTable extends TopicClustersTable
    with TableInfo<$TopicClustersTableTable, TopicClustersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicClustersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('suggested'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    summary,
    status,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topic_clusters';
  @override
  VerificationContext validateIntegrity(
    Insertable<TopicClustersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TopicClustersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicClustersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TopicClustersTableTable createAlias(String alias) {
    return $TopicClustersTableTable(attachedDatabase, alias);
  }
}

class TopicClustersTableData extends DataClass
    implements Insertable<TopicClustersTableData> {
  final String id;
  final String label;
  final String? summary;
  final String status;
  final int createdAt;
  final int updatedAt;
  const TopicClustersTableData({
    required this.id,
    required this.label,
    this.summary,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TopicClustersTableCompanion toCompanion(bool nullToAbsent) {
    return TopicClustersTableCompanion(
      id: Value(id),
      label: Value(label),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TopicClustersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicClustersTableData(
      id: serializer.fromJson<String>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      summary: serializer.fromJson<String?>(json['summary']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'label': serializer.toJson<String>(label),
      'summary': serializer.toJson<String?>(summary),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TopicClustersTableData copyWith({
    String? id,
    String? label,
    Value<String?> summary = const Value.absent(),
    String? status,
    int? createdAt,
    int? updatedAt,
  }) => TopicClustersTableData(
    id: id ?? this.id,
    label: label ?? this.label,
    summary: summary.present ? summary.value : this.summary,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TopicClustersTableData copyWithCompanion(TopicClustersTableCompanion data) {
    return TopicClustersTableData(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      summary: data.summary.present ? data.summary.value : this.summary,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicClustersTableData(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, label, summary, status, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicClustersTableData &&
          other.id == this.id &&
          other.label == this.label &&
          other.summary == this.summary &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TopicClustersTableCompanion
    extends UpdateCompanion<TopicClustersTableData> {
  final Value<String> id;
  final Value<String> label;
  final Value<String?> summary;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TopicClustersTableCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicClustersTableCompanion.insert({
    required String id,
    required String label,
    this.summary = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       label = Value(label),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TopicClustersTableData> custom({
    Expression<String>? id,
    Expression<String>? label,
    Expression<String>? summary,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (summary != null) 'summary': summary,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicClustersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? label,
    Value<String?>? summary,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TopicClustersTableCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicClustersTableCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('summary: $summary, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TopicMembershipsTableTable extends TopicMembershipsTable
    with TableInfo<$TopicMembershipsTableTable, TopicMembershipsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicMembershipsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clusterIdMeta = const VerificationMeta(
    'clusterId',
  );
  @override
  late final GeneratedColumn<String> clusterId = GeneratedColumn<String>(
    'cluster_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clusterId,
    noteId,
    confidence,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topic_memberships';
  @override
  VerificationContext validateIntegrity(
    Insertable<TopicMembershipsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cluster_id')) {
      context.handle(
        _clusterIdMeta,
        clusterId.isAcceptableOrUnknown(data['cluster_id']!, _clusterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clusterIdMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clusterId, noteId};
  @override
  TopicMembershipsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TopicMembershipsTableData(
      clusterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cluster_id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TopicMembershipsTableTable createAlias(String alias) {
    return $TopicMembershipsTableTable(attachedDatabase, alias);
  }
}

class TopicMembershipsTableData extends DataClass
    implements Insertable<TopicMembershipsTableData> {
  final String clusterId;
  final String noteId;
  final double confidence;
  final int updatedAt;
  const TopicMembershipsTableData({
    required this.clusterId,
    required this.noteId,
    required this.confidence,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cluster_id'] = Variable<String>(clusterId);
    map['note_id'] = Variable<String>(noteId);
    map['confidence'] = Variable<double>(confidence);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  TopicMembershipsTableCompanion toCompanion(bool nullToAbsent) {
    return TopicMembershipsTableCompanion(
      clusterId: Value(clusterId),
      noteId: Value(noteId),
      confidence: Value(confidence),
      updatedAt: Value(updatedAt),
    );
  }

  factory TopicMembershipsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TopicMembershipsTableData(
      clusterId: serializer.fromJson<String>(json['clusterId']),
      noteId: serializer.fromJson<String>(json['noteId']),
      confidence: serializer.fromJson<double>(json['confidence']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clusterId': serializer.toJson<String>(clusterId),
      'noteId': serializer.toJson<String>(noteId),
      'confidence': serializer.toJson<double>(confidence),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  TopicMembershipsTableData copyWith({
    String? clusterId,
    String? noteId,
    double? confidence,
    int? updatedAt,
  }) => TopicMembershipsTableData(
    clusterId: clusterId ?? this.clusterId,
    noteId: noteId ?? this.noteId,
    confidence: confidence ?? this.confidence,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TopicMembershipsTableData copyWithCompanion(
    TopicMembershipsTableCompanion data,
  ) {
    return TopicMembershipsTableData(
      clusterId: data.clusterId.present ? data.clusterId.value : this.clusterId,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TopicMembershipsTableData(')
          ..write('clusterId: $clusterId, ')
          ..write('noteId: $noteId, ')
          ..write('confidence: $confidence, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clusterId, noteId, confidence, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TopicMembershipsTableData &&
          other.clusterId == this.clusterId &&
          other.noteId == this.noteId &&
          other.confidence == this.confidence &&
          other.updatedAt == this.updatedAt);
}

class TopicMembershipsTableCompanion
    extends UpdateCompanion<TopicMembershipsTableData> {
  final Value<String> clusterId;
  final Value<String> noteId;
  final Value<double> confidence;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const TopicMembershipsTableCompanion({
    this.clusterId = const Value.absent(),
    this.noteId = const Value.absent(),
    this.confidence = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicMembershipsTableCompanion.insert({
    required String clusterId,
    required String noteId,
    required double confidence,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : clusterId = Value(clusterId),
       noteId = Value(noteId),
       confidence = Value(confidence),
       updatedAt = Value(updatedAt);
  static Insertable<TopicMembershipsTableData> custom({
    Expression<String>? clusterId,
    Expression<String>? noteId,
    Expression<double>? confidence,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clusterId != null) 'cluster_id': clusterId,
      if (noteId != null) 'note_id': noteId,
      if (confidence != null) 'confidence': confidence,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicMembershipsTableCompanion copyWith({
    Value<String>? clusterId,
    Value<String>? noteId,
    Value<double>? confidence,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return TopicMembershipsTableCompanion(
      clusterId: clusterId ?? this.clusterId,
      noteId: noteId ?? this.noteId,
      confidence: confidence ?? this.confidence,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clusterId.present) {
      map['cluster_id'] = Variable<String>(clusterId.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicMembershipsTableCompanion(')
          ..write('clusterId: $clusterId, ')
          ..write('noteId: $noteId, ')
          ..write('confidence: $confidence, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteInterpretationsTableTable extends NoteInterpretationsTable
    with
        TableInfo<
          $NoteInterpretationsTableTable,
          NoteInterpretationsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteInterpretationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _rawTranscriptMeta = const VerificationMeta(
    'rawTranscript',
  );
  @override
  late final GeneratedColumn<String> rawTranscript = GeneratedColumn<String>(
    'raw_transcript',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedTextMeta = const VerificationMeta(
    'normalizedText',
  );
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
    'normalized_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _primaryLanguageMeta = const VerificationMeta(
    'primaryLanguage',
  );
  @override
  late final GeneratedColumn<String> primaryLanguage = GeneratedColumn<String>(
    'primary_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mixedLanguagesJsonMeta =
      const VerificationMeta('mixedLanguagesJson');
  @override
  late final GeneratedColumn<String> mixedLanguagesJson =
      GeneratedColumn<String>(
        'mixed_languages_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _intentsJsonMeta = const VerificationMeta(
    'intentsJson',
  );
  @override
  late final GeneratedColumn<String> intentsJson = GeneratedColumn<String>(
    'intents_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _entitiesJsonMeta = const VerificationMeta(
    'entitiesJson',
  );
  @override
  late final GeneratedColumn<String> entitiesJson = GeneratedColumn<String>(
    'entities_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _projectCandidatesJsonMeta =
      const VerificationMeta('projectCandidatesJson');
  @override
  late final GeneratedColumn<String> projectCandidatesJson =
      GeneratedColumn<String>(
        'project_candidates_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _agentPromptJsonMeta = const VerificationMeta(
    'agentPromptJson',
  );
  @override
  late final GeneratedColumn<String> agentPromptJson = GeneratedColumn<String>(
    'agent_prompt_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _provenanceJsonMeta = const VerificationMeta(
    'provenanceJson',
  );
  @override
  late final GeneratedColumn<String> provenanceJson = GeneratedColumn<String>(
    'provenance_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    noteId,
    schemaVersion,
    rawTranscript,
    normalizedText,
    primaryLanguage,
    mixedLanguagesJson,
    intentsJson,
    entitiesJson,
    projectCandidatesJson,
    agentPromptJson,
    provenanceJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_interpretations';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteInterpretationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('raw_transcript')) {
      context.handle(
        _rawTranscriptMeta,
        rawTranscript.isAcceptableOrUnknown(
          data['raw_transcript']!,
          _rawTranscriptMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rawTranscriptMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
        _normalizedTextMeta,
        normalizedText.isAcceptableOrUnknown(
          data['normalized_text']!,
          _normalizedTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedTextMeta);
    }
    if (data.containsKey('primary_language')) {
      context.handle(
        _primaryLanguageMeta,
        primaryLanguage.isAcceptableOrUnknown(
          data['primary_language']!,
          _primaryLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_primaryLanguageMeta);
    }
    if (data.containsKey('mixed_languages_json')) {
      context.handle(
        _mixedLanguagesJsonMeta,
        mixedLanguagesJson.isAcceptableOrUnknown(
          data['mixed_languages_json']!,
          _mixedLanguagesJsonMeta,
        ),
      );
    }
    if (data.containsKey('intents_json')) {
      context.handle(
        _intentsJsonMeta,
        intentsJson.isAcceptableOrUnknown(
          data['intents_json']!,
          _intentsJsonMeta,
        ),
      );
    }
    if (data.containsKey('entities_json')) {
      context.handle(
        _entitiesJsonMeta,
        entitiesJson.isAcceptableOrUnknown(
          data['entities_json']!,
          _entitiesJsonMeta,
        ),
      );
    }
    if (data.containsKey('project_candidates_json')) {
      context.handle(
        _projectCandidatesJsonMeta,
        projectCandidatesJson.isAcceptableOrUnknown(
          data['project_candidates_json']!,
          _projectCandidatesJsonMeta,
        ),
      );
    }
    if (data.containsKey('agent_prompt_json')) {
      context.handle(
        _agentPromptJsonMeta,
        agentPromptJson.isAcceptableOrUnknown(
          data['agent_prompt_json']!,
          _agentPromptJsonMeta,
        ),
      );
    }
    if (data.containsKey('provenance_json')) {
      context.handle(
        _provenanceJsonMeta,
        provenanceJson.isAcceptableOrUnknown(
          data['provenance_json']!,
          _provenanceJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_provenanceJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId};
  @override
  NoteInterpretationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteInterpretationsTableData(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      rawTranscript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_transcript'],
      )!,
      normalizedText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_text'],
      )!,
      primaryLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}primary_language'],
      )!,
      mixedLanguagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mixed_languages_json'],
      )!,
      intentsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intents_json'],
      )!,
      entitiesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entities_json'],
      )!,
      projectCandidatesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_candidates_json'],
      )!,
      agentPromptJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}agent_prompt_json'],
      ),
      provenanceJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NoteInterpretationsTableTable createAlias(String alias) {
    return $NoteInterpretationsTableTable(attachedDatabase, alias);
  }
}

class NoteInterpretationsTableData extends DataClass
    implements Insertable<NoteInterpretationsTableData> {
  final String noteId;
  final int schemaVersion;
  final String rawTranscript;
  final String normalizedText;
  final String primaryLanguage;
  final String mixedLanguagesJson;
  final String intentsJson;
  final String entitiesJson;
  final String projectCandidatesJson;
  final String? agentPromptJson;
  final String provenanceJson;
  final int createdAt;
  final int updatedAt;
  const NoteInterpretationsTableData({
    required this.noteId,
    required this.schemaVersion,
    required this.rawTranscript,
    required this.normalizedText,
    required this.primaryLanguage,
    required this.mixedLanguagesJson,
    required this.intentsJson,
    required this.entitiesJson,
    required this.projectCandidatesJson,
    this.agentPromptJson,
    required this.provenanceJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<String>(noteId);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['raw_transcript'] = Variable<String>(rawTranscript);
    map['normalized_text'] = Variable<String>(normalizedText);
    map['primary_language'] = Variable<String>(primaryLanguage);
    map['mixed_languages_json'] = Variable<String>(mixedLanguagesJson);
    map['intents_json'] = Variable<String>(intentsJson);
    map['entities_json'] = Variable<String>(entitiesJson);
    map['project_candidates_json'] = Variable<String>(projectCandidatesJson);
    if (!nullToAbsent || agentPromptJson != null) {
      map['agent_prompt_json'] = Variable<String>(agentPromptJson);
    }
    map['provenance_json'] = Variable<String>(provenanceJson);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  NoteInterpretationsTableCompanion toCompanion(bool nullToAbsent) {
    return NoteInterpretationsTableCompanion(
      noteId: Value(noteId),
      schemaVersion: Value(schemaVersion),
      rawTranscript: Value(rawTranscript),
      normalizedText: Value(normalizedText),
      primaryLanguage: Value(primaryLanguage),
      mixedLanguagesJson: Value(mixedLanguagesJson),
      intentsJson: Value(intentsJson),
      entitiesJson: Value(entitiesJson),
      projectCandidatesJson: Value(projectCandidatesJson),
      agentPromptJson: agentPromptJson == null && nullToAbsent
          ? const Value.absent()
          : Value(agentPromptJson),
      provenanceJson: Value(provenanceJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteInterpretationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteInterpretationsTableData(
      noteId: serializer.fromJson<String>(json['noteId']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      rawTranscript: serializer.fromJson<String>(json['rawTranscript']),
      normalizedText: serializer.fromJson<String>(json['normalizedText']),
      primaryLanguage: serializer.fromJson<String>(json['primaryLanguage']),
      mixedLanguagesJson: serializer.fromJson<String>(
        json['mixedLanguagesJson'],
      ),
      intentsJson: serializer.fromJson<String>(json['intentsJson']),
      entitiesJson: serializer.fromJson<String>(json['entitiesJson']),
      projectCandidatesJson: serializer.fromJson<String>(
        json['projectCandidatesJson'],
      ),
      agentPromptJson: serializer.fromJson<String?>(json['agentPromptJson']),
      provenanceJson: serializer.fromJson<String>(json['provenanceJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<String>(noteId),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'rawTranscript': serializer.toJson<String>(rawTranscript),
      'normalizedText': serializer.toJson<String>(normalizedText),
      'primaryLanguage': serializer.toJson<String>(primaryLanguage),
      'mixedLanguagesJson': serializer.toJson<String>(mixedLanguagesJson),
      'intentsJson': serializer.toJson<String>(intentsJson),
      'entitiesJson': serializer.toJson<String>(entitiesJson),
      'projectCandidatesJson': serializer.toJson<String>(projectCandidatesJson),
      'agentPromptJson': serializer.toJson<String?>(agentPromptJson),
      'provenanceJson': serializer.toJson<String>(provenanceJson),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  NoteInterpretationsTableData copyWith({
    String? noteId,
    int? schemaVersion,
    String? rawTranscript,
    String? normalizedText,
    String? primaryLanguage,
    String? mixedLanguagesJson,
    String? intentsJson,
    String? entitiesJson,
    String? projectCandidatesJson,
    Value<String?> agentPromptJson = const Value.absent(),
    String? provenanceJson,
    int? createdAt,
    int? updatedAt,
  }) => NoteInterpretationsTableData(
    noteId: noteId ?? this.noteId,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    rawTranscript: rawTranscript ?? this.rawTranscript,
    normalizedText: normalizedText ?? this.normalizedText,
    primaryLanguage: primaryLanguage ?? this.primaryLanguage,
    mixedLanguagesJson: mixedLanguagesJson ?? this.mixedLanguagesJson,
    intentsJson: intentsJson ?? this.intentsJson,
    entitiesJson: entitiesJson ?? this.entitiesJson,
    projectCandidatesJson: projectCandidatesJson ?? this.projectCandidatesJson,
    agentPromptJson: agentPromptJson.present
        ? agentPromptJson.value
        : this.agentPromptJson,
    provenanceJson: provenanceJson ?? this.provenanceJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteInterpretationsTableData copyWithCompanion(
    NoteInterpretationsTableCompanion data,
  ) {
    return NoteInterpretationsTableData(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      rawTranscript: data.rawTranscript.present
          ? data.rawTranscript.value
          : this.rawTranscript,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
      primaryLanguage: data.primaryLanguage.present
          ? data.primaryLanguage.value
          : this.primaryLanguage,
      mixedLanguagesJson: data.mixedLanguagesJson.present
          ? data.mixedLanguagesJson.value
          : this.mixedLanguagesJson,
      intentsJson: data.intentsJson.present
          ? data.intentsJson.value
          : this.intentsJson,
      entitiesJson: data.entitiesJson.present
          ? data.entitiesJson.value
          : this.entitiesJson,
      projectCandidatesJson: data.projectCandidatesJson.present
          ? data.projectCandidatesJson.value
          : this.projectCandidatesJson,
      agentPromptJson: data.agentPromptJson.present
          ? data.agentPromptJson.value
          : this.agentPromptJson,
      provenanceJson: data.provenanceJson.present
          ? data.provenanceJson.value
          : this.provenanceJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteInterpretationsTableData(')
          ..write('noteId: $noteId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('primaryLanguage: $primaryLanguage, ')
          ..write('mixedLanguagesJson: $mixedLanguagesJson, ')
          ..write('intentsJson: $intentsJson, ')
          ..write('entitiesJson: $entitiesJson, ')
          ..write('projectCandidatesJson: $projectCandidatesJson, ')
          ..write('agentPromptJson: $agentPromptJson, ')
          ..write('provenanceJson: $provenanceJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    noteId,
    schemaVersion,
    rawTranscript,
    normalizedText,
    primaryLanguage,
    mixedLanguagesJson,
    intentsJson,
    entitiesJson,
    projectCandidatesJson,
    agentPromptJson,
    provenanceJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteInterpretationsTableData &&
          other.noteId == this.noteId &&
          other.schemaVersion == this.schemaVersion &&
          other.rawTranscript == this.rawTranscript &&
          other.normalizedText == this.normalizedText &&
          other.primaryLanguage == this.primaryLanguage &&
          other.mixedLanguagesJson == this.mixedLanguagesJson &&
          other.intentsJson == this.intentsJson &&
          other.entitiesJson == this.entitiesJson &&
          other.projectCandidatesJson == this.projectCandidatesJson &&
          other.agentPromptJson == this.agentPromptJson &&
          other.provenanceJson == this.provenanceJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NoteInterpretationsTableCompanion
    extends UpdateCompanion<NoteInterpretationsTableData> {
  final Value<String> noteId;
  final Value<int> schemaVersion;
  final Value<String> rawTranscript;
  final Value<String> normalizedText;
  final Value<String> primaryLanguage;
  final Value<String> mixedLanguagesJson;
  final Value<String> intentsJson;
  final Value<String> entitiesJson;
  final Value<String> projectCandidatesJson;
  final Value<String?> agentPromptJson;
  final Value<String> provenanceJson;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const NoteInterpretationsTableCompanion({
    this.noteId = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.rawTranscript = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.primaryLanguage = const Value.absent(),
    this.mixedLanguagesJson = const Value.absent(),
    this.intentsJson = const Value.absent(),
    this.entitiesJson = const Value.absent(),
    this.projectCandidatesJson = const Value.absent(),
    this.agentPromptJson = const Value.absent(),
    this.provenanceJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteInterpretationsTableCompanion.insert({
    required String noteId,
    this.schemaVersion = const Value.absent(),
    required String rawTranscript,
    required String normalizedText,
    required String primaryLanguage,
    this.mixedLanguagesJson = const Value.absent(),
    this.intentsJson = const Value.absent(),
    this.entitiesJson = const Value.absent(),
    this.projectCandidatesJson = const Value.absent(),
    this.agentPromptJson = const Value.absent(),
    required String provenanceJson,
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       rawTranscript = Value(rawTranscript),
       normalizedText = Value(normalizedText),
       primaryLanguage = Value(primaryLanguage),
       provenanceJson = Value(provenanceJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NoteInterpretationsTableData> custom({
    Expression<String>? noteId,
    Expression<int>? schemaVersion,
    Expression<String>? rawTranscript,
    Expression<String>? normalizedText,
    Expression<String>? primaryLanguage,
    Expression<String>? mixedLanguagesJson,
    Expression<String>? intentsJson,
    Expression<String>? entitiesJson,
    Expression<String>? projectCandidatesJson,
    Expression<String>? agentPromptJson,
    Expression<String>? provenanceJson,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (rawTranscript != null) 'raw_transcript': rawTranscript,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (primaryLanguage != null) 'primary_language': primaryLanguage,
      if (mixedLanguagesJson != null)
        'mixed_languages_json': mixedLanguagesJson,
      if (intentsJson != null) 'intents_json': intentsJson,
      if (entitiesJson != null) 'entities_json': entitiesJson,
      if (projectCandidatesJson != null)
        'project_candidates_json': projectCandidatesJson,
      if (agentPromptJson != null) 'agent_prompt_json': agentPromptJson,
      if (provenanceJson != null) 'provenance_json': provenanceJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteInterpretationsTableCompanion copyWith({
    Value<String>? noteId,
    Value<int>? schemaVersion,
    Value<String>? rawTranscript,
    Value<String>? normalizedText,
    Value<String>? primaryLanguage,
    Value<String>? mixedLanguagesJson,
    Value<String>? intentsJson,
    Value<String>? entitiesJson,
    Value<String>? projectCandidatesJson,
    Value<String?>? agentPromptJson,
    Value<String>? provenanceJson,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return NoteInterpretationsTableCompanion(
      noteId: noteId ?? this.noteId,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      normalizedText: normalizedText ?? this.normalizedText,
      primaryLanguage: primaryLanguage ?? this.primaryLanguage,
      mixedLanguagesJson: mixedLanguagesJson ?? this.mixedLanguagesJson,
      intentsJson: intentsJson ?? this.intentsJson,
      entitiesJson: entitiesJson ?? this.entitiesJson,
      projectCandidatesJson:
          projectCandidatesJson ?? this.projectCandidatesJson,
      agentPromptJson: agentPromptJson ?? this.agentPromptJson,
      provenanceJson: provenanceJson ?? this.provenanceJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (rawTranscript.present) {
      map['raw_transcript'] = Variable<String>(rawTranscript.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
    }
    if (primaryLanguage.present) {
      map['primary_language'] = Variable<String>(primaryLanguage.value);
    }
    if (mixedLanguagesJson.present) {
      map['mixed_languages_json'] = Variable<String>(mixedLanguagesJson.value);
    }
    if (intentsJson.present) {
      map['intents_json'] = Variable<String>(intentsJson.value);
    }
    if (entitiesJson.present) {
      map['entities_json'] = Variable<String>(entitiesJson.value);
    }
    if (projectCandidatesJson.present) {
      map['project_candidates_json'] = Variable<String>(
        projectCandidatesJson.value,
      );
    }
    if (agentPromptJson.present) {
      map['agent_prompt_json'] = Variable<String>(agentPromptJson.value);
    }
    if (provenanceJson.present) {
      map['provenance_json'] = Variable<String>(provenanceJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteInterpretationsTableCompanion(')
          ..write('noteId: $noteId, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('rawTranscript: $rawTranscript, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('primaryLanguage: $primaryLanguage, ')
          ..write('mixedLanguagesJson: $mixedLanguagesJson, ')
          ..write('intentsJson: $intentsJson, ')
          ..write('entitiesJson: $entitiesJson, ')
          ..write('projectCandidatesJson: $projectCandidatesJson, ')
          ..write('agentPromptJson: $agentPromptJson, ')
          ..write('provenanceJson: $provenanceJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KnownProjectsTableTable extends KnownProjectsTable
    with TableInfo<$KnownProjectsTableTable, KnownProjectsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KnownProjectsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasesJsonMeta = const VerificationMeta(
    'aliasesJson',
  );
  @override
  late final GeneratedColumn<String> aliasesJson = GeneratedColumn<String>(
    'aliases_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReferencedAtMeta = const VerificationMeta(
    'lastReferencedAt',
  );
  @override
  late final GeneratedColumn<int> lastReferencedAt = GeneratedColumn<int>(
    'last_referenced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    normalizedName,
    aliasesJson,
    description,
    lastReferencedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'known_projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<KnownProjectsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('aliases_json')) {
      context.handle(
        _aliasesJsonMeta,
        aliasesJson.isAcceptableOrUnknown(
          data['aliases_json']!,
          _aliasesJsonMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('last_referenced_at')) {
      context.handle(
        _lastReferencedAtMeta,
        lastReferencedAt.isAcceptableOrUnknown(
          data['last_referenced_at']!,
          _lastReferencedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastReferencedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KnownProjectsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KnownProjectsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      aliasesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases_json'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      lastReferencedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_referenced_at'],
      )!,
    );
  }

  @override
  $KnownProjectsTableTable createAlias(String alias) {
    return $KnownProjectsTableTable(attachedDatabase, alias);
  }
}

class KnownProjectsTableData extends DataClass
    implements Insertable<KnownProjectsTableData> {
  final String id;
  final String name;
  final String normalizedName;
  final String aliasesJson;
  final String? description;
  final int lastReferencedAt;
  const KnownProjectsTableData({
    required this.id,
    required this.name,
    required this.normalizedName,
    required this.aliasesJson,
    this.description,
    required this.lastReferencedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['aliases_json'] = Variable<String>(aliasesJson);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['last_referenced_at'] = Variable<int>(lastReferencedAt);
    return map;
  }

  KnownProjectsTableCompanion toCompanion(bool nullToAbsent) {
    return KnownProjectsTableCompanion(
      id: Value(id),
      name: Value(name),
      normalizedName: Value(normalizedName),
      aliasesJson: Value(aliasesJson),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      lastReferencedAt: Value(lastReferencedAt),
    );
  }

  factory KnownProjectsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KnownProjectsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      aliasesJson: serializer.fromJson<String>(json['aliasesJson']),
      description: serializer.fromJson<String?>(json['description']),
      lastReferencedAt: serializer.fromJson<int>(json['lastReferencedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'aliasesJson': serializer.toJson<String>(aliasesJson),
      'description': serializer.toJson<String?>(description),
      'lastReferencedAt': serializer.toJson<int>(lastReferencedAt),
    };
  }

  KnownProjectsTableData copyWith({
    String? id,
    String? name,
    String? normalizedName,
    String? aliasesJson,
    Value<String?> description = const Value.absent(),
    int? lastReferencedAt,
  }) => KnownProjectsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    aliasesJson: aliasesJson ?? this.aliasesJson,
    description: description.present ? description.value : this.description,
    lastReferencedAt: lastReferencedAt ?? this.lastReferencedAt,
  );
  KnownProjectsTableData copyWithCompanion(KnownProjectsTableCompanion data) {
    return KnownProjectsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      aliasesJson: data.aliasesJson.present
          ? data.aliasesJson.value
          : this.aliasesJson,
      description: data.description.present
          ? data.description.value
          : this.description,
      lastReferencedAt: data.lastReferencedAt.present
          ? data.lastReferencedAt.value
          : this.lastReferencedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KnownProjectsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('aliasesJson: $aliasesJson, ')
          ..write('description: $description, ')
          ..write('lastReferencedAt: $lastReferencedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    normalizedName,
    aliasesJson,
    description,
    lastReferencedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KnownProjectsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.aliasesJson == this.aliasesJson &&
          other.description == this.description &&
          other.lastReferencedAt == this.lastReferencedAt);
}

class KnownProjectsTableCompanion
    extends UpdateCompanion<KnownProjectsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String> aliasesJson;
  final Value<String?> description;
  final Value<int> lastReferencedAt;
  final Value<int> rowid;
  const KnownProjectsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.aliasesJson = const Value.absent(),
    this.description = const Value.absent(),
    this.lastReferencedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KnownProjectsTableCompanion.insert({
    required String id,
    required String name,
    required String normalizedName,
    this.aliasesJson = const Value.absent(),
    this.description = const Value.absent(),
    required int lastReferencedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       normalizedName = Value(normalizedName),
       lastReferencedAt = Value(lastReferencedAt);
  static Insertable<KnownProjectsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? aliasesJson,
    Expression<String>? description,
    Expression<int>? lastReferencedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (aliasesJson != null) 'aliases_json': aliasesJson,
      if (description != null) 'description': description,
      if (lastReferencedAt != null) 'last_referenced_at': lastReferencedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KnownProjectsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String>? aliasesJson,
    Value<String?>? description,
    Value<int>? lastReferencedAt,
    Value<int>? rowid,
  }) {
    return KnownProjectsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      aliasesJson: aliasesJson ?? this.aliasesJson,
      description: description ?? this.description,
      lastReferencedAt: lastReferencedAt ?? this.lastReferencedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (aliasesJson.present) {
      map['aliases_json'] = Variable<String>(aliasesJson.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (lastReferencedAt.present) {
      map['last_referenced_at'] = Variable<int>(lastReferencedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnownProjectsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('aliasesJson: $aliasesJson, ')
          ..write('description: $description, ')
          ..write('lastReferencedAt: $lastReferencedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KnownApplicationsTableTable extends KnownApplicationsTable
    with TableInfo<$KnownApplicationsTableTable, KnownApplicationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KnownApplicationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bundleIdMeta = const VerificationMeta(
    'bundleId',
  );
  @override
  late final GeneratedColumn<String> bundleId = GeneratedColumn<String>(
    'bundle_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aliasesJsonMeta = const VerificationMeta(
    'aliasesJson',
  );
  @override
  late final GeneratedColumn<String> aliasesJson = GeneratedColumn<String>(
    'aliases_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastReferencedAtMeta = const VerificationMeta(
    'lastReferencedAt',
  );
  @override
  late final GeneratedColumn<int> lastReferencedAt = GeneratedColumn<int>(
    'last_referenced_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    bundleId,
    aliasesJson,
    description,
    lastReferencedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'known_applications';
  @override
  VerificationContext validateIntegrity(
    Insertable<KnownApplicationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bundle_id')) {
      context.handle(
        _bundleIdMeta,
        bundleId.isAcceptableOrUnknown(data['bundle_id']!, _bundleIdMeta),
      );
    }
    if (data.containsKey('aliases_json')) {
      context.handle(
        _aliasesJsonMeta,
        aliasesJson.isAcceptableOrUnknown(
          data['aliases_json']!,
          _aliasesJsonMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('last_referenced_at')) {
      context.handle(
        _lastReferencedAtMeta,
        lastReferencedAt.isAcceptableOrUnknown(
          data['last_referenced_at']!,
          _lastReferencedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastReferencedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KnownApplicationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KnownApplicationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bundleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bundle_id'],
      ),
      aliasesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases_json'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      lastReferencedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_referenced_at'],
      )!,
    );
  }

  @override
  $KnownApplicationsTableTable createAlias(String alias) {
    return $KnownApplicationsTableTable(attachedDatabase, alias);
  }
}

class KnownApplicationsTableData extends DataClass
    implements Insertable<KnownApplicationsTableData> {
  final String id;
  final String name;
  final String? bundleId;
  final String aliasesJson;
  final String? description;
  final int lastReferencedAt;
  const KnownApplicationsTableData({
    required this.id,
    required this.name,
    this.bundleId,
    required this.aliasesJson,
    this.description,
    required this.lastReferencedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || bundleId != null) {
      map['bundle_id'] = Variable<String>(bundleId);
    }
    map['aliases_json'] = Variable<String>(aliasesJson);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['last_referenced_at'] = Variable<int>(lastReferencedAt);
    return map;
  }

  KnownApplicationsTableCompanion toCompanion(bool nullToAbsent) {
    return KnownApplicationsTableCompanion(
      id: Value(id),
      name: Value(name),
      bundleId: bundleId == null && nullToAbsent
          ? const Value.absent()
          : Value(bundleId),
      aliasesJson: Value(aliasesJson),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      lastReferencedAt: Value(lastReferencedAt),
    );
  }

  factory KnownApplicationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KnownApplicationsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bundleId: serializer.fromJson<String?>(json['bundleId']),
      aliasesJson: serializer.fromJson<String>(json['aliasesJson']),
      description: serializer.fromJson<String?>(json['description']),
      lastReferencedAt: serializer.fromJson<int>(json['lastReferencedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bundleId': serializer.toJson<String?>(bundleId),
      'aliasesJson': serializer.toJson<String>(aliasesJson),
      'description': serializer.toJson<String?>(description),
      'lastReferencedAt': serializer.toJson<int>(lastReferencedAt),
    };
  }

  KnownApplicationsTableData copyWith({
    String? id,
    String? name,
    Value<String?> bundleId = const Value.absent(),
    String? aliasesJson,
    Value<String?> description = const Value.absent(),
    int? lastReferencedAt,
  }) => KnownApplicationsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    bundleId: bundleId.present ? bundleId.value : this.bundleId,
    aliasesJson: aliasesJson ?? this.aliasesJson,
    description: description.present ? description.value : this.description,
    lastReferencedAt: lastReferencedAt ?? this.lastReferencedAt,
  );
  KnownApplicationsTableData copyWithCompanion(
    KnownApplicationsTableCompanion data,
  ) {
    return KnownApplicationsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bundleId: data.bundleId.present ? data.bundleId.value : this.bundleId,
      aliasesJson: data.aliasesJson.present
          ? data.aliasesJson.value
          : this.aliasesJson,
      description: data.description.present
          ? data.description.value
          : this.description,
      lastReferencedAt: data.lastReferencedAt.present
          ? data.lastReferencedAt.value
          : this.lastReferencedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KnownApplicationsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bundleId: $bundleId, ')
          ..write('aliasesJson: $aliasesJson, ')
          ..write('description: $description, ')
          ..write('lastReferencedAt: $lastReferencedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    bundleId,
    aliasesJson,
    description,
    lastReferencedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KnownApplicationsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.bundleId == this.bundleId &&
          other.aliasesJson == this.aliasesJson &&
          other.description == this.description &&
          other.lastReferencedAt == this.lastReferencedAt);
}

class KnownApplicationsTableCompanion
    extends UpdateCompanion<KnownApplicationsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> bundleId;
  final Value<String> aliasesJson;
  final Value<String?> description;
  final Value<int> lastReferencedAt;
  final Value<int> rowid;
  const KnownApplicationsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bundleId = const Value.absent(),
    this.aliasesJson = const Value.absent(),
    this.description = const Value.absent(),
    this.lastReferencedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KnownApplicationsTableCompanion.insert({
    required String id,
    required String name,
    this.bundleId = const Value.absent(),
    this.aliasesJson = const Value.absent(),
    this.description = const Value.absent(),
    required int lastReferencedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       lastReferencedAt = Value(lastReferencedAt);
  static Insertable<KnownApplicationsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bundleId,
    Expression<String>? aliasesJson,
    Expression<String>? description,
    Expression<int>? lastReferencedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bundleId != null) 'bundle_id': bundleId,
      if (aliasesJson != null) 'aliases_json': aliasesJson,
      if (description != null) 'description': description,
      if (lastReferencedAt != null) 'last_referenced_at': lastReferencedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KnownApplicationsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? bundleId,
    Value<String>? aliasesJson,
    Value<String?>? description,
    Value<int>? lastReferencedAt,
    Value<int>? rowid,
  }) {
    return KnownApplicationsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bundleId: bundleId ?? this.bundleId,
      aliasesJson: aliasesJson ?? this.aliasesJson,
      description: description ?? this.description,
      lastReferencedAt: lastReferencedAt ?? this.lastReferencedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bundleId.present) {
      map['bundle_id'] = Variable<String>(bundleId.value);
    }
    if (aliasesJson.present) {
      map['aliases_json'] = Variable<String>(aliasesJson.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (lastReferencedAt.present) {
      map['last_referenced_at'] = Variable<int>(lastReferencedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KnownApplicationsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bundleId: $bundleId, ')
          ..write('aliasesJson: $aliasesJson, ')
          ..write('description: $description, ')
          ..write('lastReferencedAt: $lastReferencedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DraftCommunicationsTableTable extends DraftCommunicationsTable
    with
        TableInfo<
          $DraftCommunicationsTableTable,
          DraftCommunicationsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DraftCommunicationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recipientMeta = const VerificationMeta(
    'recipient',
  );
  @override
  late final GeneratedColumn<String> recipient = GeneratedColumn<String>(
    'recipient',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectMeta = const VerificationMeta(
    'subject',
  );
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
    'subject',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedChannelMeta = const VerificationMeta(
    'resolvedChannel',
  );
  @override
  late final GeneratedColumn<String> resolvedChannel = GeneratedColumn<String>(
    'resolved_channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    type,
    recipient,
    subject,
    body,
    resolvedChannel,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'draft_communications';
  @override
  VerificationContext validateIntegrity(
    Insertable<DraftCommunicationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('recipient')) {
      context.handle(
        _recipientMeta,
        recipient.isAcceptableOrUnknown(data['recipient']!, _recipientMeta),
      );
    }
    if (data.containsKey('subject')) {
      context.handle(
        _subjectMeta,
        subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('resolved_channel')) {
      context.handle(
        _resolvedChannelMeta,
        resolvedChannel.isAcceptableOrUnknown(
          data['resolved_channel']!,
          _resolvedChannelMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DraftCommunicationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DraftCommunicationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      recipient: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recipient'],
      ),
      subject: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject'],
      ),
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      resolvedChannel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolved_channel'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DraftCommunicationsTableTable createAlias(String alias) {
    return $DraftCommunicationsTableTable(attachedDatabase, alias);
  }
}

class DraftCommunicationsTableData extends DataClass
    implements Insertable<DraftCommunicationsTableData> {
  final String id;
  final String noteId;
  final String type;
  final String? recipient;
  final String? subject;
  final String body;
  final String? resolvedChannel;
  final String status;
  final int createdAt;
  const DraftCommunicationsTableData({
    required this.id,
    required this.noteId,
    required this.type,
    this.recipient,
    this.subject,
    required this.body,
    this.resolvedChannel,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || recipient != null) {
      map['recipient'] = Variable<String>(recipient);
    }
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || resolvedChannel != null) {
      map['resolved_channel'] = Variable<String>(resolvedChannel);
    }
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  DraftCommunicationsTableCompanion toCompanion(bool nullToAbsent) {
    return DraftCommunicationsTableCompanion(
      id: Value(id),
      noteId: Value(noteId),
      type: Value(type),
      recipient: recipient == null && nullToAbsent
          ? const Value.absent()
          : Value(recipient),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      body: Value(body),
      resolvedChannel: resolvedChannel == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedChannel),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory DraftCommunicationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DraftCommunicationsTableData(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      type: serializer.fromJson<String>(json['type']),
      recipient: serializer.fromJson<String?>(json['recipient']),
      subject: serializer.fromJson<String?>(json['subject']),
      body: serializer.fromJson<String>(json['body']),
      resolvedChannel: serializer.fromJson<String?>(json['resolvedChannel']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'type': serializer.toJson<String>(type),
      'recipient': serializer.toJson<String?>(recipient),
      'subject': serializer.toJson<String?>(subject),
      'body': serializer.toJson<String>(body),
      'resolvedChannel': serializer.toJson<String?>(resolvedChannel),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  DraftCommunicationsTableData copyWith({
    String? id,
    String? noteId,
    String? type,
    Value<String?> recipient = const Value.absent(),
    Value<String?> subject = const Value.absent(),
    String? body,
    Value<String?> resolvedChannel = const Value.absent(),
    String? status,
    int? createdAt,
  }) => DraftCommunicationsTableData(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    type: type ?? this.type,
    recipient: recipient.present ? recipient.value : this.recipient,
    subject: subject.present ? subject.value : this.subject,
    body: body ?? this.body,
    resolvedChannel: resolvedChannel.present
        ? resolvedChannel.value
        : this.resolvedChannel,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  DraftCommunicationsTableData copyWithCompanion(
    DraftCommunicationsTableCompanion data,
  ) {
    return DraftCommunicationsTableData(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      type: data.type.present ? data.type.value : this.type,
      recipient: data.recipient.present ? data.recipient.value : this.recipient,
      subject: data.subject.present ? data.subject.value : this.subject,
      body: data.body.present ? data.body.value : this.body,
      resolvedChannel: data.resolvedChannel.present
          ? data.resolvedChannel.value
          : this.resolvedChannel,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DraftCommunicationsTableData(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('type: $type, ')
          ..write('recipient: $recipient, ')
          ..write('subject: $subject, ')
          ..write('body: $body, ')
          ..write('resolvedChannel: $resolvedChannel, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    noteId,
    type,
    recipient,
    subject,
    body,
    resolvedChannel,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DraftCommunicationsTableData &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.type == this.type &&
          other.recipient == this.recipient &&
          other.subject == this.subject &&
          other.body == this.body &&
          other.resolvedChannel == this.resolvedChannel &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class DraftCommunicationsTableCompanion
    extends UpdateCompanion<DraftCommunicationsTableData> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<String> type;
  final Value<String?> recipient;
  final Value<String?> subject;
  final Value<String> body;
  final Value<String?> resolvedChannel;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> rowid;
  const DraftCommunicationsTableCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.type = const Value.absent(),
    this.recipient = const Value.absent(),
    this.subject = const Value.absent(),
    this.body = const Value.absent(),
    this.resolvedChannel = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DraftCommunicationsTableCompanion.insert({
    required String id,
    required String noteId,
    required String type,
    this.recipient = const Value.absent(),
    this.subject = const Value.absent(),
    required String body,
    this.resolvedChannel = const Value.absent(),
    this.status = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       type = Value(type),
       body = Value(body),
       createdAt = Value(createdAt);
  static Insertable<DraftCommunicationsTableData> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<String>? type,
    Expression<String>? recipient,
    Expression<String>? subject,
    Expression<String>? body,
    Expression<String>? resolvedChannel,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (type != null) 'type': type,
      if (recipient != null) 'recipient': recipient,
      if (subject != null) 'subject': subject,
      if (body != null) 'body': body,
      if (resolvedChannel != null) 'resolved_channel': resolvedChannel,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DraftCommunicationsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<String>? type,
    Value<String?>? recipient,
    Value<String?>? subject,
    Value<String>? body,
    Value<String?>? resolvedChannel,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return DraftCommunicationsTableCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      type: type ?? this.type,
      recipient: recipient ?? this.recipient,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      resolvedChannel: resolvedChannel ?? this.resolvedChannel,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (recipient.present) {
      map['recipient'] = Variable<String>(recipient.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (resolvedChannel.present) {
      map['resolved_channel'] = Variable<String>(resolvedChannel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DraftCommunicationsTableCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('type: $type, ')
          ..write('recipient: $recipient, ')
          ..write('subject: $subject, ')
          ..write('body: $body, ')
          ..write('resolvedChannel: $resolvedChannel, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentPromptDraftsTableTable extends AgentPromptDraftsTable
    with TableInfo<$AgentPromptDraftsTableTable, AgentPromptDraftsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentPromptDraftsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contextMeta = const VerificationMeta(
    'context',
  );
  @override
  late final GeneratedColumn<String> context = GeneratedColumn<String>(
    'context',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _requirementsJsonMeta = const VerificationMeta(
    'requirementsJson',
  );
  @override
  late final GeneratedColumn<String> requirementsJson = GeneratedColumn<String>(
    'requirements_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _constraintsJsonMeta = const VerificationMeta(
    'constraintsJson',
  );
  @override
  late final GeneratedColumn<String> constraintsJson = GeneratedColumn<String>(
    'constraints_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _acceptanceCriteriaJsonMeta =
      const VerificationMeta('acceptanceCriteriaJson');
  @override
  late final GeneratedColumn<String> acceptanceCriteriaJson =
      GeneratedColumn<String>(
        'acceptance_criteria_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _relevantFilesJsonMeta = const VerificationMeta(
    'relevantFilesJson',
  );
  @override
  late final GeneratedColumn<String> relevantFilesJson =
      GeneratedColumn<String>(
        'relevant_files_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _nonGoalsJsonMeta = const VerificationMeta(
    'nonGoalsJson',
  );
  @override
  late final GeneratedColumn<String> nonGoalsJson = GeneratedColumn<String>(
    'non_goals_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _openQuestionsJsonMeta = const VerificationMeta(
    'openQuestionsJson',
  );
  @override
  late final GeneratedColumn<String> openQuestionsJson =
      GeneratedColumn<String>(
        'open_questions_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    goal,
    context,
    requirementsJson,
    constraintsJson,
    acceptanceCriteriaJson,
    relevantFilesJson,
    nonGoalsJson,
    openQuestionsJson,
    confidence,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_prompt_drafts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgentPromptDraftsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('context')) {
      context.handle(
        _contextMeta,
        this.context.isAcceptableOrUnknown(data['context']!, _contextMeta),
      );
    } else if (isInserting) {
      context.missing(_contextMeta);
    }
    if (data.containsKey('requirements_json')) {
      context.handle(
        _requirementsJsonMeta,
        requirementsJson.isAcceptableOrUnknown(
          data['requirements_json']!,
          _requirementsJsonMeta,
        ),
      );
    }
    if (data.containsKey('constraints_json')) {
      context.handle(
        _constraintsJsonMeta,
        constraintsJson.isAcceptableOrUnknown(
          data['constraints_json']!,
          _constraintsJsonMeta,
        ),
      );
    }
    if (data.containsKey('acceptance_criteria_json')) {
      context.handle(
        _acceptanceCriteriaJsonMeta,
        acceptanceCriteriaJson.isAcceptableOrUnknown(
          data['acceptance_criteria_json']!,
          _acceptanceCriteriaJsonMeta,
        ),
      );
    }
    if (data.containsKey('relevant_files_json')) {
      context.handle(
        _relevantFilesJsonMeta,
        relevantFilesJson.isAcceptableOrUnknown(
          data['relevant_files_json']!,
          _relevantFilesJsonMeta,
        ),
      );
    }
    if (data.containsKey('non_goals_json')) {
      context.handle(
        _nonGoalsJsonMeta,
        nonGoalsJson.isAcceptableOrUnknown(
          data['non_goals_json']!,
          _nonGoalsJsonMeta,
        ),
      );
    }
    if (data.containsKey('open_questions_json')) {
      context.handle(
        _openQuestionsJsonMeta,
        openQuestionsJson.isAcceptableOrUnknown(
          data['open_questions_json']!,
          _openQuestionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentPromptDraftsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentPromptDraftsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      context: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context'],
      )!,
      requirementsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requirements_json'],
      )!,
      constraintsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}constraints_json'],
      )!,
      acceptanceCriteriaJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}acceptance_criteria_json'],
      )!,
      relevantFilesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relevant_files_json'],
      )!,
      nonGoalsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}non_goals_json'],
      )!,
      openQuestionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_questions_json'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AgentPromptDraftsTableTable createAlias(String alias) {
    return $AgentPromptDraftsTableTable(attachedDatabase, alias);
  }
}

class AgentPromptDraftsTableData extends DataClass
    implements Insertable<AgentPromptDraftsTableData> {
  final String id;
  final String noteId;
  final String goal;
  final String context;
  final String requirementsJson;
  final String constraintsJson;
  final String acceptanceCriteriaJson;
  final String relevantFilesJson;
  final String nonGoalsJson;
  final String openQuestionsJson;
  final double confidence;
  final String status;
  final int createdAt;
  const AgentPromptDraftsTableData({
    required this.id,
    required this.noteId,
    required this.goal,
    required this.context,
    required this.requirementsJson,
    required this.constraintsJson,
    required this.acceptanceCriteriaJson,
    required this.relevantFilesJson,
    required this.nonGoalsJson,
    required this.openQuestionsJson,
    required this.confidence,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['goal'] = Variable<String>(goal);
    map['context'] = Variable<String>(context);
    map['requirements_json'] = Variable<String>(requirementsJson);
    map['constraints_json'] = Variable<String>(constraintsJson);
    map['acceptance_criteria_json'] = Variable<String>(acceptanceCriteriaJson);
    map['relevant_files_json'] = Variable<String>(relevantFilesJson);
    map['non_goals_json'] = Variable<String>(nonGoalsJson);
    map['open_questions_json'] = Variable<String>(openQuestionsJson);
    map['confidence'] = Variable<double>(confidence);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AgentPromptDraftsTableCompanion toCompanion(bool nullToAbsent) {
    return AgentPromptDraftsTableCompanion(
      id: Value(id),
      noteId: Value(noteId),
      goal: Value(goal),
      context: Value(context),
      requirementsJson: Value(requirementsJson),
      constraintsJson: Value(constraintsJson),
      acceptanceCriteriaJson: Value(acceptanceCriteriaJson),
      relevantFilesJson: Value(relevantFilesJson),
      nonGoalsJson: Value(nonGoalsJson),
      openQuestionsJson: Value(openQuestionsJson),
      confidence: Value(confidence),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory AgentPromptDraftsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentPromptDraftsTableData(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      goal: serializer.fromJson<String>(json['goal']),
      context: serializer.fromJson<String>(json['context']),
      requirementsJson: serializer.fromJson<String>(json['requirementsJson']),
      constraintsJson: serializer.fromJson<String>(json['constraintsJson']),
      acceptanceCriteriaJson: serializer.fromJson<String>(
        json['acceptanceCriteriaJson'],
      ),
      relevantFilesJson: serializer.fromJson<String>(json['relevantFilesJson']),
      nonGoalsJson: serializer.fromJson<String>(json['nonGoalsJson']),
      openQuestionsJson: serializer.fromJson<String>(json['openQuestionsJson']),
      confidence: serializer.fromJson<double>(json['confidence']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'goal': serializer.toJson<String>(goal),
      'context': serializer.toJson<String>(context),
      'requirementsJson': serializer.toJson<String>(requirementsJson),
      'constraintsJson': serializer.toJson<String>(constraintsJson),
      'acceptanceCriteriaJson': serializer.toJson<String>(
        acceptanceCriteriaJson,
      ),
      'relevantFilesJson': serializer.toJson<String>(relevantFilesJson),
      'nonGoalsJson': serializer.toJson<String>(nonGoalsJson),
      'openQuestionsJson': serializer.toJson<String>(openQuestionsJson),
      'confidence': serializer.toJson<double>(confidence),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AgentPromptDraftsTableData copyWith({
    String? id,
    String? noteId,
    String? goal,
    String? context,
    String? requirementsJson,
    String? constraintsJson,
    String? acceptanceCriteriaJson,
    String? relevantFilesJson,
    String? nonGoalsJson,
    String? openQuestionsJson,
    double? confidence,
    String? status,
    int? createdAt,
  }) => AgentPromptDraftsTableData(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    goal: goal ?? this.goal,
    context: context ?? this.context,
    requirementsJson: requirementsJson ?? this.requirementsJson,
    constraintsJson: constraintsJson ?? this.constraintsJson,
    acceptanceCriteriaJson:
        acceptanceCriteriaJson ?? this.acceptanceCriteriaJson,
    relevantFilesJson: relevantFilesJson ?? this.relevantFilesJson,
    nonGoalsJson: nonGoalsJson ?? this.nonGoalsJson,
    openQuestionsJson: openQuestionsJson ?? this.openQuestionsJson,
    confidence: confidence ?? this.confidence,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  AgentPromptDraftsTableData copyWithCompanion(
    AgentPromptDraftsTableCompanion data,
  ) {
    return AgentPromptDraftsTableData(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      goal: data.goal.present ? data.goal.value : this.goal,
      context: data.context.present ? data.context.value : this.context,
      requirementsJson: data.requirementsJson.present
          ? data.requirementsJson.value
          : this.requirementsJson,
      constraintsJson: data.constraintsJson.present
          ? data.constraintsJson.value
          : this.constraintsJson,
      acceptanceCriteriaJson: data.acceptanceCriteriaJson.present
          ? data.acceptanceCriteriaJson.value
          : this.acceptanceCriteriaJson,
      relevantFilesJson: data.relevantFilesJson.present
          ? data.relevantFilesJson.value
          : this.relevantFilesJson,
      nonGoalsJson: data.nonGoalsJson.present
          ? data.nonGoalsJson.value
          : this.nonGoalsJson,
      openQuestionsJson: data.openQuestionsJson.present
          ? data.openQuestionsJson.value
          : this.openQuestionsJson,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentPromptDraftsTableData(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('goal: $goal, ')
          ..write('context: $context, ')
          ..write('requirementsJson: $requirementsJson, ')
          ..write('constraintsJson: $constraintsJson, ')
          ..write('acceptanceCriteriaJson: $acceptanceCriteriaJson, ')
          ..write('relevantFilesJson: $relevantFilesJson, ')
          ..write('nonGoalsJson: $nonGoalsJson, ')
          ..write('openQuestionsJson: $openQuestionsJson, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    noteId,
    goal,
    context,
    requirementsJson,
    constraintsJson,
    acceptanceCriteriaJson,
    relevantFilesJson,
    nonGoalsJson,
    openQuestionsJson,
    confidence,
    status,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentPromptDraftsTableData &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.goal == this.goal &&
          other.context == this.context &&
          other.requirementsJson == this.requirementsJson &&
          other.constraintsJson == this.constraintsJson &&
          other.acceptanceCriteriaJson == this.acceptanceCriteriaJson &&
          other.relevantFilesJson == this.relevantFilesJson &&
          other.nonGoalsJson == this.nonGoalsJson &&
          other.openQuestionsJson == this.openQuestionsJson &&
          other.confidence == this.confidence &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class AgentPromptDraftsTableCompanion
    extends UpdateCompanion<AgentPromptDraftsTableData> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<String> goal;
  final Value<String> context;
  final Value<String> requirementsJson;
  final Value<String> constraintsJson;
  final Value<String> acceptanceCriteriaJson;
  final Value<String> relevantFilesJson;
  final Value<String> nonGoalsJson;
  final Value<String> openQuestionsJson;
  final Value<double> confidence;
  final Value<String> status;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AgentPromptDraftsTableCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.goal = const Value.absent(),
    this.context = const Value.absent(),
    this.requirementsJson = const Value.absent(),
    this.constraintsJson = const Value.absent(),
    this.acceptanceCriteriaJson = const Value.absent(),
    this.relevantFilesJson = const Value.absent(),
    this.nonGoalsJson = const Value.absent(),
    this.openQuestionsJson = const Value.absent(),
    this.confidence = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentPromptDraftsTableCompanion.insert({
    required String id,
    required String noteId,
    required String goal,
    required String context,
    this.requirementsJson = const Value.absent(),
    this.constraintsJson = const Value.absent(),
    this.acceptanceCriteriaJson = const Value.absent(),
    this.relevantFilesJson = const Value.absent(),
    this.nonGoalsJson = const Value.absent(),
    this.openQuestionsJson = const Value.absent(),
    required double confidence,
    this.status = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       goal = Value(goal),
       context = Value(context),
       confidence = Value(confidence),
       createdAt = Value(createdAt);
  static Insertable<AgentPromptDraftsTableData> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<String>? goal,
    Expression<String>? context,
    Expression<String>? requirementsJson,
    Expression<String>? constraintsJson,
    Expression<String>? acceptanceCriteriaJson,
    Expression<String>? relevantFilesJson,
    Expression<String>? nonGoalsJson,
    Expression<String>? openQuestionsJson,
    Expression<double>? confidence,
    Expression<String>? status,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (goal != null) 'goal': goal,
      if (context != null) 'context': context,
      if (requirementsJson != null) 'requirements_json': requirementsJson,
      if (constraintsJson != null) 'constraints_json': constraintsJson,
      if (acceptanceCriteriaJson != null)
        'acceptance_criteria_json': acceptanceCriteriaJson,
      if (relevantFilesJson != null) 'relevant_files_json': relevantFilesJson,
      if (nonGoalsJson != null) 'non_goals_json': nonGoalsJson,
      if (openQuestionsJson != null) 'open_questions_json': openQuestionsJson,
      if (confidence != null) 'confidence': confidence,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentPromptDraftsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<String>? goal,
    Value<String>? context,
    Value<String>? requirementsJson,
    Value<String>? constraintsJson,
    Value<String>? acceptanceCriteriaJson,
    Value<String>? relevantFilesJson,
    Value<String>? nonGoalsJson,
    Value<String>? openQuestionsJson,
    Value<double>? confidence,
    Value<String>? status,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AgentPromptDraftsTableCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      goal: goal ?? this.goal,
      context: context ?? this.context,
      requirementsJson: requirementsJson ?? this.requirementsJson,
      constraintsJson: constraintsJson ?? this.constraintsJson,
      acceptanceCriteriaJson:
          acceptanceCriteriaJson ?? this.acceptanceCriteriaJson,
      relevantFilesJson: relevantFilesJson ?? this.relevantFilesJson,
      nonGoalsJson: nonGoalsJson ?? this.nonGoalsJson,
      openQuestionsJson: openQuestionsJson ?? this.openQuestionsJson,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (context.present) {
      map['context'] = Variable<String>(context.value);
    }
    if (requirementsJson.present) {
      map['requirements_json'] = Variable<String>(requirementsJson.value);
    }
    if (constraintsJson.present) {
      map['constraints_json'] = Variable<String>(constraintsJson.value);
    }
    if (acceptanceCriteriaJson.present) {
      map['acceptance_criteria_json'] = Variable<String>(
        acceptanceCriteriaJson.value,
      );
    }
    if (relevantFilesJson.present) {
      map['relevant_files_json'] = Variable<String>(relevantFilesJson.value);
    }
    if (nonGoalsJson.present) {
      map['non_goals_json'] = Variable<String>(nonGoalsJson.value);
    }
    if (openQuestionsJson.present) {
      map['open_questions_json'] = Variable<String>(openQuestionsJson.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentPromptDraftsTableCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('goal: $goal, ')
          ..write('context: $context, ')
          ..write('requirementsJson: $requirementsJson, ')
          ..write('constraintsJson: $constraintsJson, ')
          ..write('acceptanceCriteriaJson: $acceptanceCriteriaJson, ')
          ..write('relevantFilesJson: $relevantFilesJson, ')
          ..write('nonGoalsJson: $nonGoalsJson, ')
          ..write('openQuestionsJson: $openQuestionsJson, ')
          ..write('confidence: $confidence, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InterpretationFeedbackTableTable extends InterpretationFeedbackTable
    with
        TableInfo<
          $InterpretationFeedbackTableTable,
          InterpretationFeedbackTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InterpretationFeedbackTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctedFieldMeta = const VerificationMeta(
    'correctedField',
  );
  @override
  late final GeneratedColumn<String> correctedField = GeneratedColumn<String>(
    'corrected_field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _originalValueMeta = const VerificationMeta(
    'originalValue',
  );
  @override
  late final GeneratedColumn<String> originalValue = GeneratedColumn<String>(
    'original_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correctedValueMeta = const VerificationMeta(
    'correctedValue',
  );
  @override
  late final GeneratedColumn<String> correctedValue = GeneratedColumn<String>(
    'corrected_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    correctedField,
    originalValue,
    correctedValue,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'interpretation_feedback';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterpretationFeedbackTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('corrected_field')) {
      context.handle(
        _correctedFieldMeta,
        correctedField.isAcceptableOrUnknown(
          data['corrected_field']!,
          _correctedFieldMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctedFieldMeta);
    }
    if (data.containsKey('original_value')) {
      context.handle(
        _originalValueMeta,
        originalValue.isAcceptableOrUnknown(
          data['original_value']!,
          _originalValueMeta,
        ),
      );
    }
    if (data.containsKey('corrected_value')) {
      context.handle(
        _correctedValueMeta,
        correctedValue.isAcceptableOrUnknown(
          data['corrected_value']!,
          _correctedValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctedValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterpretationFeedbackTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterpretationFeedbackTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      correctedField: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrected_field'],
      )!,
      originalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_value'],
      ),
      correctedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corrected_value'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InterpretationFeedbackTableTable createAlias(String alias) {
    return $InterpretationFeedbackTableTable(attachedDatabase, alias);
  }
}

class InterpretationFeedbackTableData extends DataClass
    implements Insertable<InterpretationFeedbackTableData> {
  final String id;
  final String noteId;
  final String correctedField;
  final String? originalValue;
  final String correctedValue;
  final int createdAt;
  const InterpretationFeedbackTableData({
    required this.id,
    required this.noteId,
    required this.correctedField,
    this.originalValue,
    required this.correctedValue,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['corrected_field'] = Variable<String>(correctedField);
    if (!nullToAbsent || originalValue != null) {
      map['original_value'] = Variable<String>(originalValue);
    }
    map['corrected_value'] = Variable<String>(correctedValue);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  InterpretationFeedbackTableCompanion toCompanion(bool nullToAbsent) {
    return InterpretationFeedbackTableCompanion(
      id: Value(id),
      noteId: Value(noteId),
      correctedField: Value(correctedField),
      originalValue: originalValue == null && nullToAbsent
          ? const Value.absent()
          : Value(originalValue),
      correctedValue: Value(correctedValue),
      createdAt: Value(createdAt),
    );
  }

  factory InterpretationFeedbackTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterpretationFeedbackTableData(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      correctedField: serializer.fromJson<String>(json['correctedField']),
      originalValue: serializer.fromJson<String?>(json['originalValue']),
      correctedValue: serializer.fromJson<String>(json['correctedValue']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'correctedField': serializer.toJson<String>(correctedField),
      'originalValue': serializer.toJson<String?>(originalValue),
      'correctedValue': serializer.toJson<String>(correctedValue),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  InterpretationFeedbackTableData copyWith({
    String? id,
    String? noteId,
    String? correctedField,
    Value<String?> originalValue = const Value.absent(),
    String? correctedValue,
    int? createdAt,
  }) => InterpretationFeedbackTableData(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    correctedField: correctedField ?? this.correctedField,
    originalValue: originalValue.present
        ? originalValue.value
        : this.originalValue,
    correctedValue: correctedValue ?? this.correctedValue,
    createdAt: createdAt ?? this.createdAt,
  );
  InterpretationFeedbackTableData copyWithCompanion(
    InterpretationFeedbackTableCompanion data,
  ) {
    return InterpretationFeedbackTableData(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      correctedField: data.correctedField.present
          ? data.correctedField.value
          : this.correctedField,
      originalValue: data.originalValue.present
          ? data.originalValue.value
          : this.originalValue,
      correctedValue: data.correctedValue.present
          ? data.correctedValue.value
          : this.correctedValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterpretationFeedbackTableData(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('correctedField: $correctedField, ')
          ..write('originalValue: $originalValue, ')
          ..write('correctedValue: $correctedValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    noteId,
    correctedField,
    originalValue,
    correctedValue,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterpretationFeedbackTableData &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.correctedField == this.correctedField &&
          other.originalValue == this.originalValue &&
          other.correctedValue == this.correctedValue &&
          other.createdAt == this.createdAt);
}

class InterpretationFeedbackTableCompanion
    extends UpdateCompanion<InterpretationFeedbackTableData> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<String> correctedField;
  final Value<String?> originalValue;
  final Value<String> correctedValue;
  final Value<int> createdAt;
  final Value<int> rowid;
  const InterpretationFeedbackTableCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.correctedField = const Value.absent(),
    this.originalValue = const Value.absent(),
    this.correctedValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterpretationFeedbackTableCompanion.insert({
    required String id,
    required String noteId,
    required String correctedField,
    this.originalValue = const Value.absent(),
    required String correctedValue,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       correctedField = Value(correctedField),
       correctedValue = Value(correctedValue),
       createdAt = Value(createdAt);
  static Insertable<InterpretationFeedbackTableData> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<String>? correctedField,
    Expression<String>? originalValue,
    Expression<String>? correctedValue,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (correctedField != null) 'corrected_field': correctedField,
      if (originalValue != null) 'original_value': originalValue,
      if (correctedValue != null) 'corrected_value': correctedValue,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterpretationFeedbackTableCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<String>? correctedField,
    Value<String?>? originalValue,
    Value<String>? correctedValue,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return InterpretationFeedbackTableCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      correctedField: correctedField ?? this.correctedField,
      originalValue: originalValue ?? this.originalValue,
      correctedValue: correctedValue ?? this.correctedValue,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (correctedField.present) {
      map['corrected_field'] = Variable<String>(correctedField.value);
    }
    if (originalValue.present) {
      map['original_value'] = Variable<String>(originalValue.value);
    }
    if (correctedValue.present) {
      map['corrected_value'] = Variable<String>(correctedValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterpretationFeedbackTableCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('correctedField: $correctedField, ')
          ..write('originalValue: $originalValue, ')
          ..write('correctedValue: $correctedValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AiDatabase extends GeneratedDatabase {
  _$AiDatabase(QueryExecutor e) : super(e);
  $AiDatabaseManager get managers => $AiDatabaseManager(this);
  late final $AiNoteAnalysisTableTable aiNoteAnalysisTable =
      $AiNoteAnalysisTableTable(this);
  late final $TranscriptSegmentsTableTable transcriptSegmentsTable =
      $TranscriptSegmentsTableTable(this);
  late final $DocumentsTableTable documentsTable = $DocumentsTableTable(this);
  late final $DocumentChunksTableTable documentChunksTable =
      $DocumentChunksTableTable(this);
  late final $SuggestedActionsTableTable suggestedActionsTable =
      $SuggestedActionsTableTable(this);
  late final $PersonalMemoriesTableTable personalMemoriesTable =
      $PersonalMemoriesTableTable(this);
  late final $AiJobsTableTable aiJobsTable = $AiJobsTableTable(this);
  late final $ModelInstallationsTableTable modelInstallationsTable =
      $ModelInstallationsTableTable(this);
  late final $NoteEmbeddingsTableTable noteEmbeddingsTable =
      $NoteEmbeddingsTableTable(this);
  late final $NoteRelationshipsTableTable noteRelationshipsTable =
      $NoteRelationshipsTableTable(this);
  late final $TopicClustersTableTable topicClustersTable =
      $TopicClustersTableTable(this);
  late final $TopicMembershipsTableTable topicMembershipsTable =
      $TopicMembershipsTableTable(this);
  late final $NoteInterpretationsTableTable noteInterpretationsTable =
      $NoteInterpretationsTableTable(this);
  late final $KnownProjectsTableTable knownProjectsTable =
      $KnownProjectsTableTable(this);
  late final $KnownApplicationsTableTable knownApplicationsTable =
      $KnownApplicationsTableTable(this);
  late final $DraftCommunicationsTableTable draftCommunicationsTable =
      $DraftCommunicationsTableTable(this);
  late final $AgentPromptDraftsTableTable agentPromptDraftsTable =
      $AgentPromptDraftsTableTable(this);
  late final $InterpretationFeedbackTableTable interpretationFeedbackTable =
      $InterpretationFeedbackTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    aiNoteAnalysisTable,
    transcriptSegmentsTable,
    documentsTable,
    documentChunksTable,
    suggestedActionsTable,
    personalMemoriesTable,
    aiJobsTable,
    modelInstallationsTable,
    noteEmbeddingsTable,
    noteRelationshipsTable,
    topicClustersTable,
    topicMembershipsTable,
    noteInterpretationsTable,
    knownProjectsTable,
    knownApplicationsTable,
    draftCommunicationsTable,
    agentPromptDraftsTable,
    interpretationFeedbackTable,
  ];
}

typedef $$AiNoteAnalysisTableTableCreateCompanionBuilder =
    AiNoteAnalysisTableCompanion Function({
      required String noteId,
      required String modelVersion,
      required String sourceHash,
      required String detectedLanguage,
      Value<String?> generatedTitle,
      Value<String?> summary,
      Value<String?> englishRetrievalSummary,
      Value<String?> topicsJson,
      Value<String?> peopleJson,
      Value<String?> placesJson,
      Value<String?> suggestedTagsJson,
      Value<String?> actionItemsJson,
      Value<String?> eventsJson,
      Value<String?> remindersJson,
      Value<String?> travelDetailsJson,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AiNoteAnalysisTableTableUpdateCompanionBuilder =
    AiNoteAnalysisTableCompanion Function({
      Value<String> noteId,
      Value<String> modelVersion,
      Value<String> sourceHash,
      Value<String> detectedLanguage,
      Value<String?> generatedTitle,
      Value<String?> summary,
      Value<String?> englishRetrievalSummary,
      Value<String?> topicsJson,
      Value<String?> peopleJson,
      Value<String?> placesJson,
      Value<String?> suggestedTagsJson,
      Value<String?> actionItemsJson,
      Value<String?> eventsJson,
      Value<String?> remindersJson,
      Value<String?> travelDetailsJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AiNoteAnalysisTableTableFilterComposer
    extends Composer<_$AiDatabase, $AiNoteAnalysisTableTable> {
  $$AiNoteAnalysisTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedLanguage => $composableBuilder(
    column: $table.detectedLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get generatedTitle => $composableBuilder(
    column: $table.generatedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishRetrievalSummary => $composableBuilder(
    column: $table.englishRetrievalSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get peopleJson => $composableBuilder(
    column: $table.peopleJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get placesJson => $composableBuilder(
    column: $table.placesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestedTagsJson => $composableBuilder(
    column: $table.suggestedTagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionItemsJson => $composableBuilder(
    column: $table.actionItemsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventsJson => $composableBuilder(
    column: $table.eventsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remindersJson => $composableBuilder(
    column: $table.remindersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get travelDetailsJson => $composableBuilder(
    column: $table.travelDetailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiNoteAnalysisTableTableOrderingComposer
    extends Composer<_$AiDatabase, $AiNoteAnalysisTableTable> {
  $$AiNoteAnalysisTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedLanguage => $composableBuilder(
    column: $table.detectedLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get generatedTitle => $composableBuilder(
    column: $table.generatedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishRetrievalSummary => $composableBuilder(
    column: $table.englishRetrievalSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get peopleJson => $composableBuilder(
    column: $table.peopleJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get placesJson => $composableBuilder(
    column: $table.placesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestedTagsJson => $composableBuilder(
    column: $table.suggestedTagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionItemsJson => $composableBuilder(
    column: $table.actionItemsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventsJson => $composableBuilder(
    column: $table.eventsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remindersJson => $composableBuilder(
    column: $table.remindersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get travelDetailsJson => $composableBuilder(
    column: $table.travelDetailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiNoteAnalysisTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $AiNoteAnalysisTableTable> {
  $$AiNoteAnalysisTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedLanguage => $composableBuilder(
    column: $table.detectedLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get generatedTitle => $composableBuilder(
    column: $table.generatedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get englishRetrievalSummary => $composableBuilder(
    column: $table.englishRetrievalSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get topicsJson => $composableBuilder(
    column: $table.topicsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get peopleJson => $composableBuilder(
    column: $table.peopleJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get placesJson => $composableBuilder(
    column: $table.placesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get suggestedTagsJson => $composableBuilder(
    column: $table.suggestedTagsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionItemsJson => $composableBuilder(
    column: $table.actionItemsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventsJson => $composableBuilder(
    column: $table.eventsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remindersJson => $composableBuilder(
    column: $table.remindersJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get travelDetailsJson => $composableBuilder(
    column: $table.travelDetailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AiNoteAnalysisTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $AiNoteAnalysisTableTable,
          AiNoteAnalysisTableData,
          $$AiNoteAnalysisTableTableFilterComposer,
          $$AiNoteAnalysisTableTableOrderingComposer,
          $$AiNoteAnalysisTableTableAnnotationComposer,
          $$AiNoteAnalysisTableTableCreateCompanionBuilder,
          $$AiNoteAnalysisTableTableUpdateCompanionBuilder,
          (
            AiNoteAnalysisTableData,
            BaseReferences<
              _$AiDatabase,
              $AiNoteAnalysisTableTable,
              AiNoteAnalysisTableData
            >,
          ),
          AiNoteAnalysisTableData,
          PrefetchHooks Function()
        > {
  $$AiNoteAnalysisTableTableTableManager(
    _$AiDatabase db,
    $AiNoteAnalysisTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiNoteAnalysisTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiNoteAnalysisTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AiNoteAnalysisTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> noteId = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> sourceHash = const Value.absent(),
                Value<String> detectedLanguage = const Value.absent(),
                Value<String?> generatedTitle = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> englishRetrievalSummary = const Value.absent(),
                Value<String?> topicsJson = const Value.absent(),
                Value<String?> peopleJson = const Value.absent(),
                Value<String?> placesJson = const Value.absent(),
                Value<String?> suggestedTagsJson = const Value.absent(),
                Value<String?> actionItemsJson = const Value.absent(),
                Value<String?> eventsJson = const Value.absent(),
                Value<String?> remindersJson = const Value.absent(),
                Value<String?> travelDetailsJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiNoteAnalysisTableCompanion(
                noteId: noteId,
                modelVersion: modelVersion,
                sourceHash: sourceHash,
                detectedLanguage: detectedLanguage,
                generatedTitle: generatedTitle,
                summary: summary,
                englishRetrievalSummary: englishRetrievalSummary,
                topicsJson: topicsJson,
                peopleJson: peopleJson,
                placesJson: placesJson,
                suggestedTagsJson: suggestedTagsJson,
                actionItemsJson: actionItemsJson,
                eventsJson: eventsJson,
                remindersJson: remindersJson,
                travelDetailsJson: travelDetailsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String noteId,
                required String modelVersion,
                required String sourceHash,
                required String detectedLanguage,
                Value<String?> generatedTitle = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String?> englishRetrievalSummary = const Value.absent(),
                Value<String?> topicsJson = const Value.absent(),
                Value<String?> peopleJson = const Value.absent(),
                Value<String?> placesJson = const Value.absent(),
                Value<String?> suggestedTagsJson = const Value.absent(),
                Value<String?> actionItemsJson = const Value.absent(),
                Value<String?> eventsJson = const Value.absent(),
                Value<String?> remindersJson = const Value.absent(),
                Value<String?> travelDetailsJson = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AiNoteAnalysisTableCompanion.insert(
                noteId: noteId,
                modelVersion: modelVersion,
                sourceHash: sourceHash,
                detectedLanguage: detectedLanguage,
                generatedTitle: generatedTitle,
                summary: summary,
                englishRetrievalSummary: englishRetrievalSummary,
                topicsJson: topicsJson,
                peopleJson: peopleJson,
                placesJson: placesJson,
                suggestedTagsJson: suggestedTagsJson,
                actionItemsJson: actionItemsJson,
                eventsJson: eventsJson,
                remindersJson: remindersJson,
                travelDetailsJson: travelDetailsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiNoteAnalysisTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $AiNoteAnalysisTableTable,
      AiNoteAnalysisTableData,
      $$AiNoteAnalysisTableTableFilterComposer,
      $$AiNoteAnalysisTableTableOrderingComposer,
      $$AiNoteAnalysisTableTableAnnotationComposer,
      $$AiNoteAnalysisTableTableCreateCompanionBuilder,
      $$AiNoteAnalysisTableTableUpdateCompanionBuilder,
      (
        AiNoteAnalysisTableData,
        BaseReferences<
          _$AiDatabase,
          $AiNoteAnalysisTableTable,
          AiNoteAnalysisTableData
        >,
      ),
      AiNoteAnalysisTableData,
      PrefetchHooks Function()
    >;
typedef $$TranscriptSegmentsTableTableCreateCompanionBuilder =
    TranscriptSegmentsTableCompanion Function({
      required String id,
      required String noteId,
      required int startMs,
      required int endMs,
      required String language,
      required String segmentText,
      required double confidence,
      Value<String?> speakerLabel,
      required int sequenceNumber,
      Value<int> rowid,
    });
typedef $$TranscriptSegmentsTableTableUpdateCompanionBuilder =
    TranscriptSegmentsTableCompanion Function({
      Value<String> id,
      Value<String> noteId,
      Value<int> startMs,
      Value<int> endMs,
      Value<String> language,
      Value<String> segmentText,
      Value<double> confidence,
      Value<String?> speakerLabel,
      Value<int> sequenceNumber,
      Value<int> rowid,
    });

class $$TranscriptSegmentsTableTableFilterComposer
    extends Composer<_$AiDatabase, $TranscriptSegmentsTableTable> {
  $$TranscriptSegmentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get segmentText => $composableBuilder(
    column: $table.segmentText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get speakerLabel => $composableBuilder(
    column: $table.speakerLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TranscriptSegmentsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $TranscriptSegmentsTableTable> {
  $$TranscriptSegmentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMs => $composableBuilder(
    column: $table.startMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMs => $composableBuilder(
    column: $table.endMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get segmentText => $composableBuilder(
    column: $table.segmentText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get speakerLabel => $composableBuilder(
    column: $table.speakerLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TranscriptSegmentsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $TranscriptSegmentsTableTable> {
  $$TranscriptSegmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<int> get startMs =>
      $composableBuilder(column: $table.startMs, builder: (column) => column);

  GeneratedColumn<int> get endMs =>
      $composableBuilder(column: $table.endMs, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get segmentText => $composableBuilder(
    column: $table.segmentText,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get speakerLabel => $composableBuilder(
    column: $table.speakerLabel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );
}

class $$TranscriptSegmentsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $TranscriptSegmentsTableTable,
          TranscriptSegmentsTableData,
          $$TranscriptSegmentsTableTableFilterComposer,
          $$TranscriptSegmentsTableTableOrderingComposer,
          $$TranscriptSegmentsTableTableAnnotationComposer,
          $$TranscriptSegmentsTableTableCreateCompanionBuilder,
          $$TranscriptSegmentsTableTableUpdateCompanionBuilder,
          (
            TranscriptSegmentsTableData,
            BaseReferences<
              _$AiDatabase,
              $TranscriptSegmentsTableTable,
              TranscriptSegmentsTableData
            >,
          ),
          TranscriptSegmentsTableData,
          PrefetchHooks Function()
        > {
  $$TranscriptSegmentsTableTableTableManager(
    _$AiDatabase db,
    $TranscriptSegmentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TranscriptSegmentsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TranscriptSegmentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TranscriptSegmentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<int> startMs = const Value.absent(),
                Value<int> endMs = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String> segmentText = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String?> speakerLabel = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TranscriptSegmentsTableCompanion(
                id: id,
                noteId: noteId,
                startMs: startMs,
                endMs: endMs,
                language: language,
                segmentText: segmentText,
                confidence: confidence,
                speakerLabel: speakerLabel,
                sequenceNumber: sequenceNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required int startMs,
                required int endMs,
                required String language,
                required String segmentText,
                required double confidence,
                Value<String?> speakerLabel = const Value.absent(),
                required int sequenceNumber,
                Value<int> rowid = const Value.absent(),
              }) => TranscriptSegmentsTableCompanion.insert(
                id: id,
                noteId: noteId,
                startMs: startMs,
                endMs: endMs,
                language: language,
                segmentText: segmentText,
                confidence: confidence,
                speakerLabel: speakerLabel,
                sequenceNumber: sequenceNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TranscriptSegmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $TranscriptSegmentsTableTable,
      TranscriptSegmentsTableData,
      $$TranscriptSegmentsTableTableFilterComposer,
      $$TranscriptSegmentsTableTableOrderingComposer,
      $$TranscriptSegmentsTableTableAnnotationComposer,
      $$TranscriptSegmentsTableTableCreateCompanionBuilder,
      $$TranscriptSegmentsTableTableUpdateCompanionBuilder,
      (
        TranscriptSegmentsTableData,
        BaseReferences<
          _$AiDatabase,
          $TranscriptSegmentsTableTable,
          TranscriptSegmentsTableData
        >,
      ),
      TranscriptSegmentsTableData,
      PrefetchHooks Function()
    >;
typedef $$DocumentsTableTableCreateCompanionBuilder =
    DocumentsTableCompanion Function({
      required String id,
      Value<String?> notebookId,
      required String localPath,
      required String sha256,
      required String title,
      Value<int?> pageCount,
      Value<String> processingState,
      Value<String?> processingError,
      required int importedAt,
      Value<int> rowid,
    });
typedef $$DocumentsTableTableUpdateCompanionBuilder =
    DocumentsTableCompanion Function({
      Value<String> id,
      Value<String?> notebookId,
      Value<String> localPath,
      Value<String> sha256,
      Value<String> title,
      Value<int?> pageCount,
      Value<String> processingState,
      Value<String?> processingError,
      Value<int> importedAt,
      Value<int> rowid,
    });

class $$DocumentsTableTableFilterComposer
    extends Composer<_$AiDatabase, $DocumentsTableTable> {
  $$DocumentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processingState => $composableBuilder(
    column: $table.processingState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get processingError => $composableBuilder(
    column: $table.processingError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $DocumentsTableTable> {
  $$DocumentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processingState => $composableBuilder(
    column: $table.processingState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get processingError => $composableBuilder(
    column: $table.processingError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $DocumentsTableTable> {
  $$DocumentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get notebookId => $composableBuilder(
    column: $table.notebookId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get processingState => $composableBuilder(
    column: $table.processingState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get processingError => $composableBuilder(
    column: $table.processingError,
    builder: (column) => column,
  );

  GeneratedColumn<int> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );
}

class $$DocumentsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $DocumentsTableTable,
          DocumentsTableData,
          $$DocumentsTableTableFilterComposer,
          $$DocumentsTableTableOrderingComposer,
          $$DocumentsTableTableAnnotationComposer,
          $$DocumentsTableTableCreateCompanionBuilder,
          $$DocumentsTableTableUpdateCompanionBuilder,
          (
            DocumentsTableData,
            BaseReferences<
              _$AiDatabase,
              $DocumentsTableTable,
              DocumentsTableData
            >,
          ),
          DocumentsTableData,
          PrefetchHooks Function()
        > {
  $$DocumentsTableTableTableManager(_$AiDatabase db, $DocumentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> notebookId = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> sha256 = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String> processingState = const Value.absent(),
                Value<String?> processingError = const Value.absent(),
                Value<int> importedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentsTableCompanion(
                id: id,
                notebookId: notebookId,
                localPath: localPath,
                sha256: sha256,
                title: title,
                pageCount: pageCount,
                processingState: processingState,
                processingError: processingError,
                importedAt: importedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> notebookId = const Value.absent(),
                required String localPath,
                required String sha256,
                required String title,
                Value<int?> pageCount = const Value.absent(),
                Value<String> processingState = const Value.absent(),
                Value<String?> processingError = const Value.absent(),
                required int importedAt,
                Value<int> rowid = const Value.absent(),
              }) => DocumentsTableCompanion.insert(
                id: id,
                notebookId: notebookId,
                localPath: localPath,
                sha256: sha256,
                title: title,
                pageCount: pageCount,
                processingState: processingState,
                processingError: processingError,
                importedAt: importedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $DocumentsTableTable,
      DocumentsTableData,
      $$DocumentsTableTableFilterComposer,
      $$DocumentsTableTableOrderingComposer,
      $$DocumentsTableTableAnnotationComposer,
      $$DocumentsTableTableCreateCompanionBuilder,
      $$DocumentsTableTableUpdateCompanionBuilder,
      (
        DocumentsTableData,
        BaseReferences<_$AiDatabase, $DocumentsTableTable, DocumentsTableData>,
      ),
      DocumentsTableData,
      PrefetchHooks Function()
    >;
typedef $$DocumentChunksTableTableCreateCompanionBuilder =
    DocumentChunksTableCompanion Function({
      required String id,
      required String documentId,
      required int pageStart,
      required int pageEnd,
      Value<String?> chapter,
      required String originalText,
      Value<String?> englishRetrievalText,
      Value<String?> keywords,
      Value<int?> tokenEstimate,
      required int sourceOrder,
      Value<int> rowid,
    });
typedef $$DocumentChunksTableTableUpdateCompanionBuilder =
    DocumentChunksTableCompanion Function({
      Value<String> id,
      Value<String> documentId,
      Value<int> pageStart,
      Value<int> pageEnd,
      Value<String?> chapter,
      Value<String> originalText,
      Value<String?> englishRetrievalText,
      Value<String?> keywords,
      Value<int?> tokenEstimate,
      Value<int> sourceOrder,
      Value<int> rowid,
    });

class $$DocumentChunksTableTableFilterComposer
    extends Composer<_$AiDatabase, $DocumentChunksTableTable> {
  $$DocumentChunksTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get englishRetrievalText => $composableBuilder(
    column: $table.englishRetrievalText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokenEstimate => $composableBuilder(
    column: $table.tokenEstimate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceOrder => $composableBuilder(
    column: $table.sourceOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DocumentChunksTableTableOrderingComposer
    extends Composer<_$AiDatabase, $DocumentChunksTableTable> {
  $$DocumentChunksTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageStart => $composableBuilder(
    column: $table.pageStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageEnd => $composableBuilder(
    column: $table.pageEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get englishRetrievalText => $composableBuilder(
    column: $table.englishRetrievalText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keywords => $composableBuilder(
    column: $table.keywords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokenEstimate => $composableBuilder(
    column: $table.tokenEstimate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceOrder => $composableBuilder(
    column: $table.sourceOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DocumentChunksTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $DocumentChunksTableTable> {
  $$DocumentChunksTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageStart =>
      $composableBuilder(column: $table.pageStart, builder: (column) => column);

  GeneratedColumn<int> get pageEnd =>
      $composableBuilder(column: $table.pageEnd, builder: (column) => column);

  GeneratedColumn<String> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<String> get originalText => $composableBuilder(
    column: $table.originalText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get englishRetrievalText => $composableBuilder(
    column: $table.englishRetrievalText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keywords =>
      $composableBuilder(column: $table.keywords, builder: (column) => column);

  GeneratedColumn<int> get tokenEstimate => $composableBuilder(
    column: $table.tokenEstimate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceOrder => $composableBuilder(
    column: $table.sourceOrder,
    builder: (column) => column,
  );
}

class $$DocumentChunksTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $DocumentChunksTableTable,
          DocumentChunksTableData,
          $$DocumentChunksTableTableFilterComposer,
          $$DocumentChunksTableTableOrderingComposer,
          $$DocumentChunksTableTableAnnotationComposer,
          $$DocumentChunksTableTableCreateCompanionBuilder,
          $$DocumentChunksTableTableUpdateCompanionBuilder,
          (
            DocumentChunksTableData,
            BaseReferences<
              _$AiDatabase,
              $DocumentChunksTableTable,
              DocumentChunksTableData
            >,
          ),
          DocumentChunksTableData,
          PrefetchHooks Function()
        > {
  $$DocumentChunksTableTableTableManager(
    _$AiDatabase db,
    $DocumentChunksTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentChunksTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentChunksTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DocumentChunksTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> documentId = const Value.absent(),
                Value<int> pageStart = const Value.absent(),
                Value<int> pageEnd = const Value.absent(),
                Value<String?> chapter = const Value.absent(),
                Value<String> originalText = const Value.absent(),
                Value<String?> englishRetrievalText = const Value.absent(),
                Value<String?> keywords = const Value.absent(),
                Value<int?> tokenEstimate = const Value.absent(),
                Value<int> sourceOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DocumentChunksTableCompanion(
                id: id,
                documentId: documentId,
                pageStart: pageStart,
                pageEnd: pageEnd,
                chapter: chapter,
                originalText: originalText,
                englishRetrievalText: englishRetrievalText,
                keywords: keywords,
                tokenEstimate: tokenEstimate,
                sourceOrder: sourceOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String documentId,
                required int pageStart,
                required int pageEnd,
                Value<String?> chapter = const Value.absent(),
                required String originalText,
                Value<String?> englishRetrievalText = const Value.absent(),
                Value<String?> keywords = const Value.absent(),
                Value<int?> tokenEstimate = const Value.absent(),
                required int sourceOrder,
                Value<int> rowid = const Value.absent(),
              }) => DocumentChunksTableCompanion.insert(
                id: id,
                documentId: documentId,
                pageStart: pageStart,
                pageEnd: pageEnd,
                chapter: chapter,
                originalText: originalText,
                englishRetrievalText: englishRetrievalText,
                keywords: keywords,
                tokenEstimate: tokenEstimate,
                sourceOrder: sourceOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DocumentChunksTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $DocumentChunksTableTable,
      DocumentChunksTableData,
      $$DocumentChunksTableTableFilterComposer,
      $$DocumentChunksTableTableOrderingComposer,
      $$DocumentChunksTableTableAnnotationComposer,
      $$DocumentChunksTableTableCreateCompanionBuilder,
      $$DocumentChunksTableTableUpdateCompanionBuilder,
      (
        DocumentChunksTableData,
        BaseReferences<
          _$AiDatabase,
          $DocumentChunksTableTable,
          DocumentChunksTableData
        >,
      ),
      DocumentChunksTableData,
      PrefetchHooks Function()
    >;
typedef $$SuggestedActionsTableTableCreateCompanionBuilder =
    SuggestedActionsTableCompanion Function({
      required String id,
      required String noteId,
      required String actionType,
      required String title,
      required String detailsJson,
      required String evidenceText,
      Value<int?> sourceStartMs,
      Value<int?> sourceEndMs,
      Value<int?> sourcePage,
      required double confidence,
      Value<String> status,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$SuggestedActionsTableTableUpdateCompanionBuilder =
    SuggestedActionsTableCompanion Function({
      Value<String> id,
      Value<String> noteId,
      Value<String> actionType,
      Value<String> title,
      Value<String> detailsJson,
      Value<String> evidenceText,
      Value<int?> sourceStartMs,
      Value<int?> sourceEndMs,
      Value<int?> sourcePage,
      Value<double> confidence,
      Value<String> status,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$SuggestedActionsTableTableFilterComposer
    extends Composer<_$AiDatabase, $SuggestedActionsTableTable> {
  $$SuggestedActionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get evidenceText => $composableBuilder(
    column: $table.evidenceText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceStartMs => $composableBuilder(
    column: $table.sourceStartMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourceEndMs => $composableBuilder(
    column: $table.sourceEndMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sourcePage => $composableBuilder(
    column: $table.sourcePage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuggestedActionsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $SuggestedActionsTableTable> {
  $$SuggestedActionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get evidenceText => $composableBuilder(
    column: $table.evidenceText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceStartMs => $composableBuilder(
    column: $table.sourceStartMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourceEndMs => $composableBuilder(
    column: $table.sourceEndMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sourcePage => $composableBuilder(
    column: $table.sourcePage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuggestedActionsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $SuggestedActionsTableTable> {
  $$SuggestedActionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get detailsJson => $composableBuilder(
    column: $table.detailsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get evidenceText => $composableBuilder(
    column: $table.evidenceText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceStartMs => $composableBuilder(
    column: $table.sourceStartMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourceEndMs => $composableBuilder(
    column: $table.sourceEndMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sourcePage => $composableBuilder(
    column: $table.sourcePage,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SuggestedActionsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $SuggestedActionsTableTable,
          SuggestedActionsTableData,
          $$SuggestedActionsTableTableFilterComposer,
          $$SuggestedActionsTableTableOrderingComposer,
          $$SuggestedActionsTableTableAnnotationComposer,
          $$SuggestedActionsTableTableCreateCompanionBuilder,
          $$SuggestedActionsTableTableUpdateCompanionBuilder,
          (
            SuggestedActionsTableData,
            BaseReferences<
              _$AiDatabase,
              $SuggestedActionsTableTable,
              SuggestedActionsTableData
            >,
          ),
          SuggestedActionsTableData,
          PrefetchHooks Function()
        > {
  $$SuggestedActionsTableTableTableManager(
    _$AiDatabase db,
    $SuggestedActionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuggestedActionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SuggestedActionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SuggestedActionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> detailsJson = const Value.absent(),
                Value<String> evidenceText = const Value.absent(),
                Value<int?> sourceStartMs = const Value.absent(),
                Value<int?> sourceEndMs = const Value.absent(),
                Value<int?> sourcePage = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuggestedActionsTableCompanion(
                id: id,
                noteId: noteId,
                actionType: actionType,
                title: title,
                detailsJson: detailsJson,
                evidenceText: evidenceText,
                sourceStartMs: sourceStartMs,
                sourceEndMs: sourceEndMs,
                sourcePage: sourcePage,
                confidence: confidence,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required String actionType,
                required String title,
                required String detailsJson,
                required String evidenceText,
                Value<int?> sourceStartMs = const Value.absent(),
                Value<int?> sourceEndMs = const Value.absent(),
                Value<int?> sourcePage = const Value.absent(),
                required double confidence,
                Value<String> status = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => SuggestedActionsTableCompanion.insert(
                id: id,
                noteId: noteId,
                actionType: actionType,
                title: title,
                detailsJson: detailsJson,
                evidenceText: evidenceText,
                sourceStartMs: sourceStartMs,
                sourceEndMs: sourceEndMs,
                sourcePage: sourcePage,
                confidence: confidence,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuggestedActionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $SuggestedActionsTableTable,
      SuggestedActionsTableData,
      $$SuggestedActionsTableTableFilterComposer,
      $$SuggestedActionsTableTableOrderingComposer,
      $$SuggestedActionsTableTableAnnotationComposer,
      $$SuggestedActionsTableTableCreateCompanionBuilder,
      $$SuggestedActionsTableTableUpdateCompanionBuilder,
      (
        SuggestedActionsTableData,
        BaseReferences<
          _$AiDatabase,
          $SuggestedActionsTableTable,
          SuggestedActionsTableData
        >,
      ),
      SuggestedActionsTableData,
      PrefetchHooks Function()
    >;
typedef $$PersonalMemoriesTableTableCreateCompanionBuilder =
    PersonalMemoriesTableCompanion Function({
      required String id,
      required String type,
      required String value,
      Value<String?> sourceNoteId,
      Value<int> userConfirmed,
      required int createdAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });
typedef $$PersonalMemoriesTableTableUpdateCompanionBuilder =
    PersonalMemoriesTableCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> value,
      Value<String?> sourceNoteId,
      Value<int> userConfirmed,
      Value<int> createdAt,
      Value<int?> deletedAt,
      Value<int> rowid,
    });

class $$PersonalMemoriesTableTableFilterComposer
    extends Composer<_$AiDatabase, $PersonalMemoriesTableTable> {
  $$PersonalMemoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceNoteId => $composableBuilder(
    column: $table.sourceNoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalMemoriesTableTableOrderingComposer
    extends Composer<_$AiDatabase, $PersonalMemoriesTableTable> {
  $$PersonalMemoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceNoteId => $composableBuilder(
    column: $table.sourceNoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalMemoriesTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $PersonalMemoriesTableTable> {
  $$PersonalMemoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get sourceNoteId => $composableBuilder(
    column: $table.sourceNoteId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get userConfirmed => $composableBuilder(
    column: $table.userConfirmed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$PersonalMemoriesTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $PersonalMemoriesTableTable,
          PersonalMemoriesTableData,
          $$PersonalMemoriesTableTableFilterComposer,
          $$PersonalMemoriesTableTableOrderingComposer,
          $$PersonalMemoriesTableTableAnnotationComposer,
          $$PersonalMemoriesTableTableCreateCompanionBuilder,
          $$PersonalMemoriesTableTableUpdateCompanionBuilder,
          (
            PersonalMemoriesTableData,
            BaseReferences<
              _$AiDatabase,
              $PersonalMemoriesTableTable,
              PersonalMemoriesTableData
            >,
          ),
          PersonalMemoriesTableData,
          PrefetchHooks Function()
        > {
  $$PersonalMemoriesTableTableTableManager(
    _$AiDatabase db,
    $PersonalMemoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalMemoriesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PersonalMemoriesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PersonalMemoriesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<String?> sourceNoteId = const Value.absent(),
                Value<int> userConfirmed = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalMemoriesTableCompanion(
                id: id,
                type: type,
                value: value,
                sourceNoteId: sourceNoteId,
                userConfirmed: userConfirmed,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String value,
                Value<String?> sourceNoteId = const Value.absent(),
                Value<int> userConfirmed = const Value.absent(),
                required int createdAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalMemoriesTableCompanion.insert(
                id: id,
                type: type,
                value: value,
                sourceNoteId: sourceNoteId,
                userConfirmed: userConfirmed,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalMemoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $PersonalMemoriesTableTable,
      PersonalMemoriesTableData,
      $$PersonalMemoriesTableTableFilterComposer,
      $$PersonalMemoriesTableTableOrderingComposer,
      $$PersonalMemoriesTableTableAnnotationComposer,
      $$PersonalMemoriesTableTableCreateCompanionBuilder,
      $$PersonalMemoriesTableTableUpdateCompanionBuilder,
      (
        PersonalMemoriesTableData,
        BaseReferences<
          _$AiDatabase,
          $PersonalMemoriesTableTable,
          PersonalMemoriesTableData
        >,
      ),
      PersonalMemoriesTableData,
      PrefetchHooks Function()
    >;
typedef $$AiJobsTableTableCreateCompanionBuilder =
    AiJobsTableCompanion Function({
      required String id,
      required String jobType,
      required String sourceId,
      required String sourceHash,
      required String modelVersion,
      Value<String> status,
      Value<double> progress,
      Value<int> attemptCount,
      Value<String?> errorCode,
      required int createdAt,
      Value<int?> startedAt,
      Value<int?> completedAt,
      Value<int> rowid,
    });
typedef $$AiJobsTableTableUpdateCompanionBuilder =
    AiJobsTableCompanion Function({
      Value<String> id,
      Value<String> jobType,
      Value<String> sourceId,
      Value<String> sourceHash,
      Value<String> modelVersion,
      Value<String> status,
      Value<double> progress,
      Value<int> attemptCount,
      Value<String?> errorCode,
      Value<int> createdAt,
      Value<int?> startedAt,
      Value<int?> completedAt,
      Value<int> rowid,
    });

class $$AiJobsTableTableFilterComposer
    extends Composer<_$AiDatabase, $AiJobsTableTable> {
  $$AiJobsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiJobsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $AiJobsTableTable> {
  $$AiJobsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobType => $composableBuilder(
    column: $table.jobType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceId => $composableBuilder(
    column: $table.sourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiJobsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $AiJobsTableTable> {
  $$AiJobsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get jobType =>
      $composableBuilder(column: $table.jobType, builder: (column) => column);

  GeneratedColumn<String> get sourceId =>
      $composableBuilder(column: $table.sourceId, builder: (column) => column);

  GeneratedColumn<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$AiJobsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $AiJobsTableTable,
          AiJobsTableData,
          $$AiJobsTableTableFilterComposer,
          $$AiJobsTableTableOrderingComposer,
          $$AiJobsTableTableAnnotationComposer,
          $$AiJobsTableTableCreateCompanionBuilder,
          $$AiJobsTableTableUpdateCompanionBuilder,
          (
            AiJobsTableData,
            BaseReferences<_$AiDatabase, $AiJobsTableTable, AiJobsTableData>,
          ),
          AiJobsTableData,
          PrefetchHooks Function()
        > {
  $$AiJobsTableTableTableManager(_$AiDatabase db, $AiJobsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiJobsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiJobsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiJobsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> jobType = const Value.absent(),
                Value<String> sourceId = const Value.absent(),
                Value<String> sourceHash = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiJobsTableCompanion(
                id: id,
                jobType: jobType,
                sourceId: sourceId,
                sourceHash: sourceHash,
                modelVersion: modelVersion,
                status: status,
                progress: progress,
                attemptCount: attemptCount,
                errorCode: errorCode,
                createdAt: createdAt,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String jobType,
                required String sourceId,
                required String sourceHash,
                required String modelVersion,
                Value<String> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                required int createdAt,
                Value<int?> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiJobsTableCompanion.insert(
                id: id,
                jobType: jobType,
                sourceId: sourceId,
                sourceHash: sourceHash,
                modelVersion: modelVersion,
                status: status,
                progress: progress,
                attemptCount: attemptCount,
                errorCode: errorCode,
                createdAt: createdAt,
                startedAt: startedAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiJobsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $AiJobsTableTable,
      AiJobsTableData,
      $$AiJobsTableTableFilterComposer,
      $$AiJobsTableTableOrderingComposer,
      $$AiJobsTableTableAnnotationComposer,
      $$AiJobsTableTableCreateCompanionBuilder,
      $$AiJobsTableTableUpdateCompanionBuilder,
      (
        AiJobsTableData,
        BaseReferences<_$AiDatabase, $AiJobsTableTable, AiJobsTableData>,
      ),
      AiJobsTableData,
      PrefetchHooks Function()
    >;
typedef $$ModelInstallationsTableTableCreateCompanionBuilder =
    ModelInstallationsTableCompanion Function({
      required String modelId,
      required String version,
      required String localPath,
      required String expectedSha256,
      Value<String?> actualSha256,
      required int sizeBytes,
      Value<String> installationState,
      Value<int?> installedAt,
      Value<int> rowid,
    });
typedef $$ModelInstallationsTableTableUpdateCompanionBuilder =
    ModelInstallationsTableCompanion Function({
      Value<String> modelId,
      Value<String> version,
      Value<String> localPath,
      Value<String> expectedSha256,
      Value<String?> actualSha256,
      Value<int> sizeBytes,
      Value<String> installationState,
      Value<int?> installedAt,
      Value<int> rowid,
    });

class $$ModelInstallationsTableTableFilterComposer
    extends Composer<_$AiDatabase, $ModelInstallationsTableTable> {
  $$ModelInstallationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expectedSha256 => $composableBuilder(
    column: $table.expectedSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actualSha256 => $composableBuilder(
    column: $table.actualSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get installationState => $composableBuilder(
    column: $table.installationState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ModelInstallationsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $ModelInstallationsTableTable> {
  $$ModelInstallationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get modelId => $composableBuilder(
    column: $table.modelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expectedSha256 => $composableBuilder(
    column: $table.expectedSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actualSha256 => $composableBuilder(
    column: $table.actualSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get installationState => $composableBuilder(
    column: $table.installationState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ModelInstallationsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $ModelInstallationsTableTable> {
  $$ModelInstallationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get modelId =>
      $composableBuilder(column: $table.modelId, builder: (column) => column);

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get expectedSha256 => $composableBuilder(
    column: $table.expectedSha256,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actualSha256 => $composableBuilder(
    column: $table.actualSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get installationState => $composableBuilder(
    column: $table.installationState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installedAt => $composableBuilder(
    column: $table.installedAt,
    builder: (column) => column,
  );
}

class $$ModelInstallationsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $ModelInstallationsTableTable,
          ModelInstallationsTableData,
          $$ModelInstallationsTableTableFilterComposer,
          $$ModelInstallationsTableTableOrderingComposer,
          $$ModelInstallationsTableTableAnnotationComposer,
          $$ModelInstallationsTableTableCreateCompanionBuilder,
          $$ModelInstallationsTableTableUpdateCompanionBuilder,
          (
            ModelInstallationsTableData,
            BaseReferences<
              _$AiDatabase,
              $ModelInstallationsTableTable,
              ModelInstallationsTableData
            >,
          ),
          ModelInstallationsTableData,
          PrefetchHooks Function()
        > {
  $$ModelInstallationsTableTableTableManager(
    _$AiDatabase db,
    $ModelInstallationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ModelInstallationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ModelInstallationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ModelInstallationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> modelId = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> expectedSha256 = const Value.absent(),
                Value<String?> actualSha256 = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<String> installationState = const Value.absent(),
                Value<int?> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelInstallationsTableCompanion(
                modelId: modelId,
                version: version,
                localPath: localPath,
                expectedSha256: expectedSha256,
                actualSha256: actualSha256,
                sizeBytes: sizeBytes,
                installationState: installationState,
                installedAt: installedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String modelId,
                required String version,
                required String localPath,
                required String expectedSha256,
                Value<String?> actualSha256 = const Value.absent(),
                required int sizeBytes,
                Value<String> installationState = const Value.absent(),
                Value<int?> installedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ModelInstallationsTableCompanion.insert(
                modelId: modelId,
                version: version,
                localPath: localPath,
                expectedSha256: expectedSha256,
                actualSha256: actualSha256,
                sizeBytes: sizeBytes,
                installationState: installationState,
                installedAt: installedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ModelInstallationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $ModelInstallationsTableTable,
      ModelInstallationsTableData,
      $$ModelInstallationsTableTableFilterComposer,
      $$ModelInstallationsTableTableOrderingComposer,
      $$ModelInstallationsTableTableAnnotationComposer,
      $$ModelInstallationsTableTableCreateCompanionBuilder,
      $$ModelInstallationsTableTableUpdateCompanionBuilder,
      (
        ModelInstallationsTableData,
        BaseReferences<
          _$AiDatabase,
          $ModelInstallationsTableTable,
          ModelInstallationsTableData
        >,
      ),
      ModelInstallationsTableData,
      PrefetchHooks Function()
    >;
typedef $$NoteEmbeddingsTableTableCreateCompanionBuilder =
    NoteEmbeddingsTableCompanion Function({
      required String noteId,
      required String modelVersion,
      required String sourceHash,
      required Uint8List vector,
      required int dimensions,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$NoteEmbeddingsTableTableUpdateCompanionBuilder =
    NoteEmbeddingsTableCompanion Function({
      Value<String> noteId,
      Value<String> modelVersion,
      Value<String> sourceHash,
      Value<Uint8List> vector,
      Value<int> dimensions,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$NoteEmbeddingsTableTableFilterComposer
    extends Composer<_$AiDatabase, $NoteEmbeddingsTableTable> {
  $$NoteEmbeddingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteEmbeddingsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $NoteEmbeddingsTableTable> {
  $$NoteEmbeddingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get vector => $composableBuilder(
    column: $table.vector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteEmbeddingsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $NoteEmbeddingsTableTable> {
  $$NoteEmbeddingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get modelVersion => $composableBuilder(
    column: $table.modelVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceHash => $composableBuilder(
    column: $table.sourceHash,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get vector =>
      $composableBuilder(column: $table.vector, builder: (column) => column);

  GeneratedColumn<int> get dimensions => $composableBuilder(
    column: $table.dimensions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NoteEmbeddingsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $NoteEmbeddingsTableTable,
          NoteEmbeddingsTableData,
          $$NoteEmbeddingsTableTableFilterComposer,
          $$NoteEmbeddingsTableTableOrderingComposer,
          $$NoteEmbeddingsTableTableAnnotationComposer,
          $$NoteEmbeddingsTableTableCreateCompanionBuilder,
          $$NoteEmbeddingsTableTableUpdateCompanionBuilder,
          (
            NoteEmbeddingsTableData,
            BaseReferences<
              _$AiDatabase,
              $NoteEmbeddingsTableTable,
              NoteEmbeddingsTableData
            >,
          ),
          NoteEmbeddingsTableData,
          PrefetchHooks Function()
        > {
  $$NoteEmbeddingsTableTableTableManager(
    _$AiDatabase db,
    $NoteEmbeddingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteEmbeddingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteEmbeddingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NoteEmbeddingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> noteId = const Value.absent(),
                Value<String> modelVersion = const Value.absent(),
                Value<String> sourceHash = const Value.absent(),
                Value<Uint8List> vector = const Value.absent(),
                Value<int> dimensions = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteEmbeddingsTableCompanion(
                noteId: noteId,
                modelVersion: modelVersion,
                sourceHash: sourceHash,
                vector: vector,
                dimensions: dimensions,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String noteId,
                required String modelVersion,
                required String sourceHash,
                required Uint8List vector,
                required int dimensions,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NoteEmbeddingsTableCompanion.insert(
                noteId: noteId,
                modelVersion: modelVersion,
                sourceHash: sourceHash,
                vector: vector,
                dimensions: dimensions,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteEmbeddingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $NoteEmbeddingsTableTable,
      NoteEmbeddingsTableData,
      $$NoteEmbeddingsTableTableFilterComposer,
      $$NoteEmbeddingsTableTableOrderingComposer,
      $$NoteEmbeddingsTableTableAnnotationComposer,
      $$NoteEmbeddingsTableTableCreateCompanionBuilder,
      $$NoteEmbeddingsTableTableUpdateCompanionBuilder,
      (
        NoteEmbeddingsTableData,
        BaseReferences<
          _$AiDatabase,
          $NoteEmbeddingsTableTable,
          NoteEmbeddingsTableData
        >,
      ),
      NoteEmbeddingsTableData,
      PrefetchHooks Function()
    >;
typedef $$NoteRelationshipsTableTableCreateCompanionBuilder =
    NoteRelationshipsTableCompanion Function({
      required String sourceNoteId,
      required String targetNoteId,
      required double similarity,
      Value<String> status,
      Value<String?> explanation,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$NoteRelationshipsTableTableUpdateCompanionBuilder =
    NoteRelationshipsTableCompanion Function({
      Value<String> sourceNoteId,
      Value<String> targetNoteId,
      Value<double> similarity,
      Value<String> status,
      Value<String?> explanation,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$NoteRelationshipsTableTableFilterComposer
    extends Composer<_$AiDatabase, $NoteRelationshipsTableTable> {
  $$NoteRelationshipsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceNoteId => $composableBuilder(
    column: $table.sourceNoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetNoteId => $composableBuilder(
    column: $table.targetNoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get similarity => $composableBuilder(
    column: $table.similarity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteRelationshipsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $NoteRelationshipsTableTable> {
  $$NoteRelationshipsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceNoteId => $composableBuilder(
    column: $table.sourceNoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetNoteId => $composableBuilder(
    column: $table.targetNoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get similarity => $composableBuilder(
    column: $table.similarity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteRelationshipsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $NoteRelationshipsTableTable> {
  $$NoteRelationshipsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceNoteId => $composableBuilder(
    column: $table.sourceNoteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetNoteId => $composableBuilder(
    column: $table.targetNoteId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get similarity => $composableBuilder(
    column: $table.similarity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NoteRelationshipsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $NoteRelationshipsTableTable,
          NoteRelationshipsTableData,
          $$NoteRelationshipsTableTableFilterComposer,
          $$NoteRelationshipsTableTableOrderingComposer,
          $$NoteRelationshipsTableTableAnnotationComposer,
          $$NoteRelationshipsTableTableCreateCompanionBuilder,
          $$NoteRelationshipsTableTableUpdateCompanionBuilder,
          (
            NoteRelationshipsTableData,
            BaseReferences<
              _$AiDatabase,
              $NoteRelationshipsTableTable,
              NoteRelationshipsTableData
            >,
          ),
          NoteRelationshipsTableData,
          PrefetchHooks Function()
        > {
  $$NoteRelationshipsTableTableTableManager(
    _$AiDatabase db,
    $NoteRelationshipsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteRelationshipsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NoteRelationshipsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NoteRelationshipsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> sourceNoteId = const Value.absent(),
                Value<String> targetNoteId = const Value.absent(),
                Value<double> similarity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteRelationshipsTableCompanion(
                sourceNoteId: sourceNoteId,
                targetNoteId: targetNoteId,
                similarity: similarity,
                status: status,
                explanation: explanation,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceNoteId,
                required String targetNoteId,
                required double similarity,
                Value<String> status = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NoteRelationshipsTableCompanion.insert(
                sourceNoteId: sourceNoteId,
                targetNoteId: targetNoteId,
                similarity: similarity,
                status: status,
                explanation: explanation,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteRelationshipsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $NoteRelationshipsTableTable,
      NoteRelationshipsTableData,
      $$NoteRelationshipsTableTableFilterComposer,
      $$NoteRelationshipsTableTableOrderingComposer,
      $$NoteRelationshipsTableTableAnnotationComposer,
      $$NoteRelationshipsTableTableCreateCompanionBuilder,
      $$NoteRelationshipsTableTableUpdateCompanionBuilder,
      (
        NoteRelationshipsTableData,
        BaseReferences<
          _$AiDatabase,
          $NoteRelationshipsTableTable,
          NoteRelationshipsTableData
        >,
      ),
      NoteRelationshipsTableData,
      PrefetchHooks Function()
    >;
typedef $$TopicClustersTableTableCreateCompanionBuilder =
    TopicClustersTableCompanion Function({
      required String id,
      required String label,
      Value<String?> summary,
      Value<String> status,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TopicClustersTableTableUpdateCompanionBuilder =
    TopicClustersTableCompanion Function({
      Value<String> id,
      Value<String> label,
      Value<String?> summary,
      Value<String> status,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$TopicClustersTableTableFilterComposer
    extends Composer<_$AiDatabase, $TopicClustersTableTable> {
  $$TopicClustersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TopicClustersTableTableOrderingComposer
    extends Composer<_$AiDatabase, $TopicClustersTableTable> {
  $$TopicClustersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TopicClustersTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $TopicClustersTableTable> {
  $$TopicClustersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TopicClustersTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $TopicClustersTableTable,
          TopicClustersTableData,
          $$TopicClustersTableTableFilterComposer,
          $$TopicClustersTableTableOrderingComposer,
          $$TopicClustersTableTableAnnotationComposer,
          $$TopicClustersTableTableCreateCompanionBuilder,
          $$TopicClustersTableTableUpdateCompanionBuilder,
          (
            TopicClustersTableData,
            BaseReferences<
              _$AiDatabase,
              $TopicClustersTableTable,
              TopicClustersTableData
            >,
          ),
          TopicClustersTableData,
          PrefetchHooks Function()
        > {
  $$TopicClustersTableTableTableManager(
    _$AiDatabase db,
    $TopicClustersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicClustersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicClustersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicClustersTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> summary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicClustersTableCompanion(
                id: id,
                label: label,
                summary: summary,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String label,
                Value<String?> summary = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TopicClustersTableCompanion.insert(
                id: id,
                label: label,
                summary: summary,
                status: status,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TopicClustersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $TopicClustersTableTable,
      TopicClustersTableData,
      $$TopicClustersTableTableFilterComposer,
      $$TopicClustersTableTableOrderingComposer,
      $$TopicClustersTableTableAnnotationComposer,
      $$TopicClustersTableTableCreateCompanionBuilder,
      $$TopicClustersTableTableUpdateCompanionBuilder,
      (
        TopicClustersTableData,
        BaseReferences<
          _$AiDatabase,
          $TopicClustersTableTable,
          TopicClustersTableData
        >,
      ),
      TopicClustersTableData,
      PrefetchHooks Function()
    >;
typedef $$TopicMembershipsTableTableCreateCompanionBuilder =
    TopicMembershipsTableCompanion Function({
      required String clusterId,
      required String noteId,
      required double confidence,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$TopicMembershipsTableTableUpdateCompanionBuilder =
    TopicMembershipsTableCompanion Function({
      Value<String> clusterId,
      Value<String> noteId,
      Value<double> confidence,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$TopicMembershipsTableTableFilterComposer
    extends Composer<_$AiDatabase, $TopicMembershipsTableTable> {
  $$TopicMembershipsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clusterId => $composableBuilder(
    column: $table.clusterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TopicMembershipsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $TopicMembershipsTableTable> {
  $$TopicMembershipsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clusterId => $composableBuilder(
    column: $table.clusterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TopicMembershipsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $TopicMembershipsTableTable> {
  $$TopicMembershipsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clusterId =>
      $composableBuilder(column: $table.clusterId, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TopicMembershipsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $TopicMembershipsTableTable,
          TopicMembershipsTableData,
          $$TopicMembershipsTableTableFilterComposer,
          $$TopicMembershipsTableTableOrderingComposer,
          $$TopicMembershipsTableTableAnnotationComposer,
          $$TopicMembershipsTableTableCreateCompanionBuilder,
          $$TopicMembershipsTableTableUpdateCompanionBuilder,
          (
            TopicMembershipsTableData,
            BaseReferences<
              _$AiDatabase,
              $TopicMembershipsTableTable,
              TopicMembershipsTableData
            >,
          ),
          TopicMembershipsTableData,
          PrefetchHooks Function()
        > {
  $$TopicMembershipsTableTableTableManager(
    _$AiDatabase db,
    $TopicMembershipsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicMembershipsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$TopicMembershipsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TopicMembershipsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clusterId = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicMembershipsTableCompanion(
                clusterId: clusterId,
                noteId: noteId,
                confidence: confidence,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clusterId,
                required String noteId,
                required double confidence,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TopicMembershipsTableCompanion.insert(
                clusterId: clusterId,
                noteId: noteId,
                confidence: confidence,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TopicMembershipsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $TopicMembershipsTableTable,
      TopicMembershipsTableData,
      $$TopicMembershipsTableTableFilterComposer,
      $$TopicMembershipsTableTableOrderingComposer,
      $$TopicMembershipsTableTableAnnotationComposer,
      $$TopicMembershipsTableTableCreateCompanionBuilder,
      $$TopicMembershipsTableTableUpdateCompanionBuilder,
      (
        TopicMembershipsTableData,
        BaseReferences<
          _$AiDatabase,
          $TopicMembershipsTableTable,
          TopicMembershipsTableData
        >,
      ),
      TopicMembershipsTableData,
      PrefetchHooks Function()
    >;
typedef $$NoteInterpretationsTableTableCreateCompanionBuilder =
    NoteInterpretationsTableCompanion Function({
      required String noteId,
      Value<int> schemaVersion,
      required String rawTranscript,
      required String normalizedText,
      required String primaryLanguage,
      Value<String> mixedLanguagesJson,
      Value<String> intentsJson,
      Value<String> entitiesJson,
      Value<String> projectCandidatesJson,
      Value<String?> agentPromptJson,
      required String provenanceJson,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$NoteInterpretationsTableTableUpdateCompanionBuilder =
    NoteInterpretationsTableCompanion Function({
      Value<String> noteId,
      Value<int> schemaVersion,
      Value<String> rawTranscript,
      Value<String> normalizedText,
      Value<String> primaryLanguage,
      Value<String> mixedLanguagesJson,
      Value<String> intentsJson,
      Value<String> entitiesJson,
      Value<String> projectCandidatesJson,
      Value<String?> agentPromptJson,
      Value<String> provenanceJson,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$NoteInterpretationsTableTableFilterComposer
    extends Composer<_$AiDatabase, $NoteInterpretationsTableTable> {
  $$NoteInterpretationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get primaryLanguage => $composableBuilder(
    column: $table.primaryLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mixedLanguagesJson => $composableBuilder(
    column: $table.mixedLanguagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intentsJson => $composableBuilder(
    column: $table.intentsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entitiesJson => $composableBuilder(
    column: $table.entitiesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectCandidatesJson => $composableBuilder(
    column: $table.projectCandidatesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get agentPromptJson => $composableBuilder(
    column: $table.agentPromptJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenanceJson => $composableBuilder(
    column: $table.provenanceJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteInterpretationsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $NoteInterpretationsTableTable> {
  $$NoteInterpretationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryLanguage => $composableBuilder(
    column: $table.primaryLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mixedLanguagesJson => $composableBuilder(
    column: $table.mixedLanguagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intentsJson => $composableBuilder(
    column: $table.intentsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entitiesJson => $composableBuilder(
    column: $table.entitiesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectCandidatesJson => $composableBuilder(
    column: $table.projectCandidatesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get agentPromptJson => $composableBuilder(
    column: $table.agentPromptJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenanceJson => $composableBuilder(
    column: $table.provenanceJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteInterpretationsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $NoteInterpretationsTableTable> {
  $$NoteInterpretationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawTranscript => $composableBuilder(
    column: $table.rawTranscript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get normalizedText => $composableBuilder(
    column: $table.normalizedText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get primaryLanguage => $composableBuilder(
    column: $table.primaryLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mixedLanguagesJson => $composableBuilder(
    column: $table.mixedLanguagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intentsJson => $composableBuilder(
    column: $table.intentsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entitiesJson => $composableBuilder(
    column: $table.entitiesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectCandidatesJson => $composableBuilder(
    column: $table.projectCandidatesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get agentPromptJson => $composableBuilder(
    column: $table.agentPromptJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get provenanceJson => $composableBuilder(
    column: $table.provenanceJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NoteInterpretationsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $NoteInterpretationsTableTable,
          NoteInterpretationsTableData,
          $$NoteInterpretationsTableTableFilterComposer,
          $$NoteInterpretationsTableTableOrderingComposer,
          $$NoteInterpretationsTableTableAnnotationComposer,
          $$NoteInterpretationsTableTableCreateCompanionBuilder,
          $$NoteInterpretationsTableTableUpdateCompanionBuilder,
          (
            NoteInterpretationsTableData,
            BaseReferences<
              _$AiDatabase,
              $NoteInterpretationsTableTable,
              NoteInterpretationsTableData
            >,
          ),
          NoteInterpretationsTableData,
          PrefetchHooks Function()
        > {
  $$NoteInterpretationsTableTableTableManager(
    _$AiDatabase db,
    $NoteInterpretationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteInterpretationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$NoteInterpretationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NoteInterpretationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> noteId = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> rawTranscript = const Value.absent(),
                Value<String> normalizedText = const Value.absent(),
                Value<String> primaryLanguage = const Value.absent(),
                Value<String> mixedLanguagesJson = const Value.absent(),
                Value<String> intentsJson = const Value.absent(),
                Value<String> entitiesJson = const Value.absent(),
                Value<String> projectCandidatesJson = const Value.absent(),
                Value<String?> agentPromptJson = const Value.absent(),
                Value<String> provenanceJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteInterpretationsTableCompanion(
                noteId: noteId,
                schemaVersion: schemaVersion,
                rawTranscript: rawTranscript,
                normalizedText: normalizedText,
                primaryLanguage: primaryLanguage,
                mixedLanguagesJson: mixedLanguagesJson,
                intentsJson: intentsJson,
                entitiesJson: entitiesJson,
                projectCandidatesJson: projectCandidatesJson,
                agentPromptJson: agentPromptJson,
                provenanceJson: provenanceJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String noteId,
                Value<int> schemaVersion = const Value.absent(),
                required String rawTranscript,
                required String normalizedText,
                required String primaryLanguage,
                Value<String> mixedLanguagesJson = const Value.absent(),
                Value<String> intentsJson = const Value.absent(),
                Value<String> entitiesJson = const Value.absent(),
                Value<String> projectCandidatesJson = const Value.absent(),
                Value<String?> agentPromptJson = const Value.absent(),
                required String provenanceJson,
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NoteInterpretationsTableCompanion.insert(
                noteId: noteId,
                schemaVersion: schemaVersion,
                rawTranscript: rawTranscript,
                normalizedText: normalizedText,
                primaryLanguage: primaryLanguage,
                mixedLanguagesJson: mixedLanguagesJson,
                intentsJson: intentsJson,
                entitiesJson: entitiesJson,
                projectCandidatesJson: projectCandidatesJson,
                agentPromptJson: agentPromptJson,
                provenanceJson: provenanceJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteInterpretationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $NoteInterpretationsTableTable,
      NoteInterpretationsTableData,
      $$NoteInterpretationsTableTableFilterComposer,
      $$NoteInterpretationsTableTableOrderingComposer,
      $$NoteInterpretationsTableTableAnnotationComposer,
      $$NoteInterpretationsTableTableCreateCompanionBuilder,
      $$NoteInterpretationsTableTableUpdateCompanionBuilder,
      (
        NoteInterpretationsTableData,
        BaseReferences<
          _$AiDatabase,
          $NoteInterpretationsTableTable,
          NoteInterpretationsTableData
        >,
      ),
      NoteInterpretationsTableData,
      PrefetchHooks Function()
    >;
typedef $$KnownProjectsTableTableCreateCompanionBuilder =
    KnownProjectsTableCompanion Function({
      required String id,
      required String name,
      required String normalizedName,
      Value<String> aliasesJson,
      Value<String?> description,
      required int lastReferencedAt,
      Value<int> rowid,
    });
typedef $$KnownProjectsTableTableUpdateCompanionBuilder =
    KnownProjectsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> normalizedName,
      Value<String> aliasesJson,
      Value<String?> description,
      Value<int> lastReferencedAt,
      Value<int> rowid,
    });

class $$KnownProjectsTableTableFilterComposer
    extends Composer<_$AiDatabase, $KnownProjectsTableTable> {
  $$KnownProjectsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReferencedAt => $composableBuilder(
    column: $table.lastReferencedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KnownProjectsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $KnownProjectsTableTable> {
  $$KnownProjectsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReferencedAt => $composableBuilder(
    column: $table.lastReferencedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KnownProjectsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $KnownProjectsTableTable> {
  $$KnownProjectsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastReferencedAt => $composableBuilder(
    column: $table.lastReferencedAt,
    builder: (column) => column,
  );
}

class $$KnownProjectsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $KnownProjectsTableTable,
          KnownProjectsTableData,
          $$KnownProjectsTableTableFilterComposer,
          $$KnownProjectsTableTableOrderingComposer,
          $$KnownProjectsTableTableAnnotationComposer,
          $$KnownProjectsTableTableCreateCompanionBuilder,
          $$KnownProjectsTableTableUpdateCompanionBuilder,
          (
            KnownProjectsTableData,
            BaseReferences<
              _$AiDatabase,
              $KnownProjectsTableTable,
              KnownProjectsTableData
            >,
          ),
          KnownProjectsTableData,
          PrefetchHooks Function()
        > {
  $$KnownProjectsTableTableTableManager(
    _$AiDatabase db,
    $KnownProjectsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KnownProjectsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KnownProjectsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KnownProjectsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String> aliasesJson = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> lastReferencedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KnownProjectsTableCompanion(
                id: id,
                name: name,
                normalizedName: normalizedName,
                aliasesJson: aliasesJson,
                description: description,
                lastReferencedAt: lastReferencedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String normalizedName,
                Value<String> aliasesJson = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required int lastReferencedAt,
                Value<int> rowid = const Value.absent(),
              }) => KnownProjectsTableCompanion.insert(
                id: id,
                name: name,
                normalizedName: normalizedName,
                aliasesJson: aliasesJson,
                description: description,
                lastReferencedAt: lastReferencedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KnownProjectsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $KnownProjectsTableTable,
      KnownProjectsTableData,
      $$KnownProjectsTableTableFilterComposer,
      $$KnownProjectsTableTableOrderingComposer,
      $$KnownProjectsTableTableAnnotationComposer,
      $$KnownProjectsTableTableCreateCompanionBuilder,
      $$KnownProjectsTableTableUpdateCompanionBuilder,
      (
        KnownProjectsTableData,
        BaseReferences<
          _$AiDatabase,
          $KnownProjectsTableTable,
          KnownProjectsTableData
        >,
      ),
      KnownProjectsTableData,
      PrefetchHooks Function()
    >;
typedef $$KnownApplicationsTableTableCreateCompanionBuilder =
    KnownApplicationsTableCompanion Function({
      required String id,
      required String name,
      Value<String?> bundleId,
      Value<String> aliasesJson,
      Value<String?> description,
      required int lastReferencedAt,
      Value<int> rowid,
    });
typedef $$KnownApplicationsTableTableUpdateCompanionBuilder =
    KnownApplicationsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> bundleId,
      Value<String> aliasesJson,
      Value<String?> description,
      Value<int> lastReferencedAt,
      Value<int> rowid,
    });

class $$KnownApplicationsTableTableFilterComposer
    extends Composer<_$AiDatabase, $KnownApplicationsTableTable> {
  $$KnownApplicationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReferencedAt => $composableBuilder(
    column: $table.lastReferencedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KnownApplicationsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $KnownApplicationsTableTable> {
  $$KnownApplicationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bundleId => $composableBuilder(
    column: $table.bundleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReferencedAt => $composableBuilder(
    column: $table.lastReferencedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KnownApplicationsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $KnownApplicationsTableTable> {
  $$KnownApplicationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bundleId =>
      $composableBuilder(column: $table.bundleId, builder: (column) => column);

  GeneratedColumn<String> get aliasesJson => $composableBuilder(
    column: $table.aliasesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastReferencedAt => $composableBuilder(
    column: $table.lastReferencedAt,
    builder: (column) => column,
  );
}

class $$KnownApplicationsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $KnownApplicationsTableTable,
          KnownApplicationsTableData,
          $$KnownApplicationsTableTableFilterComposer,
          $$KnownApplicationsTableTableOrderingComposer,
          $$KnownApplicationsTableTableAnnotationComposer,
          $$KnownApplicationsTableTableCreateCompanionBuilder,
          $$KnownApplicationsTableTableUpdateCompanionBuilder,
          (
            KnownApplicationsTableData,
            BaseReferences<
              _$AiDatabase,
              $KnownApplicationsTableTable,
              KnownApplicationsTableData
            >,
          ),
          KnownApplicationsTableData,
          PrefetchHooks Function()
        > {
  $$KnownApplicationsTableTableTableManager(
    _$AiDatabase db,
    $KnownApplicationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KnownApplicationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$KnownApplicationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$KnownApplicationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> bundleId = const Value.absent(),
                Value<String> aliasesJson = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> lastReferencedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => KnownApplicationsTableCompanion(
                id: id,
                name: name,
                bundleId: bundleId,
                aliasesJson: aliasesJson,
                description: description,
                lastReferencedAt: lastReferencedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> bundleId = const Value.absent(),
                Value<String> aliasesJson = const Value.absent(),
                Value<String?> description = const Value.absent(),
                required int lastReferencedAt,
                Value<int> rowid = const Value.absent(),
              }) => KnownApplicationsTableCompanion.insert(
                id: id,
                name: name,
                bundleId: bundleId,
                aliasesJson: aliasesJson,
                description: description,
                lastReferencedAt: lastReferencedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KnownApplicationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $KnownApplicationsTableTable,
      KnownApplicationsTableData,
      $$KnownApplicationsTableTableFilterComposer,
      $$KnownApplicationsTableTableOrderingComposer,
      $$KnownApplicationsTableTableAnnotationComposer,
      $$KnownApplicationsTableTableCreateCompanionBuilder,
      $$KnownApplicationsTableTableUpdateCompanionBuilder,
      (
        KnownApplicationsTableData,
        BaseReferences<
          _$AiDatabase,
          $KnownApplicationsTableTable,
          KnownApplicationsTableData
        >,
      ),
      KnownApplicationsTableData,
      PrefetchHooks Function()
    >;
typedef $$DraftCommunicationsTableTableCreateCompanionBuilder =
    DraftCommunicationsTableCompanion Function({
      required String id,
      required String noteId,
      required String type,
      Value<String?> recipient,
      Value<String?> subject,
      required String body,
      Value<String?> resolvedChannel,
      Value<String> status,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$DraftCommunicationsTableTableUpdateCompanionBuilder =
    DraftCommunicationsTableCompanion Function({
      Value<String> id,
      Value<String> noteId,
      Value<String> type,
      Value<String?> recipient,
      Value<String?> subject,
      Value<String> body,
      Value<String?> resolvedChannel,
      Value<String> status,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$DraftCommunicationsTableTableFilterComposer
    extends Composer<_$AiDatabase, $DraftCommunicationsTableTable> {
  $$DraftCommunicationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolvedChannel => $composableBuilder(
    column: $table.resolvedChannel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DraftCommunicationsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $DraftCommunicationsTableTable> {
  $$DraftCommunicationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recipient => $composableBuilder(
    column: $table.recipient,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subject => $composableBuilder(
    column: $table.subject,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolvedChannel => $composableBuilder(
    column: $table.resolvedChannel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DraftCommunicationsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $DraftCommunicationsTableTable> {
  $$DraftCommunicationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get recipient =>
      $composableBuilder(column: $table.recipient, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get resolvedChannel => $composableBuilder(
    column: $table.resolvedChannel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DraftCommunicationsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $DraftCommunicationsTableTable,
          DraftCommunicationsTableData,
          $$DraftCommunicationsTableTableFilterComposer,
          $$DraftCommunicationsTableTableOrderingComposer,
          $$DraftCommunicationsTableTableAnnotationComposer,
          $$DraftCommunicationsTableTableCreateCompanionBuilder,
          $$DraftCommunicationsTableTableUpdateCompanionBuilder,
          (
            DraftCommunicationsTableData,
            BaseReferences<
              _$AiDatabase,
              $DraftCommunicationsTableTable,
              DraftCommunicationsTableData
            >,
          ),
          DraftCommunicationsTableData,
          PrefetchHooks Function()
        > {
  $$DraftCommunicationsTableTableTableManager(
    _$AiDatabase db,
    $DraftCommunicationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DraftCommunicationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DraftCommunicationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DraftCommunicationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> recipient = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> resolvedChannel = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DraftCommunicationsTableCompanion(
                id: id,
                noteId: noteId,
                type: type,
                recipient: recipient,
                subject: subject,
                body: body,
                resolvedChannel: resolvedChannel,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required String type,
                Value<String?> recipient = const Value.absent(),
                Value<String?> subject = const Value.absent(),
                required String body,
                Value<String?> resolvedChannel = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DraftCommunicationsTableCompanion.insert(
                id: id,
                noteId: noteId,
                type: type,
                recipient: recipient,
                subject: subject,
                body: body,
                resolvedChannel: resolvedChannel,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DraftCommunicationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $DraftCommunicationsTableTable,
      DraftCommunicationsTableData,
      $$DraftCommunicationsTableTableFilterComposer,
      $$DraftCommunicationsTableTableOrderingComposer,
      $$DraftCommunicationsTableTableAnnotationComposer,
      $$DraftCommunicationsTableTableCreateCompanionBuilder,
      $$DraftCommunicationsTableTableUpdateCompanionBuilder,
      (
        DraftCommunicationsTableData,
        BaseReferences<
          _$AiDatabase,
          $DraftCommunicationsTableTable,
          DraftCommunicationsTableData
        >,
      ),
      DraftCommunicationsTableData,
      PrefetchHooks Function()
    >;
typedef $$AgentPromptDraftsTableTableCreateCompanionBuilder =
    AgentPromptDraftsTableCompanion Function({
      required String id,
      required String noteId,
      required String goal,
      required String context,
      Value<String> requirementsJson,
      Value<String> constraintsJson,
      Value<String> acceptanceCriteriaJson,
      Value<String> relevantFilesJson,
      Value<String> nonGoalsJson,
      Value<String> openQuestionsJson,
      required double confidence,
      Value<String> status,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$AgentPromptDraftsTableTableUpdateCompanionBuilder =
    AgentPromptDraftsTableCompanion Function({
      Value<String> id,
      Value<String> noteId,
      Value<String> goal,
      Value<String> context,
      Value<String> requirementsJson,
      Value<String> constraintsJson,
      Value<String> acceptanceCriteriaJson,
      Value<String> relevantFilesJson,
      Value<String> nonGoalsJson,
      Value<String> openQuestionsJson,
      Value<double> confidence,
      Value<String> status,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$AgentPromptDraftsTableTableFilterComposer
    extends Composer<_$AiDatabase, $AgentPromptDraftsTableTable> {
  $$AgentPromptDraftsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requirementsJson => $composableBuilder(
    column: $table.requirementsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get constraintsJson => $composableBuilder(
    column: $table.constraintsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get acceptanceCriteriaJson => $composableBuilder(
    column: $table.acceptanceCriteriaJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relevantFilesJson => $composableBuilder(
    column: $table.relevantFilesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nonGoalsJson => $composableBuilder(
    column: $table.nonGoalsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openQuestionsJson => $composableBuilder(
    column: $table.openQuestionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AgentPromptDraftsTableTableOrderingComposer
    extends Composer<_$AiDatabase, $AgentPromptDraftsTableTable> {
  $$AgentPromptDraftsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get context => $composableBuilder(
    column: $table.context,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requirementsJson => $composableBuilder(
    column: $table.requirementsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get constraintsJson => $composableBuilder(
    column: $table.constraintsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get acceptanceCriteriaJson => $composableBuilder(
    column: $table.acceptanceCriteriaJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relevantFilesJson => $composableBuilder(
    column: $table.relevantFilesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nonGoalsJson => $composableBuilder(
    column: $table.nonGoalsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openQuestionsJson => $composableBuilder(
    column: $table.openQuestionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AgentPromptDraftsTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $AgentPromptDraftsTableTable> {
  $$AgentPromptDraftsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<String> get context =>
      $composableBuilder(column: $table.context, builder: (column) => column);

  GeneratedColumn<String> get requirementsJson => $composableBuilder(
    column: $table.requirementsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get constraintsJson => $composableBuilder(
    column: $table.constraintsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get acceptanceCriteriaJson => $composableBuilder(
    column: $table.acceptanceCriteriaJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relevantFilesJson => $composableBuilder(
    column: $table.relevantFilesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nonGoalsJson => $composableBuilder(
    column: $table.nonGoalsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openQuestionsJson => $composableBuilder(
    column: $table.openQuestionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AgentPromptDraftsTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $AgentPromptDraftsTableTable,
          AgentPromptDraftsTableData,
          $$AgentPromptDraftsTableTableFilterComposer,
          $$AgentPromptDraftsTableTableOrderingComposer,
          $$AgentPromptDraftsTableTableAnnotationComposer,
          $$AgentPromptDraftsTableTableCreateCompanionBuilder,
          $$AgentPromptDraftsTableTableUpdateCompanionBuilder,
          (
            AgentPromptDraftsTableData,
            BaseReferences<
              _$AiDatabase,
              $AgentPromptDraftsTableTable,
              AgentPromptDraftsTableData
            >,
          ),
          AgentPromptDraftsTableData,
          PrefetchHooks Function()
        > {
  $$AgentPromptDraftsTableTableTableManager(
    _$AiDatabase db,
    $AgentPromptDraftsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentPromptDraftsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AgentPromptDraftsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AgentPromptDraftsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<String> context = const Value.absent(),
                Value<String> requirementsJson = const Value.absent(),
                Value<String> constraintsJson = const Value.absent(),
                Value<String> acceptanceCriteriaJson = const Value.absent(),
                Value<String> relevantFilesJson = const Value.absent(),
                Value<String> nonGoalsJson = const Value.absent(),
                Value<String> openQuestionsJson = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AgentPromptDraftsTableCompanion(
                id: id,
                noteId: noteId,
                goal: goal,
                context: context,
                requirementsJson: requirementsJson,
                constraintsJson: constraintsJson,
                acceptanceCriteriaJson: acceptanceCriteriaJson,
                relevantFilesJson: relevantFilesJson,
                nonGoalsJson: nonGoalsJson,
                openQuestionsJson: openQuestionsJson,
                confidence: confidence,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required String goal,
                required String context,
                Value<String> requirementsJson = const Value.absent(),
                Value<String> constraintsJson = const Value.absent(),
                Value<String> acceptanceCriteriaJson = const Value.absent(),
                Value<String> relevantFilesJson = const Value.absent(),
                Value<String> nonGoalsJson = const Value.absent(),
                Value<String> openQuestionsJson = const Value.absent(),
                required double confidence,
                Value<String> status = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AgentPromptDraftsTableCompanion.insert(
                id: id,
                noteId: noteId,
                goal: goal,
                context: context,
                requirementsJson: requirementsJson,
                constraintsJson: constraintsJson,
                acceptanceCriteriaJson: acceptanceCriteriaJson,
                relevantFilesJson: relevantFilesJson,
                nonGoalsJson: nonGoalsJson,
                openQuestionsJson: openQuestionsJson,
                confidence: confidence,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AgentPromptDraftsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $AgentPromptDraftsTableTable,
      AgentPromptDraftsTableData,
      $$AgentPromptDraftsTableTableFilterComposer,
      $$AgentPromptDraftsTableTableOrderingComposer,
      $$AgentPromptDraftsTableTableAnnotationComposer,
      $$AgentPromptDraftsTableTableCreateCompanionBuilder,
      $$AgentPromptDraftsTableTableUpdateCompanionBuilder,
      (
        AgentPromptDraftsTableData,
        BaseReferences<
          _$AiDatabase,
          $AgentPromptDraftsTableTable,
          AgentPromptDraftsTableData
        >,
      ),
      AgentPromptDraftsTableData,
      PrefetchHooks Function()
    >;
typedef $$InterpretationFeedbackTableTableCreateCompanionBuilder =
    InterpretationFeedbackTableCompanion Function({
      required String id,
      required String noteId,
      required String correctedField,
      Value<String?> originalValue,
      required String correctedValue,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$InterpretationFeedbackTableTableUpdateCompanionBuilder =
    InterpretationFeedbackTableCompanion Function({
      Value<String> id,
      Value<String> noteId,
      Value<String> correctedField,
      Value<String?> originalValue,
      Value<String> correctedValue,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$InterpretationFeedbackTableTableFilterComposer
    extends Composer<_$AiDatabase, $InterpretationFeedbackTableTable> {
  $$InterpretationFeedbackTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctedField => $composableBuilder(
    column: $table.correctedField,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get originalValue => $composableBuilder(
    column: $table.originalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correctedValue => $composableBuilder(
    column: $table.correctedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InterpretationFeedbackTableTableOrderingComposer
    extends Composer<_$AiDatabase, $InterpretationFeedbackTableTable> {
  $$InterpretationFeedbackTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctedField => $composableBuilder(
    column: $table.correctedField,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalValue => $composableBuilder(
    column: $table.originalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correctedValue => $composableBuilder(
    column: $table.correctedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InterpretationFeedbackTableTableAnnotationComposer
    extends Composer<_$AiDatabase, $InterpretationFeedbackTableTable> {
  $$InterpretationFeedbackTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get correctedField => $composableBuilder(
    column: $table.correctedField,
    builder: (column) => column,
  );

  GeneratedColumn<String> get originalValue => $composableBuilder(
    column: $table.originalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correctedValue => $composableBuilder(
    column: $table.correctedValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InterpretationFeedbackTableTableTableManager
    extends
        RootTableManager<
          _$AiDatabase,
          $InterpretationFeedbackTableTable,
          InterpretationFeedbackTableData,
          $$InterpretationFeedbackTableTableFilterComposer,
          $$InterpretationFeedbackTableTableOrderingComposer,
          $$InterpretationFeedbackTableTableAnnotationComposer,
          $$InterpretationFeedbackTableTableCreateCompanionBuilder,
          $$InterpretationFeedbackTableTableUpdateCompanionBuilder,
          (
            InterpretationFeedbackTableData,
            BaseReferences<
              _$AiDatabase,
              $InterpretationFeedbackTableTable,
              InterpretationFeedbackTableData
            >,
          ),
          InterpretationFeedbackTableData,
          PrefetchHooks Function()
        > {
  $$InterpretationFeedbackTableTableTableManager(
    _$AiDatabase db,
    $InterpretationFeedbackTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InterpretationFeedbackTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InterpretationFeedbackTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InterpretationFeedbackTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<String> correctedField = const Value.absent(),
                Value<String?> originalValue = const Value.absent(),
                Value<String> correctedValue = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterpretationFeedbackTableCompanion(
                id: id,
                noteId: noteId,
                correctedField: correctedField,
                originalValue: originalValue,
                correctedValue: correctedValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required String correctedField,
                Value<String?> originalValue = const Value.absent(),
                required String correctedValue,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => InterpretationFeedbackTableCompanion.insert(
                id: id,
                noteId: noteId,
                correctedField: correctedField,
                originalValue: originalValue,
                correctedValue: correctedValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InterpretationFeedbackTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AiDatabase,
      $InterpretationFeedbackTableTable,
      InterpretationFeedbackTableData,
      $$InterpretationFeedbackTableTableFilterComposer,
      $$InterpretationFeedbackTableTableOrderingComposer,
      $$InterpretationFeedbackTableTableAnnotationComposer,
      $$InterpretationFeedbackTableTableCreateCompanionBuilder,
      $$InterpretationFeedbackTableTableUpdateCompanionBuilder,
      (
        InterpretationFeedbackTableData,
        BaseReferences<
          _$AiDatabase,
          $InterpretationFeedbackTableTable,
          InterpretationFeedbackTableData
        >,
      ),
      InterpretationFeedbackTableData,
      PrefetchHooks Function()
    >;

class $AiDatabaseManager {
  final _$AiDatabase _db;
  $AiDatabaseManager(this._db);
  $$AiNoteAnalysisTableTableTableManager get aiNoteAnalysisTable =>
      $$AiNoteAnalysisTableTableTableManager(_db, _db.aiNoteAnalysisTable);
  $$TranscriptSegmentsTableTableTableManager get transcriptSegmentsTable =>
      $$TranscriptSegmentsTableTableTableManager(
        _db,
        _db.transcriptSegmentsTable,
      );
  $$DocumentsTableTableTableManager get documentsTable =>
      $$DocumentsTableTableTableManager(_db, _db.documentsTable);
  $$DocumentChunksTableTableTableManager get documentChunksTable =>
      $$DocumentChunksTableTableTableManager(_db, _db.documentChunksTable);
  $$SuggestedActionsTableTableTableManager get suggestedActionsTable =>
      $$SuggestedActionsTableTableTableManager(_db, _db.suggestedActionsTable);
  $$PersonalMemoriesTableTableTableManager get personalMemoriesTable =>
      $$PersonalMemoriesTableTableTableManager(_db, _db.personalMemoriesTable);
  $$AiJobsTableTableTableManager get aiJobsTable =>
      $$AiJobsTableTableTableManager(_db, _db.aiJobsTable);
  $$ModelInstallationsTableTableTableManager get modelInstallationsTable =>
      $$ModelInstallationsTableTableTableManager(
        _db,
        _db.modelInstallationsTable,
      );
  $$NoteEmbeddingsTableTableTableManager get noteEmbeddingsTable =>
      $$NoteEmbeddingsTableTableTableManager(_db, _db.noteEmbeddingsTable);
  $$NoteRelationshipsTableTableTableManager get noteRelationshipsTable =>
      $$NoteRelationshipsTableTableTableManager(
        _db,
        _db.noteRelationshipsTable,
      );
  $$TopicClustersTableTableTableManager get topicClustersTable =>
      $$TopicClustersTableTableTableManager(_db, _db.topicClustersTable);
  $$TopicMembershipsTableTableTableManager get topicMembershipsTable =>
      $$TopicMembershipsTableTableTableManager(_db, _db.topicMembershipsTable);
  $$NoteInterpretationsTableTableTableManager get noteInterpretationsTable =>
      $$NoteInterpretationsTableTableTableManager(
        _db,
        _db.noteInterpretationsTable,
      );
  $$KnownProjectsTableTableTableManager get knownProjectsTable =>
      $$KnownProjectsTableTableTableManager(_db, _db.knownProjectsTable);
  $$KnownApplicationsTableTableTableManager get knownApplicationsTable =>
      $$KnownApplicationsTableTableTableManager(
        _db,
        _db.knownApplicationsTable,
      );
  $$DraftCommunicationsTableTableTableManager get draftCommunicationsTable =>
      $$DraftCommunicationsTableTableTableManager(
        _db,
        _db.draftCommunicationsTable,
      );
  $$AgentPromptDraftsTableTableTableManager get agentPromptDraftsTable =>
      $$AgentPromptDraftsTableTableTableManager(
        _db,
        _db.agentPromptDraftsTable,
      );
  $$InterpretationFeedbackTableTableTableManager
  get interpretationFeedbackTable =>
      $$InterpretationFeedbackTableTableTableManager(
        _db,
        _db.interpretationFeedbackTable,
      );
}
