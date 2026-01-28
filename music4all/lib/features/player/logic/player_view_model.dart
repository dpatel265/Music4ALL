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

// Logic
class PlayerViewModel extends StateNotifier<PlayerState> {
  final YoutubeRepository _repository;
  final AudioHandlerService _audioHandler;
  final LibraryViewModel _libraryViewModel;

  PlayerViewModel(this._repository, this._audioHandler, this._libraryViewModel) : super(PlayerInitial());

  Future<void> loadAndPlay(TrackModel track) async {
    state = PlayerLoading();
    try {
      // 1. Extract Stream URL
      final streamUrl = await _repository.getAudioStreamUrl(track.id);
      
      // 2. Play via AudioHandler
      await _audioHandler.playUrl(
        streamUrl,
        track.title,
        track.artist,
        track.thumbnailUrl,
      );

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
final playerViewModelProvider = StateNotifierProvider<PlayerViewModel, PlayerState>((ref) {
  final repo = ref.watch(youtubeRepositoryProvider);
  final handler = ref.watch(audioHandlerProvider);
  final library = ref.watch(libraryViewModelProvider.notifier); // Access logic
  return PlayerViewModel(repo, handler, library);
});
