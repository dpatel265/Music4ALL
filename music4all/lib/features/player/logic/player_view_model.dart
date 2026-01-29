import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../../search/data/youtube_repository.dart';
import '../../library/presentation/library_view_model.dart';
import '../../../core/providers.dart';
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
class PlayerViewModel extends Notifier<PlayerState> {
  YoutubeRepository get _repository => ref.read(youtubeRepositoryProvider);
  AudioHandlerService get _audioHandler => ref.read(audioHandlerProvider);
  LibraryViewModel get _libraryViewModel =>
      ref.read(libraryViewModelProvider.notifier);

  @override
  PlayerState build() => PlayerInitial();

  Future<void> loadAndPlay(TrackModel track) async {
    state = PlayerLoading();
    try {
      // 1. Extract Stream URL
      String streamUrl;
      if (track.audioUrl != null && track.audioUrl!.isNotEmpty) {
        // Local file or direct URL
        streamUrl = track.audioUrl!;
      } else {
        // Fetch from YouTube
        streamUrl = await _repository.getAudioStreamUrl(track.id);
      }

      // 2. Play via AudioHandler
      final mediaItem = MediaItem(
        id: track.id,
        album: "Music4All",
        title: track.title,
        artist: track.artist,
        artUri: Uri.parse(track.thumbnailUrl),
      );

      await _audioHandler.playTrack(mediaItem, streamUrl);

      // 3. Add to History
      await _libraryViewModel.addToHistory(track);

      state = PlayerPlaying(track);
    } catch (e) {
      state = PlayerError("Failed to play: $e");
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
