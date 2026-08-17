import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'services/note_service.dart';
import 'ai/config/ai_feature_flags.dart';
import 'ai/config/ai_runtime_config.dart';
import 'theme/app_theme.dart';
import 'theme/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050505),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Step 1: Initialize storage so notes are loaded from disk first
  await NoteService().initStorage();

  // Step 2: AI flags
  await AiFeatureFlags.instance.load();
  await AiRuntimeConfig.instance.detect();
  await AppPreferences.instance.load();

  // NOTE: ActionButtonNoteIngestionService.initialize() is intentionally
  // NOT called here. MethodChannels require a live FlutterViewController
  // which is only registered AFTER runApp(). Calling it before runApp()
  // makes every peekPendingActionButtonNote call return null silently.
  // HomeScreen.initState() handles the first import on its first frame.

  runApp(const NoteEchoesApp());
}

class NoteEchoesApp extends StatelessWidget {
  const NoteEchoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences.instance,
      builder: (context, _) => MaterialApp(
        title: 'NoteEchoes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme(AppPreferences.instance.accentColor),
        home: const HomeScreen(),
      ),
    );
  }
}
