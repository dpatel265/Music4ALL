import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/audio_handler_service.dart';
import '../../../core/providers.dart';
import '../../search/domain/track_model.dart';
import 'player_view_model.dart';

class QueueManager extends Notifier<void> {
  bool _isFetching = false;

  AudioHandlerService get _audioHandler => ref.read(audioHandlerProvider);
  PlayerViewModel get _playerViewModel =>
      ref.read(playerViewModelProvider.notifier);

  @override
  void build() {
    _monitorPlayback();
  }

  void _monitorPlayback() {
    // Listen to position changes to trigger pre-fetch
    _audioHandler.positionStream.listen((position) {
      final duration = _audioHandler.mediaItem.value?.duration;
      if (duration == null) return;

      // 1. Check if we are near the end (e.g., < 30 seconds remaining)
      final remaining = duration - position;
      if (remaining.inSeconds <= 30 && remaining.inSeconds > 0) {
        // 2. Check if we need more songs
        // Simple heuristic: If the queue is at the last item, we need more.
        // We can access queue state logic via AudioHandler or ViewModel.
        // For accurate index, we check PlayerViewModel.
        // NOTE: We need to expose queue state from ViewModel or check AudioHandler's queue.
        _checkAndRefillQueue();
      }
    });

    // Also listen to current media item changes to clean up or reset flags if needed
  }

  Future<void> _checkAndRefillQueue() async {
    if (_isFetching) return;

    // Ideally we check if _playerViewModel.isLastTrack.
    // Since we don't have easy synchronous access to that boolean without reading state,
    // let's assume we maintain a buffer.
    // If AudioHandler queue length - current index <= 1, fetch.
    final queue = _audioHandler.queue.value;
    final index = _audioHandler.playbackState.value.queueIndex ?? 0;

    if (queue.length - index <= 1) {
      debugPrint(
        "QueueManager: Approaching end of queue (Index: $index, Length: ${queue.length}). Pre-fetching...",
      );
      _isFetching = true;
      try {
        await _fetchNextTracks();
      } finally {
        _isFetching = false;
      }
    }
  }

  Future<void> _fetchNextTracks() async {
    // 1. Try Backend
    try {
      final currentMedia = _audioHandler.mediaItem.value;
      if (currentMedia == null) return;

      // Use a local IP that works for Simulator (localhost)
      // For real device, this often fails without specific IP.
      // We set a short timeout to fall back quickly.
      /*
      final response = await _dio.post(
        'http://localhost:8000/recommendations',
        data: {
          "seed_track_id": currentMedia.id,
          "user_history_ids": [], // TODO: wired up history
          "limit": 3
        },
        options: Options(sendTimeout: const Duration(seconds: 2)),
      );

      final List<dynamic> tracksJson = response.data['tracks'];
      if (tracksJson.isNotEmpty) {
          final trackData = tracksJson.first;
           final track = TrackModel(
              id: trackData['id'],
              title: trackData['title'],
              artist: trackData['artist'],
              thumbnailUrl: "https://i.ytimg.com/vi/${trackData['id']}/mqdefault.jpg", // heuristic
              channelTitle: trackData['artist'],
           );
           await _playerViewModel.appendTrack(track);
           return;
      }
      */
      // Backend logic temporarily commented out or wrapped in try/catch for demo reliability on device
      throw Exception("Backend unreachable on device (Demo Fallback)");
    } catch (e) {
      debugPrint(
        "QueueManager: Backend fetch failed ($e). Using local fallback.",
      );
      await _executeFallbackStrategy();
    }
  }

  Future<void> _executeFallbackStrategy() async {
    // Fallback: Pick a random supported track (Simulating 'Intelligence')
    // In a real app, this would query similar songs from YoutubeRepository directly.
    final fallbackTracks = [
      TrackModel(
        id: "uLK2r3sG4lE",
        title: "PUSH 2 START",
        artist: "Tyla",
        thumbnailUrl: "https://i.ytimg.com/vi/uLK2r3sG4lE/mqdefault.jpg",
      ),
      TrackModel(
        id: "XoiOOiuH8iI",
        title: "Water",
        artist: "Tyla",
        thumbnailUrl: "https://i.ytimg.com/vi/XoiOOiuH8iI/mqdefault.jpg",
      ),
      TrackModel(
        id: "SZpiiixlHWY",
        title: "IS IT",
        artist: "Tyla",
        thumbnailUrl: "https://i.ytimg.com/vi/SZpiiixlHWY/mqdefault.jpg",
      ),
      TrackModel(
        id: "bYUObXSWYc8",
        title: "MR. MEDIA",
        artist: "Tyla",
        thumbnailUrl: "https://i.ytimg.com/vi/bYUObXSWYc8/mqdefault.jpg",
      ),
      TrackModel(
        id: "xiZUf98A1Ts",
        title: "CHANEL",
        artist: "Tyla",
        thumbnailUrl: "https://i.ytimg.com/vi/xiZUf98A1Ts/mqdefault.jpg",
      ),
    ];

    // Simple random pick that isn't the current one?
    fallbackTracks.shuffle();
    final candidate = fallbackTracks.first;

    // Check if duplicate? PlayerViewModel handles deduping mostly, but good to check.
    debugPrint("QueueManager: Adding fallback track ${candidate.title}");
    await _playerViewModel.appendTrack(candidate);
  }
}

final queueManagerProvider = NotifierProvider<QueueManager, void>(
  QueueManager.new,
);
