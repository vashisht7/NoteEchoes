import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/ai_feature_flags.dart';
import 'e5_embedding_service.dart';
import 'offline_speech_bridge.dart';

enum ModelHealth { checking, missing, ready, needsRepair, unavailable }

@immutable
class LocalModelStatus {
  final String id;
  final ModelHealth health;
  final int sizeBytes;
  final String localPath;
  final String reason;
  final String? reasonCode;
  final String? sdkVersion;
  final List<String> missingComponents;

  const LocalModelStatus({
    required this.id,
    required this.health,
    this.sizeBytes = 0,
    this.localPath = '',
    this.reason = '',
    this.reasonCode,
    this.sdkVersion,
    this.missingComponents = const [],
  });

  const LocalModelStatus.checking(this.id)
    : health = ModelHealth.checking,
      sizeBytes = 0,
      localPath = '',
      reason = '',
      reasonCode = null,
      sdkVersion = null,
      missingComponents = const [];

  bool get isReady => health == ModelHealth.ready;
  bool get hasFiles => sizeBytes > 0;

  factory LocalModelStatus.fromNative(String id, Map<Object?, Object?> value) {
    final installed = value['installed'] == true;
    final verified = value['verified'] == true;
    final state = value['state'] as String? ?? '';
    final isReady = verified || state == 'ready' || state == 'downloaded';
    return LocalModelStatus(
      id: id,
      health: isReady
          ? ModelHealth.ready
          : (installed || state == 'needsRepair' || state == 'partial')
          ? ModelHealth.needsRepair
          : (state == 'failed' ? ModelHealth.needsRepair : ModelHealth.missing),
      sizeBytes: (value['sizeBytes'] as num?)?.toInt() ?? 0,
      localPath: value['path'] as String? ?? '',
      reason: value['reason'] as String? ?? (value['error_message'] as String? ?? ''),
      reasonCode: value['error_code'] as String?,
      sdkVersion: value['sdkVersion'] as String?,
      missingComponents: (value['missingComponents'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  factory LocalModelStatus.fromWhisperDetails(WhisperModelDetails details) {
    return LocalModelStatus(
      id: 'whisper-base',
      health: details.isReady
          ? ModelHealth.ready
          : (details.needsRepair || details.state == 'failed')
          ? ModelHealth.needsRepair
          : ModelHealth.missing,
      sizeBytes: details.sizeBytes,
      localPath: details.relativePath,
      reason: details.reason ?? '',
      reasonCode: details.reasonCode,
      sdkVersion: details.sdkVersion,
      missingComponents: details.missingComponents,
    );
  }
}

/// The single source of truth for downloadable models. Native code verifies
/// the actual cache contents; saved preferences are repaired to match it.
class ModelAvailabilityService extends ChangeNotifier {
  ModelAvailabilityService._();
  static final instance = ModelAvailabilityService._();

  static const _mlxChannel = MethodChannel('noteechoes/mlx_text_generation');

  LocalModelStatus qwen = const LocalModelStatus.checking('qwen3-0.6b');
  LocalModelStatus whisper = const LocalModelStatus.checking('whisper-base');
  LocalModelStatus embedding = const LocalModelStatus.checking(
    E5EmbeddingService.modelVersion,
  );
  bool _refreshing = false;

  bool get isRefreshing => _refreshing;
  bool get enhancedSearchAvailable => qwen.isReady;
  bool get documentChatAvailable => qwen.isReady;
  bool get noteInsightsAvailable => qwen.isReady;
  bool get offlineMultilingualSpeechAvailable => whisper.isReady;
  bool get semanticTopicsAvailable => embedding.isReady;

  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    notifyListeners();
    try {
      qwen = await _readStatus(_mlxChannel, 'status', qwen.id);
      final whisperDetails = await OfflineSpeechBridge.instance.getWhisperStatus();
      whisper = LocalModelStatus.fromWhisperDetails(whisperDetails);
      embedding = await E5EmbeddingService.instance.status();
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
    await OfflineSpeechBridge.instance.deleteWhisperBase();
    await refresh();
  }

  Future<void> removeEmbedding() async {
    await E5EmbeddingService.instance.remove();
    await refresh();
  }
}
