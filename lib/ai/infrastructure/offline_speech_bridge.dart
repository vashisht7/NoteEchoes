import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/ai_models.dart';

/// Progress update event emitted during Whisper model downloading, specialization, or loading.
class WhisperDownloadProgress {
  final double progress;
  final int percent;
  final int completedBytes;
  final int totalBytes;
  final String statusText;

  const WhisperDownloadProgress({
    required this.progress,
    required this.percent,
    required this.completedBytes,
    required this.totalBytes,
    required this.statusText,
  });

  factory WhisperDownloadProgress.fromMap(Map<Object?, Object?> map) {
    final progress = (map['progress'] as num?)?.toDouble() ?? 0.0;
    final percent = (map['percent'] as num?)?.toInt() ?? (progress * 100).round();
    final completedBytes = (map['completedBytes'] as num?)?.toInt() ?? 0;
    final totalBytes = (map['totalBytes'] as num?)?.toInt() ?? 0;
    final statusText = (map['statusText'] as String?) ?? '';

    return WhisperDownloadProgress(
      progress: progress,
      percent: percent,
      completedBytes: completedBytes,
      totalBytes: totalBytes,
      statusText: statusText,
    );
  }
}

/// Structured status returned by the native WhisperModelManager actor.
class WhisperModelDetails {
  final String state;
  final bool installed;
  final bool verified;
  final bool loaded;
  final String modelSelector;
  final String repositoryFolder;
  final String sdkVersion;
  final int sizeBytes;
  final String relativePath;
  final List<String> verifiedComponents;
  final List<String> missingComponents;
  final String? reasonCode;
  final String? reason;

  const WhisperModelDetails({
    required this.state,
    required this.installed,
    required this.verified,
    required this.loaded,
    required this.modelSelector,
    required this.repositoryFolder,
    required this.sdkVersion,
    required this.sizeBytes,
    required this.relativePath,
    required this.verifiedComponents,
    required this.missingComponents,
    this.reasonCode,
    this.reason,
  });

  factory WhisperModelDetails.fromMap(Map<Object?, Object?> map) {
    return WhisperModelDetails(
      state: map['state'] as String? ?? 'notInstalled',
      installed: map['installed'] == true,
      verified: map['verified'] == true,
      loaded: map['loaded'] == true,
      modelSelector: map['modelSelector'] as String? ?? 'base',
      repositoryFolder: map['repositoryFolder'] as String? ?? 'openai_whisper-base',
      sdkVersion: map['sdkVersion'] as String? ?? '1.1.0',
      sizeBytes: (map['sizeBytes'] as num?)?.toInt() ?? 0,
      relativePath: map['path'] as String? ?? '',
      verifiedComponents: (map['verified_components'] as List?)?.map((e) => e.toString()).toList() ?? [],
      missingComponents: (map['missingComponents'] as List?)?.map((e) => e.toString()).toList() ?? [],
      reasonCode: map['error_code'] as String?,
      reason: map['error_message'] as String?,
    );
  }

  bool get isReady => verified || state == 'ready' || state == 'downloaded';
  bool get needsRepair => state == 'needsRepair' || state == 'partial';
}

/// Centralized singleton bridge for native speech services and Whisper model lifecycle.
class OfflineSpeechBridge {
  OfflineSpeechBridge._() {
    _channel.setMethodCallHandler(_handleNativeMethodCall);
  }

  static final OfflineSpeechBridge instance = OfflineSpeechBridge._();

  static const MethodChannel _channel = MethodChannel('noteechoes/offline_speech');

  final StreamController<WhisperDownloadProgress> _progressController =
      StreamController<WhisperDownloadProgress>.broadcast();

  /// Stream of download progress events from the native WhisperModelManager actor.
  Stream<WhisperDownloadProgress> get progressStream => _progressController.stream;

  Future<void> _handleNativeMethodCall(MethodCall call) async {
    if (call.method == 'onWhisperDownloadProgress') {
      final args = call.arguments;
      if (args is Map<Object?, Object?>) {
        final progress = WhisperDownloadProgress.fromMap(args);
        _progressController.add(progress);
      }
    }
  }

  /// Queries the structured health and verification state of the local Whisper model.
  Future<WhisperModelDetails> getWhisperStatus() async {
    try {
      final result = await _channel.invokeMapMethod<Object?, Object?>('whisperStatus');
      if (result != null) {
        return WhisperModelDetails.fromMap(result);
      }
    } catch (e) {
      debugPrint('[OfflineSpeechBridge] Error reading whisper status: $e');
    }
    return const WhisperModelDetails(
      state: 'notInstalled',
      installed: false,
      verified: false,
      loaded: false,
      modelSelector: 'base',
      repositoryFolder: 'openai_whisper-base',
      sdkVersion: '1.1.0',
      sizeBytes: 0,
      relativePath: '',
      verifiedComponents: [],
      missingComponents: [],
      reasonCode: 'status_query_failed',
    );
  }

  /// Downloads and verifies the canonical Whisper Base model.
  Future<bool> downloadWhisperBase() async {
    try {
      final result = await _channel.invokeMethod<bool>('downloadWhisperBase');
      return result == true;
    } catch (e) {
      debugPrint('[OfflineSpeechBridge] Error downloading whisper base: $e');
      rethrow;
    }
  }

  /// Repairs an incomplete or corrupted Whisper installation.
  Future<bool> repairWhisperBase() async {
    try {
      final result = await _channel.invokeMethod<bool>('repairWhisperBase');
      return result == true;
    } catch (e) {
      debugPrint('[OfflineSpeechBridge] Error repairing whisper base: $e');
      rethrow;
    }
  }

  /// Cancels any active in-flight model download.
  Future<void> cancelWhisperDownload() async {
    try {
      await _channel.invokeMethod<bool>('cancelWhisperDownload');
    } catch (e) {
      debugPrint('[OfflineSpeechBridge] Error canceling whisper download: $e');
    }
  }

  /// Deletes all local model files from the canonical folder and releases memory.
  Future<void> deleteWhisperBase() async {
    try {
      await _channel.invokeMethod<dynamic>('deleteWhisperBase');
    } catch (e) {
      debugPrint('[OfflineSpeechBridge] Error deleting whisper base: $e');
      rethrow;
    }
  }

  /// Transcribes an audio file with explicit language routing and returns full provenance.
  Future<TranscriptionProvenance> transcribeAudioFile({
    required String audioPath,
    AudioLanguage language = AudioLanguage.auto,
  }) async {
    try {
      final result = await _channel.invokeMethod<dynamic>('transcribeAudioFile', {
        'path': audioPath,
        'language': language.bcp47,
      });
      return TranscriptionProvenance.fromNative(result);
    } catch (e) {
      debugPrint('[OfflineSpeechBridge] Error during audio transcription: $e');
      rethrow;
    }
  }

  /// Gets recording permission status from AVAudioSession.
  Future<String> getRecordingPermissionStatus() async {
    try {
      final status = await _channel.invokeMethod<String>('recordingPermissionStatus');
      return status ?? 'undetermined';
    } catch (_) {
      return 'undetermined';
    }
  }
}
