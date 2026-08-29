import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/infrastructure/language_detection_service.dart';

void main() {
  group('LanguageDetectionService Tests', () {
    test('Detects pure English text', () {
      final res = LanguageDetectionService.detect(
        'Tomorrow we need to finalize the quarterly roadmap and deploy the update.',
      );
      expect(res.primaryLanguage, equals('en'));
      expect(res.isRomanized, isFalse);
    });

    test('Detects Telugu script', () {
      final res = LanguageDetectionService.detect(
        'రేపు ఉదయం పది గంటలకు మీటింగ్ పెట్టుకుందాం.',
      );
      expect(res.primaryLanguage, equals('te'));
      expect(res.mixedLanguages, contains('te'));
    });

    test('Detects Hindi script', () {
      final res = LanguageDetectionService.detect(
        'कल सुबह दस बजे हम नई योजना पर चर्चा करेंगे।',
      );
      expect(res.primaryLanguage, equals('hi'));
      expect(res.mixedLanguages, contains('hi'));
    });

    test('Detects Romanized Telugu speech', () {
      final res = LanguageDetectionService.detect(
        'nenu repu vachanu meeting gurinchi matladali cheyandi',
      );
      expect(res.primaryLanguage, anyOf(equals('te'), equals('mixed')));
      expect(res.mixedLanguages, contains('te'));
      expect(res.isRomanized, isTrue);
    });

    test('Detects Romanized Hindi speech', () {
      final res = LanguageDetectionService.detect(
        'aaj hum kaam shuru karenge aur mujhe update batao',
      );
      expect(res.primaryLanguage, anyOf(equals('hi'), equals('mixed')));
      expect(res.mixedLanguages, contains('hi'));
      expect(res.isRomanized, isTrue);
    });

    test('Detects mixed Telugu and English script', () {
      final res = LanguageDetectionService.detect(
        'రేపు team meeting లో NoteEchoes architecture గురించి discuss చేద్దాం.',
      );
      expect(res.primaryLanguage, equals('mixed'));
      expect(res.mixedLanguages, containsAll(['te', 'en']));
    });

    test('preserves Telugu, Hindi, and English in three-language speech', () {
      final res = LanguageDetectionService.detect(
        'Ravi కోసం report भेजना, मुझे రేపు 6 PM remind చేయి',
      );
      expect(res.primaryLanguage, 'mixed');
      expect(res.mixedLanguages, containsAll(['te', 'hi', 'en']));
    });

    test('detects Telugu-Hindi without requiring English', () {
      final res = LanguageDetectionService.detect(
        'రేపు Ravi కోసం रिपोर्ट भेजना और मुझे याद दिलाना',
      );
      expect(res.primaryLanguage, 'mixed');
      expect(res.mixedLanguages, containsAll(['te', 'hi']));
    });
  });
}
