class VoiceCaptureControl {
  static final RegExp _punctuation = RegExp(
    r'[^\p{L}\p{M}\p{N}\s]',
    unicode: true,
  );

  static const Set<String> _cancelCommands = {
    'cancel',
    'cancel that',
    'discard that',
    'never mind',
    'nevermind',
    'do not save that',
    'dont save that',
    'रद्द करो',
    'इसे रद्द करो',
    'इसे सेव मत करो',
    'సేవ్ చేయొద్దు',
    'రద్దు చేయి',
    'ఇది రద్దు చేయి',
  };

  static bool isCancelCommand(String transcript) {
    final normalized = transcript
        .toLowerCase()
        .replaceAll(_punctuation, ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return _cancelCommands.contains(normalized);
  }
}
