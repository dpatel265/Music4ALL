import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../domain/track_model.dart';
import 'youtube_api_client.dart';

class YoutubeRepository {
  final YoutubeApiClient _apiClient;
  final YoutubeExplode _extractor;

  YoutubeRepository({YoutubeApiClient? apiClient})
      : _apiClient = apiClient ?? YoutubeApiClient(),
        _extractor = YoutubeExplode();

  /// Searches for music videos using the Official API (Quota efficient)
  Future<List<TrackModel>> search(String query) async {
    final items = await _apiClient.searchVideos(query);
    return items.map<TrackModel>((item) {
      final snippet = item['snippet'];
      final videoId = item['id']['videoId'];
      return TrackModel.fromApi(snippet, videoId);
    }).toList();
  }

  /// Extracts the audio stream URL using YoutubeExplode (Scraping)
  /// This is called ONLY when the user clicks "Play".
  Future<String> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _extractor.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      return audioStream.url.toString();
    } catch (e) {
      throw Exception('Failed to extract audio stream: $e');
    }
  }

  void dispose() {
    _extractor.close();
  }
}
