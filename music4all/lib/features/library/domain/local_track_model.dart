import 'package:hive/hive.dart';

part 'local_track_model.g.dart';

@HiveType(typeId: 1)
class LocalTrack extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String path;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String artist;

  @HiveField(4)
  final String album;

  @HiveField(5)
  final int durationMs;

  @HiveField(6)
  final DateTime dateAdded;

  LocalTrack({
    required this.id,
    required this.path,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.dateAdded,
  });

  Duration get duration => Duration(milliseconds: durationMs);
}
