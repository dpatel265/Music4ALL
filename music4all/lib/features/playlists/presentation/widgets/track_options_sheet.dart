import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers.dart';
import '../../../search/domain/track_model.dart';
import '../../../library/presentation/library_view_model.dart';

import 'add_to_playlist_sheet.dart';

class TrackOptionsSheet extends ConsumerWidget {
  final TrackModel track;

  const TrackOptionsSheet({super.key, required this.track});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if favorite
    final isFavorite = ref
        .watch(libraryViewModelProvider.notifier)
        .isFavorite(track.id);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              height: 4,
              width: 40,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  track.thumbnailUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
                ),
              ),
              title: Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const Divider(color: Colors.white10),

            // Actions
            ListTile(
              leading: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? AppColors.accent : Colors.white70,
              ),
              title: Text(
                isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                ref
                    .read(libraryViewModelProvider.notifier)
                    .toggleFavorite(track);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite
                          ? 'Removed from Favorites'
                          : 'Added to Favorites',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white70),
              title: const Text(
                'Add to Queue',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                ref
                    .read(audioHandlerProvider)
                    .addQueueItem(
                      MediaItem(
                        id: track.id,
                        album: "Music4All",
                        title: track.title,
                        artist: track.artist,
                        artUri: Uri.parse(track.thumbnailUrl),
                      ),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to Queue'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white70),
              title: const Text(
                'Add to Playlist',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context); // Close this sheet first
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddToPlaylistSheet(trackId: track.id),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
