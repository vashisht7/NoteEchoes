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

  test('rejects gasps and other non-speech transcription events', () {
    for (final value in [
      'gasp',
      '[GASP]',
      '(breathing)',
      '*coughing*',
      '[background noise]',
      'sighing',
    ]) {
      expect(
        VoiceCaptureValidator.hasMeaningfulSpeech(value),
        isFalse,
        reason: value,
      );
    }
  });

  test('removes a non-speech marker but preserves surrounding words', () {
    expect(
      VoiceCaptureValidator.sanitizeTranscript(
        '[GASP] Remind me to call Ravi (breathing)',
      ),
      'Remind me to call Ravi',
    );
    expect(
      VoiceCaptureValidator.hasMeaningfulSpeech(
        '[GASP] Remind me to call Ravi (breathing)',
      ),
      isTrue,
    );
  });
}
