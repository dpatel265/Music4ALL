import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import '../features/search/data/youtube_api_client.dart';
import '../features/search/data/youtube_repository.dart';
import '../features/library/data/local_library_repository.dart';
import '../features/player/data/lyrics_repository.dart';
import 'services/audio_handler_service.dart';
import 'services/storage_service.dart';

// --- Core Services ---

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

final audioHandlerProvider = Provider<AudioHandlerService>((ref) {
  return AudioHandlerService();
});

final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  return ref.watch(audioHandlerProvider).mediaItem;
});

/// Provides the StorageService singleton
/// Note: Must call init() in main.dart before using this.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// --- Data Layer ---

final youtubeApiClientProvider = Provider<YoutubeApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return YoutubeApiClient(dio: dio);
});

final youtubeRepositoryProvider = Provider<YoutubeRepository>((ref) {
  final client = ref.watch(youtubeApiClientProvider);
  return YoutubeRepository(apiClient: client);
});

final localLibraryRepositoryProvider = Provider<LocalLibraryRepository>((ref) {
  return LocalLibraryRepository();
});

final lyricsRepositoryProvider = Provider<LyricsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LyricsRepository(dio: dio);
});
