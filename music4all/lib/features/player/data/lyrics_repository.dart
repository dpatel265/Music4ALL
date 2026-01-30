import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../player/domain/lyric_line.dart';
import '../logic/lyrics_parser.dart';

class LyricsRepository {
  final Dio _dio;
  final String _baseUrl = 'https://lrclib.net/api';

  LyricsRepository({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<LyricLine>> fetchLyrics(String title, String artist) async {
    try {
      debugPrint(
        'LyricsRepository: Fetching from LrcLib for "$title" by "$artist"',
      );

      final response = await _dio.get(
        '$_baseUrl/get',
        queryParameters: {'artist_name': artist, 'track_name': title},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['syncedLyrics'] != null) {
          return _parseSyncedLyrics(data['syncedLyrics']);
        } else if (data['plainLyrics'] != null) {
          // We prefer synced, but plain is better than nothing?
          // For now, let's just return empty if not synced,
          // because our UI expects timestamps for auto-scroll.
          debugPrint('LyricsRepository: Only plain lyrics found.');
        }
      }
      return [];
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        debugPrint('LyricsRepository: Lyrics not found (404).');
      } else {
        debugPrint('LyricsRepository: Error fetching lyrics: $e');
      }
      return [];
    }
  }

  List<LyricLine> _parseSyncedLyrics(String syncedLyrics) {
    final List<LyricLine> lines = [];

    for (final line in syncedLyrics.split('\n')) {
      final richLine = LyricsParser.parseRichSyncLine(line);
      if (richLine != null) {
        // Construct standard LyricLine from first word's timestamp
        // For now, we flatten rich sync to line-sync as the UI currently supports line-sync.
        // Future todo: Update UI to support word-level highlighting using richLine.words

        // Reconstruct text from words
        final text = richLine.words.map((w) => w.text).join(' ');

        lines.add(
          LyricLine(
            text: text,
            offset: richLine.lineStartTime,
            duration: const Duration(seconds: 3), // Default, fixed below
          ),
        );
      }
    }

    // Fix durations
    for (int i = 0; i < lines.length - 1; i++) {
      final current = lines[i];
      final next = lines[i + 1];
      lines[i] = LyricLine(
        text: current.text,
        offset: current.offset,
        duration: next.offset - current.offset,
      );
    }

    return lines;
  }
}
