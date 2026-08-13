import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';
import '../widgets/apple_drawing_canvas.dart';
import '../widgets/apple_notes_toolbar.dart';
import '../widgets/apple_text_format_sheet.dart';
import '../widgets/math_markdown_viewer.dart';

class NoteDetailSheet extends StatefulWidget {
  final NoteModel? existingNote;

  const NoteDetailSheet({super.key, this.existingNote});

  @override
  State<NoteDetailSheet> createState() => _NoteDetailSheetState();
}

class _NoteDetailSheetState extends State<NoteDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _summaryController;
  late TextEditingController _contentController;
  late TextEditingController _tagInputController;
  late List<String> _tags;
  late bool _isPinned;
  late NoteContentType _contentType;
  late List<MediaAsset> _mediaAssets;
  late List<CheckListItem> _checklist;
  bool _isPreviewMode = false;

  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _summaryController =
        TextEditingController(text: note?.summarySnippet ?? '');
    _contentController = TextEditingController(text: note?.textContent ?? '');
    _tagInputController = TextEditingController();
    _tags = List.from(note?.tags ?? []);
    _isPinned = note?.isPinned ?? false;
    _contentType = note?.contentType ?? NoteContentType.textOnly;
    _mediaAssets = List.from(note?.mediaAssets ?? []);
    _checklist = List.from(note?.checklist ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim().isEmpty
        ? "Untitled Note"
        : _titleController.text.trim();
    final content = _contentController.text;
    final summary = _summaryController.text.trim().isEmpty
        ? (content.isNotEmpty
            ? content.split("\n").first
            : "No description provided")
        : _summaryController.text.trim();

    // Auto-detect tags if none were manually added
    if (_tags.isEmpty) {
      _tags = NoteService().autoDetectTags("$title $summary $content");
    }

    final note = NoteModel(
      noteId: widget.existingNote?.noteId ??
          "echo_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      contentType:
          _mediaAssets.isNotEmpty ? NoteContentType.richMedia : _contentType,
      mediaAssets: _mediaAssets,
      summarySnippet: summary,
      textContent: content,
      createdAt: widget.existingNote?.createdAt ?? DateTime.now(),
      tags: _tags,
      isPinned: _isPinned,
      checklist: _checklist,
    );

    if (widget.existingNote != null) {
      NoteService().updateNote(note);
    } else {
      NoteService().addNote(note);
    }

    Navigator.of(context).pop();
  }

  // ── Apple Notes Formatting Engine ──────────────────────────────────────

  void _applyTextFormatting(TextFormattingType format) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;
    final selectedText =
        start < end ? text.substring(start, end) : "text";

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
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + cursorOffset),
    );
  }

  void _insertTable() {
    const tableTemplate =
        "\n\n| Item | Description | Status |\n| :--- | :--- | :--- |\n| Task 1 | Requirements | Done |\n| Task 2 | Design specs | In Progress |\n\n";
    final text = _contentController.text;
    final selection = _contentController.selection;
    final index = selection.start >= 0 ? selection.start : text.length;

    final newText = text.replaceRange(index, index, tableTemplate);
    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: index + tableTemplate.length),
    );
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
  }

  void _addChecklistItem() {
    setState(() {
      _checklist.add(CheckListItem(
        id: "c_${DateTime.now().millisecondsSinceEpoch}",
        text: "New task item",
        isCompleted: false,
      ));
    });
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
                leading: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppColors.badgePdf),
                title: const Text("Scan / Attach Document (PDF)"),
                subtitle: const Text("Import PDF with OCR tables & math",
                    style: TextStyle(fontSize: 12, color: Colors.white54)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndAttachFile(['pdf']);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded,
                    color: AppColors.nebulaCyan),
                title: const Text("Photo Library"),
                subtitle: const Text("Insert photos or artwork",
                    style: TextStyle(fontSize: 12, color: Colors.white54)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndAttachFile(['png', 'jpg', 'jpeg']);
                },
              ),
              ListTile(
                leading: const Icon(Icons.draw_rounded,
                    color: AppColors.dropletRed),
                title: const Text("Markup & Sketch (Apple Notes Style)"),
                subtitle: const Text("Draw with pen, pencil and marker",
                    style: TextStyle(fontSize: 12, color: Colors.white54)),
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

        setState(() {
          _mediaAssets.add(MediaAsset(
            type: isPdf ? MediaAssetType.pdf : MediaAssetType.image,
            url: file.path ?? "assets/${file.name}",
            pageCount: isPdf ? 4 : null,
            caption: file.name,
            visualPreset: isPdf ? "pdf_doc" : "nebula_art",
          ));
          _contentType = NoteContentType.richMedia;

          if (_titleController.text.isEmpty) {
            _titleController.text =
                file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
          }
        });
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.elevation1,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: AppColors.glassBorderBright, width: 1.2),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.primaryText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryText.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Text(
                      widget.existingNote != null ? "Edit Note" : "New Note",
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
                actions: [
                  // Markdown & LaTeX Preview Toggle
                  IconButton(
                    icon: Icon(
                      _isPreviewMode
                          ? Icons.edit_note_rounded
                          : Icons.visibility_rounded,
                      color: _isPreviewMode
                          ? AppColors.nebulaCyan
                          : AppColors.secondaryText,
                    ),
                    tooltip:
                        _isPreviewMode ? "Edit Mode" : "Math & Markdown Preview",
                    onPressed: () =>
                        setState(() => _isPreviewMode = !_isPreviewMode),
                  ),

                  // Pin toggle
                  IconButton(
                    icon: Icon(
                      _isPinned
                          ? Icons.push_pin_rounded
                          : Icons.push_pin_outlined,
                      color: _isPinned
                          ? AppColors.dropletRed
                          : AppColors.secondaryText,
                    ),
                    onPressed: () => setState(() => _isPinned = !_isPinned),
                  ),

                  // Delete Button
                  if (widget.existingNote != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.redAccent),
                      onPressed: () {
                        NoteService().deleteNote(widget.existingNote!.noteId);
                        Navigator.of(context).pop();
                      },
                    ),

                  // Save Button
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.dropletRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                      onPressed: _saveNote,
                      child: const Text(
                        "Save",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  // Title Field
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Note Title...",
                      hintStyle: TextStyle(color: AppColors.secondaryText),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Attached Media Assets Preview (Drawings, PDFs, Images)
                  if (_mediaAssets.isNotEmpty) ...[
                    Text(
                      "ATTACHMENTS & DRAWINGS (${_mediaAssets.length})",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _mediaAssets.length,
                        itemBuilder: (context, idx) {
                          final asset = _mediaAssets[idx];
                          final isPdf = asset.type == MediaAssetType.pdf;

                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.elevation2,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.glassBorderBright,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isPdf
                                          ? Icons.picture_as_pdf_rounded
                                          : (asset.visualPreset == "sketch_markup"
                                              ? Icons.draw_rounded
                                              : Icons.image_rounded),
                                      color: isPdf
                                          ? AppColors.badgePdf
                                          : (asset.visualPreset == "sketch_markup"
                                              ? AppColors.dropletRed
                                              : AppColors.nebulaCyan),
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      asset.caption ?? "Attachment",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: GestureDetector(
                                    onTap: () => setState(
                                        () => _mediaAssets.removeAt(idx)),
                                    child: const Icon(
                                      Icons.cancel_rounded,
                                      size: 18,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Checklists Section
                  if (_checklist.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "CHECKLIST ITEMS",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.add,
                              size: 14, color: AppColors.accentGreen),
                          label: const Text(
                            "Add Item",
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.accentGreen,
                            ),
                          ),
                          onPressed: _addChecklistItem,
                        ),
                      ],
                    ),
                    ..._checklist.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Checkbox(
                              value: item.isCompleted,
                              activeColor: AppColors.accentGreen,
                              onChanged: (val) => setState(
                                  () => item.isCompleted = val ?? false),
                            ),
                            Expanded(
                              child: TextFormField(
                                initialValue: item.text,
                                onChanged: (v) => item.text = v,
                                style: TextStyle(
                                  color: item.isCompleted
                                      ? AppColors.secondaryText
                                      : AppColors.primaryText,
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 16, color: AppColors.secondaryText),
                              onPressed: () => setState(
                                  () => _checklist.removeAt(index)),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],

                  // 2-Line Summary Preview Field
                  TextField(
                    controller: _summaryController,
                    maxLines: 2,
                    style: GoogleFonts.inter(
                        fontSize: 13, color: AppColors.primaryText),
                    decoration: const InputDecoration(
                      labelText:
                          "2-Line Preview Description (Album / Grid Card)",
                      labelStyle: TextStyle(
                          color: AppColors.secondaryText, fontSize: 12),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Main Markdown & LaTeX Math Content (Edit vs. Preview)
                  if (_isPreviewMode) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.elevation2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.glassBorderBright),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome,
                                  size: 14, color: AppColors.nebulaCyan),
                              const SizedBox(width: 6),
                              Text(
                                "MATH & MARKDOWN PREVIEW",
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.nebulaCyan,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                              height: 16, color: AppColors.glassBorder),
                          MathMarkdownViewer(content: _contentController.text),
                        ],
                      ),
                    ),
                  ] else ...[
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      maxLines: 14,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.primaryText,
                      ),
                      decoration: const InputDecoration(
                        hintText:
                            r"Write your note in markdown, paste LaTeX math ($$ ... $$), or drop tables...",
                        hintStyle: TextStyle(color: AppColors.secondaryText),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Tags Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._tags.map((tag) => Chip(
                            label: Text("#$tag",
                                style: const TextStyle(fontSize: 12)),
                            backgroundColor: AppColors.elevation2,
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () =>
                                setState(() => _tags.remove(tag)),
                          )),
                      SizedBox(
                        width: 120,
                        child: TextField(
                          controller: _tagInputController,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: "+ Add tag",
                            hintStyle:
                                TextStyle(color: AppColors.secondaryText),
                            isDense: true,
                            border: InputBorder.none,
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
                  const SizedBox(height: 20),
                ],
              ),

              // Docked Apple Notes Style Bottom Toolbar
              bottomNavigationBar: AppleNotesToolbar(
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
            ),
          ),
        ),
      ),
    );
  }
}
