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

  test('extracts every Telugu-English mixed checklist item', () {
    expect(
      SpokenChecklistParser.extract(
        'checklist తయారు చేయి: మొదట డెమో సిద్ధం చేయడం, తర్వాత రిపోర్ట్ సమర్పించడం, చివరగా డాక్టర్ appointment బుక్ చేయడం.',
      ),
      [
        'డెమో సిద్ధం చేయడం',
        'రిపోర్ట్ సమర్పించడం',
        'డాక్టర్ appointment బుక్ చేయడం',
      ],
    );
  });

  test('extracts comma-separated Telugu-English task items', () {
    expect(
      SpokenChecklistParser.extract(
        'నా checklist: milk కొనాలి, Ravi కి report పంపాలి, మరియు laptop charge చేయాలి.',
      ),
      ['milk కొనాలి', 'Ravi కి report పంపాలి', 'laptop charge చేయాలి'],
    );
  });
}
