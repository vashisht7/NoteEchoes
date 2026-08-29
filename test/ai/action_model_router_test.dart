import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/infrastructure/action_model_router.dart';

void main() {
  test('every recognition language uses the combined production model', () {
    for (final language in const ['en', 'te', 'hi', 'te-en-mixed', 'auto']) {
      expect(
        ActionModelRouter.route(
          recognitionLanguage: language,
          transcript: 'Checklist first milk కొనాలి second report పంపాలి',
        ),
        ActionModelRoute.combined,
      );
    }
  });
}
