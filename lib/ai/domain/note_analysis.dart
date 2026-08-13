// note_analysis.dart
// Structured output from LLM note analysis — maps to the JSON schema
// defined in the implementation specification § 10.

/// The high-level category of a note.
enum NoteType {
  meeting,
  actionList,
  reminder,
  journal,
  travelPlan,
  lecture,
  brainstorm,
  general,
  unknown,
}

extension NoteTypeExt on NoteType {
  String get jsonKey => name;

  static NoteType fromString(String? s) {
    if (s == null) return NoteType.unknown;
    switch (s.toLowerCase()) {
      case 'meeting':
        return NoteType.meeting;
      case 'action_list':
      case 'actionlist':
        return NoteType.actionList;
      case 'reminder':
        return NoteType.reminder;
      case 'journal':
        return NoteType.journal;
      case 'travel_plan':
      case 'travelplan':
        return NoteType.travelPlan;
      case 'lecture':
        return NoteType.lecture;
      case 'brainstorm':
        return NoteType.brainstorm;
      case 'general':
        return NoteType.general;
      default:
        return NoteType.unknown;
    }
  }
}

/// A single action item extracted from note content.
class ActionItem {
  final String id;
  final String task;
  final String? assignee;
  final DateTime? dueDate;
  final double confidence;
  final String evidenceText;

