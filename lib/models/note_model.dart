enum NoteContentType { richMedia, textOnly }

enum MediaAssetType { image, pdf, audio }

enum NoteBlockType { text, table }

/// Durable editor content. Keeping tables as structured cells means they can
/// be reopened and indexed for search instead of disappearing after "Done".
class NoteBlockData {
  final NoteBlockType type;
  final String text;
  final List<List<String>> tableCells;

  const NoteBlockData.text(this.text)
    : type = NoteBlockType.text,
      tableCells = const [];

  const NoteBlockData.table(this.tableCells)
    : type = NoteBlockType.table,
      text = '';

  Map<String, dynamic> toJson() => {
    'type': type.name,
    if (type == NoteBlockType.text) 'text': text,
    if (type == NoteBlockType.table) 'cells': tableCells,
  };

  factory NoteBlockData.fromJson(Map<String, dynamic> json) {
    if (json['type'] == NoteBlockType.table.name) {
      final rows = (json['cells'] as List<dynamic>? ?? const [])
          .map(
            (row) =>
                (row as List<dynamic>).map((cell) => cell.toString()).toList(),
          )
          .toList();
      return NoteBlockData.table(rows);
    }
    return NoteBlockData.text(json['text'] as String? ?? '');
  }

  /// Plain-text representation used by summaries, sharing and retrieval.
  String get searchableText {
    if (type == NoteBlockType.text) return text;
    return tableCells.map((row) => row.join(' | ')).join('\n');
  }
}

class MediaAsset {
  final MediaAssetType type;
  final String url;
  final String? previewTileAspect; // "1:1", "16:9"
  final int? pageCount;
  final String? caption;
  final String?
  visualPreset; // e.g. "gemini_spec", "system_arch", "apple_album"
  final String? documentId;

  const MediaAsset({
    required this.type,
    required this.url,
    this.previewTileAspect = "1:1",
    this.pageCount,
    this.caption,
    this.visualPreset,
    this.documentId,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'url': url,
    'preview_tile_aspect': previewTileAspect,
    if (pageCount != null) 'page_count': pageCount,
    if (caption != null) 'caption': caption,
    if (visualPreset != null) 'visual_preset': visualPreset,
    if (documentId != null) 'document_id': documentId,
  };

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    return MediaAsset(
      type: json['type'] == 'pdf'
          ? MediaAssetType.pdf
          : json['type'] == 'audio'
          ? MediaAssetType.audio
          : MediaAssetType.image,
      url: json['url'] as String? ?? '',
      previewTileAspect: json['preview_tile_aspect'] as String? ?? '1:1',
      pageCount: json['page_count'] as int?,
      caption: json['caption'] as String?,
      visualPreset: json['visual_preset'] as String?,
      documentId: json['document_id'] as String?,
    );
  }
}

class CheckListItem {
  final String id;
  String text;
  bool isCompleted;

  CheckListItem({
    required this.id,
    required this.text,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'is_completed': isCompleted,
  };

  factory CheckListItem.fromJson(Map<String, dynamic> json) {
    return CheckListItem(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }
}

class NoteModel {
  final String noteId;
  final String title;
  final NoteContentType contentType;
  final List<MediaAsset> mediaAssets;
  final String summarySnippet;
  final String textContent;
  final DateTime createdAt;
  final List<String> tags;
  final bool isPinned;
  final List<CheckListItem> checklist;
  final List<NoteBlockData> contentBlocks;
  final int? accentColor;

  const NoteModel({
    required this.noteId,
    required this.title,
    required this.contentType,
    this.mediaAssets = const [],
    required this.summarySnippet,
    required this.textContent,
    required this.createdAt,
    this.tags = const [],
    this.isPinned = false,
    this.checklist = const [],
    this.contentBlocks = const [],
    this.accentColor,
  });

  NoteModel copyWith({
    String? noteId,
    String? title,
    NoteContentType? contentType,
    List<MediaAsset>? mediaAssets,
    String? summarySnippet,
    String? textContent,
    DateTime? createdAt,
    List<String>? tags,
    bool? isPinned,
    List<CheckListItem>? checklist,
    List<NoteBlockData>? contentBlocks,
    int? accentColor,
  }) {
    return NoteModel(
      noteId: noteId ?? this.noteId,
      title: title ?? this.title,
      contentType: contentType ?? this.contentType,
      mediaAssets: mediaAssets ?? this.mediaAssets,
      summarySnippet: summarySnippet ?? this.summarySnippet,
      textContent: textContent ?? this.textContent,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      checklist: checklist ?? this.checklist,
      contentBlocks: contentBlocks ?? this.contentBlocks,
      accentColor: accentColor ?? this.accentColor,
    );
  }

  Map<String, dynamic> toJson() => {
    'note_id': noteId,
    'title': title,
    'content_type': contentType == NoteContentType.richMedia
        ? 'rich_media'
        : 'text_only',
    'media_assets': mediaAssets.map((e) => e.toJson()).toList(),
    'summary_snippet': summarySnippet,
    'text_content': textContent,
    'created_at': createdAt.toIso8601String(),
    'tags': tags,
    'is_pinned': isPinned,
    'checklist': checklist.map((e) => e.toJson()).toList(),
    'content_blocks': contentBlocks.map((e) => e.toJson()).toList(),
    if (accentColor != null) 'accent_color': accentColor,
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      noteId:
          json['note_id'] as String? ??
          'echo_${DateTime.now().millisecondsSinceEpoch}',
      title: json['title'] as String? ?? 'Untitled Note',
      contentType: json['content_type'] == 'rich_media'
          ? NoteContentType.richMedia
          : NoteContentType.textOnly,
      mediaAssets:
          (json['media_assets'] as List<dynamic>?)
              ?.map((e) => MediaAsset.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summarySnippet: json['summary_snippet'] as String? ?? '',
      textContent: json['text_content'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
      isPinned: json['is_pinned'] as bool? ?? false,
      checklist:
          (json['checklist'] as List<dynamic>?)
              ?.map((e) => CheckListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      contentBlocks:
          (json['content_blocks'] as List<dynamic>?)
              ?.map(
                (e) =>
                    NoteBlockData.fromJson(Map<String, dynamic>.from(e as Map)),
              )
              .toList() ??
          [],
      accentColor: json['accent_color'] as int?,
    );
  }
}
