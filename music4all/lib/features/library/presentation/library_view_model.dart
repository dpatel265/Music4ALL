import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../../../core/providers.dart';
import '../../../core/services/storage_service.dart';

class LibraryState {
  final List<TrackModel> favorites;
  final List<TrackModel> history;
  
  LibraryState({this.favorites = const [], this.history = const []});
}

class LibraryViewModel extends StateNotifier<LibraryState> {
  final StorageService _storageService;

  LibraryViewModel(this._storageService) : super(LibraryState()) {
    _loadLibrary();
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
final libraryViewModelProvider = StateNotifierProvider<LibraryViewModel, LibraryState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return LibraryViewModel(storage);
});
