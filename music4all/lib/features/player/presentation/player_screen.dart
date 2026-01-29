import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../logic/player_view_model.dart';
import '../../../core/providers.dart';
import 'package:audio_service/audio_service.dart';
import '../../../core/services/audio_handler_service.dart';
import 'widgets/seek_bar.dart';
import '../../queue/presentation/queue_screen.dart';
import '../../library/presentation/library_view_model.dart';
import '../../search/presentation/search_view_model.dart';
import '../../playlists/presentation/widgets/add_to_playlist_sheet.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final TrackModel? track; // Passed from navigation

  const PlayerScreen({super.key, this.track});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.track != null) {
      _initialized = true;
      // Trigger load on first mount
      Future.microtask(() {
        ref.read(playerViewModelProvider.notifier).loadAndPlay(widget.track!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerViewModelProvider);
    final audioHandler = ref.read(audioHandlerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => FractionallySizedBox(
                  heightFactor: 0.8,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    child: const QueueScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900, Colors.black],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Builder(
              builder: (context) {
                if (state is PlayerLoading) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 20),
                      Text(
                        "Loading Audio...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  );
                }

                if (state is PlayerError) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Error: ${state.message}",
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                }

                if (state is PlayerPlaying ||
                    (state is PlayerInitial && widget.track != null)) {
                  final displayTrack = (state is PlayerPlaying)
                      ? state.track
                      : widget.track!;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 3),
                      _buildArtwork(context, displayTrack),
                      const Spacer(flex: 2),
                      _buildMetadata(context, displayTrack),
                      const SizedBox(height: 24),
                      _buildActionButtons(displayTrack),
                      const Spacer(flex: 2),
                      _buildSeekBar(audioHandler),
                      _buildControls(audioHandler),
                      const Spacer(flex: 3),
                    ],
                  );
                }

                return const Text(
                  "No track selected",
                  style: TextStyle(color: Colors.white54),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArtwork(BuildContext context, TrackModel track) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          track.thumbnailUrl,
          width: 280,
          height: 280,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 280,
            height: 280,
            color: Colors.grey.shade900,
            child: const Icon(Icons.music_note, color: Colors.white, size: 80),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, TrackModel track) {
    return Column(
      children: [
        Text(
          track.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        Text(
          track.artist,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(TrackModel track) {
    final libraryState = ref.watch(libraryViewModelProvider);
    final isFavorite = libraryState.favorites.any((t) => t.id == track.id);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.redAccent : Colors.white,
          ),
          iconSize: 28,
          onPressed: () {
            ref.read(libraryViewModelProvider.notifier).toggleFavorite(track);
          },
        ),
        const SizedBox(width: 32),
        IconButton(
          icon: const Icon(Icons.playlist_add, color: Colors.white),
          iconSize: 28,
          tooltip: 'Add to Queue',
          onPressed: () {
            ref.read(searchViewModelProvider.notifier).addToQueue(track);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Added to Queue'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
        const SizedBox(width: 32),
        IconButton(
          icon: const Icon(Icons.playlist_add_check, color: Colors.white),
          iconSize: 28,
          tooltip: 'Add to Playlist',
          onPressed: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => AddToPlaylistSheet(trackId: track.id),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSeekBar(AudioHandlerService audioHandler) {
    return StreamBuilder<Duration?>(
      stream: audioHandler.durationStream,
      builder: (context, snapshotDuration) {
        final duration = snapshotDuration.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: audioHandler.positionStream,
          builder: (context, snapshotPosition) {
            var position = snapshotPosition.data ?? Duration.zero;
            if (position > duration) position = duration;

            return SeekBar(
              duration: duration,
              position: position,
              onChangeEnd: (newPosition) {
                audioHandler.seek(newPosition);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildControls(AudioHandlerService audioHandler) {
    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        final shuffleMode =
            snapshot.data?.shuffleMode ?? AudioServiceShuffleMode.none;
        final repeatMode =
            snapshot.data?.repeatMode ?? AudioServiceRepeatMode.none;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.shuffle),
              color: shuffleMode == AudioServiceShuffleMode.all
                  ? Colors.blueAccent
                  : Colors.white,
              onPressed: () {
                final enable = shuffleMode == AudioServiceShuffleMode.none;
                audioHandler.setShuffleMode(
                  enable
                      ? AudioServiceShuffleMode.all
                      : AudioServiceShuffleMode.none,
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.skip_previous,
                color: Colors.white,
                size: 36,
              ),
              onPressed: () {
                audioHandler.seek(Duration.zero);
              },
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: IconButton(
                iconSize: 48,
                color: Colors.black,
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  if (playing) {
                    audioHandler.pause();
                  } else {
                    audioHandler.play();
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                repeatMode == AudioServiceRepeatMode.one
                    ? Icons.repeat_one
                    : Icons.repeat,
              ),
              color: repeatMode != AudioServiceRepeatMode.none
                  ? Colors.blueAccent
                  : Colors.white,
              onPressed: () {
                final nextMode = {
                  AudioServiceRepeatMode.none: AudioServiceRepeatMode.all,
                  AudioServiceRepeatMode.all: AudioServiceRepeatMode.one,
                  AudioServiceRepeatMode.one: AudioServiceRepeatMode.none,
                }[repeatMode]!;
                audioHandler.setRepeatMode(nextMode);
              },
            ),
          ],
        );
      },
    );
  }
}
