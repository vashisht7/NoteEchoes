import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';
import '../theme/app_colors.dart';

enum DrawingTool {
  pen,
  pencil,
  marker,
  eraser,
}

class DrawnStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final DrawingTool tool;

  DrawnStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.tool,
  });
}

class AppleDrawingCanvasDialog extends StatefulWidget {
  const AppleDrawingCanvasDialog({super.key});

  static Future<MediaAsset?> show(BuildContext context) {
    return Navigator.push<MediaAsset?>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const AppleDrawingCanvasDialog(),
      ),
    );
  }

  @override
  State<AppleDrawingCanvasDialog> createState() =>
      _AppleDrawingCanvasDialogState();
}

class _AppleDrawingCanvasDialogState extends State<AppleDrawingCanvasDialog> {
  final List<DrawnStroke> _strokes = [];
  final List<DrawnStroke> _redoHistory = [];

  DrawingTool _selectedTool = DrawingTool.pen;
  Color _selectedColor = const ui.Color(0xFFFFFFFF);
  double _strokeWidth = 3.5;

  static const List<Color> _palette = [
    ui.Color(0xFFFFFFFF), // White
    ui.Color(0xFFFFD60A), // Apple Yellow
    ui.Color(0xFFFF9F0A), // Apple Orange
    ui.Color(0xFFFF453A), // Apple Red
    ui.Color(0xFFBF5AF2), // Apple Purple
    ui.Color(0xFF0A84FF), // Apple Blue
    ui.Color(0xFF30D158), // Apple Green
    ui.Color(0xFF64D2FF), // Apple Cyan
    ui.Color(0xFF1E1E24), // Charcoal
  ];

  void _onPanStart(DragStartDetails details) {
    final point = details.localPosition;
    setState(() {
      _redoHistory.clear();
      _strokes.add(
        DrawnStroke(
          points: [point],
          color: _selectedTool == DrawingTool.eraser
              ? const ui.Color(0xFF121214)
              : (_selectedTool == DrawingTool.marker
                  ? _selectedColor.withValues(alpha: 0.45)
                  : _selectedColor),
          strokeWidth: _selectedTool == DrawingTool.eraser
              ? 24.0
              : (_selectedTool == DrawingTool.marker
                  ? _strokeWidth * 3.2
                  : _strokeWidth),
          tool: _selectedTool,
        ),
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final point = details.localPosition;
    setState(() {
      if (_strokes.isNotEmpty) {
        _strokes.last.points.add(point);
      }
    });
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() {
        _redoHistory.add(_strokes.removeLast());
      });
    }
  }

  void _redo() {
    if (_redoHistory.isNotEmpty) {
      setState(() {
        _strokes.add(_redoHistory.removeLast());
      });
    }
  }

  void _clear() {
    if (_strokes.isEmpty) return;
    setState(() {
      _redoHistory.addAll(_strokes);
      _strokes.clear();
    });
  }

  Future<void> _exportAndSave() async {
    if (_strokes.isEmpty) {
      Navigator.pop(context, null);
      return;
    }

    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(800, 1000);

      // Dark drawing background
      final bgPaint = Paint()..color = const Color(0xFF121214);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

      // Render strokes
      for (final stroke in _strokes) {
        if (stroke.points.length < 2) continue;
        final paint = Paint()
          ..color = stroke.color
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = stroke.strokeWidth
          ..style = PaintingStyle.stroke;

        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(size.width.toInt(), size.height.toInt());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      if (pngBytes == null) {
        if (mounted) Navigator.pop(context, null);
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath =
          '${tempDir.path}/sketch_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes.buffer.asUint8List());

      final asset = MediaAsset(
        type: MediaAssetType.image,
        url: filePath,
        caption: "Apple Notes Drawing",
        visualPreset: "sketch_markup",
      );

      if (mounted) {
        Navigator.pop(context, asset);
      }
    } catch (e) {
      debugPrint("Error exporting drawing: $e");
      if (mounted) Navigator.pop(context, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Markup & Sketch",
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            color: _strokes.isNotEmpty ? Colors.white : Colors.white24,
            tooltip: "Undo",
            onPressed: _strokes.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 20),
            color: _redoHistory.isNotEmpty ? Colors.white : Colors.white24,
            tooltip: "Redo",
            onPressed: _redoHistory.isNotEmpty ? _redo : null,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, size: 20),
            color: _strokes.isNotEmpty ? Colors.redAccent : Colors.white24,
            tooltip: "Clear Canvas",
            onPressed: _strokes.isNotEmpty ? _clear : null,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 4),
            child: FilledButton(
              onPressed: _exportAndSave,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.dropletRed,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Done",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Drawing Area
          Expanded(
            child: ClipRect(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                child: CustomPaint(
                  painter: _DrawingPainter(strokes: _strokes),
                  size: Size.infinite,
                ),
              ),
            ),
          ),

          // Apple Notes Bottom Brush & Color Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Tool Selector (Pen, Pencil, Marker, Eraser)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildToolButton(
                      icon: Icons.edit_rounded,
                      label: "Pen",
                      tool: DrawingTool.pen,
                    ),
                    _buildToolButton(
                      icon: Icons.brush_rounded,
                      label: "Marker",
                      tool: DrawingTool.marker,
                    ),
                    _buildToolButton(
                      icon: Icons.draw_rounded,
                      label: "Pencil",
                      tool: DrawingTool.pencil,
                    ),
                    _buildToolButton(
                      icon: Icons.auto_fix_high_rounded,
                      label: "Eraser",
                      tool: DrawingTool.eraser,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Palette & Thickness
                Row(
                  children: [
                    // Stroke width slider indicator
                    IconButton(
                      icon: Icon(
                        Icons.lens,
                        size: (_strokeWidth * 2.5).clamp(8.0, 24.0),
                        color: _selectedColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _strokeWidth = _strokeWidth >= 8.0 ? 2.0 : _strokeWidth + 2.0;
                        });
                      },
                    ),
                    const SizedBox(width: 4),

                    // Color swatches
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _palette.map((color) {
                            final isSelected = _selectedColor == color &&
                                _selectedTool != DrawingTool.eraser;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                  if (_selectedTool == DrawingTool.eraser) {
                                    _selectedTool = DrawingTool.pen;
                                  }
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white24,
                                    width: isSelected ? 2.5 : 1.0,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: color.withValues(alpha: 0.6),
                                            blurRadius: 6,
                                          ),
                                        ]
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    required DrawingTool tool,
  }) {
    final isSelected = _selectedTool == tool;
    return GestureDetector(
      onTap: () => setState(() => _selectedTool = tool),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.dropletRed.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.dropletRed : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.dropletRed : Colors.white60,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawingPainter extends CustomPainter {
  final List<DrawnStroke> strokes;

  _DrawingPainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final paint = Paint()
        ..color = stroke.color
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = stroke.strokeWidth
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(stroke.points.first, stroke.strokeWidth / 2, paint);
      } else {
        final path = Path();
        path.moveTo(stroke.points.first.dx, stroke.points.first.dy);
        for (int i = 1; i < stroke.points.length; i++) {
          path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
