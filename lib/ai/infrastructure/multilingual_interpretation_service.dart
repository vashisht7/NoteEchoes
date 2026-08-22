// multilingual_interpretation_service.dart
// Two-pass note normalization and structured intent extraction.
// Pass 1: Normalization (filler cleanup, self-correction, punctuation preservation)
// Pass 2: Structured Intent & Entity extraction with provenance

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../domain/ai_models.dart';
import '../domain/note_interpretation.dart';
import 'language_detection_service.dart';
import 'model_availability_service.dart';
import 'project_matching_service.dart';
import 'agent_prompt_service.dart';
import 'structured_generation_service.dart';

class MultilingualInterpretationService {
  static const String modelId = 'qwen3-0.6b-4bit';
  static const String modelVersion = '3.0.0';
  static const String promptVersion = '1.0';
  static const int schemaVersion = 1;

  // Common fillers across English, Telugu, Hindi
  static final _fillerPattern = RegExp(
    r'\b(?:um+|uh+|er+|ah+|like\s+you\s+know|you\s+know|ante\s+adi|mari\s+adi|matlab\s+ki|toh\s+phir)\b',
    caseSensitive: false,
  );

  /// Pass 1: Normalizes transcript text without altering underlying meaning or facts.
  static String normalizeTranscript(String rawTranscript) {
    if (rawTranscript.trim().isEmpty) return '';

    var text = rawTranscript.trim();

    // 1. Remove filler sounds
    text = text.replaceAll(_fillerPattern, ' ');

    // 2. Resolve common speech self-corrections:
    // e.g. "Tuesday wait no Wednesday" -> "Wednesday"
    // e.g. "5 PM sorry I mean 6 PM" -> "6 PM"
    // e.g. "Rahul leda Ravi" -> "Ravi" (if self-corrected)
    final correctionPatterns = [
      RegExp(r'\b[\w\s]+(?:\s+wait\s+no\s+|\s+sorry\s+I\s+mean\s+|\s+no\s+wait\s+|\s+actually\s+no\s+)([\w\s]+)', caseSensitive: false),
    ];
    for (final pattern in correctionPatterns) {
      text = text.replaceAllMapped(pattern, (match) => match.group(1) ?? match.group(0)!);
    }

    // 3. Normalize multiple spaces
    text = text.replaceAll(RegExp(r'\s{2,}'), ' ').trim();

    // 4. Ensure trailing period if sentence-like
    if (text.isNotEmpty && !text.endsWith('.') && !text.endsWith('?') && !text.endsWith('!')) {
      text = '$text.';
    }

    // Capitalize first letter
    if (text.isNotEmpty) {
      text = text[0].toUpperCase() + text.substring(1);
    }

    return text;
  }

  /// Pass 2: Structured Interpretation (Intents, Entities, Projects, Agent Prompts).
  static Future<NoteInterpretation> interpretNote({
    required String noteId,
    required String rawTranscript,
    String? whisperReportedLang,
    String? userPreferredLang,
    List<String> knownProjects = const [],
  }) async {
    // 1. Language Detection
    final langResult = LanguageDetectionService.detect(
      rawTranscript,
      whisperReportedLang: whisperReportedLang,
      userPreferredLang: userPreferredLang,
    );

    // 2. Pass 1: Normalization
    final normalized = normalizeTranscript(rawTranscript);

    // 3. Pass 2: Structured Extraction
    if (ModelAvailabilityService.instance.qwen.isReady) {
      try {
        final systemPrompt = '''
You are the NoteEchoes Multilingual Note Intelligence Engine.
Analyze the user's voice note text and extract structured intent, entities, and actions.
Input language: ${langResult.primaryLanguage} (mixed: ${langResult.mixedLanguages.join(', ')})
Known projects: ${knownProjects.join(', ')}

Output JSON ONLY with this schema:
{
  "intents": [
    {"type": "task|reminder|calendar_event|idea|email_draft|message_draft|project_update|decision|question|agent_prompt|reference|plain_note", "confidence": 0.0-1.0, "raw_phrase": "..."}
  ],
  "entities": [
    {"type": "person|organization|application|project|date_time|location|url|email|note_reference", "value": "...", "raw_phrase": "...", "confidence": 0.0-1.0}
  ],
  "project_name": "exact known project or null if unassigned",
  "project_confidence": 0.0-1.0,
  "project_reason": "...",
  "is_agent_prompt": false,
  "agent_prompt": {
    "goal": "...",
    "context": "...",
    "requirements": ["..."],
    "constraints": ["..."],
    "acceptance_criteria": ["..."],
    "relevant_files": ["..."],
    "non_goals": ["..."],
    "open_questions": ["..."],
    "confidence": 0.0-1.0
  }
}
''';

        final result = await StructuredGenerationService.generateStructured<Map<String, dynamic>>(
          prompt: "Analyze this note transcript:\n\"$normalized\"",
          systemPrompt: systemPrompt,
          fromJson: (json) => json,
          modelId: modelId,
          modelVersion: modelVersion,
          promptVersion: promptVersion,
          schemaVersion: schemaVersion,
        );

        if (result.isSuccess && result.value != null) {
          final json = result.value!;
          final intentsList = (json['intents'] as List?)
                  ?.map((i) => DetectedIntent.fromJson(i as Map<String, dynamic>))
                  .toList() ??
              [];

          final entitiesList = (json['entities'] as List?)
                  ?.map((e) => ExtractedEntity.fromJson(e as Map<String, dynamic>))
                  .toList() ??
              [];

          // Resolve proposed project candidates
          final projectCandidates = ProjectMatchingService.matchCandidates(
            noteText: normalized,
            knownProjects: knownProjects,
            extractedEntities: entitiesList,
            llmProposedProject: json['project_name'] as String?,
            llmConfidence: (json['project_confidence'] as num?)?.toDouble(),
          );

          // Resolve agent prompt if detected
          AgentPromptDraft? agentPrompt;
          if (json['agent_prompt'] != null && json['is_agent_prompt'] == true) {
            agentPrompt = AgentPromptDraft.fromJson(json['agent_prompt'] as Map<String, dynamic>);
          } else {
            agentPrompt = AgentPromptService.detectFromText(normalized);
          }

          return NoteInterpretation(
            schemaVersion: schemaVersion,
            noteId: noteId,
            rawTranscript: rawTranscript,
            normalizedText: normalized,
            primaryLanguage: langResult.primaryLanguage,
            mixedLanguages: langResult.mixedLanguages,
            intents: intentsList.isNotEmpty ? intentsList : [const DetectedIntent(type: IntentType.plainNote, confidence: 1.0)],
            entities: entitiesList,
            projectCandidates: projectCandidates,
            agentPrompt: agentPrompt,
            provenance: result.provenance,
          );
        }
      } catch (e) {
        debugPrint("[MultilingualInterpretation] LLM generation error: $e. Falling back to deterministic parsing.");
      }
    }

    // Deterministic Fallback
    return _buildDeterministicInterpretation(
      noteId: noteId,
      rawTranscript: rawTranscript,
      normalizedText: normalized,
      langResult: langResult,
      knownProjects: knownProjects,
    );
  }

