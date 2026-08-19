import '../models/note_model.dart';

class NoteAnalysisResult {
  final String title;
  final String summarySnippet;
  final List<String> categories;
  final List<CheckListItem> extractedChecklist;
  final NoteContentType contentType;

  const NoteAnalysisResult({
    required this.title,
    required this.summarySnippet,
    required this.categories,
    required this.extractedChecklist,
    required this.contentType,
  });
}

class AiCategorizationEngine {
  static final AiCategorizationEngine _instance = AiCategorizationEngine._internal();
  factory AiCategorizationEngine() => _instance;
  AiCategorizationEngine._internal();

  /// Intelligently analyzes note text, extracts meaning, generates a title,
  /// builds checklists, and assigns structured categories.
  NoteAnalysisResult analyzeNote(String rawContent) {
    final text = rawContent.trim();
    if (text.isEmpty) {
      return const NoteAnalysisResult(
        title: "Quick Voice Note",
        summarySnippet: "Empty note",
        categories: ["voice-memo"],
        extractedChecklist: [],
        contentType: NoteContentType.textOnly,
      );
    }

    final lower = text.toLowerCase();
    final categories = <String>{};
    final checklist = <CheckListItem>[];

    // 1. Math & Formulas
    final hasMath = lower.contains("math") ||
        lower.contains("equation") ||
        lower.contains("formula") ||
        lower.contains("integral") ||
        lower.contains("derivative") ||
        lower.contains(r"$$") ||
        lower.contains(r"\int") ||
        lower.contains(r"\sum") ||
        lower.contains(r"\frac") ||
        RegExp(r'\b\d+\s*[\+\-\*\/]\s*\d+\b').hasMatch(text);
    if (hasMath) {
      categories.add("math");
    }

    // 2. Grocery & Shopping
    final hasGrocery = lower.contains("grocery") ||
        lower.contains("milk") ||
        lower.contains("coffee") ||
        lower.contains("bread") ||
        lower.contains("eggs") ||
        lower.contains("butter") ||
        lower.contains("fruits") ||
        lower.contains("vegetables") ||
        lower.contains("buy") ||
        lower.contains("pantry") ||
        lower.contains("supermarket") ||
        lower.contains("store");
    if (hasGrocery) {
      categories.add("grocery");
    }

    // 3. Tasks & Todo Actions
    final hasTasks = lower.contains("todo") ||
        lower.contains("task") ||
        lower.contains("sprint") ||
        lower.contains("deadline") ||
        lower.contains("finish") ||
        lower.contains("complete") ||
        lower.contains("due") ||
        lower.contains("deliverable") ||
        lower.contains("fix") ||
        lower.contains("remember to") ||
        lower.contains("need to");
    if (hasTasks) {
      categories.add("tasks");
    }

    // 4. Meetings & Discussions
    final hasMeeting = lower.contains("meeting") ||
        lower.contains("discussion") ||
        lower.contains("agenda") ||
        lower.contains("client") ||
        lower.contains("sync") ||
        lower.contains("call") ||
        lower.contains("standup") ||
        lower.contains("presentation");
    if (hasMeeting) {
      categories.add("meeting");
    }

    // 5. Ideas & Brainstorming
    final hasIdeas = lower.contains("idea") ||
        lower.contains("brainstorm") ||
        lower.contains("concept") ||
        lower.contains("innovation") ||
        lower.contains("startup") ||
        lower.contains("feature") ||
        lower.contains("product idea") ||
        lower.contains("what if");
    if (hasIdeas) {
      categories.add("ideas");
    }

    // 6. UI / UX Design & Architecture
    final hasDesign = lower.contains("design") ||
        lower.contains("ui") ||
        lower.contains("ux") ||
        lower.contains("layout") ||
        lower.contains("color") ||
        lower.contains("token") ||
        lower.contains("glassmorphism") ||
        lower.contains("typography") ||
        lower.contains("animation") ||
        lower.contains("dark mode");
    if (hasDesign) {
      categories.add("design");
    }

    // 7. Finance & Expenses
    final hasFinance = lower.contains("budget") ||
        lower.contains("expense") ||
        lower.contains("cost") ||
        lower.contains("price") ||
        lower.contains("dollar") ||
        lower.contains("payment") ||
        lower.contains("invoice") ||
        lower.contains("bill") ||
        lower.contains(r"$") ||
        lower.contains("invest");
    if (hasFinance) {
      categories.add("finance");
    }

    // 8. Study & Research
    final hasStudy = lower.contains("study") ||
        lower.contains("research") ||
        lower.contains("learn") ||
        lower.contains("paper") ||
        lower.contains("exam") ||
        lower.contains("chapter") ||
        lower.contains("algorithm") ||
        lower.contains("notes on");
    if (hasStudy) {
      categories.add("study");
    }

    // 9. Document & PDF Excerpt
    final hasDoc = lower.contains("pdf") ||
        lower.contains("document") ||
        lower.contains("table") ||
        lower.contains("specification") ||
        lower.contains("summary of");
    if (hasDoc) {
      categories.add("pdf-doc");
    }

    // 10. Reminders & Alerts
    final hasReminder = lower.contains("remind") ||
        lower.contains("reminder") ||
        lower.contains("alert") ||
        lower.contains("don't forget") ||
        lower.contains("notify me") ||
        lower.contains("alarm");
    if (hasReminder) {
      categories.add("reminders");
    }

    // 11. Calendar Events & Schedules
    final hasEvent = lower.contains("calendar") ||
        lower.contains("schedule") ||
        lower.contains("appointment") ||
        lower.contains("tomorrow at") ||
        lower.contains("o'clock") ||
        lower.contains("am ") ||
        lower.contains("pm ") ||
        lower.contains("birthday") ||
        lower.contains("anniversary") ||
        lower.contains("event");
    if (hasEvent) {
      categories.add("events");
    }

    // 12. Travel & Trips
    final hasTravel = lower.contains("flight") ||
        lower.contains("hotel") ||
        lower.contains("airport") ||
        lower.contains("trip") ||
        lower.contains("travel") ||
        lower.contains("vacation") ||
        lower.contains("passport") ||
        lower.contains("booking") ||
        lower.contains("itinerary");
    if (hasTravel) {
      categories.add("travel");
    }

    // 13. Health & Fitness
    final hasHealth = lower.contains("workout") ||
        lower.contains("gym") ||
        lower.contains("doctor") ||
        lower.contains("medicine") ||
        lower.contains("prescription") ||
        lower.contains("diet") ||
        lower.contains("health") ||
        lower.contains("exercise");
    if (hasHealth) {
      categories.add("health");
    }

    // Default tag if none detected
    if (categories.isEmpty) {
      categories.add("voice-memo");
    }

    // 10. Extract checklist items if list patterns exist
    final lines = text.split('\n');
    for (final line in lines) {
      final cleanLine = line.trim();
      if (cleanLine.startsWith('- [ ]') || cleanLine.startsWith('- [x]')) {
        final itemText = cleanLine.substring(5).trim();
        if (itemText.isNotEmpty) {
          checklist.add(CheckListItem(
            id: "chk_${DateTime.now().millisecondsSinceEpoch}_${checklist.length}",
            text: itemText,
            isCompleted: cleanLine.startsWith('- [x]'),
          ));
        }
      } else if (cleanLine.startsWith('- ') || cleanLine.startsWith('• ') || RegExp(r'^\d+\.\s+').hasMatch(cleanLine)) {
        final itemText = cleanLine.replaceFirst(RegExp(r'^[-•\d\.]+\s*'), '').trim();
        if (itemText.isNotEmpty && (hasGrocery || hasTasks)) {
          checklist.add(CheckListItem(
            id: "chk_${DateTime.now().millisecondsSinceEpoch}_${checklist.length}",
            text: itemText,
            isCompleted: false,
          ));
        }
      }
    }

    // 11. Smart Title Generation
    String generatedTitle = _generateTitle(text, categories);

    // 12. Smart 2-line preview snippet
    String summarySnippet = _generateSummarySnippet(text);

    return NoteAnalysisResult(
      title: generatedTitle,
      summarySnippet: summarySnippet,
      categories: categories.toList(),
      extractedChecklist: checklist,
      contentType: NoteContentType.textOnly,
    );
  }

