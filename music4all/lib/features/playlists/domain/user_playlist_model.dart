import 'package:hive/hive.dart';

part 'user_playlist_model.g.dart';

@HiveType(typeId: 3)
class UserPlaylist {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final List<String> trackIds; // Stores track IDs in order

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  @HiveField(6)
  final String? coverImageUrl;

  UserPlaylist({
    required this.id,
    required this.name,
    this.description,
    required this.trackIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverImageUrl,
  });

  UserPlaylist copyWith({
    String? name,
    String? description,
    List<String>? trackIds,
    DateTime? updatedAt,
    String? coverImageUrl,
  }) {
    return UserPlaylist(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      trackIds: trackIds ?? this.trackIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }
}
