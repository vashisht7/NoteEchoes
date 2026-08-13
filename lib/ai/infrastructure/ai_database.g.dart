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
}
