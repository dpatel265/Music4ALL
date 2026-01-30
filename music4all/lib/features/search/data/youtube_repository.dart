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

  /// Fetches tracks from an album/playlist
  Future<List<TrackModel>> getAlbumTracks(String playlistId) async {
    final items = await _apiClient.getPlaylistItems(playlistId);
    return items.map((item) {
      final videoId = item['contentDetails']['videoId'];
      final snippet = item['snippet'];
      return TrackModel.fromApi(snippet, videoId);
    }).toList();
  }

  /// Fetches trending music videos (Charts)
  /// Uses "Billboard Hot 100" playlist via Scraping to save API Quota.
  /// Playlist ID: PL4fGSI1pDJn6jXS_Ix_Y5XRjrrqptSk84
  Future<List<TrackModel>> getTrendingTracks() async {
    try {
      debugPrint('YoutubeRepository: Fetching Top Charts (Scraper)...');
      final searchList = await _extractor.search.getVideos(
        'Billboard Hot 100 Top 50',
      );
      var videos = searchList.take(50).toList();

      final processedVideos = videos
          .where((v) => v.duration != null && v.duration!.inMinutes <= 10)
          .map(
            (v) => TrackModel(
              id: v.id.value,
              title: v.title,
              artist: v.author,
              thumbnailUrl: v.thumbnails.highResUrl,
            ),
          )
          .toList();

      if (processedVideos.isNotEmpty) {
        debugPrint(
          'YoutubeRepository: Scraper returning ${processedVideos.length} chart videos.',
        );
        return processedVideos;
      } else {
        debugPrint(
          'YoutubeRepository: Scraper found videos but all were filtered out.',
        );
      }
    } catch (e) {
      debugPrint('YoutubeRepository: Scraper failed for Charts: $e');
    }

    // 2. Fallback to API
    try {
      print('DEBUG: Falling back to API for Charts...');
      final apiResults = await search('Billboard Hot 100');
      if (apiResults.isNotEmpty) return apiResults;
    } catch (e) {
      print('DEBUG: API Fallback failed for Charts: $e');
    }

    // 3. Failsafe: Mock Data
    print('DEBUG: Falling back to Mock Data for Charts...');
    return [
      TrackModel(
        id: 'UceaB4D0jpo',
        title: 'Beautiful Things',
        artist: 'Benson Boone',
        thumbnailUrl:
            'https://img.youtube.com/vi/UceaB4D0jpo/maxresdefault.jpg',
      ),
      TrackModel(
        id: 't7bQwwqW-Hc',
        title: 'Lose Control',
        artist: 'Teddy Swims',
        thumbnailUrl:
            'https://img.youtube.com/vi/t7bQwwqW-Hc/maxresdefault.jpg',
      ),
      TrackModel(
        id: 'H2q-02s37p0',
        title: 'Greedy',
        artist: 'Tate McRae',
        thumbnailUrl:
            'https://img.youtube.com/vi/H2q-02s37p0/maxresdefault.jpg',
      ),
      TrackModel(
        id: 'lp-EO5I60KA',
        title: 'Houdini',
        artist: 'Dua Lipa',
        thumbnailUrl:
            'https://img.youtube.com/vi/lp-EO5I60KA/maxresdefault.jpg',
      ),
      TrackModel(
        id: 'rlW2tFqH2io',
        title: 'Water',
        artist: 'Tyla',
        thumbnailUrl:
            'https://img.youtube.com/vi/rlW2tFqH2io/maxresdefault.jpg',
      ),
    ];
  }

  Future<List<TrackModel>> getMoodTracks(String mood) async {
    try {
      debugPrint(
        'YoutubeRepository: Fetching mood tracks for "$mood" (Scraper)...',
      );
      final query = '$mood music';
      final searchList = await _extractor.search.getVideos(query);
      final videos = searchList.take(20).toList();

      final processedVideos = videos
          .where((v) => v.duration != null && v.duration!.inMinutes <= 10)
          .map(
            (v) => TrackModel(
              id: v.id.value,
              title: v.title,
              artist: v.author,
              thumbnailUrl: v.thumbnails.highResUrl,
            ),
          )
          .toList();

      if (processedVideos.isNotEmpty) {
        debugPrint(
          'YoutubeRepository: Scraper returning ${processedVideos.length} mood videos.',
        );
        return processedVideos;
      } else {
        debugPrint(
          'YoutubeRepository: Scraper found videos but all were filtered out.',
        );
      }
    } catch (e) {
      debugPrint('YoutubeRepository: Scraper failed for Moods: $e');
    }

    // 2. Fallback to API
    try {
      print('DEBUG: Falling back to API for Moods...');
      final apiResults = await search('$mood music');
      if (apiResults.isNotEmpty) return apiResults;
    } catch (e) {
      print('DEBUG: API Fallback failed for Moods: $e');
    }

    // 3. Failsafe: Mock Data
    print('DEBUG: Falling back to Mock Data for Moods...');
    return [
      TrackModel(
        id: '5yx6BWlEVcY',
        title: 'Chill Lo-Fi Hip Hop',
        artist: 'Lofi Girl',
        thumbnailUrl:
            'https://img.youtube.com/vi/5yx6BWlEVcY/maxresdefault.jpg',
      ),
      TrackModel(
        id: 'jfKfPfyJRdk',
        title: 'LoFi Study Stream',
        artist: 'Lofi Girl',
        thumbnailUrl:
            'https://img.youtube.com/vi/jfKfPfyJRdk/maxresdefault.jpg',
      ),
      TrackModel(
        id: '7NOSDKb0HlU',
        title: 'Focus Music',
        artist: 'StudyMD',
        thumbnailUrl:
            'https://img.youtube.com/vi/7NOSDKb0HlU/maxresdefault.jpg',
      ),
      TrackModel(
        id: 'lTRiuFIWV54',
        title: 'Relaxing Music',
        artist: 'Soothing Relaxation',
        thumbnailUrl:
            'https://img.youtube.com/vi/lTRiuFIWV54/maxresdefault.jpg',
      ),
    ];
  }

  /// Extracts the audio stream URL using YoutubeExplode (Scraping)
  /// This is called ONLY when the user clicks "Play".
  /// Extracts the audio stream URL using YoutubeExplode (Scraping)
  /// This is called ONLY when the user clicks "Play".
  Future<String> getAudioStreamUrl(String videoId) async {
    try {
      final manifest = await _extractor.videos.streamsClient.getManifest(
        videoId,
      );

      // 1. Priority: Audio-only M4A (Best for iOS AVPlayer & Bandwidth)
      // iOS struggles with DASH, but progressive M4A (iTag 140) works great.
      final audioStreams = manifest.audioOnly;
      final m4aStreams = audioStreams.where((s) => s.container.name == 'm4a');

      if (m4aStreams.isNotEmpty) {
        final bestStream = m4aStreams.withHighestBitrate();
        debugPrint("Selected Audio-Only M4A Stream: ${bestStream.bitrate} bps");
        return bestStream.url.toString();
      }

      // 2. Fallback: MUXED MP4 (Video+Audio)
      // Reliable but wastes bandwidth.
      final muxedStreams = manifest.muxed.where(
        (s) => s.container.name == 'mp4',
      );

      if (muxedStreams.isNotEmpty) {
        final bestStream = muxedStreams.withHighestBitrate();
        debugPrint(
          "Selected MUXED Stream: ${bestStream.container.name} | ${bestStream.bitrate} bps",
        );
        return bestStream.url.toString();
      }

      // 3. Last Resort: Any Audio Stream
      final bestStream = audioStreams.withHighestBitrate();
      return bestStream.url.toString();
    } catch (e) {
      throw Exception('Failed to extract audio stream: $e');
    }
  }

  /// Fetches closed captions (lyrics) for a video
  Future<List<Map<String, dynamic>>> getLyrics(
    String videoId, {
    String? title,
    String? artist,
  }) async {
    try {
      // 1. Try original video
      var lyrics = await _fetchCaptionsForVideo(videoId);
      if (lyrics.isNotEmpty) return lyrics;

      // 2. Fallback: Search for "Title Artist lyrics"
      if (title != null && artist != null) {
        debugPrint(
          'YoutubeRepository: No lyrics found for original video. Trying fallback search...',
        );
        final query = '$title $artist lyrics';
        final searchResults = await search(query);

        for (final result in searchResults.take(3)) {
          // Don't try the same video again
          if (result.id == videoId) continue;

          debugPrint(
            'YoutubeRepository: Trying fallback video: ${result.title} (${result.id})',
          );
          lyrics = await _fetchCaptionsForVideo(result.id);
          if (lyrics.isNotEmpty) {
            debugPrint('YoutubeRepository: Found lyrics in fallback video!');
            return lyrics;
          }
        }
      }

      debugPrint('YoutubeRepository: No lyrics found after all attempts.');
      return [];
    } catch (e) {
      debugPrint('YoutubeRepository: Failed to load lyrics: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCaptionsForVideo(
    String videoId,
  ) async {
    try {
      debugPrint('YoutubeRepository: Fetching lyrics manifest for $videoId');
      final manifest = await _extractor.videos.closedCaptions.getManifest(
        videoId,
      );
      debugPrint(
        'YoutubeRepository: Manifest found. Tracks: ${manifest.tracks.length}',
      );

      // Prefer English, then auto-generated
      final trackInfo =
          manifest.getByLanguage('en', autoGenerated: false).firstOrNull ??
          manifest.getByLanguage('en').firstOrNull ??
          manifest.tracks.firstOrNull;

      if (trackInfo != null) {
        debugPrint(
          'YoutubeRepository: Selected track: ${trackInfo.language.name} (Auto: ${trackInfo.isAutoGenerated})',
        );
        final track = await _extractor.videos.closedCaptions.get(trackInfo);
        debugPrint(
          'YoutubeRepository: Lyrics fetched. Lines: ${track.captions.length}',
        );
        return track.captions
            .map(
              (c) => {
                'text': c.text,
                'offset': c.offset.inMilliseconds,
                'duration': c.duration.inMilliseconds,
              },
            )
            .toList();
      }
    } catch (_) {
      // Ignore specific video failures during fallback loop
    }
    return [];
  }

  void dispose() {
    _extractor.close();
  }
}
