import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/note_model.dart';
import '../ai/domain/ai_models.dart';
import '../ai/domain/voice_feedback.dart';
import '../ai/infrastructure/offline_speech_bridge.dart';
import '../ai/infrastructure/multilingual_interpretation_service.dart';
import '../ai/infrastructure/voice_feedback_store.dart';
import '../services/ai_categorization_engine.dart';
import '../services/note_service.dart';
import '../services/voice_capture_validator.dart';
import '../services/voice_capture_control.dart';
import '../theme/app_colors.dart';
import '../theme/app_preferences.dart';

class SiriActionOverlay extends StatefulWidget {
  final VoidCallback? onDismiss;
  final bool autoStartRecording;

  const SiriActionOverlay({
    super.key,
    this.onDismiss,
    this.autoStartRecording = true,
  });

  /// Shows the sleek, real-time bottom recording sheet inspired by Google/Apple Notes & Antigravity.
  static Future<NoteModel?> show(
    BuildContext context, {
    bool autoStart = true,
  }) {
    return showModalBottomSheet<NoteModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return SiriActionOverlay(
          autoStartRecording: autoStart,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  State<SiriActionOverlay> createState() => _SiriActionOverlayState();
}

class _SiriActionOverlayState extends State<SiriActionOverlay>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isSpeechAvailable = false;
  bool _isRecording = false;
  bool _isAnalyzing = false;

  String _accumulatedText = "";
  String _currentSessionText = "";
  int _recordingSeconds = 0;
  Timer? _durationTimer;
  NoteAnalysisResult? _completedAnalysis;
  NoteModel? _completedNote;
  String _feedbackRawTranscript = '';
  bool _feedbackBusy = false;
  String? _recordingPath;

  String get _spokenText {
    final combined = "$_accumulatedText $_currentSessionText".trim();
    return combined;
  }

  @override
  void initState() {
    super.initState();
    NoteService().addListener(_handleNoteServiceUpdate);
    _initSpeechAndStart();
  }

  void _handleNoteServiceUpdate() {
    final completed = _completedNote;
    if (!mounted || completed == null) return;
    final matches = NoteService().allNotes.where(
      (note) => note.noteId == completed.noteId,
    );
    if (matches.isEmpty) return;
    setState(() => _completedNote = matches.first);
  }

  Future<void> _initSpeechAndStart() async {
    try {
      _isSpeechAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint("Live Speech Status: $status");
          if (_isRecording &&
              (status == 'done' || status == 'notListening') &&
              mounted) {
            _restartLiveDictation();
          }
        },
        onError: (error) {
          debugPrint("Live Speech Error: ${error.errorMsg}");
          if (_isRecording && mounted) {
            _restartLiveDictation();
          }
        },
      );
    } catch (e) {
      debugPrint("Speech recognition init exception: $e");
      _isSpeechAvailable = false;
    }

