// ai_runtime_config.dart
// Device capability detection, tier assignment and conservative
// LLM safety checks.

import 'dart:io';

/// Device capability tier based on available RAM and architecture.
enum DeviceTier {
  /// ≥ 6 GB RAM, 64-bit: full LLM + Dolphin STT + GPU/Metal.
  tierA,

  /// 4–6 GB RAM, 64-bit: LLM enabled, Dolphin Base, single queue.
  tierB,

  /// < 4 GB RAM or 32-bit legacy: speech-only / no-AI mode.
  tierC,
}

/// Runtime device configuration.
///
/// Call [detect] once at application startup before any AI
/// provider is loaded.
class AiRuntimeConfig {
  AiRuntimeConfig._();
  static final AiRuntimeConfig instance = AiRuntimeConfig._();

  DeviceTier _tier = DeviceTier.tierA;
  bool _is64Bit = true;
  int _physicalRamBytes = 6 * 1024 * 1024 * 1024;
  int _processorCount = 6;
  bool _detected = false;

  // ── Public getters ────────────────────────────────────────────

  DeviceTier get tier => _tier;
  bool get is64Bit => _is64Bit;
  int get physicalRamBytes => _physicalRamBytes;
  int get processorCount => _processorCount;

  /// Qwen 3.5-0.8B Q4 requires only ~600 MB of working memory.
  /// Enabled for Tier A and Tier B.
  bool get llmSupported =>
      _tier == DeviceTier.tierA || _tier == DeviceTier.tierB;
  bool get dolphinSupported => _tier != DeviceTier.tierC;
  bool get dolphinSmallRecommended => _tier == DeviceTier.tierA;

  /// Conservative thread count for llama.cpp inference.
  int get inferenceThreads => (_processorCount - 2).clamp(2, 4);

  /// Context token limit appropriate for this tier.
  int get contextTokens {
    switch (_tier) {
      case DeviceTier.tierA:
        return 4096;
      case DeviceTier.tierB:
        return 4096;
      case DeviceTier.tierC:
        return 0;
    }
  }

  // ── Detection ─────────────────────────────────────────────────

  /// Detects device capabilities. Safe to call multiple times;
  /// subsequent calls are no-ops.
  Future<void> detect() async {
    if (_detected) return;
    _detected = true;

    _processorCount = Platform.numberOfProcessors;

    if (Platform.isIOS || Platform.isMacOS) {
      await _detectApple();
    } else if (Platform.isAndroid) {
      await _detectAndroid();
    }

    _assignTier();
  }

  Future<void> _detectApple() async {
    // All 64-bit Apple Silicon / iPhone devices from A13+ have 4GB–8GB+ RAM
    _is64Bit = true;
    _physicalRamBytes = 6 * 1024 * 1024 * 1024; // 6 GB default
    _tier = DeviceTier.tierA;
  }

  Future<void> _detectAndroid() async {
    _is64Bit = _checkAndroid64Bit();
    _physicalRamBytes = _is64Bit
        ? 6 * 1024 * 1024 * 1024
        : 3 * 1024 * 1024 * 1024;
  }

  bool _checkAndroid64Bit() {
    return Platform.version.contains('arm64') ||
        Platform.version.contains('aarch64') ||
        Platform.version.contains('x86_64');
  }

  void _assignTier() {
    const gb4 = 4 * 1024 * 1024 * 1024;
    const gb6 = 6 * 1024 * 1024 * 1024;

    if (!_is64Bit || _physicalRamBytes < gb4) {
      _tier = DeviceTier.tierC;
    } else if (_physicalRamBytes < gb6) {
      _tier = DeviceTier.tierB;
    } else {
      _tier = DeviceTier.tierA;
    }
  }

  // ── Override for testing ───────────────────────────────────────

  /// Force a specific tier. Only for testing.
  // ignore: avoid_positional_boolean_parameters
  void overrideTierForTesting(DeviceTier tier) {
    _tier = tier;
    _detected = true;
  }
}
