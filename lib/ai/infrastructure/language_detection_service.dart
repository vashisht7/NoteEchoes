// language_detection_service.dart
// Robust multilingual and code-mixing language detector.
// Evaluates script ratios (Telugu, Devanagari), Romanized lexicons, and Whisper output.

class LanguageDetectionResult {
  final String primaryLanguage; // 'en', 'te', 'hi', 'mixed'
  final List<String> mixedLanguages;
  final double confidence;
  final bool isRomanized;
  final Map<String, double> scriptRatios;

  const LanguageDetectionResult({
    required this.primaryLanguage,
    this.mixedLanguages = const [],
    required this.confidence,
    this.isRomanized = false,
    this.scriptRatios = const {},
  });
}

class LanguageDetectionService {
  // Romanized Telugu high-frequency markers
  static const _romanizedTeluguMarkers = {
    'nenu', 'meeru', 'cheppandi', 'cheyali', 'cheyandi', 'unnanu', 'chesanu',
    'repati', 'repu', 'vachanu', 'enti', 'ela', 'undi', 'chesi', 'manchi',
    'ippudu', 'roju', 'kuda', 'gurinchi', 'cheyadam', 'chudali', 'chepparu',
    'telugu', 'andaru', 'kavali', 'pampali', 'matladali', 'pedda', 'chinnadi'
  };

  // Romanized Hindi high-frequency markers
  static const _romanizedHindiMarkers = {
    'karna', 'karenge', 'hoga', 'hai', 'kya', 'nahi', 'accha', 'kal',
    'mujhe', 'hum', 'batao', 'raha', 'rahe', 'wala', 'karke', 'baat',
    'aaj', 'shuru', 'bhejo', 'dekho', 'samajh', 'kaam', 'karte', 'kripya'
  };

  static LanguageDetectionResult detect(
    String text, {
    String? whisperReportedLang,
    String? userPreferredLang,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return LanguageDetectionResult(
        primaryLanguage: userPreferredLang ?? 'en',
        mixedLanguages: [userPreferredLang ?? 'en'],
        confidence: 1.0,
      );
    }

    // 1. Script count
    int teluguCount = 0;
    int devanagariCount = 0;
    int latinCount = 0;
    int totalLetters = 0;

    for (final rune in trimmed.runes) {
      if (rune >= 0x0C00 && rune <= 0x0C7F) {
        teluguCount++;
        totalLetters++;
      } else if (rune >= 0x0900 && rune <= 0x097F) {
        devanagariCount++;
        totalLetters++;
      } else if ((rune >= 0x0041 && rune <= 0x005A) ||
          (rune >= 0x0061 && rune <= 0x007A)) {
        latinCount++;
        totalLetters++;
      }
    }

    final teluguRatio = totalLetters > 0 ? teluguCount / totalLetters : 0.0;
    final devanagariRatio = totalLetters > 0 ? devanagariCount / totalLetters : 0.0;
    final latinRatio = totalLetters > 0 ? latinCount / totalLetters : 0.0;

    final scriptRatios = {
      'te': teluguRatio,
      'hi': devanagariRatio,
      'en': latinRatio,
    };

    // 2. Pure native or code-mixed script cases
    if (teluguRatio >= 0.15 && latinRatio >= 0.15) {
      return LanguageDetectionResult(
        primaryLanguage: 'mixed',
        mixedLanguages: ['te', 'en'],
        confidence: 0.95,
        scriptRatios: scriptRatios,
      );
    }
    if (devanagariRatio >= 0.15 && latinRatio >= 0.15) {
      return LanguageDetectionResult(
        primaryLanguage: 'mixed',
        mixedLanguages: ['hi', 'en'],
        confidence: 0.95,
        scriptRatios: scriptRatios,
      );
    }
    if (teluguRatio > 0.50) {
      return LanguageDetectionResult(
        primaryLanguage: 'te',
        mixedLanguages: ['te'],
        confidence: 0.98,
        scriptRatios: scriptRatios,
      );
    }
    if (devanagariRatio > 0.50) {
      return LanguageDetectionResult(
        primaryLanguage: 'hi',
        mixedLanguages: ['hi'],
        confidence: 0.98,
        scriptRatios: scriptRatios,
      );
    }

    // 3. Romanized lexicon evaluation (when text is largely Latin script)
    final words = trimmed
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();

    int romanizedTeMatches = 0;
    int romanizedHiMatches = 0;
    int englishWords = 0;

    for (final w in words) {
      if (_romanizedTeluguMarkers.contains(w)) romanizedTeMatches++;
      if (_romanizedHindiMarkers.contains(w)) romanizedHiMatches++;
      // crude english word indicator
      if (!w.contains('ch') && !w.contains('sh') && (w.endsWith('ing') || w.endsWith('ed') || w.startsWith('th'))) {
        englishWords++;
      }
    }

    final totalEvaluated = words.isEmpty ? 1 : words.length;
    final teScore = romanizedTeMatches / totalEvaluated;
    final hiScore = romanizedHiMatches / totalEvaluated;

    if (teScore >= 0.15 || romanizedTeMatches >= 2) {
      final isMixed = englishWords > 0 || (whisperReportedLang == 'en' && romanizedTeMatches < words.length);
      return LanguageDetectionResult(
        primaryLanguage: isMixed ? 'mixed' : 'te',
        mixedLanguages: isMixed ? ['te', 'en'] : ['te'],
        confidence: 0.90,
        isRomanized: true,
        scriptRatios: scriptRatios,
      );
    }

    if (hiScore >= 0.15 || romanizedHiMatches >= 2) {
      final isMixed = englishWords > 0 || (whisperReportedLang == 'en' && romanizedHiMatches < words.length);
      return LanguageDetectionResult(
        primaryLanguage: isMixed ? 'mixed' : 'hi',
        mixedLanguages: isMixed ? ['hi', 'en'] : ['hi'],
        confidence: 0.90,
        isRomanized: true,
        scriptRatios: scriptRatios,
      );
    }

    // 4. Default to English or Whisper reported language
    final primary = (whisperReportedLang == 'te' || whisperReportedLang == 'hi')
        ? whisperReportedLang!
        : 'en';

    return LanguageDetectionResult(
      primaryLanguage: primary,
      mixedLanguages: [primary],
      confidence: 0.85,
      scriptRatios: scriptRatios,
    );
  }
}
