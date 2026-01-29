import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/providers.dart';
import '../../search/domain/track_model.dart';
import '../../../core/models/track_metadata.dart';

/// Home screen state
class HomeData {
  final TrackModel? continueListeningTrack;
  final Duration? continueListeningPosition;
  final List<TrackModel> quickPicks;
  final List<TrackModel> likedMix;
  final List<TrackModel> recentMix;
  final List<TrackModel> mostPlayedMix;
  final List<TrackModel> recentlyAdded;

  HomeData({
    this.continueListeningTrack,
    this.continueListeningPosition,
    this.quickPicks = const [],
    this.likedMix = const [],
    this.recentMix = const [],
    this.mostPlayedMix = const [],
    this.recentlyAdded = const [],
  });
}

final homeDataProvider = FutureProvider.autoDispose<HomeData>((ref) async {
  final storage = ref.watch(storageServiceProvider);

  // 1. Continue Listening
  final context = storage.getLastPlaybackContext();
  TrackModel? continueTrack;
  Duration? continuePosition;
  if (context != null && context.currentTrack != null) {
    continueTrack = context.currentTrack;
    continuePosition = context.position;
  }

  // 2. Quick Picks (weighted scoring)
  final quickPicks = _calculateQuickPicks(storage);

  // 3. Auto-generated Mixes
  final likedMix = storage.getFavorites().toList()..shuffle();
  final recentMix = storage.getHistory().take(50).toList();
  final mostPlayedMix = _calculateMostPlayed(storage);

  // 4. Recently Added (from history as proxy)
  final recentlyAdded = storage.getHistory().take(10).toList();

  return HomeData(
    continueListeningTrack: continueTrack,
    continueListeningPosition: continuePosition,
    quickPicks: quickPicks,
    likedMix: likedMix,
    recentMix: recentMix,
    mostPlayedMix: mostPlayedMix,
    recentlyAdded: recentlyAdded,
  );
});

/// Calculate Quick Picks using weighted scoring
/// Score = (playCount * 0.5) + (recentPlays * 0.3) + (liked ? 0.2 : 0)
List<TrackModel> _calculateQuickPicks(StorageService storage) {
  final tracksWithMetadata = storage.getTracksWithMetadata();
  final favorites = storage.getFavorites();
  final favoriteIds = favorites.map((t) => t.id).toSet();

  // Calculate scores
  final scored = tracksWithMetadata.map((entry) {
    final track = entry.key;
    final metadata = entry.value;

    final playCount = metadata.playCount;
    final recentPlays = _calculateRecentPlays(metadata);
    final isLiked = favoriteIds.contains(track.id);

    final score = (playCount * 0.5) + (recentPlays * 0.3) + (isLiked ? 0.2 : 0);

    return MapEntry(track, score);
  }).toList();

  // Sort by score descending
  scored.sort((a, b) => b.value.compareTo(a.value));

  // Return top 10
  return scored.take(10).map((e) => e.key).toList();
}

/// Calculate recent plays score (1.0 if played within 7 days, 0 otherwise)
double _calculateRecentPlays(TrackMetadata metadata) {
  if (metadata.lastPlayedAt == null) return 0;

  final daysSince = DateTime.now().difference(metadata.lastPlayedAt!).inDays;
  if (daysSince <= 7) return 1.0;
  return 0.0;
}

/// Calculate Most Played mix (top 50 by play count)
List<TrackModel> _calculateMostPlayed(StorageService storage) {
  final tracksWithMetadata = storage.getTracksWithMetadata();

  // Sort by play count descending
  tracksWithMetadata.sort(
    (a, b) => b.value.playCount.compareTo(a.value.playCount),
  );

  return tracksWithMetadata.take(50).map((e) => e.key).toList();
}
