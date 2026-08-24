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
  };

  static const _fillers = {'um', 'uh', 'hmm', 'hm', 'ah', 'er', 'like'};

  static bool hasMeaningfulSpeech(String value) {
    final normalized = value
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
