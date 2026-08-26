import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/domain/core_action_v5.dart';
import 'package:notechoes_app/ai/providers/action_provider_registry.dart';

Map<String, dynamic> validEnvelope() => {
  'schema_version': 5,
  'language': 'en',
  'mode': 'capture',
  'normalized_text': 'Remind me tomorrow at 6 PM to call Priya.',
  'intent': 'reminder',
  'title': 'Call Priya',
  'items': <dynamic>[],
  'entities': {
    'recipient_query': null,
    'date_phrase': 'tomorrow',
    'time_phrase': '6 PM',
    'people': ['Priya'],
    'place': null,
    'subject': null,
  },
  'draft': null,
  'proposed_tool': {
    'name': 'reminders.propose',
    'arguments': {
      'normalized_text': 'Remind me tomorrow at 6 PM to call Priya.',
    },
  },
  'confidence': 0.98,
  'requires_confirmation': true,
  'clarification_question': null,
};

class FakeReminderProvider implements ActionProvider {
  bool called = false;

  @override
  String get name => 'reminders.propose';
  @override
  int get version => 1;
  @override
  ActionConfirmationPolicy get confirmationPolicy =>
      ActionConfirmationPolicy.beforeWrite;
  @override
  Set<String> get requiredArgumentKeys => {'normalized_text'};
  @override
  Set<String> get requiredPermissions => {'reminders'};
  @override
  List<String> validateArguments(Map<String, dynamic> arguments) => const [];
  @override
  Future<ActionProviderResult> execute(Map<String, dynamic> arguments) async {
    called = true;
    return const ActionProviderResult.success(externalId: 'test-id');
  }
}

void main() {
  const validator = CoreV5Validator();

  test('accepts a grounded strict reminder proposal', () {
    final result = validator.parseAndValidate(
      validEnvelope(),
      rawTranscript: 'remind me tomorrow at 6 PM to call Priya',
    );
    expect(result.isValid, isTrue, reason: result.errors.join('\n'));
  });

  test('rejects invented entities and unsupported keys', () {
    final value = validEnvelope();
    (value['entities'] as Map<String, dynamic>)['people'] = ['Invented Person'];
    value['claim'] = 'scheduled';
    final result = validator.parseAndValidate(
      value,
      rawTranscript: 'remind me tomorrow at 6 PM',
    );
    expect(result.isValid, isFalse);
    expect(
      result.errors.any((error) => error.contains('unsupported key claim')),
      isTrue,
    );
    expect(
      result.errors.any((error) => error.contains('not grounded')),
      isTrue,
    );
  });

  test(
    'provider registry blocks execution without permission and confirmation',
    () async {
      final parsed = validator
          .parseAndValidate(
            validEnvelope(),
            rawTranscript: 'remind me tomorrow at 6 PM to call Priya',
          )
          .value!;
      final provider = FakeReminderProvider();
      final registry = ActionProviderRegistry()..register(provider);
      expect(
        (await registry.execute(
          parsed,
          userConfirmed: false,
          grantedPermissions: {'reminders'},
        )).errorCode,
        'confirmation_required',
      );
      expect(
        (await registry.execute(
          parsed,
          userConfirmed: true,
          grantedPermissions: const {},
        )).errorCode,
        'permission_required',
      );
      final result = await registry.execute(
        parsed,
        userConfirmed: true,
        grantedPermissions: {'reminders'},
      );
      expect(result.succeeded, isTrue);
      expect(provider.called, isTrue);
    },
  );
}
