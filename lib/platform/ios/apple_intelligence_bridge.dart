import 'package:flutter/services.dart';

class AppleIntelligenceBridge {
  static final AppleIntelligenceBridge instance = AppleIntelligenceBridge._();
  AppleIntelligenceBridge._();
  
  static const MethodChannel _channel = MethodChannel('notechoes/apple_intelligence');

  /// Apple Intelligence API availability.
  /// Requires iOS 18.1+ and an Apple Silicon device (iPhone 15 Pro, M1+ iPads).
  Future<bool> get isAvailable async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> generateTitle(String text) async {
    try {
      return await _channel.invokeMethod<String>('generateTitle', {'text': text});
    } catch (e) {
      return null;
    }
  }

  Future<String?> summarize(String text) async {
    try {
      return await _channel.invokeMethod<String>('summarize', {'text': text});
    } catch (e) {
      return null;
    }
  }

  bool shouldUseAppleProvider({required String detectedLanguage, required bool appleAvailable}) {
    // Telugu/Hindi always uses local Qwen, Apple Intelligence currently works best for 'en'
    if (appleAvailable && detectedLanguage == 'en') {
      return true;
    }
    return false;
  }
}
