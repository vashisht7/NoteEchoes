import 'package:flutter_test/flutter_test.dart';
import 'package:notechoes_app/ai/domain/multilingual_action_semantics.dart';

void main() {
  const validator = MultilingualActionSemanticsValidator();
  const enricher = MultilingualActionPolicyEnricher();

  test('accepts grounded Telugu-English reminder and derives policy', () {
    const raw = 'Ravi కి call చేయాలని రేపు సాయంత్రం 6 గంటలకు remind చేయి';
    final result = validator.parse({
      'schema_version': 1,
      'intent': 'reminder',
      'title': 'Call Ravi',
      'items': ['Ravi కి call చేయాలని'],
      'recipient': 'Ravi',
      'people': ['Ravi'],
      'date': 'రేపు',
      'time': 'సాయంత్రం 6 గంటలకు',
      'place': null,
      'subject': null,
      'draft': null,
      'clarification_question': null,
    }, rawTranscript: raw);
    expect(result.errors, isEmpty);
    final envelope = enricher.enrich(result.value!, rawTranscript: raw);
    expect(envelope.language, 'mixed');
    expect(envelope.mode, 'capture');
    expect(envelope.proposedTool.name, 'reminders.propose');
    expect(envelope.requiresConfirmation, isTrue);
  });

  test('accepts Telugu-Hindi-English code switching', () {
    const raw = 'Ravi కోసం report भेजना, मुझे రేపు 6 PM remind చేయి';
    final result = validator.parse({
      'schema_version': 1,
      'intent': 'reminder',
      'title': 'Report to Ravi',
      'items': ['report भेजना'],
      'recipient': 'Ravi',
      'people': ['Ravi'],
      'date': 'రేపు',
      'time': '6 PM',
      'place': null,
      'subject': null,
      'draft': null,
      'clarification_question': null,
    }, rawTranscript: raw);
    expect(result.isValid, isTrue);
    expect(
      enricher.enrich(result.value!, rawTranscript: raw).language,
      'mixed',
    );
  });

  test('rejects hallucinated entities before policy enrichment', () {
    const raw = 'Remind me tomorrow to submit the report';
    final result = validator.parse({
      'schema_version': 1,
      'intent': 'reminder',
      'title': 'Submit report',
      'items': ['submit the report'],
      'recipient': 'Priya',
      'people': ['Priya'],
      'date': 'tomorrow',
      'time': null,
      'place': null,
      'subject': null,
      'draft': null,
      'clarification_question': null,
    }, rawTranscript: raw);
    expect(result.isValid, isFalse);
    expect(result.errors.join(' '), contains('Priya'));
  });

  test('rejects an incomplete reminder instead of guessing a time', () {
    const raw = 'मुझे कल report जमा करना याद दिलाना';
    final result = validator.parse({
      'schema_version': 1,
      'intent': 'reminder',
      'title': 'Report जमा करना',
      'items': ['report जमा करना'],
      'recipient': null,
      'people': <String>[],
      'date': 'कल',
      'time': null,
      'place': null,
      'subject': null,
      'draft': null,
      'clarification_question': null,
    }, rawTranscript: raw);
    expect(result.isValid, isFalse);
    expect(
      result.errors,
      contains('reminder requires an item, date, and time'),
    );
  });

  test('rejects an incomplete message proposal', () {
    const raw = 'Rahul को message भेजो';
    final result = validator.parse({
      'schema_version': 1,
      'intent': 'message',
      'title': 'Message to Rahul',
      'items': <String>[],
      'recipient': 'Rahul',
      'people': ['Rahul'],
      'date': null,
      'time': null,
      'place': null,
      'subject': null,
      'draft': null,
      'clarification_question': null,
    }, rawTranscript: raw);
    expect(result.isValid, isFalse);
    expect(result.errors, contains('message requires a recipient and draft'));
  });

  test('rejects a subtly corrupted Telugu-English checklist item', () {
    const raw =
        'checklist తయారు చేయి: డెమో సిద్ధం చేయడం, రిపోర్ట్ సమర్పించడం, డాక్టర్ అపాయింట్‌మెంట్ బుక్ చేయడం';
    final result = validator.parse({
      'schema_version': 1,
      'intent': 'checklist',
      'title': 'పనుల జాబితా',
      'items': [
        'డెమో సిద్ధం చేయడం',
        'రిపోర్ట్ సమర్పించడం',
        'డాక్టర్ అపాయింట్‌మెంట్‌మెంట్ బుక్ చేయడం',
      ],
      'recipient': null,
      'people': <String>[],
      'date': null,
      'time': null,
      'place': null,
      'subject': null,
      'draft': null,
      'clarification_question': null,
    }, rawTranscript: raw);

    expect(result.isValid, isFalse);
    expect(result.errors.single, contains('Ungrounded value'));
  });

  test('derives a null tool for cancellation', () {
    const raw = 'यह recording cancel करो';
    final result = validator.parse({
      'schema_version': 1,
      'intent': 'cancel',
      'title': null,
      'items': <String>[],
      'recipient': null,
      'people': <String>[],
      'date': null,
      'time': null,
      'place': null,
      'subject': null,
      'draft': null,
      'clarification_question': null,
    }, rawTranscript: raw);
    final envelope = enricher.enrich(result.value!, rawTranscript: raw);
    expect(envelope.mode, 'control');
    expect(envelope.proposedTool.name, isNull);
    expect(envelope.proposedTool.arguments, isEmpty);
  });
}
