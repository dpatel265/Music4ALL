import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../search/domain/track_model.dart';

class ExploreData {
  final List<TrackModel> newMusic;
  final List<TrackModel> topCharts;

  ExploreData({required this.newMusic, required this.topCharts});
}

final exploreProvider = FutureProvider<ExploreData>((ref) async {
  final repository = ref.watch(youtubeRepositoryProvider);

  // Parallel fetching
  final results = await Future.wait([
    repository.search('New Music Videos'),
    repository.search('Global Top 50 Music'),
  ]);

  return ExploreData(
    newMusic: results[0],
    topCharts: results[1].take(10).toList(), // Limit charts to top 10
  );
});
