import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import '../widgets/apple_drawing_canvas.dart';
import '../widgets/apple_notes_toolbar.dart';
import '../widgets/apple_text_format_sheet.dart';
import '../widgets/math_markdown_viewer.dart';

class NoteDetailScreen extends StatefulWidget {
  final NoteModel? existingNote;

  const NoteDetailScreen({super.key, this.existingNote});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagInputController;
  late List<String> _tags;
  late bool _isPinned;
  late NoteContentType _contentType;
  late List<MediaAsset> _mediaAssets;
  late List<CheckListItem> _checklist;
  late DateTime _createdAt;
  bool _isPreviewMode = false;

  final FocusNode _contentFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.textContent ?? '');
    _tagInputController = TextEditingController();
    _tags = List.from(note?.tags ?? []);
    _isPinned = note?.isPinned ?? false;
    _contentType = note?.contentType ?? NoteContentType.textOnly;
    _mediaAssets = List.from(note?.mediaAssets ?? []);
    _checklist = List.from(note?.checklist ?? []);
    _createdAt = note?.createdAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    _contentFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _saveNote({bool pop = true}) {
    final title = _titleController.text.trim().isEmpty
        ? "Untitled Note"
        : _titleController.text.trim();
    final content = _contentController.text;
    final summary = content.isNotEmpty
        ? content.split("\n").first
        : (widget.existingNote?.summarySnippet ?? "No description provided");

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
      createdAt: _createdAt,
      tags: _tags,
      isPinned: _isPinned,
      checklist: _checklist,
    );

    if (widget.existingNote != null) {
      NoteService().updateNote(note);
    } else {
      NoteService().addNote(note);
    }

    if (pop && mounted) {
      Navigator.of(context).pop();
    }
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
    _contentFocusNode.requestFocus();
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
    _contentFocusNode.requestFocus();
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
                    color: Color(0xFFFF9F0A)),
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
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFFFFD60A)),
            SizedBox(width: 8),
            Text(
              "Note copied to clipboard",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _saveNote(pop: false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF000000), // Pure OLED Apple Black
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: const Color(0xFF000000),
          elevation: 0,
          leadingWidth: 90,
          leading: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _saveNote(pop: true);
            },
            child: Row(
              children: [
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFFFD60A), // Apple Notes Yellow
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  "Notes",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFD60A),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Preview Markdown & LaTeX Toggle
            IconButton(
              icon: Icon(
                _isPreviewMode
                    ? Icons.edit_note_rounded
                    : Icons.visibility_rounded,
                color: _isPreviewMode
                    ? AppColors.nebulaCyan
                    : Colors.white70,
                size: 22,
              ),
              tooltip:
                  _isPreviewMode ? "Edit Mode" : "Math & Markdown Preview",
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
                    ? AppColors.dropletRed
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
                onPressed: () {
                  NoteService().deleteNote(widget.existingNote!.noteId);
                  Navigator.of(context).pop();
                },
              ),

            // Done Button
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 4),
              child: TextButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _saveNote(pop: false);
                },
                child: Text(
                  "Done",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFD60A), // Apple Yellow
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
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
                    final isSketch = asset.visualPreset == "sketch_markup";

                    return Container(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                        ? const Color(0xFFFF9F0A)
                                        : AppColors.nebulaCyan),
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
                                  () => _mediaAssets.removeAt(idx)),
                              child: const Icon(
                                Icons.cancel_rounded,
                                size: 18,
                                color: Colors.white38,
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
              ..._checklist.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          item.isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: item.isCompleted
                              ? const Color(0xFFFFD60A)
                              : Colors.white38,
                          size: 20,
                        ),
                        onPressed: () => setState(
                            () => item.isCompleted = !item.isCompleted),
                      ),
                      Expanded(
                        child: TextFormField(
                          initialValue: item.text,
                          onChanged: (v) => item.text = v,
                          style: TextStyle(
                            fontSize: 15,
                            color: item.isCompleted
                                ? Colors.white38
                                : Colors.white,
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
                        icon: const Icon(Icons.close_rounded,
                            size: 16, color: Colors.white24),
                        onPressed: () =>
                            setState(() => _checklist.removeAt(index)),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],

            // Main Editor / Markdown Preview
            if (_isPreviewMode) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141416),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF282830)),
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
                        height: 16, color: Color(0xFF282830)),
                    MathMarkdownViewer(content: _contentController.text),
                  ],
                ),
              ),
            ] else ...[
              TextField(
                controller: _contentController,
                focusNode: _contentFocusNode,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  height: 1.55,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: "Start typing...",
                  hintStyle: TextStyle(color: Colors.white24, fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Tags Chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._tags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2C2C2E)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "#$tag",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFFD60A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => setState(() => _tags.remove(tag)),
                            child: const Icon(Icons.close_rounded,
                                size: 13, color: Colors.white38),
                          ),
                        ],
                      ),
                    )),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _tagInputController,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: "+ Add tag",
                      hintStyle: TextStyle(color: Colors.white38),
                      isDense: true,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty && !_tags.contains(v.trim())) {
                        setState(() => _tags.add(v.trim()));
                        _tagInputController.clear();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),

        // Apple Notes Accessory Toolbar: Floats directly above the keyboard
        bottomNavigationBar: AppleNotesToolbar(
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
      ),
    );
  }
}
