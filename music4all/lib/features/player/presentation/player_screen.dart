import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../logic/player_view_model.dart';
import '../../../core/providers.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:audio_service/audio_service.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/audio_handler_service.dart';
import 'widgets/seek_bar.dart';
import '../../queue/presentation/queue_screen.dart';
import '../../library/presentation/library_view_model.dart';
import '../../playlists/presentation/widgets/add_to_playlist_sheet.dart';
import '../../playlists/presentation/widgets/track_options_sheet.dart';
import 'widgets/lyrics_sheet.dart';

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
        title: Text(
          'Now Playing',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {
              if (widget.track != null ||
                  ref.read(playerViewModelProvider) is PlayerPlaying) {
                final state = ref.read(playerViewModelProvider);
                final track = (state is PlayerPlaying)
                    ? state.track
                    : widget.track!;
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (_) => TrackOptionsSheet(track: track),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          // Optional: Add blur or gradient background based on artwork
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black.withOpacity(0.8), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Builder(
              builder: (context) {
                if (state is PlayerLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is PlayerError) {
                  return Center(
                    child: Text(
                      "Error: ${state.message}",
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                if (state is PlayerPlaying ||
                    (state is PlayerInitial && widget.track != null)) {
                  final displayTrack = (state is PlayerPlaying)
                      ? state.track
                      : widget.track!;
                  return Column(
                    children: [
                      const Spacer(),
                      // Artwork
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            displayTrack.thumbnailUrl,
                            width: MediaQuery.of(context).size.width - 48,
                            height: MediaQuery.of(context).size.width - 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 300,
                              height: 300,
                              color: Colors.grey[900],
                              child: const Icon(
                                Icons.music_note,
                                size: 80,
                                color: Colors.white24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Title & Artist
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayTrack.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayTrack.artist,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final libraryState = ref.watch(
                                libraryViewModelProvider,
                              );
                              final isFavorite = libraryState.favorites.any(
                                (t) => t.id == displayTrack.id,
                              );
                              return IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? AppColors.error
                                      : Colors.white,
                                ),
                                onPressed: () {
                                  ref
                                      .read(libraryViewModelProvider.notifier)
                                      .toggleFavorite(displayTrack);
                                },
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Seek Bar
                      _buildSeekBar(audioHandler),

                      const SizedBox(height: 16),

                      // Playback Controls
                      _buildControls(audioHandler),

                      const SizedBox(height: 24),

                      // Volume Slider
                      _buildVolumeSlider(),

                      const Spacer(),

                      // Bottom Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.lyrics_outlined,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) =>
                                    LyricsSheet(track: displayTrack),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.queue_music,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (_) => const QueueScreen(),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.playlist_add,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                isScrollControlled: true,
                                builder: (context) => AddToPlaylistSheet(
                                  trackId: displayTrack.id,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      ),
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
              onChangeEnd: (newPosition) => audioHandler.seek(newPosition),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: shuffleMode != AudioServiceShuffleMode.none
                    ? AppColors.primary
                    : Colors.white,
              ),
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
              onPressed: () => audioHandler.skipToPrevious(),
            ),
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: () =>
                    playing ? audioHandler.pause() : audioHandler.play(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
              onPressed: () => audioHandler.skipToNext(),
            ),
            IconButton(
              icon: Icon(
                repeatMode == AudioServiceRepeatMode.one
                    ? Icons.repeat_one
                    : Icons.repeat,
                color: repeatMode != AudioServiceRepeatMode.none
                    ? AppColors.primary
                    : Colors.white,
              ),
              onPressed: () {
                final next = switch (repeatMode) {
                  AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
                  AudioServiceRepeatMode.all => AudioServiceRepeatMode.one,
                  _ => AudioServiceRepeatMode.none,
                };
                audioHandler.setRepeatMode(next);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildVolumeSlider() {
    return Row(
      children: [
        const Icon(Icons.volume_down, color: AppColors.textSecondary, size: 20),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 2,
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: 0.8, // TODO: Wire to real volume
              onChanged: (val) {
                // TODO: Set volume
              },
            ),
          ),
        ),
        const Icon(Icons.volume_up, color: AppColors.textSecondary, size: 20),
      ],
    );
  }
}
