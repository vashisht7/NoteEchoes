// ai.dart
// Barrel export for the AI subsystem.
// Import this single file instead of individual ai/* files.

// Config
export 'config/ai_feature_flags.dart';
export 'config/ai_runtime_config.dart';
export 'config/action_model_identity.dart';
export 'config/model_manifest.dart';

// Domain
export 'domain/ai_models.dart';
export 'domain/core_action_v5.dart';
export 'domain/core_action_v5_adapter.dart';
export 'domain/transcript.dart';
export 'domain/voice_feedback.dart';
export 'domain/note_analysis.dart';
export 'domain/document_chunk.dart';
export 'domain/source_citation.dart';
export 'domain/suggested_action.dart';

// Provider interfaces
export 'providers/text_generation_provider.dart';
export 'providers/transcription_provider.dart';
export 'infrastructure/voice_feedback_store.dart';
export 'providers/retrieval_provider.dart';
export 'providers/document_processor.dart';
export 'providers/calendar_provider.dart';
export 'providers/action_provider_registry.dart';

// Infrastructure
export 'infrastructure/ai_database.dart';
export 'infrastructure/ai_job_queue.dart';
export 'infrastructure/dolphin_sherpa_provider.dart';
export 'infrastructure/fts_retrieval_provider.dart';
export 'infrastructure/model_download_service.dart';
export 'infrastructure/model_integrity_service.dart';
export 'infrastructure/pdfrx_document_processor.dart';
export 'infrastructure/prompt_repository.dart';
export 'infrastructure/qwen_llama_provider.dart';
export 'infrastructure/ai_telemetry_service.dart';

// Application use cases
export 'application/analyze_note_use_case.dart';
export 'application/ask_document_use_case.dart';
export 'application/ask_notebook_use_case.dart';
export 'application/create_meeting_summary_use_case.dart';
export 'application/extract_actions_use_case.dart';
export 'application/ingest_document_use_case.dart';
export 'application/journal_review_use_case.dart';
export 'application/transcribe_note_use_case.dart';

// Presentation UI
export 'presentation/ai_model_settings_page.dart';
export 'presentation/document_chat_page.dart';
export 'presentation/journal_review_page.dart';
export 'presentation/note_insights_view.dart';
export 'presentation/suggested_actions_review.dart';
