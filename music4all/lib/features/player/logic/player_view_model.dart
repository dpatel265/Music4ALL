import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../../search/data/youtube_repository.dart';
import '../../library/presentation/library_view_model.dart';
import '../../../core/providers.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/audio_handler_service.dart';

// States
abstract class PlayerState {}

class PlayerInitial extends PlayerState {}

class PlayerLoading extends PlayerState {}

class PlayerPlaying extends PlayerState {
  final TrackModel track;
  PlayerPlaying(this.track);
}

class PlayerError extends PlayerState {
  final String message;
  PlayerError(this.message);
}

// Logic - migrated to Notifier for Riverpod 3.x
// Logic - migrated to Notifier for Riverpod 3.x
class PlayerViewModel extends Notifier<PlayerState> {
  YoutubeRepository get _repository => ref.read(youtubeRepositoryProvider);
  AudioHandlerService get _audioHandler => ref.read(audioHandlerProvider);
  LibraryViewModel get _libraryViewModel =>
      ref.read(libraryViewModelProvider.notifier);

  // Queue State
  List<TrackModel> _originalQueue = [];
  List<int> _effectiveIndices = [];
  int _currentIndex = 0;
  bool _isShuffleOn = false;
  AudioServiceRepeatMode _repeatMode = AudioServiceRepeatMode.none;

  @override
  PlayerState build() {
    _listenToAudioEvents();
    return PlayerInitial();
  }

  void _listenToAudioEvents() {
    // Listen for playback completion to trigger auto-next
    _audioHandler.playbackState.listen((audioState) {
      if (audioState.processingState == AudioProcessingState.completed) {
        // Guard against multiple triggers or if already loading
        if (state is! PlayerLoading) {
          debugPrint(
            "PlayerProvider: Playback completed. Auto-skipping to next.",
          );
          skipToNext();
        }
      }
    });

    // TODO: Listen for 'next' 'previous' commands from Lock Screen if exposed by AudioHandler
    // Currently relying on generic skips via AudioHandler which might need wiring back here.
    // For now, we assume this Provider drives the AudioHandler.
  }

  // --- Queue Management ---

  Future<void> loadAndPlay(TrackModel track, {List<TrackModel>? queue}) async {
    // 1. Setup Queue
    if (queue != null) {
      _originalQueue = List.from(queue);
    } else if (!_originalQueue.any((t) => t.id == track.id)) {
      // If playing a single track not in queue, start a new queue or append?
      // SimpMusic implies context matters. Let's make a new queue of 1 for now.
      _originalQueue = [track];
    }

    // 2. Find Index
    final index = _originalQueue.indexWhere((t) => t.id == track.id);
    final validIndex = index >= 0 ? index : 0;

    // 3. Update Shuffle/Indices
    _updateEffectiveIndices(startIndex: validIndex);
    _currentIndex = 0; // In effective list, we start at 0 (Logic 2A)

    await _playCurrent();
  }

  void _updateEffectiveIndices({int? startIndex}) {
    if (_originalQueue.isEmpty) {
      _effectiveIndices = [];
      return;
    }

    if (_isShuffleOn) {
      // Logic 2A: Shuffle ON
      // Generate shuffled list of indices [0, 1, 2...]
      // Ensure *current* song stays at index 0 of the shuffled list.
      final start =
          startIndex ??
          (_effectiveIndices.isNotEmpty ? _effectiveIndices[_currentIndex] : 0);

      final indices = List<int>.generate(_originalQueue.length, (i) => i);
      indices.remove(start);
      indices.shuffle();
      _effectiveIndices = [start, ...indices];
    } else {
      // Logic 2A: Shuffle OFF
      // Revert to sequential [0, 1, 2...]
      _effectiveIndices = List<int>.generate(_originalQueue.length, (i) => i);
      // If we provided a start index (e.g. user clicked a song), we need to set _currentIndex to match it
      if (startIndex != null) {
        // In sequential mode, effective index IS the original index
        // But we need to find where that index is in our new list (It's at position startIndex)
        // Wait, _currentIndex is pointer to _effectiveIndices.
        // effectiveIndices = [0, 1, 2, 3]
        // if startIndex = 2, then _currentIndex should be 2.
      }
    }
  }

