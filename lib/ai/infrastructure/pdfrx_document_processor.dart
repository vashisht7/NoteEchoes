import 'dart:math' as math;

import 'package:pdfrx/pdfrx.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

import '../domain/document_chunk.dart';
import '../providers/document_processor.dart';

/// Extracts real, selectable PDF text without adding another model to the app.
/// Fragment coordinates are used to preserve rows and wide gaps, which keeps
/// tables, formulas and labelled diagrams much more useful for retrieval.
class PdfrxDocumentProcessor implements DocumentProcessor {
  static const _targetChars = 1800;
  static const _overlapChars = 220;
  static const _visionChannel = MethodChannel('notechoes/pdf_vision');

  @override
  Future<List<DocumentChunk>> process(
    String filePath,
    ProcessedDocument document, {
    void Function(DocumentProgress progress)? onProgress,
  }) async {
    final pdf = await PdfDocument.openFile(filePath);
    final chunks = <DocumentChunk>[];

    try {
      final totalPages = pdf.pages.length;
      var sourceOrder = 0;
      List<dynamic>? visionPages;

      for (final page in pdf.pages) {
        onProgress?.call(
          DocumentProgress(
            documentId: document.id,
            state: DocumentProcessingState.extractingText,
            currentPage: page.pageNumber,
            totalPages: totalPages,
            message: 'Reading page ${page.pageNumber} of $totalPages',
          ),
        );

        final pageText = await page.loadText();
        var text = _layoutAwareText(pageText).trim();
        if (text.length < 20) {
          try {
            visionPages ??= await _visionChannel.invokeMethod<List<dynamic>>(
              'extractPages',
              {'path': filePath},
            );
            if (page.pageNumber <= (visionPages?.length ?? 0)) {
              text = visionPages![page.pageNumber - 1].toString().trim();
            }
          } on PlatformException {
            // Non-iOS platforms still retain selectable PDF text extraction.
          }
        }
        if (text.isEmpty) continue;

        for (final part in _splitWithOverlap(text)) {
          chunks.add(
            DocumentChunk(
              id: const Uuid().v4(),
              documentId: document.id,
              pageStart: page.pageNumber,
              pageEnd: page.pageNumber,
              originalText: part,
              tokenEstimate: (part.runes.length / 3.5).ceil(),
              sourceOrder: sourceOrder++,
            ),
          );
        }
      }

      if (chunks.isEmpty) {
        throw const FormatException(
          'This PDF has no selectable text. Scanned-page OCR is required.',
        );
      }

      onProgress?.call(
        DocumentProgress(
          documentId: document.id,
          state: DocumentProcessingState.completed,
          currentPage: totalPages,
          totalPages: totalPages,
          message: 'Indexed ${chunks.length} passages',
        ),
      );
      return chunks;
    } finally {
      await pdf.dispose();
    }
  }

  String _layoutAwareText(PdfPageText pageText) {
    final fragments = pageText.fragments
        .where((fragment) => fragment.text.trim().isNotEmpty)
        .toList();
    if (fragments.length < 2) return pageText.fullText;

    fragments.sort((a, b) {
      final vertical = b.bounds.top.compareTo(a.bounds.top);
      if ((a.bounds.top - b.bounds.top).abs() >
          math.max(a.bounds.height, b.bounds.height) * .55) {
        return vertical;
      }
      return a.bounds.left.compareTo(b.bounds.left);
    });

    final lines = <List<PdfPageTextFragment>>[];
    for (final fragment in fragments) {
      if (lines.isEmpty) {
        lines.add([fragment]);
        continue;
      }
      final anchor = lines.last.first;
      final tolerance =
          math.max(anchor.bounds.height, fragment.bounds.height) * .55;
      if ((anchor.bounds.top - fragment.bounds.top).abs() <= tolerance) {
        lines.last.add(fragment);
      } else {
        lines.add([fragment]);
      }
    }

    return lines
        .map((line) {
          line.sort((a, b) => a.bounds.left.compareTo(b.bounds.left));
          final output = StringBuffer();
          PdfPageTextFragment? previous;
          for (final fragment in line) {
            if (previous != null) {
              final gap = fragment.bounds.left - previous.bounds.right;
              final averageCharWidth =
                  previous.bounds.width /
                  math.max(1, previous.text.runes.length);
              output.write(gap > averageCharWidth * 3.5 ? ' | ' : ' ');
            }
            output.write(fragment.text.trim());
            previous = fragment;
          }
          return output.toString();
        })
        .join('\n');
  }

  Iterable<String> _splitWithOverlap(String text) sync* {
    if (text.length <= _targetChars) {
      yield text;
      return;
    }

    var start = 0;
    while (start < text.length) {
      var end = math.min(start + _targetChars, text.length);
      if (end < text.length) {
        final paragraphBreak = text.lastIndexOf('\n\n', end);
        final lineBreak = text.lastIndexOf('\n', end);
        final sentenceBreak = text.lastIndexOf(RegExp(r'[.!?。！？]\s'), end);
        final preferred = [paragraphBreak, lineBreak, sentenceBreak]
            .where((value) => value > start + (_targetChars ~/ 2))
            .fold<int>(-1, math.max);
        if (preferred > start) end = preferred + 1;
      }

      final chunk = text.substring(start, end).trim();
      if (chunk.isNotEmpty) yield chunk;
      if (end >= text.length) break;
      start = math.max(start + 1, end - _overlapChars);
    }
  }
}
