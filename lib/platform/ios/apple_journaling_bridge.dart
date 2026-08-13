import 'package:flutter/services.dart';

class AppleJournalingBridge {
  static final AppleJournalingBridge instance = AppleJournalingBridge._();
  AppleJournalingBridge._();
  
  static const MethodChannel _channel = MethodChannel('notechoes/journaling');

  /// Show the Journaling Suggestion Picker.
  /// This feature requires the `com.apple.developer.journal.journaling-suggestions` entitlement.
  Future<void> showJournalingSuggestionPicker() async {
    try {
      await _channel.invokeMethod('showSuggestionPicker');
    } catch (e) {
      // Ignore errors for now
    }
  }

  /// Get the selected suggestion from the picker.
  /// This feature requires the `com.apple.developer.journal.journaling-suggestions` entitlement.
  Future<Map<String, dynamic>?> getSelectedSuggestion() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('getSelectedSuggestion');
      return result;
    } catch (e) {
      return null;
    }
  }
}
