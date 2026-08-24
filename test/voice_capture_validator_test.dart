import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/services/voice_capture_validator.dart';

void main() {
  test('rejects silence placeholders, punctuation, and filler-only speech', () {
    for (final value in ['', '...', 'No speech detected', 'Voice memo', 'um']) {
      expect(
        VoiceCaptureValidator.hasMeaningfulSpeech(value),
        isFalse,
        reason: value,
      );
    }
  });

  test('accepts meaningful multilingual speech', () {
    expect(VoiceCaptureValidator.hasMeaningfulSpeech('Call Ravi'), isTrue);
    expect(
      VoiceCaptureValidator.hasMeaningfulSpeech('రవికి కాల్ చేయాలి'),
      isTrue,
    );
    expect(
      VoiceCaptureValidator.hasMeaningfulSpeech('रवि को कॉल करना है'),
      isTrue,
    );
  });
}
