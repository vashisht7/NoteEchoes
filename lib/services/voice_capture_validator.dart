class VoiceCaptureValidator {
  const VoiceCaptureValidator._();

  static const _nonSpeechResults = {
    'voice memo',
    'empty voice memo',
    'no speech',
    'no speech detected',
    'nothing heard',
    'silence',
    'audio',
    'recording',
    'gasp',
    'gasps',
    'gasping',
    'sigh',
    'sighs',
    'sighing',
    'breath',
    'breathing',
    'cough',
    'coughing',
    'sniff',
    'sniffing',
    'laughter',
    'laughing',
    'music',
    'background noise',
  };

  static const _fillers = {
    'um',
    'uh',
    'hmm',
    'hm',
    'ah',
    'er',
    'like',
    'gasp',
    'gasps',
    'gasping',
    'sigh',
    'sighs',
    'sighing',
    'breath',
    'breathing',
    'cough',
    'coughing',
    'sniff',
    'sniffing',
    'laughter',
    'laughing',
    'music',
  };

  static final _annotatedNonSpeech = RegExp(
    r'[\[\(\{<]\s*(?:gasp(?:s|ing)?|sigh(?:s|ing)?|breath(?:ing)?|cough(?:ing)?|sniff(?:ing)?|laugh(?:ter|ing)?|music|background\s+noise|inaudible|silence)\s*[\]\)\}>]',
    caseSensitive: false,
  );

  static final _asteriskNonSpeech = RegExp(
    r'\*+\s*(?:gasp(?:s|ing)?|sigh(?:s|ing)?|breath(?:ing)?|cough(?:ing)?|sniff(?:ing)?|laugh(?:ter|ing)?|music|background\s+noise|inaudible|silence)\s*\*+',
    caseSensitive: false,
  );

  /// Removes transcription annotations that describe sounds rather than words.
  /// Meaningful speech around an annotation is preserved verbatim.
  static String sanitizeTranscript(String value) => value
      .replaceAll(_annotatedNonSpeech, ' ')
      .replaceAll(_asteriskNonSpeech, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static bool hasMeaningfulSpeech(String value) {
    final normalized = sanitizeTranscript(value)
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty || _nonSpeechResults.contains(normalized)) {
      return false;
    }
    return normalized
        .split(' ')
        .any((token) => token.isNotEmpty && !_fillers.contains(token));
  }
}
