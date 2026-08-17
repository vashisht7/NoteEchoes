import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/ai_feature_flags.dart';

enum ModelHealth { checking, missing, ready, needsRepair, unavailable }

@immutable
class LocalModelStatus {
  final String id;
  final ModelHealth health;
  final int sizeBytes;
  final String localPath;
  final String reason;

  const LocalModelStatus({
    required this.id,
    required this.health,
    this.sizeBytes = 0,
    this.localPath = '',
    this.reason = '',
  });

  const LocalModelStatus.checking(this.id)
    : health = ModelHealth.checking,
      sizeBytes = 0,
      localPath = '',
      reason = '';

  bool get isReady => health == ModelHealth.ready;
  bool get hasFiles => sizeBytes > 0;

  factory LocalModelStatus.fromNative(String id, Map<Object?, Object?> value) {
    final installed = value['installed'] == true;
    final verified = value['verified'] == true;
    return LocalModelStatus(
      id: id,
      health: verified
          ? ModelHealth.ready
          : installed
          ? ModelHealth.needsRepair
          : ModelHealth.missing,
      sizeBytes: (value['sizeBytes'] as num?)?.toInt() ?? 0,
      localPath: value['path'] as String? ?? '',
      reason: value['reason'] as String? ?? '',
    );
  }
}

/// The single source of truth for downloadable models. Native code verifies
/// the actual cache contents; saved preferences are repaired to match it.
class ModelAvailabilityService extends ChangeNotifier {
  ModelAvailabilityService._();
  static final instance = ModelAvailabilityService._();

  static const _mlxChannel = MethodChannel('notechoes/mlx_text_generation');
  static const _speechChannel = MethodChannel('notechoes/offline_speech');

  LocalModelStatus qwen = const LocalModelStatus.checking('qwen3-0.6b');
  LocalModelStatus whisper = const LocalModelStatus.checking('whisper-base');
  bool _refreshing = false;

  bool get isRefreshing => _refreshing;
  bool get enhancedSearchAvailable => qwen.isReady;
  bool get documentChatAvailable => qwen.isReady;
  bool get noteInsightsAvailable => qwen.isReady;
  bool get offlineMultilingualSpeechAvailable => whisper.isReady;

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    notifyListeners();
    try {
      qwen = await _readStatus(_mlxChannel, 'status', qwen.id);
      whisper = await _readStatus(_speechChannel, 'whisperStatus', whisper.id);
      await _synchronizeFeatureFlags();
    } finally {
      _refreshing = false;
      notifyListeners();
    }
  }

  Future<LocalModelStatus> _readStatus(
    MethodChannel channel,
    String method,
    String id,
  ) async {
    try {
      final result = await channel.invokeMapMethod<Object?, Object?>(method);
      if (result == null) {
        return LocalModelStatus(
          id: id,
          health: ModelHealth.unavailable,
          reason: 'Model status is unavailable on this device.',
        );
      }
      return LocalModelStatus.fromNative(id, result);
    } on MissingPluginException {
      return LocalModelStatus(
        id: id,
        health: ModelHealth.unavailable,
        reason: 'Model verification is available on iPhone and iPad.',
      );
    } on PlatformException catch (error) {
      return LocalModelStatus(
        id: id,
        health: ModelHealth.unavailable,
        reason: error.message ?? 'Could not inspect this model.',
      );
    }
  }

  Future<void> _synchronizeFeatureFlags() async {
    final flags = AiFeatureFlags.instance;
    final qwenReady = qwen.isReady;
    await Future.wait([
      flags.setLocalLlmEnabled(qwenReady),
      flags.setNoteAnalysisEnabled(qwenReady),
      flags.setReminderExtractionEnabled(qwenReady),
      flags.setPdfIngestionEnabled(qwenReady),
      flags.setCrossNoteSearchEnabled(qwenReady),
      flags.setDocumentChatEnabled(qwenReady),
      flags.setJournalingMemoryEnabled(qwenReady),
      flags.setWhisperSttEnabled(whisper.isReady),
    ]);
  }

  Future<void> removeQwen() async {
    await _mlxChannel.invokeMethod<Object?>('deleteCachedModel');
    await refresh();
  }

  Future<void> removeWhisper() async {
    await _speechChannel.invokeMethod<Object?>('deleteWhisperBase');
    await refresh();
  }
}
