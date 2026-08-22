import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/services/speech_output_service.dart';

void main() {
  group('SpeechOutputService Text Cleanup Tests', () {
    test('Strips citations, markdown, and raw URLs', () {
      const input = '''
# Meeting Summary
According to your notes [1] "Project Roadmap", we will launch on Friday.
- **Action item**: Email team at https://example.com/docs
- Review PR #45 [2]
```json
{"status": "ok"}
```
''';

      final cleaned = SpeechOutputService.cleanSpeechText(input);
      expect(cleaned, isNot(contains('[1]')));
      expect(cleaned, isNot(contains('[2]')));
      expect(cleaned, isNot(contains('#')));
      expect(cleaned, isNot(contains('**')));
      expect(cleaned, isNot(contains('https://example.com')));
      expect(cleaned, isNot(contains('{"status"')));
      expect(cleaned, contains('According to your notes'));
      expect(cleaned, contains('we will launch on Friday'));
      expect(cleaned, contains('Action item: Email team at'));
    });
  });
}
