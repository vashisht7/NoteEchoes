/// Conservative, model-independent extraction for explicitly enumerated speech.
///
/// This is a safety net for natural transcripts such as "first task ...
/// second ...". It never invents steps and only returns text present in the
/// transcript.
class SpokenChecklistParser {
  static final RegExp _ordinal = RegExp(
    r'\b(?:(?:first|1st)(?:\s+(?:task|item))?|(?:number|item|task)\s+one)\b|'
    r'\b(?:(?:second|2nd)(?:\s+(?:task|item))?|(?:number|item|task)\s+two)\b|'
    r'\b(?:(?:third|3rd)(?:\s+(?:task|item))?|(?:number|item|task)\s+three)\b|'
    r'\b(?:(?:fourth|4th)(?:\s+(?:task|item))?|(?:number|item|task)\s+four)\b|'
    r'\b(?:(?:fifth|5th)(?:\s+(?:task|item))?|(?:number|item|task)\s+five)\b|'
    r'\b(?:(?:sixth|6th)(?:\s+(?:task|item))?|(?:number|item|task)\s+six)\b|'
    r'\b(?:(?:seventh|7th)(?:\s+(?:task|item))?|(?:number|item|task)\s+seven)\b|'
    r'\b(?:(?:eighth|8th)(?:\s+(?:task|item))?|(?:number|item|task)\s+eight)\b|'
    r'\b(?:(?:ninth|9th)(?:\s+(?:task|item))?|(?:number|item|task)\s+nine)\b|'
    r'\b(?:(?:tenth|10th)(?:\s+(?:task|item))?|(?:number|item|task)\s+ten)\b|'
    r'\b(?:finally|lastly|last\s+(?:task|item))\b|'
    r'(?:మొదట|మొదటి\s*పని|రెండవది|రెండో\s*పని|తర్వాత|ఆపై|చివరగా|ఆఖరుగా)|'
    r'(?:पहला\s*काम|पहली\s*चीज़|दूसरा\s*काम|दूसरी\s*चीज़|तीसरा\s*काम|पहले|फिर|उसके\s+बाद|अंत\s+में|आखिर\s+में)',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _explicitList = RegExp(
    r'\b(?:check\s*list|checklist|task\s*list|tasks?|todo|to-do|to\s+do\s+list|'
    r'things\s+to\s+do|action\s+items?|shopping\s+list|grocery\s+list|groceries|'
    r'errands?|chores?|these\s+items|the\s+following)\b|'
    r'(?:చెక్\s*లిస్ట్|చెక్‌లిస్ట్|టాస్క్\s*లిస్ట్|పనుల\s*జాబితా|పనులు|పని|కొనాల్సినవి|ఈ\s+items)|'
    r'(?:चेकलिस्ट|टास्क\s*लिस्ट|कामों\s+की\s+सूची|काम\s+हैं|काम|करने\s+वाली\s+चीज़ें|ये\s+चीज़ें|ये\s+items)|'
    r'\b(?:panula\s+jabita|cheyalsina\s+panulu|kaam\s+ki\s+list|kaam|karne\s+wali\s+cheezein)\b',
    caseSensitive: false,
    unicode: true,
  );

  static final RegExp _explicitSingleTask = RegExp(
    r'^(?:please\s+)?(?:add|create|make|save|record)\s+(?:a\s+)?task(?:\s+to)?\s*[:,-]?\s*(.+)$|'
    r'^(?:task|todo|to-do|పని|काम)\s*[:,-]?\s+(.+)$|'
    r'^(?:task|పని)\s+(?:తయారు\s+చేయి|చేయి|గా\s+(?:add|save)\s+చేయి)\s*[:,-]?\s*(.+)$|'
    r'^(?:task|काम)\s+(?:बनाओ|बना\s+दो|में\s+(?:add|save)\s+करो)\s*[:,-]?\s*(.+)$|'
    r'^(?:task)\s+(?:tayaru\s+cheyyi|add\s+cheyyi|banao|add\s+karo)\s*[:,-]?\s*(.+)$',
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

    final singleTask = _explicitSingleTask.firstMatch(text);
    if (singleTask != null) {
      for (var group = 1; group <= singleTask.groupCount; group++) {
        final value = singleTask.group(group);
        if (value == null) continue;
        final item = _clean(value);
        if (item.isNotEmpty) return [item];
      }
    }

    final listCue = _explicitList.firstMatch(text);
    if (listCue == null) return const [];
    var tail = text.substring(listCue.end).trim();
    tail = tail.replaceFirst(
      RegExp(
        r'^[\s,:;.!?\-–—]*(?:(?:with\s+(?:these\s+items|the\s+following)|'
        r'that\s+(?:has|contains|includes)|these\s+items|containing|including|'
        r'with|of|for|has|have|is|are)\s*)?',
        caseSensitive: false,
      ),
      '',
    );
    if (tail.isEmpty) return const [];

    final parts = tail
        .replaceAll(
          RegExp(r'\s+(?:number|item|task)\s+(?=\w)', caseSensitive: false),
          ', ',
        )
        .split(
          RegExp(
            r'\s*(?:\r?\n|[,;]|[.!?]+(?=\s|$))\s*|'
            r'\s+(?:and|also|then|next|plus|మరియు|అలాగే|తర్వాత|ఆపై|और|फिर|उसके\s+बाद)\s+',
            caseSensitive: false,
            unicode: true,
          ),
        )
        .map(_clean)
        .where((item) => item.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts : const [];
  }

  static String suggestedTitle(String transcript) {
    final value = transcript.toLowerCase();
    if (RegExp(
      r'\b(?:grocery|groceries|shopping)\b|కొనాల్సినవి',
    ).hasMatch(value)) {
      return 'Grocery List';
    }
    if (RegExp(r'\b(?:errands?)\b').hasMatch(value)) return 'Errands';
    if (RegExp(r'[\u0900-\u097f]').hasMatch(transcript)) return 'कार्य सूची';
    if (RegExp(r'[\u0c00-\u0c7f]').hasMatch(transcript)) return 'చెక్‌లిస్ట్';
    if (RegExp(
      r'\b(?:tasks?|todo|to-do|things\s+to\s+do|action\s+items?)\b',
    ).hasMatch(value)) {
      return 'Tasks';
    }
    return 'Checklist';
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
