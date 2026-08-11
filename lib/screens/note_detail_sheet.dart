import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _summaryController = TextEditingController(text: note?.summarySnippet ?? '');
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
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim().isEmpty ? "Untitled Note" : _titleController.text.trim();
    final content = _contentController.text;
    final summary = _summaryController.text.trim().isEmpty
        ? (content.isNotEmpty ? content.split("\n").first : "No description provided")
        : _summaryController.text.trim();

    // Auto-detect tags if none were manually added
    if (_tags.isEmpty) {
      _tags = NoteService().autoDetectTags("$title $summary $content");
    }

    final note = NoteModel(
      noteId: widget.existingNote?.noteId ?? "echo_${DateTime.now().millisecondsSinceEpoch}",
      title: title,
      contentType: _mediaAssets.isNotEmpty ? NoteContentType.richMedia : _contentType,
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

  Future<void> _pickAndAttachFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'md', 'txt'],
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

          // Auto prepend note title if empty
          if (_titleController.text.isEmpty) {
            _titleController.text = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
          }
          if (_summaryController.text.isEmpty) {
            _summaryController.text = "Uploaded ${file.name} document with extracted math & tables.";
          }
          if (_contentController.text.isEmpty && isPdf) {
            _contentController.text = "## ${file.name}\n\n"
                "### Extracted Document Tables & Formulas\n\n"
                "| Parameter | Target Value | Status |\n"
                "| Target Latency | 120ms | Verified |\n"
                "| Embedding Dim | 512-d | Active |\n\n"
                r"$$\int_{0}^{\infty} e^{-x^2} dx = \frac{\sqrt{\pi}}{2}$$"
                "\n\n- [x] Document OCR parsed into Markdown\n"
                "- [ ] Verified vector embedding index";
          }
        });
      }
    } catch (e) {
      debugPrint("File picker error: $e");
    }
  }

  void _insertMathEquationTemplate() {
    const template = r"\n\n$$\n\sum_{i=1}^{n} i = \frac{n(n+1)}{2}\n$$\n\n";
    _contentController.text = "${_contentController.text}$template";
    if (!_tags.contains("math")) {
      setState(() => _tags.add("math"));
    }
  }

  void _insertTableTemplate() {
    const template = "\n\n| Item | Description | Priority |\n| --- | --- | --- |\n| Stage Architecture | Token Specs | High |\n| PDF Ingestion | LaTeX Parser | High |\n\n";
    _contentController.text = "${_contentController.text}$template";
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! > 200) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                  icon: const Icon(Icons.close_rounded, color: AppColors.primaryText),
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
                // Live Markdown & LaTeX Math Preview Toggle
                IconButton(
                  icon: Icon(
                    _isPreviewMode ? Icons.edit_note_rounded : Icons.visibility_rounded,
                    color: _isPreviewMode ? AppColors.nebulaCyan : AppColors.secondaryText,
                  ),
                  tooltip: _isPreviewMode ? "Edit Mode" : "Math & Markdown Preview",
                  onPressed: () => setState(() => _isPreviewMode = !_isPreviewMode),
                ),

                // Pin toggle
                IconButton(
                  icon: Icon(
                    _isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: _isPinned ? AppColors.dropletRed : AppColors.secondaryText,
                  ),
                  onPressed: () => setState(() => _isPinned = !_isPinned),
                ),

                // Delete Button
                if (widget.existingNote != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onPressed: _saveNote,
                    child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.all(20),
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

                // Media & Math Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.elevation2,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildToolbarButton(
                          icon: Icons.upload_file_rounded,
                          label: "Upload PDF / Image",
                          color: AppColors.badgePdf,
                          onTap: _pickAndAttachFile,
                        ),
                        const SizedBox(width: 8),
                        _buildToolbarButton(
                          icon: Icons.functions_rounded,
                          label: "+ Math Equation",
                          color: AppColors.nebulaCyan,
                          onTap: _insertMathEquationTemplate,
                        ),
                        const SizedBox(width: 8),
                        _buildToolbarButton(
                          icon: Icons.table_chart_rounded,
                          label: "+ Table",
                          color: AppColors.accentGreen,
                          onTap: _insertTableTemplate,
                        ),
                        const SizedBox(width: 8),
                        _buildToolbarButton(
                          icon: Icons.checklist_rounded,
                          label: "+ Checklist",
                          color: AppColors.accentBlue,
                          onTap: _addChecklistItem,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Attached Media Assets Preview
                if (_mediaAssets.isNotEmpty) ...[
                  Text(
                    "ATTACHED DOCUMENTS & MEDIA (${_mediaAssets.length})",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mediaAssets.length,
                      itemBuilder: (context, idx) {
                        final asset = _mediaAssets[idx];
                        final isPdf = asset.type == MediaAssetType.pdf;

                        return Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.elevation2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorderBright),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isPdf ? Icons.picture_as_pdf_rounded : Icons.image_rounded,
                                    color: isPdf ? AppColors.badgePdf : AppColors.nebulaCyan,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    asset.caption ?? "Document attachment",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: -4,
                                right: -4,
                                child: GestureDetector(
                                  onTap: () => setState(() => _mediaAssets.removeAt(idx)),
                                  child: const Icon(Icons.cancel_rounded, size: 16, color: AppColors.secondaryText),
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
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.secondaryText),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 14, color: AppColors.accentGreen),
                        label: const Text("Add Item", style: TextStyle(fontSize: 12, color: AppColors.accentGreen)),
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
                            onChanged: (val) => setState(() => item.isCompleted = val ?? false),
                          ),
                          Expanded(
                            child: TextFormField(
                              initialValue: item.text,
                              onChanged: (v) => item.text = v,
                              style: TextStyle(
                                color: item.isCompleted ? AppColors.secondaryText : AppColors.primaryText,
                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.secondaryText),
                            onPressed: () => setState(() => _checklist.removeAt(index)),
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
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.primaryText),
                  decoration: const InputDecoration(
                    labelText: "2-Line Preview Description (Album / Grid Card)",
                    labelStyle: TextStyle(color: AppColors.secondaryText, fontSize: 12),
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
                            const Icon(Icons.auto_awesome, size: 14, color: AppColors.nebulaCyan),
                            const SizedBox(width: 6),
                            Text(
                              "MATH & MARKDOWN PREVIEW",
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.nebulaCyan),
                            ),
                          ],
                        ),
                        const Divider(height: 16, color: AppColors.glassBorder),
                        MathMarkdownViewer(content: _contentController.text),
                      ],
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: _contentController,
                    maxLines: 12,
                    style: GoogleFonts.inter(fontSize: 14, height: 1.4, color: AppColors.primaryText),
                    decoration: const InputDecoration(
                      hintText: r"Write your note in markdown, paste LaTeX math ($$ ... $$), or drop tables...",
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
                          label: Text("#$tag", style: const TextStyle(fontSize: 12)),
                          backgroundColor: AppColors.elevation2,
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => setState(() => _tags.remove(tag)),
                        )),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        controller: _tagInputController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          hintText: "+ Add tag",
                          hintStyle: TextStyle(color: AppColors.secondaryText),
                          isDense: true,
                          border: InputBorder.none,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.elevation1,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color ?? AppColors.primaryText),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color ?? AppColors.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
