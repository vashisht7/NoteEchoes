// model_manifest.dart
// Typed model manifest — parsed from a signed JSON manifest file
// fetched from the CDN before any download begins.

import 'dart:convert';

/// The type of AI model described by a [ModelEntry].
enum ModelType {
  textGeneration,
  speechRecognition,
  embedding,
}

/// A single downloadable model entry.
class ModelEntry {
  final String id;
  final String version;
  final ModelType type;
  final String url;
  final int sizeBytes;
  final String sha256;
  final String license;
  final int minimumRamBytes;

  const ModelEntry({
    required this.id,
    required this.version,
    required this.type,
    required this.url,
    required this.sizeBytes,
    required this.sha256,
    required this.license,
    this.minimumRamBytes = 0,
  });

  factory ModelEntry.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? '';
    ModelType modelType;
    switch (typeStr) {
      case 'text_generation':
        modelType = ModelType.textGeneration;
      case 'speech_recognition':
        modelType = ModelType.speechRecognition;
      case 'embedding':
        modelType = ModelType.embedding;
      default:
        modelType = ModelType.textGeneration;
    }

    return ModelEntry(
      id: json['id'] as String,
      version: json['version'] as String,
      type: modelType,
      url: json['url'] as String,
      sizeBytes: json['sizeBytes'] as int,
      sha256: json['sha256'] as String,
      license: json['license'] as String? ?? 'Unknown',
      minimumRamBytes: json['minimumRamBytes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'version': version,
        'type': type.name,
        'url': url,
        'sizeBytes': sizeBytes,
        'sha256': sha256,
        'license': license,
        'minimumRamBytes': minimumRamBytes,
      };

  String get formattedSize {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (sizeBytes < 1024 * 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(0)} MB';
    }
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// The full signed model manifest.
class ModelManifest {
  final int manifestVersion;
  final List<ModelEntry> models;

  const ModelManifest({
    required this.manifestVersion,
    required this.models,
  });

  factory ModelManifest.fromJson(Map<String, dynamic> json) {
    final version = json['manifestVersion'] as int? ?? 1;
    final modelsJson = json['models'] as List<dynamic>? ?? [];
    return ModelManifest(
      manifestVersion: version,
      models: modelsJson
          .map((e) => ModelEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory ModelManifest.fromJsonString(String jsonStr) {
    return ModelManifest.fromJson(
      jsonDecode(jsonStr) as Map<String, dynamic>,
    );
  }

  ModelEntry? findById(String id) {
    try {
      return models.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  ModelEntry? get qwen35 => findById('qwen35-08b-q4km');
  ModelEntry? get dolphinBase => findById('dolphin-base-int8');
  ModelEntry? get dolphinSmall => findById('dolphin-small-int8');
}

/// Well-known model IDs.
class KnownModelIds {
  static const qwen35q4km = 'qwen35-08b-q4km';
  static const dolphinBaseInt8 = 'dolphin-base-int8';
  static const dolphinSmallInt8 = 'dolphin-small-int8';
}
