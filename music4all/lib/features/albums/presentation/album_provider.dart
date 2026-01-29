import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../../../core/providers.dart';

/// Provider to fetch album tracks
final albumTracksProvider = FutureProvider.family<List<TrackModel>, String>((
  ref,
  playlistId,
) async {
  final repository = ref.watch(youtubeRepositoryProvider);
  return await repository.getAlbumTracks(playlistId);
});
