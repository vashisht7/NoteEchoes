class NoteNode {
  final String id;
  final String title;
  final String snippet;

  const NoteNode({
    required this.id,
    required this.title,
    required this.snippet,
  });
}

enum VoiceState { listening, thinking, speaking }
