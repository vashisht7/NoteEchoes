import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/note_model.dart';
import '../services/ai_categorization_engine.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';

class SiriActionOverlay extends StatefulWidget {
  final VoidCallback? onDismiss;
  final bool autoStartRecording;

  const SiriActionOverlay({
    super.key,
    this.onDismiss,
    this.autoStartRecording = true,
  });

  /// Static helper to trigger the Siri overlay modal from anywhere
  static Future<NoteModel?> show(BuildContext context, {bool autoStart = true}) {
    return showGeneralDialog<NoteModel>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "SiriActionOverlay",
      barrierColor: Colors.black.withValues(alpha: 0.20), // Translucent so phone content is clearly visible
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return SiriActionOverlay(
          autoStartRecording: autoStart,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          child: child,
        );
      },
    );
  }

  @override
  State<SiriActionOverlay> createState() => _SiriActionOverlayState();
}

class _SiriActionOverlayState extends State<SiriActionOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _auraController;

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isSpeechAvailable = false;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _isRestartingListening = false;
  
  String _accumulatedText = "";
  String _currentSessionText = "";
  double _soundLevel = 0.5;

  int _recordingSeconds = 0;
  Timer? _durationTimer;
  Timer? _watchdogTimer;
  NoteAnalysisResult? _completedAnalysis;
  String _statusMessage = "";

  String get _spokenText {
    final combined = "$_accumulatedText $_currentSessionText".trim();
    return combined;
  }

  @override
  void initState() {
    super.initState();

    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _initSpeechAndStart();
  }

  Future<void> _initSpeechAndStart() async {
    try {
      _isSpeechAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint("SpeechToText Status: $status");
          if (_isRecording && (status == 'done' || status == 'notListening') && mounted) {
            _handleSessionEndAndRestart();
          }
        },
        onError: (error) {
          debugPrint("Speech recognition error: ${error.errorMsg}");
          if (_isRecording && mounted) {
            _handleSessionEndAndRestart();
          }
        },
      );
      if (mounted) {
        setState(() {});
        if (widget.autoStartRecording) {
          _startRecording();
        }
      }
    } catch (e) {
      debugPrint("Speech recognition init exception: $e");
      _isSpeechAvailable = false;
    }
  }

  void _handleSessionEndAndRestart() {
    if (!_isRecording || _isRestartingListening) return;
    _isRestartingListening = true;

    // Flush current session text to master accumulator
    if (_currentSessionText.trim().isNotEmpty) {
      _accumulatedText = "$_accumulatedText $_currentSessionText".trim();
      _currentSessionText = "";
    }

    // Brief delay to allow iOS SFSpeechRecognizer audio hardware to release before re-subscribing
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _isRecording) {
        _restartListeningSession();
      }
      _isRestartingListening = false;
    });
  }

  void _restartListeningSession() {
    if (!_isRecording || !_isSpeechAvailable) return;
    try {
      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _currentSessionText = result.recognizedWords;
              if (result.finalResult && _currentSessionText.trim().isNotEmpty) {
                _accumulatedText = "$_accumulatedText $_currentSessionText".trim();
                _currentSessionText = "";
              }
            });
          }
        },
        onSoundLevelChange: (level) {
          if (mounted) {
            setState(() {
              _soundLevel = (level.abs() / 10.0).clamp(0.2, 1.0);
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          pauseFor: const Duration(hours: 2),
          partialResults: true,
          onDevice: false,
        ),
      );
    } catch (e) {
      debugPrint("Error restarting listening session: $e");
    }
  }

  void _startRecording() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _isAnalyzing = false;
      _accumulatedText = "";
      _currentSessionText = "";
      _recordingSeconds = 0;
      _completedAnalysis = null;
      _statusMessage = "";
    });

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordingSeconds++);
      }
    });

    // 1-second Watchdog Timer: Guarantees continuous recording for hours
    _watchdogTimer?.cancel();
    _watchdogTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRecording && _isSpeechAvailable && mounted) {
        if (!_speech.isListening && !_isRestartingListening) {
          debugPrint("Watchdog: Speech engine stopped while recording. Re-triggering listen...");
          _handleSessionEndAndRestart();
        }
      }
    });

    if (_isSpeechAvailable) {
      _restartListeningSession();
    } else {
      setState(() {
        _statusMessage = "Microphone permission required for speech dictation.";
      });
    }
  }

  void _stopRecordingAndSave() async {
    if (!_isRecording && !_isAnalyzing) return;

    HapticFeedback.mediumImpact();
    _durationTimer?.cancel();
    _watchdogTimer?.cancel();
    if (_isSpeechAvailable) {
      await _speech.stop();
    }

    final cleanText = _spokenText.trim();
    if (cleanText.isEmpty) {
      setState(() {
        _isRecording = false;
        _isAnalyzing = false;
        _statusMessage = "No speech detected.";
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    // Deep semantic categorization on user's real spoken words
    final analysis = AiCategorizationEngine().analyzeNote(cleanText);

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final note = NoteService().createFromVoiceTranscription(cleanText);

    setState(() {
      _isAnalyzing = false;
      _completedAnalysis = analysis;
    });

    HapticFeedback.heavyImpact();

    // Auto dismiss after displaying categorized tags
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pop(note);
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _watchdogTimer?.cancel();
    _auraController.dispose();
    if (_isSpeechAvailable) {
      _speech.stop();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Only dismiss on background tap when NOT actively recording
        if (!_isRecording && !_isAnalyzing) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // 1. Apple Intelligence Screen Perimeter Glowing Edge Aura (NO center ripples)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _auraController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: SiriScreenEdgeAuraPainter(
                        phase: _auraController.value,
                        amplitude: _soundLevel,
                        isRecording: _isRecording,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. Center Content Canvas (Transparent pass-through so underlying screen is visible)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Top Status Pill
                    _buildTopStatusPill(),

                    const Spacer(),

                    // Floating Glass Card for Spoken Speech & Categorization
                    _buildFloatingTranscriptionCard(),

                    const SizedBox(height: 16),

                    // Bottom Action Button / Hold-to-Talk Touch Target
                    _buildBottomActionControl(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TOP STATUS BADGE (Apple Intelligence Siri Mode)
  // ==========================================================
  Widget _buildTopStatusPill() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorderBright.withValues(alpha: 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? const Color(0xFFFF2D55)
                      : _isAnalyzing
                          ? const Color(0xFF00F2FE)
                          : AppColors.accentGreen,
                  boxShadow: [
                    BoxShadow(
                      color: (_isRecording ? const Color(0xFFFF2D55) : const Color(0xFF00F2FE))
                          .withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isRecording
                    ? "Recording Voice Note (${_recordingSeconds}s)..."
                    : _isAnalyzing
                        ? "AI Categorizing..."
                        : "Note Saved!",
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FLOATING TRANSCRIPTION CARD (Transparent Frosted Glass)
  // ==========================================================
  Widget _buildFloatingTranscriptionCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorderBright.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
              ),
            ],
          ),
          child: _completedAnalysis != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Saved Note Title
                    Text(
                      _completedAnalysis!.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Snippet
                    Text(
                      _completedAnalysis!.summarySnippet,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Categorized Tag Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _completedAnalysis!.categories.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F2FE).withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.6)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, size: 11, color: Color(0xFF00F2FE)),
                              const SizedBox(width: 4),
                              Text(
                                "#$tag",
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              : Text(
                  _statusMessage.isNotEmpty
                      ? _statusMessage
                      : _spokenText.isNotEmpty
                          ? _spokenText
                          : "Listening to your voice...\nSpeak your note now.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: _spokenText.isNotEmpty ? 20 : 15,
                    fontWeight: FontWeight.w600,
                    color: _spokenText.isNotEmpty ? Colors.white : AppColors.secondaryText,
                    shadows: _spokenText.isNotEmpty
                        ? [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.6),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                ),
        ),
      ),
    );
  }

  // ==========================================================
  // BOTTOM ACTION BUTTON — TOGGLE: TAP TO START / TAP TO STOP
  // ==========================================================
  Widget _buildBottomActionControl() {
    return GestureDetector(
      onTap: () {
        if (_isRecording) {
          _stopRecordingAndSave();
        } else if (!_isAnalyzing) {
          _startRecording();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: _isRecording ? AppColors.dropletRed : AppColors.elevation2.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isRecording ? Colors.white : AppColors.glassBorderBright,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (_isRecording ? AppColors.dropletRed : Colors.black).withValues(alpha: 0.5),
              blurRadius: 16,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              _isRecording ? "Listening..." : "Tap to Record",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// PAINTER: APPLE INTELLIGENCE PERIMETER SCREEN EDGE GLOW (SIRI AURA)
// ==========================================================
class SiriScreenEdgeAuraPainter extends CustomPainter {
  final double phase;
  final double amplitude;
  final bool isRecording;

  SiriScreenEdgeAuraPainter({
    required this.phase,
    required this.amplitude,
    required this.isRecording,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isRecording) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(38));

    // Outer screen edge glow path
    final glowPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: 2 * pi,
        transform: GradientRotation(phase * 2 * pi),
        colors: [
          const Color(0xFFFF0844),
          const Color(0xFF7D2AE8),
          const Color(0xFF00F2FE),
          const Color(0xFFFF2D55),
          const Color(0xFFFF0844),
        ],
        stops: const [0.0, 0.28, 0.55, 0.82, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 + (amplitude * 5.0)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10.0 + (amplitude * 6.0));

    canvas.drawRRect(rrect, glowPaint);

    // Inner sharp edge rim
    final sharpPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        startAngle: 0.0,
        endAngle: 2 * pi,
        transform: GradientRotation(phase * 2 * pi),
        colors: const [
          Color(0xFFFF0844),
          Color(0xFF7D2AE8),
          Color(0xFF00F2FE),
          Color(0xFFFF2D55),
          Color(0xFFFF0844),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;

    canvas.drawRRect(rrect, sharpPaint);
  }

  @override
  bool shouldRepaint(covariant SiriScreenEdgeAuraPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.isRecording != isRecording;
  }
}
