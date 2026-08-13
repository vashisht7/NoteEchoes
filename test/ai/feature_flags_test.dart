import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notechoes_app/ai/config/ai_feature_flags.dart';
import 'package:notechoes_app/ai/config/ai_runtime_config.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AiFeatureFlags.instance.load();
  });

  group('AiFeatureFlags Tests', () {
    test('Default flag states are false before downloads', () {
      final flags = AiFeatureFlags.instance;
      expect(flags.localLlmEnabled, isFalse);
      expect(flags.dolphinSttEnabled, isFalse);
      expect(flags.noteAnalysisEnabled, isFalse);
    });

    test('Flag toggle updates state correctly', () async {
      final flags = AiFeatureFlags.instance;
      await flags.setNoteAnalysisEnabled(true);
      expect(flags.noteAnalysisEnabled, isTrue);

      await flags.setLocalLlmEnabled(true);
      expect(flags.localLlmEnabled, isTrue);

      await flags.disableAll();
      expect(flags.noteAnalysisEnabled, isFalse);
      expect(flags.localLlmEnabled, isFalse);
    });
  });

  group('AiRuntimeConfig Tests', () {
    test('Device tier assignment and testing override', () {
      final runtime = AiRuntimeConfig.instance;
      runtime.overrideTierForTesting(DeviceTier.tierA);

      expect(runtime.tier, equals(DeviceTier.tierA));
      expect(runtime.llmSupported, isTrue);
      expect(runtime.dolphinSupported, isTrue);
      expect(runtime.contextTokens, equals(4096));

      runtime.overrideTierForTesting(DeviceTier.tierC);
      expect(runtime.tier, equals(DeviceTier.tierC));
      expect(runtime.llmSupported, isFalse);
      expect(runtime.dolphinSupported, isFalse);
      expect(runtime.contextTokens, equals(0));
    });
  });
}
