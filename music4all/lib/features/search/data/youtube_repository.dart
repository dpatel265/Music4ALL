import 'package:youtube_explode_dart/youtube_explode_dart.dart'
    hide YoutubeApiClient;
import '../domain/track_model.dart';
import 'youtube_api_client.dart';
import 'package:flutter/foundation.dart';

class YoutubeRepository {
  final YoutubeApiClient _apiClient;
  final YoutubeExplode _extractor;

  YoutubeRepository({YoutubeApiClient? apiClient})
    : _apiClient = apiClient ?? YoutubeApiClient(),
      _extractor = YoutubeExplode();

  /// Searches for music videos using the Official API (Quota efficient)
  Future<List<TrackModel>> search(String query) async {
    final items = await _apiClient.searchVideos(query);
    return items
        .where((item) => item['id'] != null && item['id']['videoId'] != null)
        .map<TrackModel>((item) {
          final snippet = item['snippet'];
          final videoId = item['id']['videoId'] as String;
          return TrackModel.fromApi(snippet, videoId);
        })
        .toList();
  }

  /// Fetches playlists/albums
  Future<List<dynamic>> searchPlaylists(String query) async {
    final items = await _apiClient.searchPlaylists(query);
    return items; // Return raw data for now, can map to PlaylistModel later
  }

  /// Fetches trending music videos (Charts)
  Future<List<TrackModel>> getTrendingTracks() async {
    final items = await _apiClient.getPopularVideos();
    return items.where((item) => item['id'] != null).map<TrackModel>((item) {
      final snippet = item['snippet'];
      // 'videos' endpoint returns ID as string directly
      final videoId = item['id'] as String;
      return TrackModel.fromApi(snippet, videoId);
    }).toList();
  }

  /// Extracts the audio stream URL using YoutubeExplode (Scraping)
  /// This is called ONLY when the user clicks "Play".
  Future<String> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _extractor.videos.streamsClient.getManifest(
        videoId,
      );

      // iOS AVPlayer struggles with DASH audio-only streams (common in manifest.audioOnly).
      // We prefer MUXED streams (Video+Audio) like iTag 18/22 which are progressive MP4s.
      // This increases bandwidth usage but ensures playback works without custom HLS/DASH handling.
      final muxedStreams = manifest.muxed.where(
        (s) => s.container.name == 'mp4',
      );

      if (muxedStreams.isNotEmpty) {
        // Use the lowest video quality to save bandwidth, as we only need audio.
        // Or just highest bitrate if we don't care. Let's sorting by bitrate ascending?
        // Actually, let's just take the first one, or 'medium'.
        // For music app, we might want highest audio quality, which usually correlates with video quality.
        // Let's safe-pick highest bitrate for now to ensure it works.
        final bestStream = muxedStreams.withHighestBitrate();
        debugPrint(
          "Selected MUXED Stream: ${bestStream.container.name} | ${bestStream.bitrate} bps",
        );
        return bestStream.url.toString();
      }

      // Fallback to audio-only if no mp4 video found (rare)
      final audioStreams = manifest.audioOnly;
      final mp4Stream = audioStreams.where(
        (s) => s.container.name == 'mp4' || s.container.name == 'm4a',
      );

      final bestStream = mp4Stream.isNotEmpty
          ? mp4Stream.withHighestBitrate()
          : audioStreams.withHighestBitrate();

      debugPrint(
        "Selected Audio-Only Stream: ${bestStream.container.name} | ${bestStream.bitrate}",
      );
      return bestStream.url.toString();
    } catch (e) {
      throw Exception('Failed to extract audio stream: $e');
    }
  }

  void dispose() {
    _extractor.close();
  }
}
