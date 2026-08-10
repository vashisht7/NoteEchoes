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
  String _spokenText = "";
  double _soundLevel = 0.5;

  Timer? _simulatedVoiceTimer;
  int _recordingSeconds = 0;
  Timer? _durationTimer;
  NoteAnalysisResult? _completedAnalysis;

  final List<String> _simulatedPhrases = [
    "Need to buy almond milk, ground coffee, and fresh sourdough bread from the store",
    "Sprint deliverable due next Tuesday: finish the Stage UI system tokens and glassmorphism specs",
    "Formula for Gaussian integral is integral from minus infinity to plus infinity e to the minus x squared dx equals square root of pi",
    "Client sync meeting notes: follow up on latency benchmark targets and mobile deployment pipeline",
    "New product idea: spatial voice canvas that categorizes thoughts instantly with zero cloud lag",
  ];

  @override
  void initState() {
    super.initState();

    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _initSpeechRecognition();

    if (widget.autoStartRecording) {
      _startRecording();
    }
  }

  Future<void> _initSpeechRecognition() async {
    try {
      _isSpeechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (_isRecording) {
              // auto stop or keep listening
            }
          }
        },
        onError: (error) {
          debugPrint("SpeechToText Error: $error");
        },
      );
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Speech recognition init exception: $e");
      _isSpeechAvailable = false;
    }
  }

  void _startRecording() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _isAnalyzing = false;
      _spokenText = "";
      _recordingSeconds = 0;
      _completedAnalysis = null;
    });

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordingSeconds++);
      }
    });

    if (_isSpeechAvailable) {
      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _spokenText = result.recognizedWords;
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
          pauseFor: const Duration(seconds: 5),
          onDevice: true,
        ),
      );
    } else {
      // Natural voice speech stream simulation if mic permission is pending
      final phrase = _simulatedPhrases[Random().nextInt(_simulatedPhrases.length)];
      final words = phrase.split(' ');
      int wordIndex = 0;

      _simulatedVoiceTimer?.cancel();
      _simulatedVoiceTimer = Timer.periodic(const Duration(milliseconds: 280), (timer) {
        if (wordIndex < words.length && _isRecording && mounted) {
          setState(() {
            _spokenText = words.sublist(0, wordIndex + 1).join(' ');
            _soundLevel = 0.4 + (sin(wordIndex * 0.8) * 0.4).abs();
          });
          wordIndex++;
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _stopRecordingAndSave() async {
    if (!_isRecording && !_isAnalyzing) return;

    HapticFeedback.mediumImpact();
    _durationTimer?.cancel();
    _simulatedVoiceTimer?.cancel();
    if (_isSpeechAvailable) {
      await _speech.stop();
    }

    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    // Deep semantic categorization using on-device AI Engine
    final textToProcess = _spokenText.trim().isNotEmpty
        ? _spokenText.trim()
        : "Quick voice recorded thought memo.";

    final analysis = AiCategorizationEngine().analyzeNote(textToProcess);

    await Future.delayed(const Duration(milliseconds: 350));

    if (!mounted) return;

    final note = NoteService().createFromVoiceTranscription(textToProcess);

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
    _simulatedVoiceTimer?.cancel();
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
        if (_isRecording) {
          _stopRecordingAndSave();
        } else {
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
                  _spokenText.isNotEmpty
                      ? _spokenText
                      : "Listening to your thoughts... Release button to auto-categorize & save.",
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
  // BOTTOM ACTION BUTTON / HOLD-TO-TALK CONTROLLER
  // ==========================================================
  Widget _buildBottomActionControl() {
    return GestureDetector(
      onTapDown: (_) {
        if (!_isRecording) _startRecording();
      },
      onTapUp: (_) {
        if (_isRecording) _stopRecordingAndSave();
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
              _isRecording ? "Release to Save & Categorize" : "Hold or Tap to Record",
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
