// note_interpretation.dart
// Structured multilingual domain models for NoteEchoes note intelligence.

import 'ai_models.dart';

enum IntentType {
  plainNote,
  task,
  reminder,
  calendarEvent,
  idea,
  emailDraft,
  messageDraft,
  projectUpdate,
  decision,
  question,
  agentPrompt,
  reference,
  journalEntry;

  String get id {
    switch (this) {
      case IntentType.plainNote: return 'plain_note';
      case IntentType.task: return 'task';
      case IntentType.reminder: return 'reminder';
      case IntentType.calendarEvent: return 'calendar_event';
      case IntentType.idea: return 'idea';
      case IntentType.emailDraft: return 'email_draft';
      case IntentType.messageDraft: return 'message_draft';
      case IntentType.projectUpdate: return 'project_update';
      case IntentType.decision: return 'decision';
      case IntentType.question: return 'question';
      case IntentType.agentPrompt: return 'agent_prompt';
      case IntentType.reference: return 'reference';
      case IntentType.journalEntry: return 'journal_entry';
    }
  }

  static IntentType fromId(String id) {
    switch (id.toLowerCase()) {
      case 'task': return IntentType.task;
      case 'reminder': return IntentType.reminder;
      case 'calendar_event': return IntentType.calendarEvent;
      case 'idea': return IntentType.idea;
      case 'email_draft': return IntentType.emailDraft;
      case 'message_draft': return IntentType.messageDraft;
      case 'project_update': return IntentType.projectUpdate;
      case 'decision': return IntentType.decision;
      case 'question': return IntentType.question;
      case 'agent_prompt': return IntentType.agentPrompt;
      case 'reference': return IntentType.reference;
      case 'journal_entry': return IntentType.journalEntry;
      default: return IntentType.plainNote;
    }
  }
}

enum EntityType {
  person,
  organization,
  application,
  project,
  dateTime,
  location,
  url,
  email,
  noteReference;

  String get id {
    switch (this) {
      case EntityType.person: return 'person';
      case EntityType.organization: return 'organization';
      case EntityType.application: return 'application';
      case EntityType.project: return 'project';
      case EntityType.dateTime: return 'date_time';
      case EntityType.location: return 'location';
      case EntityType.url: return 'url';
      case EntityType.email: return 'email';
      case EntityType.noteReference: return 'note_reference';
    }
  }

  static EntityType fromId(String id) {
    switch (id.toLowerCase()) {
      case 'person': return EntityType.person;
      case 'organization': return EntityType.organization;
      case 'application': return EntityType.application;
      case 'project': return EntityType.project;
      case 'date_time': return EntityType.dateTime;
      case 'location': return EntityType.location;
      case 'url': return EntityType.url;
      case 'email': return EntityType.email;
      default: return EntityType.noteReference;
    }
  }
}

class DetectedIntent {
  final IntentType type;
  final double confidence;
  final String? rawPhrase;
  final Map<String, dynamic> metadata;

