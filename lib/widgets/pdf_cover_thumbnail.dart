import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../services/attachment_path_service.dart';

class PdfCoverThumbnail extends StatefulWidget {
  final String filePath;
  final BorderRadius borderRadius;

  const PdfCoverThumbnail({
    super.key,
    required this.filePath,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  State<PdfCoverThumbnail> createState() => _PdfCoverThumbnailState();
}

class _PdfCoverThumbnailState extends State<PdfCoverThumbnail> {
  ui.Image? _image;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadCover();
  }

  @override
  void didUpdateWidget(covariant PdfCoverThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filePath != widget.filePath) _loadCover();
  }

  Future<void> _loadCover() async {
    _image?.dispose();
    _image = null;
    _failed = false;
    final path = await AttachmentPathService.resolve(widget.filePath);
    if (path == null) {
      if (mounted) setState(() => _failed = true);
      return;
    }

    PdfDocument? document;
    PdfImage? rendered;
    try {
      document = await PdfDocument.openFile(path);
      if (document.pages.isEmpty) throw const FormatException('Empty PDF');
      final page = document.pages.first;
      const targetWidth = 360.0;
      rendered = await page.render(
        fullWidth: targetWidth,
        fullHeight: targetWidth * page.height / page.width,
        backgroundColor: Colors.white,
      );
      final image = await rendered?.createImage();
      if (!mounted) {
        image?.dispose();
        return;
      }
      setState(() {
        _image = image;
        _failed = image == null;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    } finally {
      rendered?.dispose();
      await document?.dispose();
    }
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: ColoredBox(
        color: const Color(0xFF111113),
        child: _image != null
            ? RawImage(
                image: _image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium,
              )
            : Center(
                child: _failed
                    ? const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Colors.white38,
                        size: 28,
                      )
                    : const Icon(
                        Icons.description_outlined,
                        color: Colors.white24,
                        size: 27,
                      ),
              ),
      ),
    );
  }
}
