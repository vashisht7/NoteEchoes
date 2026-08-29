import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/infrastructure/action_model_router.dart';

void main() {
  test('explicit English always uses the proven English action model', () {
    expect(
      ActionModelRouter.route(
        recognitionLanguage: 'en',
        transcript: 'రేపు report పంపాలి',
      ),
      ActionModelRoute.english,
    );
  });

  test('Telugu and Telugu-English selections use multilingual action', () {
    for (final language in const ['te', 'te-en-mixed']) {
      expect(
        ActionModelRouter.route(
          recognitionLanguage: language,
          transcript: 'Checklist first milk కొనాలి second report పంపాలి',
        ),
        ActionModelRoute.multilingual,
      );
    }
  });

  test('Hindi selection uses multilingual action', () {
    expect(
      ActionModelRouter.route(
        recognitionLanguage: 'hi',
        transcript: 'कल report भेजना है',
      ),
      ActionModelRoute.multilingual,
    );
  });

  test('auto routes English and mixed transcripts independently', () {
    expect(
      ActionModelRouter.route(
        recognitionLanguage: 'auto',
        transcript: 'Create a checklist for milk and coffee',
      ),
      ActionModelRoute.english,
    );
    expect(
      ActionModelRouter.route(
        recognitionLanguage: 'auto',
        transcript: 'రేపు report పంపాలి',
      ),
      ActionModelRoute.multilingual,
    );
  });
}
