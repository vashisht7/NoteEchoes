import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/services/spoken_checklist_parser.dart';

void main() {
  test('extracts natural first-task second-task speech', () {
    const speech =
        'I want to implement first task, that is, I want to check whether the model is working perfectly. Second, I want to check whether the app is working perfectly.';

    expect(SpokenChecklistParser.extract(speech), [
      'check whether the model is working perfectly',
      'check whether the app is working perfectly',
    ]);
  });

  test('extracts an explicitly introduced natural checklist', () {
    expect(
      SpokenChecklistParser.extract(
        'Create a checklist with these items: buy milk, call Ravi, and charge the laptop.',
      ),
      ['buy milk', 'call Ravi', 'charge the laptop'],
    );
  });

  test('does not invent a checklist from ordinary prose', () {
    expect(
      SpokenChecklistParser.extract(
        'I checked the model and the application is working today.',
      ),
      isEmpty,
    );
  });

  test('extracts Hindi ordinal tasks', () {
    expect(
      SpokenChecklistParser.extract(
        'मेरे काम हैं: पहले मॉडल चेक करना, फिर ऐप चेक करना।',
      ),
      ['मॉडल चेक करना', 'ऐप चेक करना'],
    );
  });
}
