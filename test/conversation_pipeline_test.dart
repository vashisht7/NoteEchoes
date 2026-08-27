import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:notechoes_app/services/voice_assistant_service.dart';
import 'package:notechoes_app/services/web_knowledge_service.dart';
import 'package:notechoes_app/screens/voice_assistant_screen.dart';
import 'package:notechoes_app/theme/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'mixed Telugu-English recognition preference is accepted and saved',
    () async {
      SharedPreferences.setMockInitialValues({});
      await AppPreferences.instance.load();

      await AppPreferences.instance.setSpeechLanguage('te-en-mixed');

      expect(AppPreferences.instance.speechLanguageCode, 'te-en-mixed');
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('speech_language_code'), 'te-en-mixed');
    },
  );

  test('a natural pause automatically submits only after speech', () {
    expect(
      VoiceAssistantService.shouldAutoSubmitForTesting(
        heardVoice: true,
        listeningFor: const Duration(seconds: 2),
        silenceFor: const Duration(milliseconds: 1200),
      ),
      isTrue,
    );
    expect(
      VoiceAssistantService.shouldAutoSubmitForTesting(
        heardVoice: false,
        listeningFor: const Duration(seconds: 8),
        silenceFor: const Duration(seconds: 2),
      ),
      isFalse,
    );
    expect(
      VoiceAssistantService.shouldAutoSubmitForTesting(
        heardVoice: true,
        listeningFor: const Duration(seconds: 25),
        silenceFor: Duration.zero,
      ),
      isTrue,
    );
  });

  test('adaptive voice level rejects room noise and accepts nearby speech', () {
    expect(
      VoiceAssistantService.isProbableVoiceLevelForTesting(
        noiseFloorDb: -42,
        levelDb: -38,
      ),
      isFalse,
    );
    expect(
      VoiceAssistantService.isProbableVoiceLevelForTesting(
        noiseFloorDb: -42,
        levelDb: -28,
      ),
      isTrue,
    );
    expect(
      VoiceAssistantService.isProbableVoiceLevelForTesting(
        noiseFloorDb: -60,
        levelDb: -45,
      ),
      isTrue,
    );
    expect(
      VoiceAssistantService.shouldAutoSubmitForTesting(
        heardVoice: true,
        listeningFor: const Duration(seconds: 2),
        silenceFor: const Duration(milliseconds: 300),
      ),
      isFalse,
    );
  });

  test('a new conversation clears the previous report', () async {
    final service = VoiceAssistantService();
    service.completeReportForTesting(response: 'Old answer');
    expect(service.fullGeneratedResponse, 'Old answer');

    await service.startVoiceSession();

    expect(service.fullGeneratedResponse, isEmpty);
    expect(service.state, VoiceAssistantState.listening);
  });

  test('short factual terms do not match random note substrings', () {
    final service = VoiceAssistantService();

    expect(
      service.hasRelevantEvidenceForTesting(
        query: 'Calculate the value of pi',
        title: 'Shopping topic',
        text: 'Pick up groceries after work.',
      ),
      isFalse,
    );
    expect(
      service.hasRelevantEvidenceForTesting(
        query: 'What did I write about pi?',
        title: 'Math constants',
        text: 'Pi is approximately 3.14159.',
      ),
      isTrue,
    );
  });

  testWidgets('conversation accepts a typed question with the send action', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: VoiceAssistantScreen(),
        ),
      ),
    );
    await tester.pump();

    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('conversation_question_field')),
    );
    expect(field.textInputAction, TextInputAction.send);
    expect(field.onSubmitted, isNotNull);
    expect(find.text('Try asking about your notes'), findsNothing);
    expect(find.byType(ListWheelScrollView), findsNothing);
    expect(
      find.text('Listening for your voice • pause when finished'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  test('web fallback returns an attributable answer', () async {
    final client = MockClient((request) async {
      if (request.url.queryParameters['list'] == 'search') {
        return http.Response(
          '{"query":{"search":[{"pageid":123,"title":"Pi"}]}}',
          200,
        );
      }
      return http.Response(
        '{"query":{"pages":{"123":{"pageid":123,"title":"Pi",'
        '"extract":"Pi is the ratio of a circle circumference to its diameter. It is approximately 3.14159 and is an irrational number."}}}}',
        200,
      );
    });

    final result = await WebKnowledgeService(
      client: client,
    ).answer('Calculate the value of pi');

    expect(result.status, WebKnowledgeStatus.answered);
    expect(result.answer, contains('3.14159'));
    expect(result.sourceTitle, 'Pi');
    expect(result.sourceUrl.toString(), contains('wikipedia.org/wiki/Pi'));
  });

  test('web fallback reports offline instead of inventing an answer', () async {
    final client = MockClient((_) async {
      throw const SocketException('No network');
    });

    final result = await WebKnowledgeService(
      client: client,
    ).answer('What is pi?');

    expect(result.status, WebKnowledgeStatus.offline);
    expect(result.answer, isEmpty);
  });
}
