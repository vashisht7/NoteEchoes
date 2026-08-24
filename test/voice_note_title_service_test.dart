import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/services/voice_note_title_service.dart';

void main() {
  test('prevents a model from using the full voice sentence as title', () {
    const speech =
        'I want to check whether the model is working perfectly and then check whether the app is working';
    final title = VoiceNoteTitleService.concise(
      proposedTitle: speech,
      spokenText: speech,
    );

    expect(title.length, lessThanOrEqualTo(48));
    expect(title.split(' ').length, lessThanOrEqualTo(6));
    expect(title, isNot(equals(speech)));
  });

  test('keeps a useful compact multilingual model title', () {
    final title = VoiceNoteTitleService.concise(
      proposedTitle: 'ఈరోజు విడుదల పనులు',
      spokenText: 'మొదటి పని మోడల్ పరీక్షించాలి రెండవ పని యాప్ పరీక్షించాలి',
    );
    expect(title, 'ఈరోజు విడుదల పనులు');
  });
}
