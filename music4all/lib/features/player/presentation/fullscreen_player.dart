import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audio_service/audio_service.dart';
import '../../../core/services/audio_handler_service.dart';
import '../../../core/providers.dart';
import '../../search/domain/track_model.dart';
import 'player_expanded_provider.dart';
import 'widgets/seek_bar.dart';
import 'widgets/synced_lyrics_view.dart';
import '../logic/player_view_model.dart';

class FullscreenPlayer extends ConsumerStatefulWidget {
  final TrackModel track;
  final VoidCallback onDismiss;

  const FullscreenPlayer({
    super.key,
    required this.track,
    required this.onDismiss,
  });

  @override
  ConsumerState<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends ConsumerState<FullscreenPlayer> {
  PaletteGenerator? _palette;
  Color _dominantColor = Colors.black;
  bool _showLyrics = false;
  double _dragOffset = 0.0;
  bool _initialMatchFound = false; // Latch to prevent showing stale stream data

  @override
  void initState() {
    super.initState();
    _updatePalette();
  }

  @override
  void didUpdateWidget(covariant FullscreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.track.thumbnailUrl != oldWidget.track.thumbnailUrl) {
      _updatePalette();
    }
  }

  Future<void> _updatePalette() async {
    final provider = CachedNetworkImageProvider(widget.track.thumbnailUrl);
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        provider,
        maximumColorCount: 20,
      );
      if (mounted) {
        setState(() {
          _palette = palette;
          _dominantColor = palette.dominantColor?.color ?? Colors.black;
        });
      }
    } catch (e) {
      // Fallback color
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_dragOffset + details.delta.dy).clamp(
        0.0,
        double.infinity,
      );
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragOffset > 150 || details.primaryVelocity! > 1000) {
      widget.onDismiss();
    } else {
      setState(() {
        _dragOffset = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(playerExpandedProvider, (previous, next) {
      if (next) {
        setState(() {
          _dragOffset = 0.0;
        });
      }
    });

    final audioHandler = ref.watch(audioHandlerProvider);
    final screenSize = MediaQuery.of(context).size;

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      initialData: audioHandler.mediaItem.value,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;

        // Latch logic: Prioritize widget.track until stream confirms the correct track is playing.
        // This prevents showing the PREVIOUS song ("ghost state") while the new one loads.
        if (!_initialMatchFound && mediaItem?.id == widget.track.id) {
          _initialMatchFound = true;
        }

        final useStreamData =
            _initialMatchFound || (mediaItem?.id == widget.track.id);

        // If stream is stale/null, fall back to widget.track immediately
        final displayItem = useStreamData ? mediaItem : null;

        final title = displayItem?.title ?? widget.track.title;
        final artist = displayItem?.artist ?? widget.track.artist;
        final artUri =
            displayItem?.artUri?.toString() ?? widget.track.thumbnailUrl;

        // Update palette if art changes
        // Note: Dynamic palette update inside build is unsafe (setState).
        // For now, we accept that palette might lag or be default until we refactor to a separate widget/provider.

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: Stack(
              children: [
                // Layer 1: Dynamic Background (Glass Theme)
                Positioned.fill(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [_dominantColor.withOpacity(0.6), Colors.black],
                      ),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: artUri,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.6),
                      colorBlendMode: BlendMode.darken,
                    ),
                  ),
                ),
                // Blur Effect
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                    child: Container(color: Colors.black.withOpacity(0.3)),
                  ),
                ),

                // Layer 2: Middle Content
                SafeArea(
                  child: Column(
                    children: [
                      // Top: Dismiss Chevron
                      GestureDetector(
                        onVerticalDragUpdate: _handleDragUpdate,
                        onVerticalDragEnd: _handleDragEnd,
                        onTap: widget.onDismiss,
                        child: Container(
                          height: 48,
                          width: double.infinity,
                          color: Colors.transparent, // Hit test
                          alignment: Alignment.center,
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Center: Album Art (Hero)
                      // Center: Album Art OR Lyrics
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _showLyrics = !_showLyrics;
                            });
                          },
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: _showLyrics
                                ? SyncedLyricsView(
                                    onTap: () =>
                                        setState(() => _showLyrics = false),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 40,
                                    ),
                                    child: Container(
                                      height: screenSize.width - 80,
                                      width: screenSize.width - 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.5,
                                            ),
                                            blurRadius: 30,
                                            spreadRadius: 5,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: CachedNetworkImage(
                                          imageUrl: artUri,
                                          fit: BoxFit.cover,
                                          placeholder: (_, __) => Container(
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
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Song Title & Artist
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ).animate().fadeIn().moveY(begin: 10, end: 0),
                                  const SizedBox(height: 4),
                                  Text(
                                        artist,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white.withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )
                                      .animate()
                                      .fadeIn(delay: 100.ms)
                                      .moveY(begin: 10, end: 0),
                                ],
                              ),
                            ),
                            // Favorite Icon
                            IconButton(
                              icon: const Icon(
                                Icons.favorite_border,
                                color: Colors.white,
                                size: 28,
                              ),
                              onPressed: () {
                                // Toggle Logic Here
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Scrubber
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildSeekBar(audioHandler),
                      ),

                      const SizedBox(height: 16),

                      // Controls (Play, Pause, Skip)
                      _buildControls(audioHandler),

                      const SizedBox(height: 40),

                      // Bottom Actions (Vol)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.volume_down,
                              color: Colors.white70,
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 6,
                                  ),
                                  trackHeight: 2,
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white24,
                                ),
                                child: StreamBuilder<double>(
                                  stream: audioHandler.volumeStream,
                                  initialData: audioHandler.currentVolume,
                                  builder: (context, snapshot) {
                                    final volume = snapshot.data ?? 1.0;
                                    return Slider(
                                      value: volume,
                                      onChanged: (value) {
                                        audioHandler.setVolume(value);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                            const Icon(Icons.volume_up, color: Colors.white70),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons (Lyrics, List)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.lyrics_outlined,
                                color: _showLyrics
                                    ? Colors.white
                                    : Colors.white38,
                                size: 28,
                              ),
                              onPressed: () =>
                                  setState(() => _showLyrics = !_showLyrics),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.list,
                                color: Colors.white38,
                                size: 28,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
      initialData: audioHandler.playbackState.valueOrNull ?? PlaybackState(),
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        // Move provider read inside callback or keep here, but debugging closure capture

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shuffle, color: Colors.white70),
              iconSize: 28,
              onPressed: () =>
                  ref.read(playerViewModelProvider.notifier).toggleShuffle(),
            ),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(
                Icons.skip_previous_rounded,
                color: Colors.white,
              ),
              iconSize: 48,
              onPressed: () {
                ref.read(playerViewModelProvider.notifier).skipToPrevious();
              },
            ).animate().scale(),
            const SizedBox(width: 24),

            // Play/Pause Morph
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.black,
                  size: 48,
                ),
                onPressed: () {
                  playing ? audioHandler.pause() : audioHandler.play();
                },
              ),
            ).animate().scale(duration: 200.ms, curve: Curves.easeInOutBack),

            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: Colors.white),
              iconSize: 48,
              onPressed: () {
                ref.read(playerViewModelProvider.notifier).skipToNext();
              },
            ).animate().scale(),
            const SizedBox(width: 24),
            IconButton(
              icon: const Icon(Icons.repeat, color: Colors.white70),
              iconSize: 28,
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }
}
