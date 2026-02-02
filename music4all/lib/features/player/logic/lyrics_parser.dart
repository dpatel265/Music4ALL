class WordTiming {
  final String text;
  final Duration startTime;
  WordTiming({required this.text, required this.startTime});
}

class RichSyncLine {
  final List<WordTiming> words;
  final Duration lineStartTime;
  RichSyncLine({required this.words, required this.lineStartTime});
}

class LyricsParser {
  // Regex to capture <MM:SS.mm> tags inside the line
  static final RegExp _timestampRegex = RegExp(r'<(\d{2}):(\d{2})\.(\d{2,3})>');

  static RichSyncLine? parseRichSyncLine(String line) {
    if (line.trim().isEmpty) return null;
    final matches = _timestampRegex.allMatches(line).toList();
    if (matches.isEmpty) return null;

    List<WordTiming> words = [];
    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      final nextStart = (i + 1 < matches.length)
          ? matches[i + 1].start
          : line.length;

      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      // Handle 2 or 3 digit milliseconds
      String msString = match.group(3)!;
      if (msString.length == 2) msString += '0';
      final ms = int.parse(msString);

      final duration = Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: ms,
      );

      String text = line.substring(match.end, nextStart).trim();
      if (text.isNotEmpty) {
        words.add(WordTiming(text: text, startTime: duration));
      }
    }

    return words.isNotEmpty
        ? RichSyncLine(words: words, lineStartTime: words.first.startTime)
        : null;
  }
}
