// speech_output_service.dart
// Manages natural multilingual speech synthesis with clean speechText generation.
// Strips citations, markdown, URLs, and JSON before sending to AVSpeechSynthesizer.

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpeechOutputVoice {
  final String identifier;
  final String name;
  final String language;
  final String quality;
  final String gender;

  const SpeechOutputVoice({
    required this.identifier,
    required this.name,
    required this.language,
    required this.quality,
    required this.gender,
  });

  factory SpeechOutputVoice.fromMap(Map<dynamic, dynamic> map) => SpeechOutputVoice(
    identifier: map['identifier'] as String? ?? '',
    name: map['name'] as String? ?? '',
    language: map['language'] as String? ?? '',
    quality: map['quality'] as String? ?? 'Standard',
    gender: map['gender'] as String? ?? 'unspecified',
  );
}

class SpeechOutputService {
  static final SpeechOutputService instance = SpeechOutputService._();
  SpeechOutputService._();

  static const MethodChannel _channel = MethodChannel('notechoes/speech_output');

  /// Cleans display text into speech-optimized natural text.
  /// 1. Strips citation markers e.g. `[1] Note Title` or `[1]`
  /// 2. Strips markdown headers, asterisks, underscores, bullet markers
  /// 3. Strips URLs and raw JSON blocks
  static String cleanSpeechText(String displayText) {
    if (displayText.trim().isEmpty) return '';

    var text = displayText;

    // 1. Remove JSON code fences or raw JSON
    text = text.replaceAll(RegExp(r'```(?:json)?[\s\S]*?```', caseSensitive: false), '');

    // 2. Remove URLs
    text = text.replaceAll(RegExp(r'https?://[^\s]+', caseSensitive: false), '');

    // 3. Remove citation markers e.g. [1], [2], [1] "Note Title"
    text = text.replaceAll(RegExp(r'\[\d+\](?:\s+["\w\s]+)?'), '');

    // 4. Remove Markdown formatting characters (headers #, bold **, italic *, code `, blockquotes >)
    text = text.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    text = text.replaceAll('#', ' ');
    text = text.replaceAll(RegExp(r'[*_`~>]+'), '');

    // 5. Clean list bullet dashes/numbers into natural pauses
    text = text.replaceAll(RegExp(r'^\s*[-•*]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');

    // 6. Normalize multiple spaces and newlines
    text = text.replaceAll(RegExp(r'\n{2,}'), '. ');
    text = text.replaceAll(RegExp(r'\n'), ' ');
    text = text.replaceAll(RegExp(r'\s{2,}'), ' ');

    return text.trim();
  }

  /// Fetches all available iOS voices.
  Future<List<SpeechOutputVoice>> getAvailableVoices() async {
    try {
      final List? raw = await _channel.invokeListMethod('getAvailableVoices');
      if (raw == null) return [];
      return raw
          .map((item) => SpeechOutputVoice.fromMap(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Speaks text with language-matched voice and speech cleanup.
  Future<void> speak({
    required String text,
    required String language,
    String? voiceIdentifier,
    double rate = 0.88,
    double pitch = 0.98,
  }) async {
    final speechClean = cleanSpeechText(text);
    if (speechClean.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final savedVoiceId = voiceIdentifier ?? prefs.getString('speech_voice_$language');

    await _channel.invokeMethod('speak', {
      'text': speechClean,
      'language': language,
      'voiceIdentifier': savedVoiceId,
      'rate': rate,
      'pitch': pitch,
    });
  }

  /// Stops any active speech.
  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } catch (_) {}
  }
}