  const ActionItem({
    required this.id,
    required this.task,
    this.assignee,
    this.dueDate,
    required this.confidence,
    required this.evidenceText,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
        id: json['id'] as String? ?? '',
        task: json['task'] as String? ?? '',
        assignee: json['assignee'] as String?,
        dueDate: json['due_date'] != null
            ? DateTime.tryParse(json['due_date'] as String)
            : null,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
        evidenceText: json['evidence_text'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'task': task,
        if (assignee != null) 'assignee': assignee,
        if (dueDate != null) 'due_date': dueDate!.toIso8601String(),
        'confidence': confidence,
        'evidence_text': evidenceText,
      };
}

/// A calendar event extracted from note content.
class CalendarEvent {
  final String id;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isAllDay;
  final String? location;
  final List<String> attendees;
  final String? notes;
  final double confidence;
  final String evidenceText;

  const CalendarEvent({
    required this.id,
    required this.title,
    this.startDate,
    this.endDate,
    this.isAllDay = false,
    this.location,
    this.attendees = const [],
    this.notes,
    required this.confidence,
    required this.evidenceText,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        startDate: json['start_date'] != null
            ? DateTime.tryParse(json['start_date'] as String)
            : null,
        endDate: json['end_date'] != null
            ? DateTime.tryParse(json['end_date'] as String)
            : null,
        isAllDay: json['is_all_day'] as bool? ?? false,
        location: json['location'] as String?,
        attendees: (json['attendees'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        notes: json['notes'] as String?,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
        evidenceText: json['evidence_text'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (startDate != null) 'start_date': startDate!.toIso8601String(),
        if (endDate != null) 'end_date': endDate!.toIso8601String(),
        'is_all_day': isAllDay,
        if (location != null) 'location': location,
        'attendees': attendees,
        if (notes != null) 'notes': notes,
        'confidence': confidence,
        'evidence_text': evidenceText,
      };
}

/// A reminder extracted from note content.
class Reminder {
  final String id;
  final String title;
  final DateTime? triggerDate;
  final bool isUncertain; // "sometime next week"
  final double confidence;
  final String evidenceText;

  const Reminder({
    required this.id,
    required this.title,
    this.triggerDate,
    this.isUncertain = false,
    required this.confidence,
    required this.evidenceText,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        triggerDate: json['trigger_date'] != null
            ? DateTime.tryParse(json['trigger_date'] as String)
            : null,
        isUncertain: json['is_uncertain'] as bool? ?? false,
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.5,
        evidenceText: json['evidence_text'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (triggerDate != null)
          'trigger_date': triggerDate!.toIso8601String(),
        'is_uncertain': isUncertain,
        'confidence': confidence,
        'evidence_text': evidenceText,
      };
}

/// Travel details extracted from note content.
class TravelDetail {
  final String id;
  final String destination;
  final DateTime? departureDate;
  final DateTime? returnDate;
  final List<String> transportModes;
  final String? accommodation;
  final String evidenceText;

  const TravelDetail({
    required this.id,
    required this.destination,
    this.departureDate,
    this.returnDate,
    this.transportModes = const [],
    this.accommodation,
    required this.evidenceText,
  });

  factory TravelDetail.fromJson(Map<String, dynamic> json) => TravelDetail(
        id: json['id'] as String? ?? '',
        destination: json['destination'] as String? ?? '',
        departureDate: json['departure_date'] != null
            ? DateTime.tryParse(json['departure_date'] as String)
            : null,
        returnDate: json['return_date'] != null
            ? DateTime.tryParse(json['return_date'] as String)
            : null,
        transportModes: (json['transport_modes'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        accommodation: json['accommodation'] as String?,
        evidenceText: json['evidence_text'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'destination': destination,
        if (departureDate != null)
          'departure_date': departureDate!.toIso8601String(),
        if (returnDate != null)
          'return_date': returnDate!.toIso8601String(),
        'transport_modes': transportModes,
        if (accommodation != null) 'accommodation': accommodation,
        'evidence_text': evidenceText,
      };
}

/// Full structured output of one LLM note analysis pass.
class NoteAnalysisResult {
  final String noteId;
  final String modelVersion;
  final String detectedLanguage;
  final NoteType noteType;
  final String generatedTitle;
  final String summary;
  final String englishRetrievalSummary;
  final List<String> topics;
  final List<String> people;
  final List<String> places;
  final List<String> suggestedTags;
  final List<ActionItem> actionItems;
  final List<CalendarEvent> events;
  final List<Reminder> reminders;
  final List<TravelDetail> travelDetails;
  final DateTime analysedAt;

  const NoteAnalysisResult({
    required this.noteId,
    required this.modelVersion,
    required this.detectedLanguage,
    required this.noteType,
    required this.generatedTitle,
    required this.summary,
    required this.englishRetrievalSummary,
    this.topics = const [],
    this.people = const [],
    this.places = const [],
    this.suggestedTags = const [],
    this.actionItems = const [],
    this.events = const [],
    this.reminders = const [],
    this.travelDetails = const [],
    required this.analysedAt,
  });

  factory NoteAnalysisResult.fromJson(Map<String, dynamic> json) =>
      NoteAnalysisResult(
        noteId: json['note_id'] as String? ?? '',
        modelVersion: json['model_version'] as String? ?? '',
        detectedLanguage: json['detected_language'] as String? ?? 'en',
        noteType: NoteTypeExt.fromString(json['note_type'] as String?),
        generatedTitle: json['generated_title'] as String? ?? 'Untitled Note',
        summary: json['summary'] as String? ?? '',
        englishRetrievalSummary:
            json['english_retrieval_summary'] as String? ?? '',
        topics: (json['topics'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        people: (json['people'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        places: (json['places'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        suggestedTags: (json['suggested_tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        actionItems: (json['action_items'] as List<dynamic>?)
                ?.map((e) =>
                    ActionItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        events: (json['events'] as List<dynamic>?)
                ?.map((e) =>
                    CalendarEvent.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        reminders: (json['reminders'] as List<dynamic>?)
                ?.map((e) =>
                    Reminder.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        travelDetails: (json['travel_details'] as List<dynamic>?)
                ?.map((e) =>
                    TravelDetail.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        analysedAt: DateTime.tryParse(
                json['analysed_at'] as String? ?? '') ??
            DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'note_id': noteId,
        'model_version': modelVersion,
        'detected_language': detectedLanguage,
        'note_type': noteType.jsonKey,
        'generated_title': generatedTitle,
        'summary': summary,
        'english_retrieval_summary': englishRetrievalSummary,
        'topics': topics,
        'people': people,
        'places': places,
        'suggested_tags': suggestedTags,
        'action_items': actionItems.map((e) => e.toJson()).toList(),
        'events': events.map((e) => e.toJson()).toList(),
        'reminders': reminders.map((e) => e.toJson()).toList(),
        'travel_details': travelDetails.map((e) => e.toJson()).toList(),
        'analysed_at': analysedAt.toIso8601String(),
      };
}
