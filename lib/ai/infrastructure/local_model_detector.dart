// local_model_detector.dart
// Discovers locally available LLMs from Ollama (localhost:11434),
// LM Studio (localhost:1234), and local MLX/GGUF directories.
// Populates available brains, highlights recommended models (Gemma 3 4B / Qwen 2.5 7B),
// and provides direct 1-click download options for recommended models if not yet installed.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Dynamic intelligence tier based on the detected model's capabilities.
enum ModelIntelligenceTier {
  /// < 2B parameters: fast titling, tag categorization, simple summary.
  slm,

  /// 3B–8B parameters (e.g. Gemma 3 4B, Qwen 2.5 7B): full tool calling,
  /// cross-note Q&A, structured action items, multimodal vision.
  balanced,

  /// > 13B parameters (e.g. Qwen 2.5 14B+, Llama 70B): deep multi-document
  /// research synthesis and complex reasoning.
  heavyweight,
}

/// A detected local LLM provider/engine.
enum LocalEngineType {
  ollama,
  lmStudio,
  nativeMlx,
  downloadable,
}

/// Metadata for a discovered or suggested local model.
class DiscoveredLocalModel {
  final String id;
  final String displayName;
  final LocalEngineType engineType;
  final ModelIntelligenceTier intelligenceTier;
  final int? parameterSizeBillions;
  final bool supportsVision;
  final bool supportsToolCalling;
  final bool isInstalled;
  final bool isRecommended;
  final String? downloadUrl;
  final String? endpointUrl;

  const DiscoveredLocalModel({
    required this.id,
    required this.displayName,
    required this.engineType,
    required this.intelligenceTier,
    this.parameterSizeBillions,
    this.supportsVision = false,
    this.supportsToolCalling = true,
    this.isInstalled = true,
    this.isRecommended = false,
    this.downloadUrl,
    this.endpointUrl,
  });

  String get tierLabel => switch (intelligenceTier) {
    ModelIntelligenceTier.slm => 'SLM (Lightweight)',
    ModelIntelligenceTier.balanced => 'Balanced (Recommended)',
    ModelIntelligenceTier.heavyweight => 'Heavyweight (Deep Reasoning)',
  };
}

/// Service that auto-detects all available local models on the user's Mac
/// and suggests recommended lightweight brains.
class LocalModelDetector extends ChangeNotifier {
  static final LocalModelDetector instance = LocalModelDetector._();
  LocalModelDetector._();

  List<DiscoveredLocalModel> _availableModels = [];
  DiscoveredLocalModel? _activeModel;
  bool _isScanning = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatusText = '';

  List<DiscoveredLocalModel> get availableModels =>
      List.unmodifiable(_availableModels);
  DiscoveredLocalModel? get activeModel => _activeModel;
  bool get isScanning => _isScanning;
  bool get isDownloading => _isDownloading;
  double get downloadProgress => _downloadProgress;
  String get downloadStatusText => _downloadStatusText;

  /// Scans Ollama, LM Studio, and local folders for available models.
  Future<void> scanForModels() async {
    _isScanning = true;
    notifyListeners();

    final discovered = <DiscoveredLocalModel>[];

    // 1. Probe Ollama (localhost:11434)
    final ollamaModels = await _probeOllama();
    discovered.addAll(ollamaModels);

    // 2. Probe LM Studio (localhost:1234)
    final lmStudioModels = await _probeLmStudio();
    discovered.addAll(lmStudioModels);

    // 3. Scan local app models folder
    final localFolderModels = await _scanLocalModelsFolder();
    discovered.addAll(localFolderModels);

    // 4. Always add Recommended Models list (with installed/download status)
    _addRecommendedCatalog(discovered);

    _availableModels = discovered;

    // Pick active model: prefer user's installed balanced model, else first installed
    if (_activeModel == null ||
        !_availableModels.any((m) => m.id == _activeModel!.id && m.isInstalled)) {
      final installed = _availableModels.where((m) => m.isInstalled).toList();
      if (installed.isNotEmpty) {
        _activeModel = installed.firstWhere(
          (m) => m.isRecommended,
          orElse: () => installed.first,
        );
      } else {
        _activeModel = null;
      }
    }

    _isScanning = false;
    notifyListeners();
  }

  /// Sets the currently active brain.
  void setActiveModel(DiscoveredLocalModel model) {
    if (model.isInstalled) {
      _activeModel = model;
      notifyListeners();
    }
  }

