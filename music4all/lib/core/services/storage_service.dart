import 'package:hive_flutter/hive_flutter.dart';
import '../../features/search/domain/track_model.dart';
import '../../features/playlists/domain/user_playlist_model.dart';
import '../models/track_metadata.dart';
import '../models/playback_context.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  late Box<TrackModel> _favoritesBox;
  late Box<TrackModel> _historyBox;
  late Box<TrackMetadata> _metadataBox;
  late Box<PlaybackContext> _contextBox;
  late Box<UserPlaylist> _playlistsBox;

  final _uuid = const Uuid();

  Future<void> init() async {
    _favoritesBox = await Hive.openBox<TrackModel>('favorites');
    _historyBox = await Hive.openBox<TrackModel>('history');
    _metadataBox = await Hive.openBox<TrackMetadata>('metadata');
    _contextBox = await Hive.openBox<PlaybackContext>('playback_context');
    _playlistsBox = await Hive.openBox<UserPlaylist>('user_playlists');
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

  // --- Playlists ---
  List<UserPlaylist> getPlaylists() => _playlistsBox.values.toList();

  UserPlaylist? getPlaylist(String id) => _playlistsBox.get(id);

  Future<UserPlaylist> createPlaylist({
    required String name,
    String? description,
  }) async {
    final playlist = UserPlaylist(
      id: _uuid.v4(),
      name: name,
      description: description,
      trackIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _playlistsBox.put(playlist.id, playlist);
    return playlist;
  }

  Future<void> updatePlaylist(UserPlaylist playlist) async {
    await _playlistsBox.put(playlist.id, playlist);
  }

  Future<void> deletePlaylist(String id) async {
    await _playlistsBox.delete(id);
  }

  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final playlist = _playlistsBox.get(playlistId);
    if (playlist != null) {
      final updatedTrackIds = List<String>.from(playlist.trackIds)
        ..add(trackId);
      final updated = playlist.copyWith(
        trackIds: updatedTrackIds,
        updatedAt: DateTime.now(),
      );
      await _playlistsBox.put(playlistId, updated);
    }
  }

  Future<void> removeTrackFromPlaylist(
    String playlistId,
    String trackId,
  ) async {
    final playlist = _playlistsBox.get(playlistId);
    if (playlist != null) {
      final updatedTrackIds = List<String>.from(playlist.trackIds)
        ..remove(trackId);
      final updated = playlist.copyWith(
        trackIds: updatedTrackIds,
        updatedAt: DateTime.now(),
      );
      await _playlistsBox.put(playlistId, updated);
    }
  }

  Future<void> reorderPlaylist(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    final playlist = _playlistsBox.get(playlistId);
    if (playlist != null) {
      final trackIds = List<String>.from(playlist.trackIds);
      final item = trackIds.removeAt(oldIndex);
      trackIds.insert(newIndex, item);

      final updated = playlist.copyWith(
        trackIds: trackIds,
        updatedAt: DateTime.now(),
      );
      await _playlistsBox.put(playlistId, updated);
    }
  }

  // Get tracks for a playlist
  List<TrackModel> getPlaylistTracks(String playlistId) {
    final playlist = _playlistsBox.get(playlistId);
    if (playlist == null) return [];

    final tracks = <TrackModel>[];
    for (final trackId in playlist.trackIds) {
      final track = _historyBox.get(trackId) ?? _favoritesBox.get(trackId);
      if (track != null) tracks.add(track);
    }
    return tracks;
  }
}