    if (mounted) {
      setState(() {});
      if (widget.autoStartRecording) {
        _startRecording();
      }
    }
  }

  void _startLiveDictation() {
    if (!_isSpeechAvailable || !_isRecording) return;
    // Determine the locale to use for live dictation
    final localeId = _appleLocaleId;

    try {
      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _currentSessionText = result.recognizedWords;
              if (result.finalResult && _currentSessionText.trim().isNotEmpty) {
                _accumulatedText = "$_accumulatedText $_currentSessionText"
                    .trim();
                _currentSessionText = "";
              }
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          pauseFor: const Duration(seconds: 4),
          partialResults: true,
          onDevice: false,
          // Use null for auto detection (en-US default on iOS when no te-IN is installed).
          // Whisper will handle the full-file Telugu/Hindi transcription offline.
          localeId: localeId,
        ),
      );
    } catch (e) {
      debugPrint("Error starting live dictation ($localeId): $e");
      // If te-IN / hi-IN dictation fails, continue — Whisper will transcribe the full audio.
    }
  }

  void _restartLiveDictation() {
    if (!_isRecording) return;
    if (_currentSessionText.trim().isNotEmpty) {
      _accumulatedText = "$_accumulatedText $_currentSessionText".trim();
      _currentSessionText = "";
    }
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _isRecording) {
        _startLiveDictation();
      }
    });
  }

  String? get _appleLocaleId =>
      switch (AppPreferences.instance.speechLanguageCode) {
        'te' => 'te-IN',
        'hi' => 'hi-IN',
        'en' => 'en-US',
        _ => null,
      };

  Future<void> _startRecording() async {
    if (_isRecording) return;
    if (!await _audioRecorder.hasPermission()) {
      return;
    }

    final tempDirectory = await getTemporaryDirectory();
    _recordingPath =
        '${tempDirectory.path}/noteechoes_${DateTime.now().microsecondsSinceEpoch}.m4a';

    try {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: _recordingPath!,
      );
    } catch (e) {
      debugPrint("Error starting audio recorder: $e");
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _isAnalyzing = false;
      _accumulatedText = "";
      _currentSessionText = "";
      _recordingSeconds = 0;
      _completedAnalysis = null;
      _completedNote = null;
      _feedbackRawTranscript = '';
      _feedbackBusy = false;
    });

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordingSeconds++);
      }
    });

    // Start live speech-to-text so words appear instantly as spoken
    _startLiveDictation();
  }

  Future<void> _stopRecordingAndSave({bool userCancelled = false}) async {
    if (!_isRecording && !_isAnalyzing) {
      Navigator.of(context).pop();
      return;
    }

    HapticFeedback.mediumImpact();
    _durationTimer?.cancel();

    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    try {
      if (_isSpeechAvailable) {
        await _speech.stop();
      }
    } catch (_) {}

    String? recordedPath;
    try {
      recordedPath = await _audioRecorder.stop() ?? _recordingPath;
    } catch (_) {}

    if (userCancelled) {
      if (recordedPath != null) {
        try {
          await File(recordedPath).delete();
        } catch (_) {}
      }
      if (mounted) Navigator.of(context).pop();
      return;
    }

    var cleanText = _spokenText.trim();

    // Live speech is already usable for the common path. Running a second
    // full-file Whisper pass made every Save feel frozen; reserve it for the
    // rare case where live recognition did not capture meaningful words.
    if (!VoiceCaptureValidator.hasMeaningfulSpeech(cleanText) &&
        recordedPath != null &&
        await File(recordedPath).exists()) {
      try {
        final langCode = AppPreferences.instance.speechLanguageCode;
        final audioLang = AudioLanguageExt.fromBcp47(langCode);
        final provenance = await OfflineSpeechBridge.instance
            .transcribeAudioFile(audioPath: recordedPath, language: audioLang);
        if (provenance.text.trim().isNotEmpty) {
          cleanText = provenance.text.trim();
        }
      } catch (error) {
        debugPrint('Full-file transcription fallback to live text: $error');
      } finally {
        try {
          await File(recordedPath).delete();
        } catch (_) {}
      }
    } else if (recordedPath != null) {
      try {
        await File(recordedPath).delete();
      } catch (_) {}
    }

    cleanText = VoiceCaptureValidator.sanitizeTranscript(cleanText);
    if (!VoiceCaptureValidator.hasMeaningfulSpeech(cleanText)) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (VoiceCaptureControl.isCancelCommand(cleanText)) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Categorize and create note
    final analysis = AiCategorizationEngine().analyzeNote(cleanText);
    final note = await NoteService().createFromVoiceTranscription(cleanText);

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _completedAnalysis = analysis;
        _completedNote = note;
        _feedbackRawTranscript = cleanText;
      });
      HapticFeedback.heavyImpact();
    }
  }

  Future<void> _submitFeedback({String? correctedOutput}) async {
    final note = _completedNote;
    if (note == null || _feedbackBusy) return;
    setState(() => _feedbackBusy = true);
    var returnedNote = note;
    final correction = correctedOutput?.trim();
    if (correction != null && correction.isNotEmpty) {
      returnedNote = note.copyWith(textContent: correction);
      await NoteService().updateNote(returnedNote);
    }
    try {
      final now = DateTime.now();
      await VoiceFeedbackStore.instance.append(
        VoiceFeedbackRecord(
          feedbackId: 'voice-feedback-${now.microsecondsSinceEpoch}',
          noteId: note.noteId,
          rawTranscript: _feedbackRawTranscript,
          modelOutput: note.textContent,
          correctedOutput: correction,
          language: AppPreferences.instance.speechLanguageCode,
          modelVersion: MultilingualInterpretationService.modelVersion,
          decision: correction == null
              ? VoiceFeedbackDecision.accepted
              : VoiceFeedbackDecision.corrected,
          createdAt: now,
        ),
      );
    } catch (error) {
      debugPrint('Could not save local voice feedback: $error');
    }
    if (mounted) Navigator.of(context).pop(returnedNote);
  }

  Future<void> _correctAndSubmitFeedback() async {
    final note = _completedNote;
    if (note == null || _feedbackBusy) return;
    final controller = TextEditingController(text: note.textContent);
    final correction = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Fix the clean note'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: 'Keep only what you meant to save',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('Save correction'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (correction != null && correction.trim().isNotEmpty) {
      await _submitFeedback(correctedOutput: correction);
    }
  }

  void _skipFeedback() {
    final note = _completedNote;
    if (note != null) Navigator.of(context).pop(note);
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    NoteService().removeListener(_handleNoteServiceUpdate);
    if (_isSpeechAvailable) {
      _speech.stop();
    }
    _audioRecorder.dispose();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, 24 + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Row: Status & Live Timer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? accent
                        : _isAnalyzing
                        ? const Color(0xFFFF9F0A)
                        : AppColors.accentGreen,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isRecording
                      ? 'Dictating • ${_formatTime(_recordingSeconds)}'
                      : _isAnalyzing
                      ? 'Saving to Home Notes…'
                      : 'Review clean note',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                // Language badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppPreferences.instance.speechLanguageLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF2C2C2E), height: 1),

          // Real-time spoken transcript display
          Container(
            constraints: const BoxConstraints(minHeight: 110, maxHeight: 220),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: SingleChildScrollView(
              reverse: true,
              child: _completedAnalysis != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _completedAnalysis!.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        if (_completedNote!.tags.contains('reminders')) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _completedNote!.tags.contains(
                                    'reminder-scheduled',
                                  )
                                  ? AppColors.accentGreen.withValues(alpha: .12)
                                  : _completedNote!.tags.contains(
                                      'reminder-pending',
                                    )
                                  ? accent.withValues(alpha: .12)
                                  : const Color(
                                      0xFFFF9F0A,
                                    ).withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _completedNote!.tags.contains(
                                        'reminder-scheduled',
                                      )
                                      ? Icons.notifications_active_rounded
                                      : _completedNote!.tags.contains(
                                          'reminder-pending',
                                        )
                                      ? Icons.schedule_rounded
                                      : Icons.notifications_off_rounded,
                                  size: 18,
                                  color:
                                      _completedNote!.tags.contains(
                                        'reminder-scheduled',
                                      )
                                      ? AppColors.accentGreen
                                      : _completedNote!.tags.contains(
                                          'reminder-pending',
                                        )
                                      ? accent
                                      : const Color(0xFFFF9F0A),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _completedNote!.tags.contains(
                                          'reminder-scheduled',
                                        )
                                        ? 'iPhone reminder scheduled'
                                        : _completedNote!.tags.contains(
                                            'reminder-pending',
                                          )
                                        ? 'Saved • scheduling iPhone reminder'
                                        : 'Reminder not scheduled — allow Reminders and Notifications in Settings',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          _completedNote?.textContent ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _completedAnalysis!.categories.map((t) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '#$t',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Was this clean-up right?',
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      _spokenText.isNotEmpty
                          ? _spokenText
                          : 'Speak now — your words will appear here in real time…',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.45,
                        color: _spokenText.isNotEmpty
                            ? Colors.white
                            : Colors.white38,
                        fontWeight: _spokenText.isNotEmpty
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
            ),
          ),

          const Divider(color: Color(0xFF2C2C2E), height: 1),

          // Capture controls become an explicit local feedback review.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: _completedNote == null
                ? Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _feedbackBusy
                              ? null
                              : () =>
                                    _stopRecordingAndSave(userCancelled: true),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _feedbackBusy
                              ? null
                              : _stopRecordingAndSave,
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Save Note'),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _feedbackBusy
                                  ? null
                                  : _correctAndSubmitFeedback,
                              icon: const Icon(Icons.edit_rounded, size: 17),
                              label: const Text('Fix'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: _feedbackBusy ? null : _submitFeedback,
                              icon: const Icon(
                                Icons.thumb_up_alt_rounded,
                                size: 17,
                              ),
                              label: const Text('Looks right'),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: _feedbackBusy ? null : _skipFeedback,
                        child: const Text('Skip feedback'),
                      ),
                      Text(
                        'Feedback stays on this device until you choose to export it.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
