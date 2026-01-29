import 'package:hive_flutter/hive_flutter.dart';
import '../../features/search/domain/track_model.dart';
import '../models/track_metadata.dart';
import '../models/playback_context.dart';

class StorageService {
  late Box<TrackModel> _favoritesBox;
  late Box<TrackModel> _historyBox;
  late Box<TrackMetadata> _metadataBox;
  late Box<PlaybackContext> _contextBox;

  Future<void> init() async {
    _favoritesBox = await Hive.openBox<TrackModel>('favorites');
    _historyBox = await Hive.openBox<TrackModel>('history');
    _metadataBox = await Hive.openBox<TrackMetadata>('metadata');
    _contextBox = await Hive.openBox<PlaybackContext>('playback_context');
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
  List<TrackModel> getHistory() =>
      _historyBox.values.toList().reversed.toList(); // Newest first

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

  // --- Play Count & Metadata ---
  TrackMetadata? getMetadata(String trackId) => _metadataBox.get(trackId);

  int getPlayCount(String trackId) {
    final metadata = _metadataBox.get(trackId);
    return metadata?.playCount ?? 0;
  }

  Future<void> incrementPlayCount(String trackId) async {
    final existing = _metadataBox.get(trackId);
    final updated = (existing ?? TrackMetadata(trackId: trackId)).copyWith(
      playCount: (existing?.playCount ?? 0) + 1,
      lastPlayedAt: DateTime.now(),
    );
    await _metadataBox.put(trackId, updated);
  }

  Future<void> updateLastPosition(String trackId, Duration position) async {
    final existing = _metadataBox.get(trackId);
    final updated = (existing ?? TrackMetadata(trackId: trackId)).copyWith(
      lastPosition: position,
      lastPlayedAt: DateTime.now(),
    );
    await _metadataBox.put(trackId, updated);
  }

  List<MapEntry<TrackModel, TrackMetadata>> getTracksWithMetadata() {
    final tracks = _historyBox.values.toList();
    return tracks.map((track) {
      final metadata =
          _metadataBox.get(track.id) ?? TrackMetadata(trackId: track.id);
      return MapEntry(track, metadata);
    }).toList();
  }

  // --- Playback Context ---
  Future<void> savePlaybackContext(PlaybackContext context) async {
    await _contextBox.put('current', context);
  }

  PlaybackContext? getLastPlaybackContext() => _contextBox.get('current');

  Future<void> clearPlaybackContext() async {
    await _contextBox.delete('current');
  }
}
