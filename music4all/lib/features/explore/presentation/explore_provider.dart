import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../search/domain/track_model.dart';

class ExploreData {
  final List<TrackModel> newMusic;
  final List<TrackModel> topCharts;
  final List<dynamic> recommendedAlbums;

  ExploreData({
    required this.newMusic,
    required this.topCharts,
    required this.recommendedAlbums,
  });
}

final exploreProvider = FutureProvider<ExploreData>((ref) async {
  final repository = ref.watch(youtubeRepositoryProvider);

  // Fetch data
  final newMusic = await repository.search('New Music Videos');
  final topCharts = await repository.search('Global Top 50 Music');
  final albums = await repository.searchPlaylists('Full Album Music');

  return ExploreData(
    newMusic: newMusic,
    topCharts: topCharts.take(10).toList(),
    recommendedAlbums: albums,
  );
});
