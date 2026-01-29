import 'package:hive/hive.dart';
import '../../features/search/domain/track_model.dart';

part 'playback_context.g.dart';

/// Stores the complete playback context for restoration
@HiveType(typeId: 2)
class PlaybackContext {
  @HiveField(0)
  final TrackModel? currentTrack;

  @HiveField(1)
  final List<TrackModel> queue;

  @HiveField(2)
  final int currentIndex;

  @HiveField(3)
  final Duration position;

  @HiveField(4)
  final DateTime savedAt;

  PlaybackContext({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = 0,
    this.position = Duration.zero,
    required this.savedAt,
  });
}
