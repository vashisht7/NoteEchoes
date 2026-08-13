import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home_screen.dart';
import 'services/action_button_note_ingestion_service.dart';
import 'ai/config/ai_feature_flags.dart';
import 'ai/config/ai_runtime_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0C),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize AI configuration & feature flags
  await AiFeatureFlags.instance.load();
  await AiRuntimeConfig.instance.detect();

  // Import before HomeScreen loads its initial note list.
  await ActionButtonNoteIngestionService.instance.initialize();

  runApp(const NoteEchoesApp());
}

class NoteEchoesApp extends StatelessWidget {
  const NoteEchoesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'notechoes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