  /// Deterministic rule-based interpretation fallback (zero AI model required).
  static NoteInterpretation _buildDeterministicInterpretation({
    required String noteId,
    required String rawTranscript,
    required String normalizedText,
    required LanguageDetectionResult langResult,
    List<String> knownProjects = const [],
  }) {
    final lower = normalizedText.toLowerCase();
    final intents = <DetectedIntent>[];
    final entities = <ExtractedEntity>[];

    // Intent detection heuristics
    if (lower.contains('remind me') || lower.contains('repu gurtucheyi') || lower.contains('yaad dilana') || lower.contains('reminder')) {
      intents.add(const DetectedIntent(type: IntentType.reminder, confidence: 0.90));
    }
    if (lower.contains('todo') || lower.contains('task') || lower.contains('cheyali') || lower.contains('karna hai') || lower.contains('need to')) {
      intents.add(const DetectedIntent(type: IntentType.task, confidence: 0.88));
    }
    if (lower.contains('meeting') || lower.contains('schedule') || lower.contains('calendar') || lower.contains('kal subah') || lower.contains('repu madhyahnam')) {
      intents.add(const DetectedIntent(type: IntentType.calendarEvent, confidence: 0.85));
    }
    if (lower.contains('email') || lower.contains('mail pampali') || lower.contains('bhejna')) {
      intents.add(const DetectedIntent(type: IntentType.emailDraft, confidence: 0.88));
    }
    if (lower.contains('idea:') || lower.contains('thought:') || lower.contains('what if')) {
      intents.add(const DetectedIntent(type: IntentType.idea, confidence: 0.80));
    }

    if (intents.isEmpty) {
      intents.add(const DetectedIntent(type: IntentType.plainNote, confidence: 1.0));
    }

    // Temporal detection
    final temporalRegex = RegExp(
      r'\b(today|tomorrow|yesterday|tonight|next\s+week|next\s+monday|next\s+tuesday|next\s+wednesday|next\s+thursday|next\s+friday|next\s+saturday|next\s+sunday|at\s+\d{1,2}(?::\d{2})?\s*(?:am|pm)?|repu|ninna|aaj|kal)\b',
      caseSensitive: false,
    );
    for (final match in temporalRegex.allMatches(normalizedText)) {
      entities.add(ExtractedEntity(
        type: EntityType.dateTime,
        value: match.group(0)!,
        rawPhrase: match.group(0),
        confidence: 0.85,
      ));
    }

    // Project matching
    final projectCandidates = ProjectMatchingService.matchCandidates(
      noteText: normalizedText,
      knownProjects: knownProjects,
      extractedEntities: entities,
    );

    // Agent prompt detection
    final agentPrompt = AgentPromptService.detectFromText(normalizedText);

    return NoteInterpretation(
      schemaVersion: schemaVersion,
      noteId: noteId,
      rawTranscript: rawTranscript,
      normalizedText: normalizedText,
      primaryLanguage: langResult.primaryLanguage,
      mixedLanguages: langResult.mixedLanguages,
      intents: intents,
      entities: entities,
      projectCandidates: projectCandidates,
      agentPrompt: agentPrompt,
      provenance: AiProvenance(
        modelId: 'deterministic_rules_fallback',
        modelVersion: '1.0',
        promptVersion: '1.0',
        schemaVersion: schemaVersion,
        confidence: 0.75,
        rawOutput: rawTranscript,
        validatedOutput: null,
      ),
    );
  }
}
