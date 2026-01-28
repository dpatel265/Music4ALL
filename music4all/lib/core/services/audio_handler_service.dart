import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// The central audio handler that manages playback and system controls (lock screen, notification).
class AudioHandlerService extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();

  AudioHandlerService() {
    // Relay playback events from just_audio to audio_service
    _player.playbackEventStream.listen(_broadcastState);
    
    // Relay processing state (buffering, loading, etc)
    _player.processingStateStream.listen((state) {
       // logic to update playback state
       _broadcastState(_player.playbackEvent);
    });
  }

  Future<void> playUrl(String url, String title, String artist, String artUri) async {
    // 1. Set media item for display
    mediaItem.add(MediaItem(
      id: url,
      album: "Music4All",
      title: title,
      artist: artist,
      artUri: Uri.parse(artUri),
    ));

    // 2. Load audio source
    try {
      await _player.setUrl(url);
      play();
    } catch (e) {
      print("Error loading audio: $e");
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// Broadcasts the current state to the system (Notification/Lock Screen)
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = event.currentIndex;

    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.rewind,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: queueIndex,
    ));
  }
}
