import '../domain/transcript.dart';
import '../domain/ai_models.dart';
import '../providers/transcription_provider.dart';

class DolphinSherpaProvider implements TranscriptionProvider {
  @override
  String get displayName => 'Dolphin Base INT8';

  @override
  String get modelVersion => '1.0.0';

  @override
  bool get isLoaded => true;

  @override
  Future<void> load() async {}

  @override
  Future<void> unload() async {}

  @override
  bool get supportsAutoLanguage => true;

  @override
  List<String> get supportedLanguages => ['en', 'es', 'fr'];

  @override
  Future<TranscriptResult> transcribe(
    String audioFilePath, {
    required String noteId,
    AudioLanguage language = AudioLanguage.auto,
    void Function(TranscriptSegment segment)? onSegment,
    void Function(double progress)? onProgress,
  }) async {
    final segment = TranscriptSegment(
      startMs: 0,
      endMs: 1000,
      text: 'Stub transcript text.',
      language: language,
      confidence: 1.0,
      sequenceNumber: 0,
    );

    onSegment?.call(segment);
    onProgress?.call(1.0);

    return TranscriptResult(
      noteId: noteId,
      segments: [segment],
      dominantLanguage: language,
      modelVersion: modelVersion,
      realTimeFactor: 1.0,
    );
  }

  @override
  Future<void> cancel(String transcriptionId) async {}
}
