import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YoutubeApiClient {
  final Dio _dio;
  final String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  YoutubeApiClient({Dio? dio}) : _dio = dio ?? Dio();

  Future<List<dynamic>> searchVideos(String query) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    if (apiKey == null) throw Exception('API Key not found');

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'type': 'video',
          'videoCategoryId': '10', // Music category
          'q': query,
          'maxResults': 20,
          'key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return response.data['items'];
      } else {
        throw Exception('Failed to load videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<List<dynamic>> getPopularVideos({String regionCode = 'US'}) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    if (apiKey == null) throw Exception('API Key not found');

    try {
      final response = await _dio.get(
        '$_baseUrl/videos',
        queryParameters: {
          'part': 'snippet',
          'chart': 'mostPopular',
          'videoCategoryId': '10', // Music
          'regionCode': regionCode,
          'maxResults': 50,
          'key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return response.data['items'];
      } else {
        throw Exception(
          'Failed to load popular videos: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }

  Future<List<dynamic>> searchPlaylists(String query) async {
    final apiKey = dotenv.env['GOOGLE_API_KEY'];
    if (apiKey == null) throw Exception('API Key not found');

    try {
      final response = await _dio.get(
        '$_baseUrl/search',
        queryParameters: {
          'part': 'snippet',
          'type': 'playlist',
          'q': query,
          'maxResults': 10,
          'key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        return response.data['items'];
      } else {
        throw Exception('Failed to load playlists: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network Error: $e');
    }
  }
}
