import 'package:hive/hive.dart';

part 'track_model.g.dart';

@HiveType(typeId: 0)
class TrackModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String artist;
  
  @HiveField(3)
  final String thumbnailUrl;
  
  @HiveField(4)
  final String? audioUrl;

  TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnailUrl,
    this.audioUrl,
  });

  TrackModel copyWith({
    String? id,
    String? title,
    String? artist,
    String? thumbnailUrl,
    String? audioUrl,
  }) {
    return TrackModel(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  factory TrackModel.fromApi(Map<String, dynamic> snippet, String videoId) {
    return TrackModel(
      id: videoId,
      title: snippet['title'] ?? 'Unknown Title',
      artist: snippet['channelTitle'] ?? 'Unknown Artist',
      thumbnailUrl: snippet['thumbnails']['high']['url'] ?? '',
    );
  }
}
