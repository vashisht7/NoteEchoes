/// Conservative, model-independent extraction for explicitly enumerated speech.
///
/// This is a safety net for natural transcripts such as "first task ...
/// second ...". It never invents steps and only returns text present in the
/// transcript.
class SpokenChecklistParser {
  static final RegExp _ordinal = RegExp(
    r'\b(?:first|1st)(?:\s+(?:task|item))?\b|'
    r'\b(?:second|2nd)(?:\s+(?:task|item))?\b|'
    r'\b(?:third|3rd)(?:\s+(?:task|item))?\b|'
    r'\b(?:fourth|4th)(?:\s+(?:task|item))?\b|'
    r'\b(?:fifth|5th)(?:\s+(?:task|item))?\b|'
    r'(?:మొదట|మొదటి\s*పని|రెండవది|రెండో\s*పని|తర్వాత|ఆపై)|'
    r'(?:पहला\s*काम|पहली\s*चीज़|दूसरा\s*काम|दूसरी\s*चीज़|तीसरा\s*काम|पहले|फिर|उसके\s+बाद)',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _explicitList = RegExp(
    r'\b(?:check\s*list|checklist|task\s*list|tasks|todo|to-do|these\s+items)\b|'
    r'(?:చెక్\s*లిస్ట్|చెక్‌లిస్ట్|పనులు|ఈ\s+items)|'
    r'(?:चेकलिस्ट|काम\s+हैं|ये\s+चीज़ें|ये\s+items)',
    caseSensitive: false,
    unicode: true,
  );

  static List<String> extract(String transcript) {
    final text = transcript.trim();
    if (text.isEmpty) return const [];

    final markers = _ordinal.allMatches(text).toList();
    if (markers.length >= 2) {
      final items = <String>[];
      for (var index = 0; index < markers.length; index++) {
        final start = markers[index].end;
        final end = index + 1 < markers.length
            ? markers[index + 1].start
            : text.length;
        final item = _clean(text.substring(start, end));
        if (item.isNotEmpty) items.add(item);
      }
      return items.length >= 2 ? items : const [];
    }

    final listCue = _explicitList.firstMatch(text);
    if (listCue == null) return const [];
    final colon = text.indexOf(':', listCue.end);
    if (colon < 0) return const [];
    final tail = text.substring(colon + 1);
    final parts = tail
        .split(
          RegExp(
            r'\s*[,;]\s*|\s+(?:and|also|then|మరియు|అలాగే|తర్వాత|और|फिर)\s+',
            caseSensitive: false,
          ),
        )
        .map(_clean)
        .where((item) => item.isNotEmpty)
        .toList();
    return parts.length >= 2 ? parts : const [];
  }

  static String _clean(String value) {
    var result = value.trim();
    result = result.replaceFirst(
      RegExp(
        r'^[\s,:;.!?\-–—]*(?:(?:that\s+is|is|are)\s*[,;:]?\s*)?',
        caseSensitive: false,
      ),
      '',
    );
    result = result.replaceFirst(
      RegExp(
        r'^(?:i\s+(?:want|need|have)\s+to|we\s+(?:want|need|have)\s+to|please)\s+',
        caseSensitive: false,
      ),
      '',
    );
    result = result.replaceFirst(
      RegExp(r'^(?:and|also|then|మరియు|అలాగే|और|फिर)\s+', caseSensitive: false),
      '',
    );
    return result.replaceAll(RegExp(r'[\s,;.!?।]+$'), '').trim();
  }
}
