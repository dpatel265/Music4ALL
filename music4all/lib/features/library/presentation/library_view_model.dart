import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../../../core/providers.dart';
import '../../../core/services/storage_service.dart';
import '../../playlists/domain/user_playlist_model.dart';

class LibraryState {
  final List<TrackModel> favorites;
  final List<TrackModel> history;
  final List<UserPlaylist> playlists;

  LibraryState({
    this.favorites = const [],
    this.history = const [],
    this.playlists = const [],
  });

  LibraryState copyWith({
    List<TrackModel>? favorites,
    List<TrackModel>? history,
    List<UserPlaylist>? playlists,
  }) {
    return LibraryState(
      favorites: favorites ?? this.favorites,
      history: history ?? this.history,
      playlists: playlists ?? this.playlists,
    );
  }
}

// Migrated to Notifier for Riverpod 3.x
class LibraryViewModel extends Notifier<LibraryState> {
  StorageService get _storageService => ref.read(storageServiceProvider);

  @override
  LibraryState build() {
    return _loadState();
  }

  LibraryState _loadState() {
    return LibraryState(
      favorites: _storageService.getFavorites(),
      history: _storageService.getHistory(),
      playlists: _storageService.getPlaylists(),
    );
  }

  void refresh() {
    state = _loadState();
  }

  Future<void> toggleFavorite(TrackModel track) async {
    await _storageService.toggleFavorite(track);
    refresh(); // Reload state
  }

  Future<void> addToHistory(TrackModel track) async {
    await _storageService.addToHistory(track);
    refresh();
  }

  Future<void> createPlaylist(String name, String? description) async {
    await _storageService.createPlaylist(name: name, description: description);
    refresh();
  }

  Future<void> deletePlaylist(String id) async {
    await _storageService.deletePlaylist(id);
    refresh();
  }

  bool isFavorite(String id) => _storageService.isFavorite(id);
}

// Provider
final libraryViewModelProvider =
    NotifierProvider<LibraryViewModel, LibraryState>(() {
      return LibraryViewModel();
    });
