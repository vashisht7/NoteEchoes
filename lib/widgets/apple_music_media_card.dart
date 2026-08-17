import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import 'pdf_cover_thumbnail.dart';

class AppleMusicMediaCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onPinTap;
  final VoidCallback? onDeleteTap;

  const AppleMusicMediaCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.onPinTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPdf = note.mediaAssets.any((m) => m.type == MediaAssetType.pdf);
    final is16x9 = note.mediaAssets.any((m) => m.previewTileAspect == "16:9");

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF16161C),
          border: Border.all(
            color: note.isPinned
                ? AppColors.dropletRed.withValues(alpha: 0.6)
                : const Color(0xFF282834),
            width: note.isPinned ? 1.5 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
            if (note.isPinned)
              BoxShadow(
                color: AppColors.dropletRed.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // 1. Full-Bleed Artwork / Gradient Canvas
              AspectRatio(
                aspectRatio: is16x9 ? 16 / 9 : 1.05,
                child: _buildArtworkBackground(note),
              ),

              // 2. Dark Gradient Vignette at the bottom
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Color(0x990A0A0C),
                        Color(0xFA0A0A0C),
                      ],
                      stops: [0.0, 0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Top Badges: PDF Badge (Upper Right) & Pin Indicator (Upper Left)
              Positioned(
                top: 12,
                left: 12,
                right: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (note.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dropletRed.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.dropletRedSoft,
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.push_pin_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "PINNED",
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox.shrink(),

                    // PDF High-Res Preview Badge in Upper Right
                    if (hasPdf)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.badgePdf.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.picture_as_pdf_rounded,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "PDF • ${note.mediaAssets.firstWhere((m) => m.type == MediaAssetType.pdf).pageCount ?? 1}P",
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // 4. Overlaid 2-line preview description over frosted glass blur
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.elevation2.withValues(alpha: 0.85),
                        border: const Border(
                          top: BorderSide(color: AppColors.glassBorder),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Timestamp Header
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: AppColors.secondaryText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                formatNoteTimestamp(note.createdAt),
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Note Title
                          Text(
                            note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryText,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // 2-line preview description
                          Text(
                            note.summarySnippet,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Tags and metadata
                          Row(
                            children: [
                              ...note.tags
                                  .take(2)
                                  .map(
                                    (tag) => Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.badgeTag,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        "#$tag",
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primaryText,
                                        ),
                                      ),
                                    ),
                                  ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: AppColors.secondaryText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArtworkBackground(NoteModel note) {
    final pdfAssets = note.mediaAssets
        .where((asset) => asset.type == MediaAssetType.pdf)
        .toList();
    if (pdfAssets.isNotEmpty) {
      return ColoredBox(
        color: const Color(0xFF080808),
        child: PdfCoverThumbnail(
          filePath: pdfAssets.first.url,
          borderRadius: BorderRadius.zero,
        ),
      );
    }

    final firstPreset = note.mediaAssets.isNotEmpty
        ? note.mediaAssets.first.visualPreset
        : null;

    if (firstPreset == "nebula_art") {
      return Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.4, -0.3),
            radius: 1.2,
            colors: [
              AppColors.nebulaCyan,
              AppColors.nebulaViolet,
              Color(0xFF1E0836),
              AppColors.elevation1,
            ],
            stops: [0.0, 0.4, 0.75, 1.0],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Gemini AI Multi-Modal",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2838), Color(0xFF131722), Color(0xFF0A0A0C)],
        ),
      ),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentBlue.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.architecture_rounded,
                  size: 34,
                  color: AppColors.accentBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "SYSTEM TOKENS & SPECS",
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
