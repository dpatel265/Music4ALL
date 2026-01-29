class PlaylistModel {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String channelTitle;
  final int? videoCount;

  PlaylistModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.channelTitle,
    this.videoCount,
  });

  factory PlaylistModel.fromApi(
    Map<String, dynamic> snippet,
    String playlistId,
  ) {
    return PlaylistModel(
      id: playlistId,
      title: snippet['title'] ?? 'Unknown Playlist',
      description: snippet['description'] ?? '',
      thumbnailUrl:
          snippet['thumbnails']?['high']?['url'] ??
          snippet['thumbnails']?['medium']?['url'] ??
          '',
      channelTitle: snippet['channelTitle'] ?? 'Unknown Channel',
    );
  }
}
