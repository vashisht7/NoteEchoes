import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../ai/infrastructure/knowledge_service.dart';
import '../ai/infrastructure/model_availability_service.dart';
import '../ai/infrastructure/semantic_knowledge_service.dart';
import '../ai/domain/semantic_models.dart';
import '../ai/presentation/model_feature_gate.dart';
import '../ai/presentation/document_chat_page.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/apple_drawing_canvas.dart';
import '../widgets/apple_notes_toolbar.dart';
import '../widgets/apple_text_format_sheet.dart';
import '../widgets/inline_note_table.dart';
import '../widgets/math_markdown_viewer.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel? existingNote;

  const NoteDetailScreen({super.key, this.existingNote});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _TextBlock {
  final TextEditingController controller;
  final FocusNode focusNode;
  _TextBlock({String text = ''})
    : controller = TextEditingController(text: text),
      focusNode = FocusNode();
  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class _TableBlock {
  final Key key = UniqueKey();
  List<List<String>> cells;

  _TableBlock({List<List<String>>? cells})
    : cells = cells ?? List.generate(2, (_) => List.filled(2, ''));
}

class _ChecklistBlock {
  final Key key = UniqueKey();
  final CheckListItem item;

  _ChecklistBlock(this.item);
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _tagInputController;
  late List<String> _tags;
  late bool _isPinned;
  late NoteContentType _contentType;
  late List<MediaAsset> _mediaAssets;
  late List<CheckListItem> _checklist;
  late DateTime _createdAt;
  bool _isPreviewMode = false;
  bool _isSaving = false;
  bool _allowPop = false;
  double _horizontalDragDistance = 0;
  late final String _noteId;

  // Ordered editor blocks: text, tables and checklist rows all retain the
  // position where the user inserted them.
  late List<dynamic> _blocks;

  // The "active" text block that receives cursor focus (used for toolbar insertions)
  _TextBlock? get _activeTextBlock {
    for (final block in _blocks) {
      if (block is _TextBlock && block.focusNode.hasFocus) return block;
    }
    // Default to last text block
    for (final block in _blocks.reversed) {
      if (block is _TextBlock) return block;
    }
    return null;
  }

  // Legacy getter so old code that reads _contentController still compiles
  TextEditingController get _contentController =>
      (_blocks.firstWhere((b) => b is _TextBlock, orElse: () => _TextBlock())
              as _TextBlock)
          .controller;

  final FocusNode _titleFocusNode = FocusNode();
  // _contentFocusNode points to the first text block for backward compat
  FocusNode get _contentFocusNode =>
      (_blocks.firstWhere((b) => b is _TextBlock, orElse: () => _TextBlock())
              as _TextBlock)
          .focusNode;

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _tagInputController = TextEditingController();
    _tags = List.from(note?.tags ?? []);
    _isPinned = note?.isPinned ?? false;
    _contentType = note?.contentType ?? NoteContentType.textOnly;
    _mediaAssets = List.from(note?.mediaAssets ?? []);
    _checklist = List.from(note?.checklist ?? []);
    _createdAt = note?.createdAt ?? DateTime.now();
    _noteId = note?.noteId ?? "echo_${DateTime.now().microsecondsSinceEpoch}";
    final savedBlocks = note?.contentBlocks ?? const <NoteBlockData>[];
    final checklistById = <String, CheckListItem>{
      for (final item in _checklist) item.id: item,
    };
    final referencedChecklistIds = <String>{};
    _blocks = savedBlocks.isEmpty
        ? [_TextBlock(text: note?.textContent ?? '')]
        : savedBlocks.map<dynamic>((block) {
            if (block.type == NoteBlockType.table) {
              return _TableBlock(
                cells: block.tableCells
                    .map((row) => List<String>.from(row))
                    .toList(),
              );
            }
            if (block.type == NoteBlockType.checklist) {
              final item =
                  checklistById[block.checklistId] ??
                  CheckListItem(
                    id: block.checklistId.isEmpty
                        ? 'c_${DateTime.now().microsecondsSinceEpoch}'
                        : block.checklistId,
                    text: block.checklistText,
                    isCompleted: block.checklistCompleted,
                  );
              if (!checklistById.containsKey(item.id)) {
                _checklist.add(item);
                checklistById[item.id] = item;
              }
              referencedChecklistIds.add(item.id);
              return _ChecklistBlock(item);
            }
            return _TextBlock(text: block.text);
          }).toList();
    // Older notes stored checklist rows separately. Keep them, but place them
    // after the existing content instead of forcing them above the note.
    for (final item in _checklist) {
      if (!referencedChecklistIds.contains(item.id)) {
        _blocks.add(_ChecklistBlock(item));
      }
    }
    if (_blocks.whereType<_TextBlock>().isEmpty) {
      _blocks.add(_TextBlock());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (final block in _blocks) {
      if (block is _TextBlock) block.dispose();
    }
    _tagInputController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  List<NoteBlockData> _serializedBlocks() => _blocks.map((block) {
    if (block is _TableBlock) return NoteBlockData.table(block.cells);
    if (block is _ChecklistBlock) {
      return NoteBlockData.checklist(
        checklistId: block.item.id,
        checklistText: block.item.text,
        checklistCompleted: block.item.isCompleted,
      );
    }
    return NoteBlockData.text((block as _TextBlock).controller.text);
  }).toList();

  String _plainTextContent(List<NoteBlockData> blocks) => blocks
      .map((block) => block.searchableText.trim())
      .where((text) => text.isNotEmpty)
      .join('\n\n')
      .trim();

  Future<bool> _saveNote({
    bool pop = true,
    bool showConfirmation = false,
  }) async {
    if (_isSaving) return false;
    if (mounted) setState(() => _isSaving = true);

    final title = _titleController.text.trim().isEmpty
        ? "Untitled Note"
        : _titleController.text.trim();
    final contentBlocks = _serializedBlocks();
    final content = _plainTextContent(contentBlocks);
    final summary = content.isNotEmpty
        ? content.split("\n").first
        : (widget.existingNote?.summarySnippet ?? "No description provided");

    // Auto-detect tags if none were manually added
    if (_tags.isEmpty) {
      _tags = NoteService().autoDetectTags("$title $summary $content");
    }

    final note = NoteModel(
      noteId: _noteId,
      title: title,
      contentType: _mediaAssets.isNotEmpty
          ? NoteContentType.richMedia
          : _contentType,
      mediaAssets: _mediaAssets,
      summarySnippet: summary,
      textContent: content,
      createdAt: _createdAt,
      tags: _tags,
      isPinned: _isPinned,
      checklist: _checklist,
      contentBlocks: contentBlocks,
    );

    try {
      if (widget.existingNote != null) {
        await NoteService().updateNote(note);
      } else {
        await NoteService().addNote(note);
      }

      if (!mounted) return true;
      setState(() {
        _isSaving = false;
        if (pop) _allowPop = true;
      });
      if (pop) {
        Navigator.of(context).pop(note);
      } else if (showConfirmation) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Note saved'),
            duration: Duration(seconds: 1),
          ),
        );
      }
      return true;
    } catch (error) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text('Could not save note: $error'),
          ),
        );
      }
      return false;
    }
  }

  // ── Apple Notes Formatting Engine ──────────────────────────────────────

  void _applyTextFormatting(TextFormattingType format) {
    final block = _activeTextBlock;
    final ctrl = block?.controller ?? _contentController;
    final focusNode = block?.focusNode ?? _contentFocusNode;
    final text = ctrl.text;
    final selection = ctrl.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final selectedText = start < end ? text.substring(start, end) : "text";

    String replacement = "";
    int cursorOffset = 0;

    switch (format) {
      case TextFormattingType.title:
        replacement = "\n# $selectedText\n";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.heading:
        replacement = "\n## $selectedText\n";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.subheading:
        replacement = "\n### $selectedText\n";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.body:
        replacement = selectedText;
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.monospaced:
        replacement = "```\n$selectedText\n```";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.bold:
        replacement = "**$selectedText**";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.italic:
        replacement = "*$selectedText*";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.strikethrough:
        replacement = "~~$selectedText~~";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.underline:
        replacement = "<u>$selectedText</u>";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.bulletList:
        replacement = "\n• $selectedText";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.numberedList:
        replacement = "\n1. $selectedText";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.blockquote:
        replacement = "\n> $selectedText\n";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.indent:
        replacement = "  $selectedText";
        cursorOffset = replacement.length;
        break;
      case TextFormattingType.outdent:
        replacement = selectedText.startsWith("  ")
            ? selectedText.substring(2)
            : selectedText;
        cursorOffset = replacement.length;
        break;
    }

    final newText = text.replaceRange(start, end, replacement);
    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + cursorOffset),
    );
    focusNode.requestFocus();
  }

  void _insertTable() {
    setState(() {
      final active = _activeTextBlock;
      if (active == null) {
        // No focused block — just append a table at the end
        _blocks.add(_TableBlock());
        _blocks.add(_TextBlock());
        return;
      }

      final blockIdx = _blocks.indexOf(active);
      final text = active.controller.text;
      final cursor = active.controller.selection.start;
      final splitAt = cursor >= 0 ? cursor : text.length;

      // Text before cursor
      final before = text.substring(0, splitAt);
      // Text after cursor
      final after = text.substring(splitAt);

      // Replace current block with: [before text] [table] [after text]
      final beforeBlock = _TextBlock(text: before);
      final tableBlock = _TableBlock();
      final afterBlock = _TextBlock(text: after);

      _blocks.replaceRange(blockIdx, blockIdx + 1, [
        beforeBlock,
        tableBlock,
        afterBlock,
      ]);
      active.dispose(); // clean up replaced block

      // Focus the after-block so user can keep typing below the table
      WidgetsBinding.instance.addPostFrameCallback((_) {
        afterBlock.focusNode.requestFocus();
      });
    });
  }

  void _insertMathEquation() {
    const mathTemplate =
        r"\n\n$$\n\int_{0}^{\infty} e^{-x^2} dx = \frac{\sqrt{\pi}}{2}\n$$\n\n";
    final text = _contentController.text;
    final selection = _contentController.selection;
    final index = selection.start >= 0 ? selection.start : text.length;

    final newText = text.replaceRange(index, index, mathTemplate);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: index + mathTemplate.length),
    );

    if (!_tags.contains("math")) {
      setState(() => _tags.add("math"));
    }
    _contentFocusNode.requestFocus();
  }

  void _addChecklistItem() {
    setState(() {
      final item = CheckListItem(
        id: "c_${DateTime.now().microsecondsSinceEpoch}",
        text: "",
        isCompleted: false,
      );
      _checklist.add(item);
      final active = _activeTextBlock;
      if (active == null) {
        _blocks.add(_ChecklistBlock(item));
        _blocks.add(_TextBlock());
        return;
      }

      final blockIndex = _blocks.indexOf(active);
      final text = active.controller.text;
      final selection = active.controller.selection;
      final splitAt = selection.start >= 0 ? selection.start : text.length;
      final beforeBlock = _TextBlock(text: text.substring(0, splitAt));
      final checklistBlock = _ChecklistBlock(item);
      final afterBlock = _TextBlock(text: text.substring(splitAt));
      _blocks.replaceRange(blockIndex, blockIndex + 1, [
        beforeBlock,
        checklistBlock,
        afterBlock,
      ]);
      active.dispose();
    });
  }

  Widget _buildChecklistBlock(_ChecklistBlock block) {
    final item = block.item;
    return Padding(
      key: block.key,
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            tooltip: item.isCompleted ? 'Mark incomplete' : 'Mark complete',
            icon: Icon(
              item.isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: item.isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white38,
              size: 20,
            ),
            onPressed: () =>
                setState(() => item.isCompleted = !item.isCompleted),
          ),
          Expanded(
            child: TextFormField(
              key: ValueKey('checklist_${item.id}'),
              initialValue: item.text,
              autofocus: item.text.isEmpty,
              onChanged: (value) => item.text = value,
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: item.isCompleted ? Colors.white38 : Colors.white,
                decoration: item.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
              ),
              decoration: const InputDecoration(
                hintText: 'Checklist item',
                hintStyle: TextStyle(color: Colors.white24),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Remove checklist item',
            icon: const Icon(
              Icons.close_rounded,
              size: 16,
              color: Colors.white24,
            ),
            onPressed: () => setState(() {
              _blocks.remove(block);
              _checklist.removeWhere((entry) => entry.id == item.id);
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _openDrawingCanvas() async {
    final asset = await AppleDrawingCanvasDialog.show(context);
    if (asset != null) {
      setState(() {
        _mediaAssets.add(asset);
        _contentType = NoteContentType.richMedia;
      });
    }
  }

  Future<void> _showAttachmentPicker() async {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: AppColors.badgePdf,
                ),
                title: const Text("Scan / Attach Document (PDF)"),
                subtitle: const Text(
                  "Import PDF with OCR tables & math",
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndAttachFile(['pdf']);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: const Text("Photo Library"),
                subtitle: const Text(
                  "Insert photos or artwork",
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndAttachFile(['png', 'jpg', 'jpeg']);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.draw_rounded,
                  color: Color(0xFFFF9F0A),
                ),
                title: const Text("Markup & Sketch (Apple Notes Style)"),
                subtitle: const Text(
                  "Draw with pen, pencil and marker",
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _openDrawingCanvas();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndAttachFile(List<String> allowedExtensions) async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final isPdf = file.extension?.toLowerCase() == 'pdf';
        final sourcePath = file.path;
        if (sourcePath == null) {
          throw StateError('The selected file has no path.');
        }
        final storedPath = await _copyAttachment(sourcePath, file.name);

        String? documentId;
        int? pageCount;
        if (isPdf) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Reading and indexing PDF…'),
              ),
            );
          }
          final document = await KnowledgeService.instance.ingestPdf(
            storedPath,
          );
          documentId = document.id;
          pageCount = document.pageCount;
        }

        if (!mounted) return;

        setState(() {
          _mediaAssets.add(
            MediaAsset(
              type: isPdf ? MediaAssetType.pdf : MediaAssetType.image,
              url: storedPath,
              pageCount: pageCount,
              caption: file.name,
              visualPreset: isPdf ? "pdf_doc" : "nebula_art",
              documentId: documentId,
            ),
          );
          _contentType = NoteContentType.richMedia;

          if (_titleController.text.isEmpty) {
            _titleController.text = file.name.replaceAll(
              RegExp(r'\.[a-zA-Z0-9]+$'),
              '',
            );
          }
        });
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

  Future<String> _copyAttachment(String sourcePath, String fileName) async {
    final documents = await getApplicationDocumentsDirectory();
    final directory = Directory(p.join(documents.path, 'attachments'));
    await directory.create(recursive: true);
    final extension = p.extension(fileName);
    final storedName = '${DateTime.now().microsecondsSinceEpoch}$extension';
    final destination = p.join(directory.path, storedName);
    await File(sourcePath).copy(destination);
    return destination;
  }

  Future<void> _openDocumentChat(MediaAsset asset) async {
    final documentId = asset.documentId;
    if (documentId == null) return;
    final allowed = await requireQwenModel(
      context,
      featureName: 'grounded document chat',
      basicAlternative:
          'You can still read the PDF and search ordinary note text without downloading it.',
    );
    if (!allowed || !mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DocumentChatPage(
          title: asset.caption ?? 'PDF',
          sourceId: documentId,
          isDocument: true,
          onAsk: (question) =>
              KnowledgeService.instance.askDocument(question, documentId),
        ),
      ),
    );
  }

  void _shareNote() {
    final title = _titleController.text.trim().isEmpty
        ? "Untitled Note"
        : _titleController.text.trim();
    final content = _contentController.text;
    Clipboard.setData(ClipboardData(text: "$title\n\n$content"));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2C2C2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Text(
              "Note copied to clipboard",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showRelatedNotes() async {
    final note = widget.existingNote;
    if (note == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Save this note first to discover related notes.'),
        ),
      );
      return;
    }
    if (!ModelAvailabilityService.instance.embedding.isReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Download Semantic Topics in Settings → AI Models to find related notes.',
          ),
        ),
      );
      return;
    }
    await _saveNote(pop: false);
    final service = SemanticKnowledgeService.instance;
    final related = await service.relatedNotes(
      note.noteId,
      NoteService().allNotes,
    );
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.elevation1,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Related Notes',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Meaning-based suggestions created privately on this device.',
                style: GoogleFonts.inter(
                  color: AppColors.secondaryText,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 14),
              if (related.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text('No strong relationships found yet.'),
                  ),
                )
              else
                ...related
                    .take(8)
                    .map(
                      (item) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          item.status == SemanticSuggestionStatus.confirmed
                              ? Icons.link_rounded
                              : Icons.auto_awesome_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(
                          item.note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          '${(item.similarity * 100).round()}% match · ${item.explanation}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.secondaryText,
                            fontSize: 11.5,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  NoteDetailScreen(existingNote: item.note),
                            ),
                          );
                        },
                        trailing:
                            item.status == SemanticSuggestionStatus.confirmed
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Colors.greenAccent,
                                size: 18,
                              )
                            : PopupMenuButton<SemanticSuggestionStatus>(
                                tooltip: 'Review relationship',
                                onSelected: (status) async {
                                  await service.setRelationshipStatus(
                                    note.noteId,
                                    item.note.noteId,
                                    status,
                                  );
                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: SemanticSuggestionStatus.confirmed,
                                    child: Text('Confirm relationship'),
                                  ),
                                  PopupMenuItem(
                                    value: SemanticSuggestionStatus.dismissed,
                                    child: Text('Not related'),
                                  ),
                                ],
                              ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity?.abs() ?? 0;
    if (_horizontalDragDistance.abs() < 85 || velocity < 250 || _isSaving) {
      _horizontalDragDistance = 0;
      return;
    }
    _horizontalDragDistance = 0;
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();
    unawaited(_saveNote(pop: true));
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        unawaited(_saveNote(pop: true));
      },
      child: Semantics(
        label: 'Note editor. Swipe right to save and return to notes.',
        customSemanticsActions: {
          const CustomSemanticsAction(label: 'Save and return to notes'): () {
            unawaited(_saveNote(pop: true));
          },
        },
        child: GestureDetector(
          key: const ValueKey('note_editor_gesture_surface'),
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: (_) => _horizontalDragDistance = 0,
          onHorizontalDragUpdate: (details) {
            _horizontalDragDistance += details.primaryDelta ?? 0;
          },
          onHorizontalDragEnd: _handleHorizontalDragEnd,
          child: Scaffold(
            backgroundColor: const Color(0xFF000000),
            // Must be false — we manually handle keyboard avoidance in the body Column
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              backgroundColor: const Color(0xFF000000),
              elevation: 0,
              leadingWidth: 90,
              leading: GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  await _saveNote(pop: true);
                },
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Notes",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.hub_rounded,
                    color: Colors.white70,
                    size: 21,
                  ),
                  tooltip: 'Related Notes',
                  onPressed: _showRelatedNotes,
                ),
                // Preview Markdown & LaTeX Toggle
                IconButton(
                  icon: Icon(
                    _isPreviewMode
                        ? Icons.edit_note_rounded
                        : Icons.visibility_rounded,
                    color: _isPreviewMode
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white70,
                    size: 22,
                  ),
                  tooltip: _isPreviewMode
                      ? "Edit Mode"
                      : "Math & Markdown Preview",
                  onPressed: () =>
                      setState(() => _isPreviewMode = !_isPreviewMode),
                ),

                // Share button
                IconButton(
                  icon: const Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white70,
                    size: 21,
                  ),
                  tooltip: "Share Note",
                  onPressed: _shareNote,
                ),

                // Pin toggle
                IconButton(
                  icon: Icon(
                    _isPinned
                        ? Icons.push_pin_rounded
                        : Icons.push_pin_outlined,
                    color: _isPinned
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white70,
                    size: 21,
                  ),
                  tooltip: _isPinned ? "Unpin" : "Pin",
                  onPressed: () => setState(() => _isPinned = !_isPinned),
                ),

                // Delete Note
                if (widget.existingNote != null)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 21,
                    ),
                    tooltip: "Delete Note",
                    onPressed: () async {
                      await NoteService().deleteNote(
                        widget.existingNote!.noteId,
                      );
                      if (!context.mounted) return;
                      setState(() => _allowPop = true);
                      Navigator.of(context).pop();
                    },
                  ),

                // Done Button
                Padding(
                  padding: const EdgeInsets.only(right: 12, left: 4),
                  child: TextButton(
                    onPressed: _isSaving
                        ? null
                        : () async {
                            FocusScope.of(context).unfocus();
                            await _saveNote(pop: false, showConfirmation: true);
                          },
                    child: Text(
                      _isSaving ? "Saving…" : "Done",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Padding(
              // This is the key: padding == keyboard height pushes
              // the entire Column up so the toolbar stays visible.
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      children: [
                        // Apple-style creation date header
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              formatNoteTimestamp(_createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: Colors.white38,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),

                        // Large Title Field
                        TextField(
                          key: const ValueKey('note_title_field'),
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          decoration: const InputDecoration(
                            hintText: "Title",
                            hintStyle: TextStyle(color: Colors.white24),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Attached Media (Drawings, PDFs, Images)
                        if (_mediaAssets.isNotEmpty) ...[
                          SizedBox(
                            height: 110,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _mediaAssets.length,
                              itemBuilder: (context, idx) {
                                final asset = _mediaAssets[idx];
                                final isPdf = asset.type == MediaAssetType.pdf;
                                final isSketch =
                                    asset.visualPreset == "sketch_markup";

                                return GestureDetector(
                                  onTap: isPdf && asset.documentId != null
                                      ? () => _openDocumentChat(asset)
                                      : null,
                                  child: Container(
                                    width: 150,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1C1C1E),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFF2C2C2E),
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              isPdf
                                                  ? Icons.picture_as_pdf_rounded
                                                  : (isSketch
                                                        ? Icons.draw_rounded
                                                        : Icons.image_rounded),
                                              color: isPdf
                                                  ? AppColors.badgePdf
                                                  : (isSketch
                                                        ? const Color(
                                                            0xFFFF9F0A,
                                                          )
                                                        : Theme.of(context)
                                                              .colorScheme
                                                              .primary),
                                              size: 28,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              asset.caption ?? "Attachment",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Positioned(
                                          top: -4,
                                          right: -4,
                                          child: GestureDetector(
                                            onTap: () => setState(
                                              () => _mediaAssets.removeAt(idx),
                                            ),
                                            child: const Icon(
                                              Icons.cancel_rounded,
                                              size: 18,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // ── Block Editor ────────────────────────────────────────────────
                        // Each block is either a text region or an inline table.
                        // This is what gives Apple Notes-style inline tables.
                        if (_isPreviewMode) ...[
                          // Preview mode: join all text blocks and render as markdown
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF141416),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF282830),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      size: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "MATH & MARKDOWN PREVIEW",
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  height: 16,
                                  color: Color(0xFF282830),
                                ),
                                MathMarkdownViewer(
                                  content: _blocks
                                      .whereType<_TextBlock>()
                                      .map((b) => b.controller.text)
                                      .join('\n\n'),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          // Edit mode: render each block sequentially
                          ..._blocks.map((block) {
                            if (block is _TextBlock) {
                              return TextField(
                                controller: block.controller,
                                focusNode: block.focusNode,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  height: 1.55,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: _blocks.length == 1
                                      ? "Start typing..."
                                      : null,
                                  hintStyle: const TextStyle(
                                    color: Colors.white24,
                                    fontSize: 16,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              );
                            } else if (block is _ChecklistBlock) {
                              return _buildChecklistBlock(block);
                            } else if (block is _TableBlock) {
                              return Padding(
                                key: block.key,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: InlineNoteTable(
                                  initialData: block.cells,
                                  onDataChanged: (cells) => block.cells = cells,
                                  onRemove: () {
                                    setState(() {
                                      _blocks.remove(block);
                                      if (_blocks
                                          .whereType<_TextBlock>()
                                          .isEmpty) {
                                        _blocks.add(_TextBlock());
                                      }
                                    });
                                  },
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                        ],

                        // Tags Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ..._tags.map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C1C1E),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF2C2C2E),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "#$tag",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () =>
                                          setState(() => _tags.remove(tag)),
                                      child: const Icon(
                                        Icons.close_rounded,
                                        size: 13,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: TextField(
                                controller: _tagInputController,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "+ Add tag",
                                  hintStyle: TextStyle(color: Colors.white38),
                                  isDense: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                ),
                                onSubmitted: (v) {
                                  if (v.trim().isNotEmpty &&
                                      !_tags.contains(v.trim())) {
                                    setState(() => _tags.add(v.trim()));
                                    _tagInputController.clear();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ], // end ListView children
                    ), // end ListView
                  ), // end Expanded
                  // ── Apple Notes Accessory Toolbar ──────────────────────────────────────
                  // This sits at the bottom of the Column. The Column is inside a Padding
                  // with EdgeInsets.only(bottom: viewInsets.bottom), which makes the
                  // entire Column content (including this toolbar) rise as the keyboard
                  // appears — so the toolbar always floats directly above the keyboard.
                  AppleNotesToolbar(
                    isKeyboardVisible: isKeyboardOpen,
                    onInsertTable: _insertTable,
                    onFormatText: () => AppleTextFormatSheet.show(
                      context,
                      onFormatSelected: _applyTextFormatting,
                    ),
                    onInsertChecklist: _addChecklistItem,
                    onAddAttachment: _showAttachmentPicker,
                    onOpenDrawing: _openDrawingCanvas,
                    onInsertMath: _insertMathEquation,
                    onHideKeyboard: () => FocusScope.of(context).unfocus(),
                  ),
                ], // end Column children
              ), // end Column
            ), // end body Padding
          ), // end Scaffold
        ), // end swipe gesture
      ), // end Semantics
    ); // end PopScope
  }
}