  const DetectedIntent({
    required this.type,
    required this.confidence,
    this.rawPhrase,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'type': type.id,
    'confidence': confidence,
    'raw_phrase': rawPhrase,
    'metadata': metadata,
  };

  factory DetectedIntent.fromJson(Map<String, dynamic> json) => DetectedIntent(
    type: IntentType.fromId(json['type'] as String? ?? ''),
    confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    rawPhrase: json['raw_phrase'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>? ?? {},
  );
}

class ExtractedEntity {
  final EntityType type;
  final String value;
  final String? rawPhrase;
  final double confidence;
  final DateTime? resolvedDateTime;

  const ExtractedEntity({
    required this.type,
    required this.value,
    this.rawPhrase,
    required this.confidence,
    this.resolvedDateTime,
  });

  Map<String, dynamic> toJson() => {
    'type': type.id,
    'value': value,
    'raw_phrase': rawPhrase,
    'confidence': confidence,
    'resolved_date_time': resolvedDateTime?.toIso8601String(),
  };

  factory ExtractedEntity.fromJson(Map<String, dynamic> json) => ExtractedEntity(
    type: EntityType.fromId(json['type'] as String? ?? ''),
    value: json['value'] as String? ?? '',
    rawPhrase: json['raw_phrase'] as String?,
    confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    resolvedDateTime: json['resolved_date_time'] != null
        ? DateTime.tryParse(json['resolved_date_time'] as String)
        : null,
  );
}

class ProjectCandidate {
  final String projectName;
  final double confidence;
  final String reason;
  final bool isConfirmed;

  const ProjectCandidate({
    required this.projectName,
    required this.confidence,
    required this.reason,
    this.isConfirmed = false,
  });

  Map<String, dynamic> toJson() => {
    'project_name': projectName,
    'confidence': confidence,
    'reason': reason,
    'is_confirmed': isConfirmed,
  };

  factory ProjectCandidate.fromJson(Map<String, dynamic> json) => ProjectCandidate(
    projectName: json['project_name'] as String? ?? '',
    confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
    reason: json['reason'] as String? ?? '',
    isConfirmed: json['is_confirmed'] as bool? ?? false,
  );
}

class AgentPromptDraft {
  final String goal;
  final String context;
  final List<String> requirements;
  final List<String> constraints;
  final List<String> acceptanceCriteria;
  final List<String> relevantFiles;
  final List<String> nonGoals;
  final List<String> openQuestions;
  final double confidence;

  const AgentPromptDraft({
    required this.goal,
    required this.context,
    required this.requirements,
    required this.constraints,
    required this.acceptanceCriteria,
    required this.relevantFiles,
    required this.nonGoals,
    required this.openQuestions,
    required this.confidence,
  });

  String toCodexMarkdown() {
    final b = StringBuffer();
    b.writeln('# $goal\n');
    b.writeln('## Context\n$context\n');
    if (requirements.isNotEmpty) {
      b.writeln('## Requirements');
      for (final r in requirements) {
        b.writeln('- $r');
      }
      b.writeln();
    }
    if (constraints.isNotEmpty) {
      b.writeln('## Constraints');
      for (final c in constraints) {
        b.writeln('- $c');
      }
      b.writeln();
    }
    if (acceptanceCriteria.isNotEmpty) {
      b.writeln('## Acceptance Criteria');
      for (final a in acceptanceCriteria) {
        b.writeln('- [ ] $a');
      }
      b.writeln();
    }
    if (relevantFiles.isNotEmpty) {
      b.writeln('## Relevant Files or Systems');
      for (final f in relevantFiles) {
        b.writeln('- `$f`');
      }
      b.writeln();
    }
    if (nonGoals.isNotEmpty) {
      b.writeln('## Non-goals');
      for (final ng in nonGoals) {
        b.writeln('- $ng');
      }
      b.writeln();
    }
    if (openQuestions.isNotEmpty) {
      b.writeln('## Open Questions');
      for (final q in openQuestions) {
        b.writeln('- $q');
      }
      b.writeln();
    }
    return b.toString().trim();
  }

  Map<String, dynamic> toJson() => {
    'goal': goal,
    'context': context,
    'requirements': requirements,
    'constraints': constraints,
    'acceptance_criteria': acceptanceCriteria,
    'relevant_files': relevantFiles,
    'non_goals': nonGoals,
    'open_questions': openQuestions,
    'confidence': confidence,
  };

  factory AgentPromptDraft.fromJson(Map<String, dynamic> json) => AgentPromptDraft(
    goal: json['goal'] as String? ?? '',
    context: json['context'] as String? ?? '',
    requirements: (json['requirements'] as List?)?.cast<String>() ?? [],
    constraints: (json['constraints'] as List?)?.cast<String>() ?? [],
    acceptanceCriteria: (json['acceptance_criteria'] as List?)?.cast<String>() ?? [],
    relevantFiles: (json['relevant_files'] as List?)?.cast<String>() ?? [],
    nonGoals: (json['non_goals'] as List?)?.cast<String>() ?? [],
    openQuestions: (json['open_questions'] as List?)?.cast<String>() ?? [],
    confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
  );
}

class NoteInterpretation {
  final int schemaVersion;
  final String noteId;
  final String rawTranscript;
  final String normalizedText;
  final String primaryLanguage;
  final List<String> mixedLanguages;
  final List<DetectedIntent> intents;
  final List<ExtractedEntity> entities;
  final List<ProjectCandidate> projectCandidates;
  final AgentPromptDraft? agentPrompt;
  final AiProvenance provenance;

  const NoteInterpretation({
    this.schemaVersion = 1,
    required this.noteId,
    required this.rawTranscript,
    required this.normalizedText,
    required this.primaryLanguage,
    this.mixedLanguages = const [],
    this.intents = const [],
    this.entities = const [],
    this.projectCandidates = const [],
    this.agentPrompt,
    required this.provenance,
  });

  Map<String, dynamic> toJson() => {
    'schema_version': schemaVersion,
    'note_id': noteId,
    'raw_transcript': rawTranscript,
    'normalized_text': normalizedText,
    'primary_language': primaryLanguage,
    'mixed_languages': mixedLanguages,
    'intents': intents.map((i) => i.toJson()).toList(),
    'entities': entities.map((e) => e.toJson()).toList(),
    'project_candidates': projectCandidates.map((p) => p.toJson()).toList(),
    'agent_prompt': agentPrompt?.toJson(),
    'provenance': provenance.toJson(),
  };

  factory NoteInterpretation.fromJson(Map<String, dynamic> json) => NoteInterpretation(
    schemaVersion: json['schema_version'] as int? ?? 1,
    noteId: json['note_id'] as String? ?? '',
    rawTranscript: json['raw_transcript'] as String? ?? '',
    normalizedText: json['normalized_text'] as String? ?? '',
    primaryLanguage: json['primary_language'] as String? ?? 'en',
    mixedLanguages: (json['mixed_languages'] as List?)?.cast<String>() ?? [],
    intents: (json['intents'] as List?)
            ?.map((i) => DetectedIntent.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [],
    entities: (json['entities'] as List?)
            ?.map((e) => ExtractedEntity.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    projectCandidates: (json['project_candidates'] as List?)
            ?.map((p) => ProjectCandidate.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [],
    agentPrompt: json['agent_prompt'] != null
        ? AgentPromptDraft.fromJson(json['agent_prompt'] as Map<String, dynamic>)
        : null,
    provenance: json['provenance'] != null
        ? AiProvenance.fromJson(json['provenance'] as Map<String, dynamic>)
        : AiProvenance(
            modelId: 'fallback',
            modelVersion: '1.0',
            promptVersion: '1.0',
            schemaVersion: 1,
            confidence: 1.0,
            rawOutput: '',
          ),
  );
}
