import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../features/player/presentation/player_expanded_provider.dart';

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

        return GestureDetector(
          onTap: () {
            ref.read(playerExpandedProvider.notifier).state = true;
          },
          child: Container(
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: Colors.white12, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: 0.3, // Placeholder
                  minHeight: 2,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'audio_artwork_${mediaItem.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: mediaItem.artUri != null
                                ? Image.network(
                                    mediaItem.artUri.toString(),
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _placeholderArt(),
                                  )
                                : _placeholderArt(),
                          ),
                        ),
                        const SizedBox(width: 12),
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
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                mediaItem.artist ?? 'Unknown Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final playing = ref
                                .read(audioHandlerProvider)
                                .playbackState
                                .value
                                .playing;
                            if (playing) {
                              ref.read(audioHandlerProvider).pause();
                            } else {
                              ref.read(audioHandlerProvider).play();
                            }
                          },
                          icon: StreamBuilder<PlaybackState>(
                            stream: ref
                                .read(audioHandlerProvider)
                                .playbackState,
                            builder: (context, snapshot) {
                              final playing = snapshot.data?.playing ?? false;
                              return Icon(
                                playing ? Icons.pause : Icons.play_arrow,
                              );
                            },
                          ),
                          color: Colors.white,
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
  }

  Widget _placeholderArt() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFF282e39),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.music_note, color: Colors.white54),
    );
  }
}
