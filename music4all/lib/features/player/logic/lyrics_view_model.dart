import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/data/youtube_repository.dart';
import '../../../core/providers.dart';
import '../../../core/services/audio_handler_service.dart';
import '../../search/domain/track_model.dart';
import '../domain/lyric_line.dart';

class LyricsState {
  final List<LyricLine> lyrics;
  final bool isLoading;
  final String? error;
  final int currentLineIndex;

  LyricsState({
    this.lyrics = const [],
    this.isLoading = false,
    this.error,
    this.currentLineIndex = -1,
  });

  LyricsState copyWith({
    List<LyricLine>? lyrics,
    bool? isLoading,
    String? error,
    int? currentLineIndex,
  }) {
    return LyricsState(
      lyrics: lyrics ?? this.lyrics,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Nullable to clear error
      currentLineIndex: currentLineIndex ?? this.currentLineIndex,
    );
  }
}

class LyricsViewModel extends Notifier<LyricsState> {
  YoutubeRepository get _youtubeRepository =>
      ref.read(youtubeRepositoryProvider);
  AudioHandlerService get _audioHandler => ref.read(audioHandlerProvider);

  @override
  LyricsState build() {
    // Listen to position updates to sync lyrics
    _listenToPosition();
    return LyricsState();
  }

  void _listenToPosition() {
    // We bind to the stream but we need to be careful about performance.
    // Riverpod's ref.listen or stream provider might be better,
    // but for now let's use a simple listener mechanism or just poll in UI?
    // Actually, UI usually drives the sync in simple apps, but logic is better here.
    // For simplicity sake, let's expose a method to update position or let UI watch stream.
    // Better: let UI watch audio stream and find current index,
    // BUT we want to avoid searching list every frame in UI.

    // Let's rely on UI passing position updates or a StreamSubscription here.
    // For "Agentic" simplicity, I will subscribe to the stream here if possible?
    // 'ref' is valid.

    final positionStream = _audioHandler.positionStream;
    positionStream.listen((position) {
      _updateCurrentLine(position);
    });
  }

  void _updateCurrentLine(Duration position) {
    if (state.lyrics.isEmpty) return;

    // Find the line that matches current position
    // Simple linear search or binary search. Linear is fine for < 100 items.
    int newIndex = -1;
    for (int i = 0; i < state.lyrics.length; i++) {
      final line = state.lyrics[i];
      if (position >= line.offset &&
          position <
              (line.offset +
                  line.duration +
                  const Duration(milliseconds: 500))) {
        newIndex = i;
        break;
      }
      // Keep last valid line if we are in a gap?
      if (position >= line.offset) {
        newIndex = i;
      }
    }

    if (newIndex != state.currentLineIndex) {
      state = state.copyWith(currentLineIndex: newIndex);
    }
  }

  Future<void> loadLyrics(TrackModel track) async {
    state = state.copyWith(isLoading: true, error: null, lyrics: []);

    try {
      // 1. Try LrcLib (High Quality, Synced)
      debugPrint('LyricsViewModel: Attempting to fetch lyrics from LrcLib...');
      try {
        final lyricsRepo = ref.read(lyricsRepositoryProvider);
        final lrcLibLyrics = await lyricsRepo.fetchLyrics(
          track.title,
          track.artist,
        );

        if (lrcLibLyrics.isNotEmpty) {
          debugPrint(
            'LyricsViewModel: Found ${lrcLibLyrics.length} lines from LrcLib',
          );
          state = state.copyWith(isLoading: false, lyrics: lrcLibLyrics);
          return;
        }
      } catch (e) {
        debugPrint('LyricsViewModel: LrcLib fetch failed: $e');
        // Continue to fallback
      }

      // 2. Fallback to YouTube Captions
      debugPrint(
        'LyricsViewModel: LrcLib empty or failed. Falling back to YouTube Repository...',
      );
      final rawLyrics = await _youtubeRepository.getLyrics(
        track.id,
        title: track.title,
        artist: track.artist,
      );
      debugPrint(
        'LyricsViewModel: Repository returned ${rawLyrics.length} lines',
      );

      if (rawLyrics.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: "No lyrics available",
          lyrics: [],
        );
        return;
      }

      final lyrics = rawLyrics.map((map) {
        return LyricLine(
          text: map['text'],
          offset: Duration(milliseconds: map['offset']),
          duration: Duration(milliseconds: map['duration']),
        );
      }).toList();

      debugPrint(
        'LyricsViewModel: Parsed ${lyrics.length} LyricLines. Updating state.',
      );
      state = state.copyWith(isLoading: false, lyrics: lyrics);
    } catch (e) {
      debugPrint('LyricsViewModel: Error loading lyrics: $e');
      state = state.copyWith(isLoading: false, error: "Failed to load lyrics");
    }
  }
}

final lyricsViewModelProvider = NotifierProvider<LyricsViewModel, LyricsState>(
  () {
    return LyricsViewModel();
  },
);
