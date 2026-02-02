import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// The central audio handler that manages playback and system controls (lock screen, notification).
class AudioHandlerService extends BaseAudioHandler with SeekHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);
  final _volumeController = StreamController<double>.broadcast();

  late final Future<void> _sessionFuture;

  AudioHandlerService() {
    _sessionFuture = _initAudioSession();
    _initVolume();

    // Relay playback events from just_audio to audio_service
    _player.playbackEventStream.listen(_broadcastState);

    // Relay processing state (buffering, loading, etc)
    _player.processingStateStream.listen((state) {
      _broadcastState(_player.playbackEvent);
    });

    // Sync Queue and MediaItem
    _player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState.effectiveSequence;
      final newQueue = sequence
          .map((source) => source.tag as MediaItem)
          .toList();
      queue.add(newQueue);

      final currentItem = sequenceState.currentSource?.tag as MediaItem?;
      if (currentItem != null) {
        mediaItem.add(currentItem);
      }
    });
  }

  void _initVolume() {
    // Listen to system volume changes
    FlutterVolumeController.addListener((volume) {
      _currentVolume = volume;
      _volumeController.add(volume);
    });

    // Get initial volume
    FlutterVolumeController.getVolume().then((volume) {
      if (volume != null) {
        _currentVolume = volume;
        _volumeController.add(volume);
      }
    });
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  /// Plays a new track, replacing the current queue.
  Future<void> playTrack(MediaItem item, String streamUrl) async {
    debugPrint("AudioHandler: playTrack called for ${item.title}");
    await _sessionFuture;
    try {
      debugPrint("AudioHandler: preparing audio source");
      final source = AudioSource.uri(
        Uri.parse(streamUrl),
        tag: item,
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        },
      );
      await _playlist.clear();
      await _playlist.add(source);
      await _player.setAudioSource(_playlist);
      _player.play(); // Don't await to avoid UI blocking
    } catch (e) {
      debugPrint("Error playing track: $e");
      // throw Exception("Audio Error: $e"); // Don't crash, just log.
    }
  }

  /// Appends a track to the end of the queue.
  Future<void> addToQueue(MediaItem item, String streamUrl) async {
    await _sessionFuture;
    debugPrint("AudioHandler: addToQueue ${item.title}");
    final source = AudioSource.uri(
      Uri.parse(streamUrl),
      tag: item,
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
      },
    );
    await _playlist.add(source);
    if (_player.audioSource == null) {
      try {
        await _player.setAudioSource(_playlist);
      } catch (e) {
        debugPrint("Error setting audio source in addToQueue: $e");
      }
    }
  }

  /// Removes a track from the queue at the specified index.
  @override
  Future<void> removeQueueItemAt(int index) async {
    await _playlist.removeAt(index);
  }

  /// Reorders a track in the queue.
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    await _playlist.move(oldIndex, newIndex);
  }

  /// Skips to the next item in the queue.
  @override
  Future<void> skipToNext() => _player.seekToNext();

  /// Skips to the previous item in the queue.
  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  /// Jumps to a specific item in the queue.
  @override
  Future<void> skipToQueueItem(int index) async {
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled =
        shuffleMode == AudioServiceShuffleMode.all ||
        shuffleMode == AudioServiceShuffleMode.group;
    if (enabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = {
      AudioServiceRepeatMode.none: LoopMode.off,
      AudioServiceRepeatMode.one: LoopMode.one,
      AudioServiceRepeatMode.all: LoopMode.all,
      AudioServiceRepeatMode.group: LoopMode.all,
    }[repeatMode]!;
    await _player.setLoopMode(loopMode);
  }

  // Sleep Timer
  Timer? _sleepTimer;
  Future<void> scheduleSleepTimer(Duration duration) async {
    _sleepTimer?.cancel();
    if (duration == Duration.zero) return;

    debugPrint("AudioHandler: Sleep timer set for $duration");
    _sleepTimer = Timer(duration, () {
      debugPrint("AudioHandler: Sleep timer triggered. Pausing.");
      pause();
      _sleepTimer = null;
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<double> get volumeStream => _volumeController.stream;
  double get currentVolume => _currentVolume;
  double _currentVolume = 1.0;

  Future<void> setVolume(double volume) async {
    _currentVolume = volume;
    await FlutterVolumeController.setVolume(volume);
  }

  /// Broadcasts the current state to the system (Notification/Lock Screen)
  void _broadcastState(PlaybackEvent event) {
    final playing = _player.playing;
    final queueIndex = event.currentIndex;

    playbackState.add(
      playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
          MediaControl.stop,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 2],
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
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }
}
