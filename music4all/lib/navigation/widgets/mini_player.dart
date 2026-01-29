import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audio_service/audio_service.dart';
import '../../core/providers.dart';

/// MiniPlayer - Persistent playback surface per iOS TRD Section 4
///
/// Visibility Rules:
/// - Hidden when no active track
/// - Visible when loading, playing, or paused
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.read(audioHandlerProvider);

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;

        // Hide if no active track
        if (mediaItem == null || mediaItem.id.isEmpty) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, playbackSnapshot) {
            final playbackState = playbackSnapshot.data;
            final playing = playbackState?.playing ?? false;
            final position = playbackState?.updatePosition ?? Duration.zero;
            final duration = mediaItem.duration ?? Duration.zero;
            final progress = duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

            return GestureDetector(
              onTap: () {
                // Navigate to Full Player
                context.push('/player');
              },
              child: Container(
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF1e222a),
                  border: Border(
                    top: BorderSide(color: Color(0xFF282e39), width: 0.5),
                  ),
                ),
                child: Column(
                  children: [
                    // Progress indicator
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 2,
                      backgroundColor: const Color(0xFF282e39),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF256af4),
                      ),
                    ),
                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            // Artwork
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: mediaItem.artUri != null
                                  ? Image.network(
                                      mediaItem.artUri.toString(),
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _placeholderArt(),
                                    )
                                  : _placeholderArt(),
                            ),
                            const SizedBox(width: 12),
                            // Track Info
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mediaItem.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    mediaItem.artist ?? 'Unknown Artist',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF9ca6ba),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Play/Pause Button
                            IconButton(
                              onPressed: () {
                                if (playing) {
                                  audioHandler.pause();
                                } else {
                                  audioHandler.play();
                                }
                              },
                              icon: Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                              ),
                              color: Colors.white,
                              iconSize: 32,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _placeholderArt() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF282e39),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }
}
