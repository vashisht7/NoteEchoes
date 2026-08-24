class VoiceNoteTitleService {
  const VoiceNoteTitleService._();

  /// Product-side guard for model titles. Compact local models occasionally
  /// echo the complete utterance, so the app always enforces a scannable title.
  static String concise({
    required String proposedTitle,
    required String spokenText,
  }) {
    var candidate = _clean(proposedTitle);
    final spoken = _clean(spokenText);

    if (candidate.isEmpty || candidate == spoken || candidate.length > 72) {
      candidate = spoken;
    }

    candidate = candidate.replaceFirst(
      RegExp(
        r'^(?:please\s+|hey\s+|note\s+to\s+self\s+|remember\s+that\s+|'
        r'i\s+(?:want|need)\s+to\s+|create\s+(?:a\s+)?(?:note|checklist)\s+(?:that|to|with)?\s*|'
        r'నేను\s+|నాకు\s+|कृपया\s+|मुझे\s+)',
        caseSensitive: false,
      ),
      '',
    );

    final firstThought = candidate.split(RegExp(r'[\n.!?।]+')).first.trim();
    candidate = firstThought.isEmpty ? candidate : firstThought;

    final words = candidate.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    candidate = words.take(6).join(' ');
    if (candidate.length > 48) {
      final prefix = candidate.substring(0, 48);
      final boundary = prefix.lastIndexOf(' ');
      candidate = prefix.substring(0, boundary >= 18 ? boundary : 48);
    }

    candidate = candidate
        .replaceAll(RegExp(r'^[\s:;,\-–—"“”]+|[\s:;,\-–—"“”]+$'), '')
        .trim();
    if (candidate.isEmpty) return 'Voice Note';
    return candidate;
  }

  static String _clean(String value) => value
      .replaceAll(RegExp(r'[#*_`]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
