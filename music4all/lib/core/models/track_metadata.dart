import 'package:hive/hive.dart';

part 'track_metadata.g.dart';

/// Stores playback metadata for a track (play count, last position, etc.)
@HiveType(typeId: 1)
class TrackMetadata {
  @HiveField(0)
  final String trackId;

  @HiveField(1)
  final int playCount;

  @HiveField(2)
  final DateTime? lastPlayedAt;

  @HiveField(3)
  final Duration? lastPosition;

  TrackMetadata({
    required this.trackId,
    this.playCount = 0,
    this.lastPlayedAt,
    this.lastPosition,
  });

  TrackMetadata copyWith({
    int? playCount,
    DateTime? lastPlayedAt,
    Duration? lastPosition,
  }) {
    return TrackMetadata(
      trackId: trackId,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      lastPosition: lastPosition ?? this.lastPosition,
    );
  }
}
