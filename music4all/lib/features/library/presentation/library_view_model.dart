import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../../../core/providers.dart';
import '../../../core/services/storage_service.dart';

class LibraryState {
  final List<TrackModel> favorites;
  final List<TrackModel> history;

  LibraryState({this.favorites = const [], this.history = const []});
}

// Migrated to Notifier for Riverpod 3.x
class LibraryViewModel extends Notifier<LibraryState> {
  StorageService get _storageService => ref.read(storageServiceProvider);

  @override
  LibraryState build() {
    return LibraryState(
      favorites: _storageService.getFavorites(),
      history: _storageService.getHistory(),
    );
  }

  void _loadLibrary() {
    state = LibraryState(
      favorites: _storageService.getFavorites(),
      history: _storageService.getHistory(),
    );
  }

  Future<void> toggleFavorite(TrackModel track) async {
    await _storageService.toggleFavorite(track);
    _loadLibrary(); // Reload state
  }

  Future<void> addToHistory(TrackModel track) async {
    await _storageService.addToHistory(track);
    _loadLibrary();
  }

  bool isFavorite(String id) => _storageService.isFavorite(id);
}

// Provider
final libraryViewModelProvider =
    NotifierProvider<LibraryViewModel, LibraryState>(() {
      return LibraryViewModel();
    });
