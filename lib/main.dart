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

  try {
    await AppPreferences.instance.load();
  } catch (e) {
    debugPrint('AppPreferences load fallback: $e');
  }

  try {
    await AiFeatureFlags.instance.load();
    await AiRuntimeConfig.instance.detect();
  } catch (e) {
    debugPrint('AI config init fallback: $e');
  }

  try {
    await NoteService().initStorage();
  } catch (e) {
    debugPrint('Note storage init fallback: $e');
  }

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
