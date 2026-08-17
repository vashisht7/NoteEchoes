import 'dart:math';

import 'package:flutter/material.dart';

import '../models/note_node.dart';

/// A quiet, logo-derived voice field. Listening is rendered as a fine signal
/// line; thinking becomes information descending from above instead of an orb.
class VoiceVisualizerPainter extends CustomPainter {
  final double animationValue;
  final VoiceState state;
  final double amplitude;
  final Color accent;

  VoiceVisualizerPainter({
    required this.animationValue,
    required this.state,
    required this.accent,
    this.amplitude = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (state == VoiceState.listening) {
      _paintListeningField(canvas, size);
    } else if (state == VoiceState.thinking) {
      _paintDescendingMemory(canvas, size);
    }
  }

  void _paintListeningField(Canvas canvas, Size size) {
    final centerY = size.height * 0.43;
    final width = size.width * 0.72;
    final left = (size.width - width) / 2;
    final phase = animationValue * 2 * pi;

    canvas.drawLine(
      Offset(left, centerY),
      Offset(left + width, centerY),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = 1,
    );

    final signal = Path()..moveTo(left, centerY);
    const points = 120;
    for (var i = 0; i <= points; i++) {
      final t = i / points;
      final envelope = pow(sin(pi * t), 2).toDouble();
      final wave =
          sin(t * 12 * pi + phase) * 8 + sin(t * 23 * pi - phase * 1.3) * 3;
      signal.lineTo(
        left + width * t,
        centerY + wave * envelope * (0.35 + amplitude * 0.75),
      );
    }
    canvas.drawPath(
      signal,
      Paint()
        ..color = accent.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    final cursorX = left + width * ((animationValue * 1.7) % 1);
    canvas.drawCircle(
      Offset(cursorX, centerY),
      2.4,
      Paint()..color = Colors.white.withValues(alpha: 0.82),
    );
  }

  void _paintDescendingMemory(Canvas canvas, Size size) {
    final destination = Offset(size.width / 2, size.height * 0.47);
    final phase = animationValue * 2 * pi;

    // Hairline information paths descend from a source beyond the screen.
    for (var i = 0; i < 9; i++) {
      final normalized = i / 8;
      final startX = size.width * (0.08 + normalized * 0.84);
      final sway = sin(phase + i * 0.9) * 10;
      final path = Path()
        ..moveTo(startX, -24)
        ..cubicTo(
          startX + sway,
          size.height * 0.18,
          destination.dx + (startX - destination.dx) * 0.22,
          size.height * 0.32,
          destination.dx,
          destination.dy,
        );
      canvas.drawPath(
        path,
        Paint()
          ..color = (i.isEven ? accent : Colors.white).withValues(
            alpha: i.isEven ? 0.19 : 0.07,
          )
          ..style = PaintingStyle.stroke
          ..strokeWidth = i.isEven ? 1.2 : 0.7,
      );

      final travel = (animationValue * (0.8 + i * 0.035) + i * 0.13) % 1;
      final metric = path.computeMetrics().first;
      final tangent = metric.getTangentForOffset(metric.length * travel);
      if (tangent != null) {
        canvas.drawCircle(
          tangent.position,
          i.isEven ? 2.1 : 1.3,
          Paint()
            ..color = (i.isEven ? accent : Colors.white).withValues(alpha: 0.8),
        );
      }
    }

    // A precise landing mark replaces the former glowing bubble.
    canvas.drawLine(
      Offset(destination.dx - 34, destination.dy),
      Offset(destination.dx + 34, destination.dy),
      Paint()
        ..color = accent.withValues(alpha: 0.55)
        ..strokeWidth = 1,
    );
    canvas.drawCircle(destination, 3, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(covariant VoiceVisualizerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.state != state ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.accent != accent;
  }
}
