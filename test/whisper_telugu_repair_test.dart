import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/domain/ai_models.dart';
import 'package:notechoes_app/ai/infrastructure/offline_speech_bridge.dart';
import 'package:notechoes_app/ai/infrastructure/model_availability_service.dart';

void main() {
  group('Whisper Telugu Repair - AudioLanguage Domain Tests', () {
    test('AudioLanguage enum supports all required modes including teluguEnglishMixed', () {
      expect(AudioLanguage.values, contains(AudioLanguage.english));
      expect(AudioLanguage.values, contains(AudioLanguage.telugu));
      expect(AudioLanguage.values, contains(AudioLanguage.teluguEnglishMixed));
      expect(AudioLanguage.values, contains(AudioLanguage.hindi));
      expect(AudioLanguage.values, contains(AudioLanguage.auto));
    });

    test('AudioLanguageExt bcp47 codes and display names map correctly', () {
      expect(AudioLanguage.english.bcp47, 'en');
      expect(AudioLanguage.telugu.bcp47, 'te');
      expect(AudioLanguage.teluguEnglishMixed.bcp47, 'te-en-mixed');
      expect(AudioLanguage.hindi.bcp47, 'hi');
      expect(AudioLanguage.auto.bcp47, 'auto');

      expect(AudioLanguage.teluguEnglishMixed.displayName, 'Telugu & English Mixed');
    });

    test('AudioLanguageExt fromBcp47 handles mixed codes and case insensitivity', () {
      expect(AudioLanguageExt.fromBcp47('te-en-mixed'), AudioLanguage.teluguEnglishMixed);
      expect(AudioLanguageExt.fromBcp47('TE-EN-MIXED'), AudioLanguage.teluguEnglishMixed);
      expect(AudioLanguageExt.fromBcp47('te-en'), AudioLanguage.teluguEnglishMixed);
      expect(AudioLanguageExt.fromBcp47('mixed'), AudioLanguage.teluguEnglishMixed);
      expect(AudioLanguageExt.fromBcp47('te'), AudioLanguage.telugu);
      expect(AudioLanguageExt.fromBcp47('te-IN'), AudioLanguage.telugu);
      expect(AudioLanguageExt.fromBcp47('en-US'), AudioLanguage.english);
      expect(AudioLanguageExt.fromBcp47('hi-IN'), AudioLanguage.hindi);
      expect(AudioLanguageExt.fromBcp47('auto'), AudioLanguage.auto);
    });
  });

  group('Whisper Telugu Repair - TranscriptionProvenance Tests', () {
    test('Parses rich dictionary from native WhisperKit decoding', () {
      final nativeMap = {
        'text': 'నమస్కారం ఎలా ఉన్నారు NoteEchoes app is great',
        'requestedMode': 'te-en-mixed',
        'detectedLanguage': 'te',
        'engine': 'whisperkit',
        'model': 'base',
        'fallbackUsed': false,
        'fallbackReason': null,
        'quality': {
          'avgLogprob': -0.15,
          'noSpeechProb': 0.002,
          'compressionRatio': 1.12,
          'pass': 'forced_telugu',
        },
      };

      final provenance = TranscriptionProvenance.fromNative(nativeMap);
      expect(provenance.text, 'నమస్కారం ఎలా ఉన్నారు NoteEchoes app is great');
      expect(provenance.requestedMode, 'te-en-mixed');
      expect(provenance.detectedLanguage, 'te');
      expect(provenance.engine, 'whisperkit');
      expect(provenance.model, 'base');
      expect(provenance.fallbackUsed, false);
      expect(provenance.fallbackReason, isNull);
      expect(provenance.quality['pass'], 'forced_telugu');
    });

    test('Parses Apple Speech guarded fallback provenance with disclosure', () {
      final nativeMap = {
        'text': 'హలో వశిష్ట్',
        'requestedMode': 'te',
        'detectedLanguage': 'te',
        'engine': 'apple_speech',
        'model': 'sfspeech',
        'fallbackUsed': true,
        'fallbackReason': 'Whisper unavailable or failed candidate evaluation',
        'quality': {
          'pass': 'apple_speech_fallback',
        },
      };

      final provenance = TranscriptionProvenance.fromNative(nativeMap);
      expect(provenance.engine, 'apple_speech');
      expect(provenance.fallbackUsed, true);
      expect(provenance.fallbackReason, contains('Whisper unavailable'));
      expect(provenance.detectedLanguage, 'te');
    });

    test('Parses raw string gracefully for backwards compatibility', () {
      const raw = 'Simple spoken text';
      final provenance = TranscriptionProvenance.fromNative(raw);
      expect(provenance.text, 'Simple spoken text');
      expect(provenance.engine, 'whisperkit');
    });
  });

  group('Whisper Telugu Repair - Model Lifecycle & Status Mapping Tests', () {
    test('WhisperModelDetails maps all native spec keys', () {
      final details = WhisperModelDetails.fromMap({
        'state': 'ready',
        'installed': true,
        'verified': true,
        'loaded': true,
        'modelSelector': 'base',
        'repositoryFolder': 'openai_whisper-base',
        'sdkVersion': '1.1.0',
        'sizeBytes': 154000000,
        'path': 'NoteEchoes/Models/Whisper/openai_whisper-base',
        'verified_components': [
          'AudioEncoder.mlmodelc',
          'MelSpectrogram.mlmodelc',
          'TextDecoder.mlmodelc',
          'config.json'
        ],
        'missingComponents': <String>[],
        'error_code': null,
        'error_message': null,
      });

      expect(details.isReady, isTrue);
      expect(details.needsRepair, isFalse);
      expect(details.modelSelector, 'base');
      expect(details.repositoryFolder, 'openai_whisper-base');
      expect(details.sdkVersion, '1.1.0');
      expect(details.verifiedComponents.length, 4);

      final status = LocalModelStatus.fromWhisperDetails(details);
      expect(status.health, ModelHealth.ready);
      expect(status.isReady, isTrue);
    });

    test('LocalModelStatus correctly maps partial/needsRepair states', () {
      final details = WhisperModelDetails.fromMap({
        'state': 'needsRepair',
        'installed': true,
        'verified': false,
        'loaded': false,
        'modelSelector': 'base',
        'repositoryFolder': 'openai_whisper-base',
        'sdkVersion': '1.1.0',
        'sizeBytes': 50000000,
        'path': 'NoteEchoes/Models/Whisper/openai_whisper-base',
        'verified_components': ['MelSpectrogram.mlmodelc'],
        'missingComponents': ['AudioEncoder.mlmodelc', 'TextDecoder.mlmodelc'],
        'error_code': 'missing_model_component',
        'error_message': 'Missing required components: AudioEncoder.mlmodelc',
      });

      expect(details.isReady, isFalse);
      expect(details.needsRepair, isTrue);

      final status = LocalModelStatus.fromWhisperDetails(details);
      expect(status.health, ModelHealth.needsRepair);
      expect(status.missingComponents, contains('AudioEncoder.mlmodelc'));
      expect(status.reasonCode, 'missing_model_component');
    });
  });
}