  String _generateTitle(String text, Set<String> categories) {
    // 1. Clean leading punctuation, checkboxes, bullet points
    var cleanText = text.split('\n').first.trim().replaceAll(RegExp(r'^[#\-•\d\.\s]+'), '');

    // 2. Strip common conversational filler prefixes for a clean minimal highlight
    cleanText = cleanText.replaceFirst(
      RegExp(r"^(remember to|need to|make sure to|don't forget to|hey can you|please|i want to|so i was thinking that|note to self|voice memo|recording|just wanted to)\s+", caseSensitive: false),
      '',
    ).trim();

    if (cleanText.isEmpty) {
      cleanText = text.trim();
    }

    if (cleanText.isEmpty) {
      return "Voice Note";
    }

    // 3. Keep title minimal (max 5 words / 32 chars)
    final words = cleanText.split(RegExp(r'\s+'));
    if (words.length > 5) {
      final shortTitle = words.take(5).join(' ');
      return _capitalize(shortTitle.length > 32 ? "${shortTitle.substring(0, 30)}..." : shortTitle);
    }

    if (cleanText.length <= 35) {
      return _capitalize(cleanText);
    }

    final truncated = cleanText.substring(0, 32);
    final lastSpace = truncated.lastIndexOf(' ');
    return _capitalize("${lastSpace > 12 ? truncated.substring(0, lastSpace) : truncated}...");
  }

  String _generateSummarySnippet(String text) {
    final clean = text.replaceAll(RegExp(r'[\#\*\`\$\-]'), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (clean.length <= 130) {
      return clean.isNotEmpty ? clean : "Voice recorded thought note.";
    }
    final truncated = clean.substring(0, 128);
    final lastSpace = truncated.lastIndexOf(' ');
    return "${lastSpace > 80 ? truncated.substring(0, lastSpace) : truncated}...";
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
