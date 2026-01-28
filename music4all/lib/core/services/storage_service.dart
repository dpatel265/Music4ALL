import 'package:hive_flutter/hive_flutter.dart';
import '../../features/search/domain/track_model.dart';

class StorageService {
  late Box<TrackModel> _favoritesBox;
  late Box<TrackModel> _historyBox;

  Future<void> init() async {
    _favoritesBox = await Hive.openBox<TrackModel>('favorites');
    _historyBox = await Hive.openBox<TrackModel>('history');
  }

  // --- Favorites ---
  List<TrackModel> getFavorites() => _favoritesBox.values.toList();
  
  bool isFavorite(String id) => _favoritesBox.containsKey(id);

  Future<void> toggleFavorite(TrackModel track) async {
    if (_favoritesBox.containsKey(track.id)) {
      await _favoritesBox.delete(track.id);
    } else {
      await _favoritesBox.put(track.id, track);
    }
  }

  // --- History (Recently Played) ---
  List<TrackModel> getHistory() => _historyBox.values.toList().reversed.toList(); // Newest first

  Future<void> addToHistory(TrackModel track) async {
    // Optional: Limit history size
    if (_historyBox.length > 50) {
      await _historyBox.deleteAt(0); // Remove oldest
    }
    // Delete if existing to move to top
    if (_historyBox.containsKey(track.id)) {
      await _historyBox.delete(track.id);
    }
    await _historyBox.put(track.id, track);
  }
}
