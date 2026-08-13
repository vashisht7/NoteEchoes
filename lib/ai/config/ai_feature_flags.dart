// ai_feature_flags.dart
// Runtime feature toggles for all local AI capabilities.
// All flags default to false. They are enabled only after the
// corresponding model has been downloaded and verified.

import 'package:shared_preferences/shared_preferences.dart';

/// Stable keys — never rename without a migration.
class _Keys {
  static const localLlmEnabled = 'ai_flag_local_llm_enabled';
  static const dolphinSttEnabled = 'ai_flag_dolphin_stt_enabled';
  static const noteAnalysisEnabled = 'ai_flag_note_analysis_enabled';
  static const reminderExtractionEnabled = 'ai_flag_reminder_extraction_enabled';
  static const pdfIngestionEnabled = 'ai_flag_pdf_ingestion_enabled';
  static const crossNoteSearchEnabled = 'ai_flag_cross_note_search_enabled';
  static const documentChatEnabled = 'ai_flag_document_chat_enabled';
  static const journalingMemoryEnabled = 'ai_flag_journaling_memory_enabled';
  static const appleIntegrationsEnabled = 'ai_flag_apple_integrations_enabled';
  static const backgroundProcessingEnabled = 'ai_flag_background_processing_enabled';
}

/// Global AI feature flags.
///
/// All flags are readable synchronously after [load] completes.
/// Screens must never read flags before [load] is awaited.
class AiFeatureFlags {
  AiFeatureFlags._();
  static final AiFeatureFlags instance = AiFeatureFlags._();

  SharedPreferences? _prefs;
  bool _loaded = false;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _loaded = true;
  }

  void _assertLoaded() {
    assert(_loaded, 'AiFeatureFlags.load() must be called before reading flags.');
  }

  bool _get(String key) {
    _assertLoaded();
    return _prefs?.getBool(key) ?? false;
  }

  Future<void> _set(String key, bool value) async {
    _assertLoaded();
    await _prefs?.setBool(key, value);
  }

  // ── Read accessors ────────────────────────────────────────────

  /// Whether the local Qwen3.5-0.8B LLM is available and enabled.
  bool get localLlmEnabled => _get(_Keys.localLlmEnabled);

  /// Whether the Dolphin multilingual ASR is available and enabled.
  bool get dolphinSttEnabled => _get(_Keys.dolphinSttEnabled);

  /// Whether AI note analysis (title, summary, tags via LLM) is active.
  bool get noteAnalysisEnabled => _get(_Keys.noteAnalysisEnabled);

  /// Whether reminder/meeting/travel extraction is enabled.
  bool get reminderExtractionEnabled => _get(_Keys.reminderExtractionEnabled);

  /// Whether PDF document ingestion is enabled.
  bool get pdfIngestionEnabled => _get(_Keys.pdfIngestionEnabled);

  /// Whether cross-note FTS5 search is enabled.
  bool get crossNoteSearchEnabled => _get(_Keys.crossNoteSearchEnabled);

  /// Whether grounded document/notebook chat is enabled.
  bool get documentChatEnabled => _get(_Keys.documentChatEnabled);

  /// Whether journaling review and personal memory is enabled.
  bool get journalingMemoryEnabled => _get(_Keys.journalingMemoryEnabled);

  /// Whether optional Apple platform integrations are active.
  bool get appleIntegrationsEnabled => _get(_Keys.appleIntegrationsEnabled);

  /// Whether background AI processing (WorkManager / BGAppRefresh) is enabled.
  bool get backgroundProcessingEnabled => _get(_Keys.backgroundProcessingEnabled);

  // ── Write accessors (infrastructure layer only) ───────────────

  Future<void> setLocalLlmEnabled(bool v) => _set(_Keys.localLlmEnabled, v);
  Future<void> setDolphinSttEnabled(bool v) => _set(_Keys.dolphinSttEnabled, v);
  Future<void> setNoteAnalysisEnabled(bool v) => _set(_Keys.noteAnalysisEnabled, v);
  Future<void> setReminderExtractionEnabled(bool v) => _set(_Keys.reminderExtractionEnabled, v);
  Future<void> setPdfIngestionEnabled(bool v) => _set(_Keys.pdfIngestionEnabled, v);
  Future<void> setCrossNoteSearchEnabled(bool v) => _set(_Keys.crossNoteSearchEnabled, v);
  Future<void> setDocumentChatEnabled(bool v) => _set(_Keys.documentChatEnabled, v);
  Future<void> setJournalingMemoryEnabled(bool v) => _set(_Keys.journalingMemoryEnabled, v);
  Future<void> setAppleIntegrationsEnabled(bool v) => _set(_Keys.appleIntegrationsEnabled, v);
  Future<void> setBackgroundProcessingEnabled(bool v) =>
      _set(_Keys.backgroundProcessingEnabled, v);

  /// Disable every AI feature. Used for Tier-C devices or user opt-out.
  Future<void> disableAll() async {
    await Future.wait([
      _set(_Keys.localLlmEnabled, false),
      _set(_Keys.dolphinSttEnabled, false),
      _set(_Keys.noteAnalysisEnabled, false),
      _set(_Keys.reminderExtractionEnabled, false),
      _set(_Keys.pdfIngestionEnabled, false),
      _set(_Keys.crossNoteSearchEnabled, false),
      _set(_Keys.documentChatEnabled, false),
      _set(_Keys.journalingMemoryEnabled, false),
      _set(_Keys.appleIntegrationsEnabled, false),
      _set(_Keys.backgroundProcessingEnabled, false),
    ]);
  }
}
