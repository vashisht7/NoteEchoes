import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/note_model.dart';
import '../../theme/app_colors.dart';

class OrbitalNotesRing extends StatelessWidget {
  final List<NoteModel> notes;
  final int activeIndex;
  final double continuousRotationDegrees;
  final double radius;
  final Function(NoteModel)? onNoteTap;

  const OrbitalNotesRing({
    super.key,
    required this.notes,
    required this.activeIndex,
    required this.continuousRotationDegrees,
    this.radius = 145.0,
    this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) return const SizedBox.shrink();

    final count = notes.length;
    final baseStepAngle = 360.0 / count;

    return SizedBox(
      width: radius * 2 + 100,
      height: radius * 2 + 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Subtle Orbital Track Ring
          Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.glassBorderBright.withValues(alpha: 0.25),
                width: 1.2,
              ),
            ),
          ),

          // 2. Render each miniature circular preview badge along the orbit
          ...List.generate(count, (index) {
            final note = notes[index];
            final isActive = index == activeIndex;

            // Compute angle in radians with current smooth continuous rotation
            final noteAngleDeg = (index * baseStepAngle) + continuousRotationDegrees;
            final noteAngleRad = (noteAngleDeg * pi) / 180.0;

            final xOffset = radius * cos(noteAngleRad);
            final yOffset = radius * sin(noteAngleRad);

            return Transform.translate(
              offset: Offset(xOffset, yOffset),
              child: _buildOrbitalNoteBadge(context, note, isActive),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrbitalNoteBadge(BuildContext context, NoteModel note, bool isActive) {
    return GestureDetector(
      onTap: () => onNoteTap?.call(note),
      child: AnimatedScale(
        scale: isActive ? 1.22 : 0.95,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.elevation2,
            border: Border.all(
              color: isActive ? AppColors.nebulaCyan : AppColors.glassBorderBright,
              width: isActive ? 2.5 : 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.nebulaCyan.withValues(alpha: 0.65),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.nebulaViolet.withValues(alpha: 0.45),
                      blurRadius: 24,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background visual gradient / preset
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: note.contentType == NoteContentType.richMedia
                          ? [
                              const Color(0xFF1E1E24),
                              const Color(0xFF2A2A34),
                            ]
                          : [
                              const Color(0xFF141418),
                              const Color(0xFF1E1E24),
                            ],
                    ),
                  ),
                ),

                // Icon / Type indicator
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        note.contentType == NoteContentType.richMedia
                            ? Icons.image_rounded
                            : note.checklist.isNotEmpty
                                ? Icons.checklist_rounded
                                : Icons.notes_rounded,
                        color: isActive ? Colors.white : AppColors.secondaryText,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                            color: isActive ? Colors.white : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Active scanning glow badge
                if (isActive)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.nebulaCyan,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.nebulaCyan,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
