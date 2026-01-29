class LyricLine {
  final String text;
  final Duration offset;
  final Duration duration;

  LyricLine({required this.text, required this.offset, required this.duration});

  bool get isHeader => text.startsWith('[');
}
