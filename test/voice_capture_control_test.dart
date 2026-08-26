import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/services/voice_capture_control.dart';

void main() {
  group('VoiceCaptureControl', () {
    test('accepts exact multilingual cancellation commands', () {
      expect(VoiceCaptureControl.isCancelCommand('Cancel that.'), isTrue);
      expect(VoiceCaptureControl.isCancelCommand('इसे रद्द करो'), isTrue);
      expect(VoiceCaptureControl.isCancelCommand('రద్దు చేయి!'), isTrue);
    });

    test('does not cancel a note that merely discusses cancellation', () {
      expect(
        VoiceCaptureControl.isCancelCommand(
          'Add a note to cancel that subscription tomorrow',
        ),
        isFalse,
      );
    });
  });
}
