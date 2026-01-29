import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../player/domain/lyric_line.dart';

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
    final RegExp regex = RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2})\](.*)$');

    // Example Line: [00:12.34]Lyric text here
    for (final line in syncedLyrics.split('\n')) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final hundredths = int.parse(match.group(3)!);
        final text = match.group(4)!.trim();

        if (text.isNotEmpty) {
          final offset = Duration(
            minutes: minutes,
            seconds: seconds,
            milliseconds: hundredths * 10,
          );

          // Estimate duration until next line (handled by UI or VM usually,
          // but we need to populate the field).
          // For now, set duration to 0 or a default, and we can fix up later if needed.
          // Or we can post-process.

          lines.add(
            LyricLine(
              text: text,
              offset: offset,
              duration: const Duration(seconds: 3), // Default duration
            ),
          );
        }
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
