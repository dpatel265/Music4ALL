import 'package:dio/dio.dart';

class YoutubeApiClient {
  final Dio _dio;
  // Android Emulator: 10.0.2.2
  // iOS Simulator: 127.0.0.1
  // Physicall Device: Use your Machine's Local IP (e.g. 192.168.1.X)
  // For Release/Production, this should be an Environmental Variable
  final String _baseUrl = 'http://192.168.1.97:8000';

  YoutubeApiClient({Dio? dio}) : _dio = dio ?? Dio();

  /// Searches for tracks using the Python Backend (YTMusic)
  Future<List<dynamic>> searchVideos(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {'query': query, 'filter': 'songs'},
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Backend Network Error: $e');
    }
  }

  /// Fetches lyrics from Python Backend
  Future<String?> getLyrics(String videoId) async {
    try {
      final response = await _dio.get('$_baseUrl/lyrics/$videoId');
      if (response.statusCode == 200) {
        return response.data['lyrics'];
      }
      return null;
    } catch (e) {
      // It's okay if lyrics fail
      return null;
    }
  }

  // --- Legacy / Unused Methods (Kept empty or throw to ensure they aren't used incorrectly) ---

  Future<List<dynamic>> getPopularVideos({String regionCode = 'US'}) async {
    // TODO: Implement get_charts endpoint in Python if needed
    return [];
  }

  Future<List<dynamic>> searchPlaylists(String query) async {
    // TODO: Implement search_playlists endpoint in Python if needed
    return [];
  }

  Future<List<dynamic>> getPlaylistItems(String playlistId) async {
    // TODO: Implement get_playlist endpoint in Python if needed
    return [];
  }
}
