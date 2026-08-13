// ai_telemetry_service.dart
// Privacy-preserving local metrics tracker for on-device AI performance.
// Tracks execution durations, fallback events, and failure counts locally.
// Never transmits note contents, audio, or user identifiers.

import 'package:flutter/foundation.dart';

class AiTelemetryEvent {
  final String eventType;
  final Duration duration;
  final bool success;
  final String? modelVersion;
  final String? errorCode;
  final DateTime timestamp;

  const AiTelemetryEvent({
    required this.eventType,
    required this.duration,
    required this.success,
    this.modelVersion,
    this.errorCode,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'event_type': eventType,
        'duration_ms': duration.inMilliseconds,
        'success': success,
        if (modelVersion != null) 'model_version': modelVersion,
        if (errorCode != null) 'error_code': errorCode,
        'timestamp': timestamp.toIso8601String(),
      };
}

class AiTelemetryService {
  static final AiTelemetryService instance = AiTelemetryService._internal();
  factory AiTelemetryService() => instance;
  AiTelemetryService._internal();

  final List<AiTelemetryEvent> _recentEvents = [];
  static const int _maxInMemoryEvents = 100;

  List<AiTelemetryEvent> get recentEvents => List.unmodifiable(_recentEvents);

  void record({
    required String eventType,
    required Duration duration,
    required bool success,
    String? modelVersion,
    String? errorCode,
  }) {
    final event = AiTelemetryEvent(
      eventType: eventType,
      duration: duration,
      success: success,
      modelVersion: modelVersion,
      errorCode: errorCode,
      timestamp: DateTime.now(),
    );

    _recentEvents.add(event);
    if (_recentEvents.length > _maxInMemoryEvents) {
      _recentEvents.removeAt(0);
    }

    debugPrint(
      '[AiTelemetry] $eventType -> '
      '${success ? "SUCCESS" : "FAILED ($errorCode)"} '
      '(${duration.inMilliseconds}ms)',
    );
  }

  double getAverageDurationMs(String eventType) {
    final matches =
        _recentEvents.where((e) => e.eventType == eventType && e.success);
    if (matches.isEmpty) return 0.0;
    final total =
        matches.fold<int>(0, (sum, e) => sum + e.duration.inMilliseconds);
    return total / matches.length;
  }
}