  Future<List<DiscoveredLocalModel>> _probeOllama() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:11434/api/tags'))
          .timeout(const Duration(milliseconds: 600));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final models = (data['models'] as List<dynamic>? ?? []);
        return models.map((m) {
          final name = m['name'] as String? ?? 'unknown';
          final tier = _classifyTier(name);
          final isGemma3 = name.toLowerCase().contains('gemma3');
          final isRecommended = name.toLowerCase().contains('gemma3:4b') ||
              name.toLowerCase().contains('qwen2.5:7b');
          return DiscoveredLocalModel(
            id: 'ollama_$name',
            displayName: '$name (Ollama)',
            engineType: LocalEngineType.ollama,
            intelligenceTier: tier,
            isInstalled: true,
            isRecommended: isRecommended,
            supportsVision: isGemma3,
            supportsToolCalling: tier != ModelIntelligenceTier.slm,
            endpointUrl: 'http://localhost:11434/api/generate',
          );
        }).toList();
      }
    } catch (_) {
      // Ollama not running
    }
    return [];
  }

  Future<List<DiscoveredLocalModel>> _probeLmStudio() async {
    try {
      final response = await http
          .get(Uri.parse('http://localhost:1234/v1/models'))
          .timeout(const Duration(milliseconds: 600));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final models = (data['data'] as List<dynamic>? ?? []);
        return models.map((m) {
          final id = m['id'] as String? ?? 'local-model';
          final tier = _classifyTier(id);
          final isGemma3 = id.toLowerCase().contains('gemma3');
          return DiscoveredLocalModel(
            id: 'lmstudio_$id',
            displayName: '$id (LM Studio)',
            engineType: LocalEngineType.lmStudio,
            intelligenceTier: tier,
            isInstalled: true,
            isRecommended: id.toLowerCase().contains('gemma-3-4b') || id.toLowerCase().contains('qwen2.5-7b'),
            supportsVision: isGemma3 || id.toLowerCase().contains('vision'),
            supportsToolCalling: tier != ModelIntelligenceTier.slm,
            endpointUrl: 'http://localhost:1234/v1/chat/completions',
          );
        }).toList();
      }
    } catch (_) {
      // LM Studio not running
    }
    return [];
  }

  Future<List<DiscoveredLocalModel>> _scanLocalModelsFolder() async {
    final home = Platform.environment['HOME'];
    if (home == null) return [];

    final dir = Directory('$home/Library/Application Support/com.vashisht.notechoes/Models');
    if (!dir.existsSync()) return [];

    final models = <DiscoveredLocalModel>[];
    for (final entity in dir.listSync()) {
      if (entity is Directory) {
        final name = entity.uri.pathSegments.reversed.skip(1).first;
        if (name.isNotEmpty && !name.startsWith('.')) {
          final tier = _classifyTier(name);
          final isGemma3 = name.toLowerCase().contains('gemma3') || name.toLowerCase().contains('gemma-3');
          models.add(
            DiscoveredLocalModel(
              id: 'local_$name',
              displayName: '$name (MLX Native)',
              engineType: LocalEngineType.nativeMlx,
              intelligenceTier: tier,
              isInstalled: true,
              isRecommended: isGemma3 || name.toLowerCase().contains('qwen2.5-7b'),
              supportsVision: isGemma3,
              supportsToolCalling: tier != ModelIntelligenceTier.slm,
            ),
          );
        }
      }
    }
    return models;
  }

  void _addRecommendedCatalog(List<DiscoveredLocalModel> list) {
    // 1. Recommended: Gemma 3 4B (MLX)
    final hasGemma = list.any((m) => m.displayName.toLowerCase().contains('gemma-3-4b') || m.displayName.toLowerCase().contains('gemma3:4b'));
    if (!hasGemma) {
      list.add(
        const DiscoveredLocalModel(
          id: 'recommended_gemma3_4b',
          displayName: 'Gemma 3 4B (Recommended)',
          engineType: LocalEngineType.downloadable,
          intelligenceTier: ModelIntelligenceTier.balanced,
          parameterSizeBillions: 4,
          isInstalled: false,
          isRecommended: true,
          supportsVision: true,
          supportsToolCalling: true,
          downloadUrl: 'https://huggingface.co/mlx-community/gemma-3-4b-it-4bit',
        ),
      );
    }

    // 2. Recommended: Qwen 2.5 7B (MLX)
    final hasQwen7b = list.any((m) => m.displayName.toLowerCase().contains('qwen2.5:7b') || m.displayName.toLowerCase().contains('qwen2.5-7b'));
    if (!hasQwen7b) {
      list.add(
        const DiscoveredLocalModel(
          id: 'recommended_qwen25_7b',
          displayName: 'Qwen 2.5 7B Instruct',
          engineType: LocalEngineType.downloadable,
          intelligenceTier: ModelIntelligenceTier.balanced,
          parameterSizeBillions: 7,
          isInstalled: false,
          isRecommended: false,
          supportsVision: false,
          supportsToolCalling: true,
          downloadUrl: 'https://huggingface.co/mlx-community/Qwen2.5-7B-Instruct-4bit',
        ),
      );
    }
  }

  ModelIntelligenceTier _classifyTier(String modelName) {
    final lower = modelName.toLowerCase();
    if (lower.contains('14b') ||
        lower.contains('32b') ||
        lower.contains('70b') ||
        lower.contains('deepseek')) {
      return ModelIntelligenceTier.heavyweight;
    }
    if (lower.contains('4b') ||
        lower.contains('7b') ||
        lower.contains('8b') ||
        lower.contains('12b') ||
        lower.contains('nemo') ||
        lower.contains('gemma3') ||
        lower.contains('gemma-3') ||
        lower.contains('qwen2.5')) {
      return ModelIntelligenceTier.balanced;
    }
    return ModelIntelligenceTier.slm;
  }
}
