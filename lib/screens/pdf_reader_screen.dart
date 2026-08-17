import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfReaderScreen extends StatefulWidget {
  final String filePath;
  final String title;
  final int? knownPageCount;
  final VoidCallback? onAskPdf;

  const PdfReaderScreen({
    super.key,
    required this.filePath,
    required this.title,
    this.knownPageCount,
    this.onAskPdf,
  });

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final PdfViewerController _controller = PdfViewerController();
  int _currentPage = 1;
  int? _pageCount;

  @override
  void initState() {
    super.initState();
    _pageCount = widget.knownPageCount;
  }

  Future<void> _goToPage(int page) async {
    final pageCount = _pageCount;
    if (pageCount == null || page < 1 || page > pageCount) return;
    HapticFeedback.selectionClick();
    await _controller.goToPage(pageNumber: page);
  }

  @override
  Widget build(BuildContext context) {
    final fileExists = File(widget.filePath).existsSync();

    return Scaffold(
      key: const ValueKey('pdf_reader_screen'),
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          key: const ValueKey('pdf_reader_back_button'),
          tooltip: 'Back to note',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 19),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
        ),
        titleSpacing: 0,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (widget.onAskPdf != null)
            IconButton(
              key: const ValueKey('ask_pdf_button'),
              tooltip: 'Ask this PDF',
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 21),
              onPressed: widget.onAskPdf,
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: fileExists ? _buildViewer() : _buildMissingFile(),
      ),
    );
  }

  Widget _buildViewer() {
    return Stack(
      children: [
        Positioned.fill(
          child: Semantics(
            label: 'PDF document. Pinch to zoom and swipe vertically to read.',
            child: PdfViewer.file(
              widget.filePath,
              key: ValueKey('pdf_viewer_${widget.filePath}'),
              controller: _controller,
              params: PdfViewerParams(
                backgroundColor: Colors.black,
                margin: 12,
                enableTextSelection: true,
                useAlternativeFitScaleAsMinScale: false,
                maxImageBytesCachedOnMemory: 64 * 1024 * 1024,
                pageDropShadow: const BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
                onViewerReady: (document, controller) {
                  if (!mounted) return;
                  setState(() => _pageCount = document.pages.length);
                },
                onPageChanged: (page) {
                  if (!mounted || page == null || page == _currentPage) return;
                  setState(() => _currentPage = page);
                },
                loadingBannerBuilder: (context, downloaded, total) => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 2.5,
                    value: total == null ? null : downloaded / total,
                  ),
                ),
                errorBannerBuilder: (context, error, stackTrace, documentRef) =>
                    _ReaderMessage(
                      icon: Icons.error_outline_rounded,
                      title: 'This PDF could not be opened',
                      message:
                          'The file may be damaged, encrypted, or no longer available.',
                    ),
              ),
            ),
          ),
        ),
        if ((_pageCount ?? 0) > 1)
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
            child: Center(
              child: Semantics(
                label: 'Page $_currentPage of $_pageCount',
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xE61C1C1E),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Previous page',
                        visualDensity: VisualDensity.compact,
                        onPressed: _currentPage > 1
                            ? () => _goToPage(_currentPage - 1)
                            : null,
                        icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      ),
                      Text(
                        '$_currentPage / $_pageCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next page',
                        visualDensity: VisualDensity.compact,
                        onPressed: _currentPage < (_pageCount ?? 1)
                            ? () => _goToPage(_currentPage + 1)
                            : null,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMissingFile() {
    return const _ReaderMessage(
      icon: Icons.insert_drive_file_outlined,
      title: 'PDF not found',
      message: 'This attachment is no longer stored on this device.',
    );
  }
}

class _ReaderMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _ReaderMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white38, size: 42),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
