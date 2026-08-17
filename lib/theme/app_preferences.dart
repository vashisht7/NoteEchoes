import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppAccent {
  final String id;
  final String label;
  final Color color;

  const AppAccent(this.id, this.label, this.color);
}

/// Small, persisted set of preferences that genuinely affect the whole app.
class AppPreferences extends ChangeNotifier {
  AppPreferences._();
  static final AppPreferences instance = AppPreferences._();

  static const accents = <AppAccent>[
    AppAccent('crimson', 'NoteEchoes Crimson', Color(0xFFD7192D)),
    AppAccent('orange', 'Orange', Color(0xFFFF9F0A)),
    AppAccent('blue', 'Blue', Color(0xFF0A84FF)),
    AppAccent('purple', 'Purple', Color(0xFFBF5AF2)),
  ];

  SharedPreferences? _prefs;
  String _accentId = 'crimson';
  String _speechLanguageCode = 'en';

  String get accentId => _accentId;
  Color get accentColor => accents
      .firstWhere(
        (accent) => accent.id == _accentId,
        orElse: () => accents.first,
      )
      .color;
  String get speechLanguageCode => _speechLanguageCode;

  String get speechLanguageLabel => switch (_speechLanguageCode) {
    'te' => 'Telugu',
    'hi' => 'Hindi',
    'auto' => 'Automatic',
    _ => 'English',
  };

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _accentId = _prefs?.getString('app_accent') ?? 'crimson';
    _speechLanguageCode = _prefs?.getString('speech_language_code') ?? 'en';
  }

  Future<void> setAccent(String id) async {
    if (!accents.any((accent) => accent.id == id) || id == _accentId) return;
    _accentId = id;
    await _prefs?.setString('app_accent', id);
    notifyListeners();
  }

  Future<void> setSpeechLanguage(String code) async {
    if (!const {'en', 'te', 'hi', 'auto'}.contains(code) ||
        code == _speechLanguageCode) {
      return;
    }
    _speechLanguageCode = code;
    await _prefs?.setString('speech_language_code', code);
    notifyListeners();
  }
}