  Future<void> _playCurrent() async {
    if (_effectiveIndices.isEmpty || _currentIndex >= _effectiveIndices.length)
      return;

    final actualIndex = _effectiveIndices[_currentIndex];
    final track = _originalQueue[actualIndex];
    state = PlayerLoading();

    try {
      // 1. Extract Stream URL
      String streamUrl;
      if (track.audioUrl != null && track.audioUrl!.isNotEmpty) {
        streamUrl = track.audioUrl!;
      } else {
        streamUrl = await _repository.getAudioStreamUrl(track.id);
      }

      // 2. Play via AudioHandler
      final mediaItem = MediaItem(
        id: track.id,
        album: "Music4All",
        title: track.title,
        artist: track.artist,
        artUri: Uri.parse(track.thumbnailUrl),
        duration: null, // Just_audio will find it
      );

      await _audioHandler.playTrack(mediaItem, streamUrl);

      // 3. Add to History
      await _libraryViewModel.addToHistory(track);

      state = PlayerPlaying(track);
    } catch (e) {
      state = PlayerError("Failed to play: $e");
    }
  }

  // --- Controls ---

  Future<void> skipToNext() async {
    if (_repeatMode == AudioServiceRepeatMode.one) {
      await _audioHandler.seek(Duration.zero);
      return;
    }

    if (_currentIndex < _effectiveIndices.length - 1) {
      _currentIndex++;
      await _playCurrent();
    } else {
      // Endless Mode (Auto-Queue)
      // "If currentIndex is at the end... trigger YoutubeRepository... append to _originalQueue"
      await _fetchRelatedAndAppend();
    }
  }

  Future<void> skipToPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      await _playCurrent();
    } else {
      await _audioHandler.seek(Duration.zero);
    }
  }

  Future<void> toggleShuffle() async {
    _isShuffleOn = !_isShuffleOn;
    final currentTrackIndex = _effectiveIndices.isNotEmpty
        ? _effectiveIndices[_currentIndex]
        : 0;

    // Re-generate indices, keeping current track at 0 (if shuffling) or finding it (if un-shuffling)
    if (_isShuffleOn) {
      _updateEffectiveIndices(startIndex: currentTrackIndex);
      _currentIndex = 0;
    } else {
      _updateEffectiveIndices();
      // Find where currentTrackIndex ended up (it should be at index == currentTrackIndex)
      _currentIndex = currentTrackIndex;
    }

    // Notify AudioHandler? (Optional, mostly for UI state)
    await _audioHandler.setShuffleMode(
      _isShuffleOn ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }

  Future<void> _fetchRelatedAndAppend() async {
    if (_effectiveIndices.isEmpty) return;

    final currentTrack = _originalQueue[_effectiveIndices[_currentIndex]];
    debugPrint(
      "PlayerProvider: Fetching related tracks for ${currentTrack.title}...",
    );

    try {
      // Assuming Search return tracks, using title+artist as query for 'Up Next'
      // Or if we had a proper 'getRelated' in API. For now, use search.
      final related = await _repository.search(
        '${currentTrack.artist} mix',
      ); // Simple heuristic
      final newTracks = related
          .where((t) => !_originalQueue.any((oq) => oq.id == t.id))
          .take(5)
          .toList();

      if (newTracks.isNotEmpty) {
        _originalQueue.addAll(newTracks);
        // Update indices: Append new/sequential indices to effective list
        // If Shuffle is ON: Append them randomly? Or just append?
        // SimpMusic logic says "Append them".
        final newIndices = List.generate(
          newTracks.length,
          (i) => _originalQueue.length - newTracks.length + i,
        );
        if (_isShuffleOn) newIndices.shuffle();

        _effectiveIndices.addAll(newIndices);
        debugPrint("PlayerProvider: Appended ${newTracks.length} tracks.");

        // Auto-play next (which is now available)
        skipToNext();
      }
    } catch (e) {
      debugPrint("PlayerProvider: Failed to auto-queue: $e");
    }
  }

  void toggleFavorite(TrackModel track) {
    _libraryViewModel.toggleFavorite(track);
  }

  bool isFavorite(String id) => _libraryViewModel.isFavorite(id);
}

// Provider
final playerViewModelProvider = NotifierProvider<PlayerViewModel, PlayerState>(
  () {
    return PlayerViewModel();
  },
);
