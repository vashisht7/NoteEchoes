/// Single Dart-side identity for the production multilingual voice
/// intent/action model. Native iOS pins the same repository at an immutable
/// commit. The repository name retains "english" for download compatibility.
abstract final class NoteEchoesActionModelIdentity {
  static const repositoryId =
      'Vashisht7/noteechoes-english-voice-intent-action-qwen3-0.6b-mlx-8bit';
  static const modelId =
      'noteechoes-english-voice-intent-action-qwen3-0.6b-mlx-8bit';
  static const displayName =
      'NoteEchoes Multilingual Voice Intent & Action · Qwen3 0.6B · MLX 8-bit';
  static const releaseVersion = '2026.08-combined-action';
  static const downloadSize = '649 MB download';
}
