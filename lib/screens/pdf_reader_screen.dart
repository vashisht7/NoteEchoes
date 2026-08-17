import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';

import '../services/attachment_path_service.dart';
import '../widgets/math_markdown_viewer.dart';

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
  static const _visionChannel = MethodChannel('notechoes/pdf_vision');
  final PdfViewerController _controller = PdfViewerController();
  int _currentPage = 1;
  int? _pageCount;
  String? _resolvedPath;
  bool _isResolving = true;
  bool _showCleanText = false;
  bool _isLoadingText = false;
  String? _cleanMarkdown;
  List<String> _cleanPages = const [];
  String? _textError;

  @override
  void initState() {
    super.initState();
    _pageCount = widget.knownPageCount;
    _resolvePath();
  }

  Future<void> _resolvePath() async {
    final path = await AttachmentPathService.resolve(widget.filePath);
    if (!mounted) return;
    setState(() {
      _resolvedPath = path;
      _isResolving = false;
    });
  }

  Future<void> _goToPage(int page) async {
    final pageCount = _pageCount;
    if (pageCount == null || page < 1 || page > pageCount) return;
    HapticFeedback.selectionClick();
    await _controller.goToPage(pageNumber: page);
  }

  Future<void> _toggleCleanText() async {
    if (_showCleanText) {
      setState(() => _showCleanText = false);
      return;
    }
    setState(() => _showCleanText = true);
    if (_cleanMarkdown == null && !_isLoadingText) {
      await _loadCleanText();
    }
  }

  Future<void> _loadCleanText() async {
    final path = _resolvedPath;
    if (path == null) return;
    setState(() {
      _isLoadingText = true;
      _textError = null;
    });

    PdfDocument? document;
    try {
      final pages = <String>[];
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final recognized = await _visionChannel.invokeMethod<List<dynamic>>(
          'extractPages',
          {'path': path},
        );
        if (recognized != null) {
          pages.addAll(recognized.map((page) => page.toString().trim()));
        }
      } else {
        document = await PdfDocument.openFile(path);
        for (final page in document.pages) {
          pages.add((await page.loadText()).fullText.trim());
        }
      }

      final markdown = _pagesToMarkdown(pages);
      if (markdown.trim().isEmpty) {
        throw const FormatException('No readable text was found in this PDF.');
      }
      if (!mounted) return;
      setState(() {
        _cleanPages = pages;
        _cleanMarkdown = markdown;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _textError =
            'Clean text is unavailable for this PDF. You can still read every page in the original view.';
      });
    } finally {
      await document?.dispose();
      if (mounted) setState(() => _isLoadingText = false);
    }
  }

  String _pagesToMarkdown(List<String> pages) {
    final output = StringBuffer('# ${widget.title}\n\n');
    for (var index = 0; index < pages.length; index++) {
      final text = pages[index].trim();
      if (text.isEmpty) continue;
      if (pages.length > 1) output.writeln('## Page ${index + 1}\n');
      output.writeln(_cleanPageText(text));
      output.writeln();
    }
    return output.toString().trim();
  }

  String _cleanPageText(String text) {
    final output = StringBuffer();
    for (final rawLine in text.split(RegExp(r'[\r\n]+'))) {
      var line = rawLine.replaceAll(RegExp(r'[ \t]+'), ' ').trim();
      if (line.isEmpty) continue;
      if (line.startsWith('• ')) line = '- ${line.substring(2)}';
      output.writeln(line);
    }
    return output.toString().trim();
  }

  void _copyCleanText() {
    final text = _cleanMarkdown;
    if (text == null || text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('PDF text copied'),
      ),
    );
  }

  void _copyPageSection(int pageIndex, String text) {
    final section = '## Page ${pageIndex + 1}\n\n${_cleanPageText(text)}';
    Clipboard.setData(ClipboardData(text: section));
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Page ${pageIndex + 1} copied as Markdown'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          if (_resolvedPath != null)
            IconButton(
              key: const ValueKey('pdf_clean_text_button'),
              tooltip: _showCleanText ? 'Show original PDF' : 'Read clean text',
              icon: Icon(
                _showCleanText
                    ? Icons.picture_as_pdf_outlined
                    : Icons.article_outlined,
                size: 22,
              ),
              onPressed: _toggleCleanText,
            ),
          if (_showCleanText && _cleanMarkdown != null)
            IconButton(
              key: const ValueKey('copy_pdf_text_button'),
              tooltip: 'Copy PDF text',
              icon: const Icon(Icons.copy_all_rounded, size: 21),
              onPressed: _copyCleanText,
            ),
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
        child: _isResolving
            ? _buildResolving()
            : _resolvedPath == null
            ? _buildMissingFile()
            : _showCleanText
            ? _buildCleanText()
            : _buildViewer(_resolvedPath!),
      ),
    );
  }

  Widget _buildViewer(String path) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return ColoredBox(
        color: const Color(0xFF080808),
        child: UiKitView(
          key: ValueKey('native_pdf_view_$path'),
          viewType: 'noteechoes/pdf_view',
          creationParams: {'path': path},
          creationParamsCodec: const StandardMessageCodec(),
          gestureRecognizers: const {},
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Semantics(
            label: 'PDF document. Pinch to zoom and swipe vertically to read.',
            child: PdfViewer.file(
              path,
              key: ValueKey('pdf_viewer_$path'),
              controller: _controller,
              params: PdfViewerParams(
                backgroundColor: const Color(0xFF080808),
                margin: 10,
                enableTextSelection: true,
                maxImageBytesCachedOnMemory: 96 * 1024 * 1024,
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

  Widget _buildResolving() {
    return Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildCleanText() {
    if (_isLoadingText) {
      return _ReaderMessage(
        icon: Icons.auto_awesome_rounded,
        title: 'Making a clean reading view',
        message: 'Extracting text and preserving page order…',
        progressColor: Theme.of(context).colorScheme.primary,
      );
    }
    if (_textError != null) {
      return _ReaderMessage(
        icon: Icons.text_snippet_outlined,
        title: 'Clean text unavailable',
        message: _textError!,
      );
    }

    final readablePages = _cleanPages.asMap().entries.where(
      (entry) => entry.value.trim().isNotEmpty,
    );
    return Container(
      color: const Color(0xFF080808),
      child: ListView(
        key: const ValueKey('pdf_clean_text_view'),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 48),
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          for (final entry in readablePages) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Page ${entry.key + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy page ${entry.key + 1} as Markdown',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  onPressed: () => _copyPageSection(entry.key, entry.value),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SelectionArea(
              child: MathMarkdownViewer(
                content: _cleanPageText(entry.value),
                baseStyle: const TextStyle(
                  color: Color(0xFFE8E8ED),
                  fontSize: 16,
                  height: 1.58,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Colors.white12, height: 1),
            ),
          ],
        ],
      ),
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
  final Color? progressColor;

  const _ReaderMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progressColor != null)
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: progressColor,
                ),
              )
            else
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
