import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/infrastructure/think_sanitizer.dart';

void main() {
  group('ThinkSanitizer Unit Tests', () {
    setUp(() {
      ThinkSanitizer.resetTelemetry();
    });

    test('Passes plain text untouched', () {
      const input = 'This is a clean user response.';
      final result = ThinkSanitizer.sanitize(input);
      expect(result.cleanedText, equals(input));
      expect(result.hadThinkTags, isFalse);
      expect(result.isThinkOnly, isFalse);
      expect(ThinkSanitizer.leakageCounter, equals(0));
    });

    test('Strips complete inline <think> tag', () {
      const input = '<think>I should calculate the date.</think>Tomorrow at 5 PM';
      final result = ThinkSanitizer.sanitize(input);
      expect(result.cleanedText, equals('Tomorrow at 5 PM'));
      expect(result.hadThinkTags, isTrue);
      expect(result.isThinkOnly, isFalse);
      expect(ThinkSanitizer.leakageCounter, equals(1));
    });

    test('Strips multiline <think>...</think> blocks with reasoning', () {
      const input = '''
<think>
Let's see what the user meant:
1. They mentioned meeting Rahul.
2. The language is mixed Telugu-English.
</think>
Here is your structured note summary for the meeting with Rahul.''';

      final result = ThinkSanitizer.sanitize(input);
      expect(
        result.cleanedText,
        equals('Here is your structured note summary for the meeting with Rahul.'),
      );
      expect(result.hadThinkTags, isTrue);
      expect(result.isThinkOnly, isFalse);
    });

    test('Detects think-only output and marks isThinkOnly true', () {
      const input = '<think>Only reasoning and no final output generated</think>';
      final result = ThinkSanitizer.sanitize(input);
      expect(result.cleanedText, isEmpty);
      expect(result.hadThinkTags, isTrue);
      expect(result.isThinkOnly, isTrue);
    });

    test('Strips unclosed cut-off <think> tag', () {
      const input = 'Partial text <think>stream got cut off before closing tag';
      final result = ThinkSanitizer.sanitize(input);
      expect(result.cleanedText, equals('Partial text'));
      expect(result.hadThinkTags, isTrue);
      expect(result.isThinkOnly, isFalse);
    });

    test('Strips orphan closing </think> tag', () {
      const input = 'Some text here </think> and remaining answer.';
      final result = ThinkSanitizer.sanitize(input);
      expect(result.cleanedText, equals('Some text here  and remaining answer.'));
      expect(result.hadThinkTags, isTrue);
    });

    test('Handles case-insensitive and spaced < think > variations', () {
      const input = '< THINK >Internal prompt reasoning< / THINK >Actual Output';
      final result = ThinkSanitizer.sanitize(input);
      expect(result.cleanedText, equals('Actual Output'));
      expect(result.hadThinkTags, isTrue);
    });

    test('Strips echoed /no_think command', () {
      const input = '/no_think Here is the answer.';
      final result = ThinkSanitizer.sanitize(input);
      expect(result.cleanedText, equals('Here is the answer.'));
    });
  });
}
