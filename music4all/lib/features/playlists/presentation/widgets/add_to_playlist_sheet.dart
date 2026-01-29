import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../library/presentation/library_view_model.dart';
import 'create_playlist_dialog.dart';
import '../../../../core/providers.dart';

class AddToPlaylistSheet extends ConsumerWidget {
  final String trackId;

  const AddToPlaylistSheet({super.key, required this.trackId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryViewModelProvider);
    final playlists = libraryState.playlists;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1e2024),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Add to Playlist',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.white10),

          ListTile(
            leading: const Icon(Icons.add, color: Colors.purple),
            title: const Text(
              'Create New Playlist',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () async {
              Navigator.pop(context); // Close sheet
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder: (context) => const CreatePlaylistDialog(),
              );
              if (result != null) {
                await ref
                    .read(libraryViewModelProvider.notifier)
                    .createPlaylist(result['name']!, result['description']);
                // Ideally we'd also add the track to the new playlist here
                // But for simplicity let's just create it for now
              }
            },
          ),

          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                final isAdded = playlist.trackIds.contains(trackId);

                return ListTile(
                  leading: const Icon(Icons.queue_music, color: Colors.white70),
                  title: Text(
                    playlist.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${playlist.trackIds.length} tracks',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: isAdded
                      ? const Icon(Icons.check, color: Colors.purple)
                      : null,
                  onTap: () async {
                    // Use storage service via provider
                    final storage = ref.read(storageServiceProvider);

                    if (isAdded) {
                      await storage.removeTrackFromPlaylist(
                        playlist.id,
                        trackId,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Removed from ${playlist.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    } else {
                      await storage.addTrackToPlaylist(playlist.id, trackId);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added to ${playlist.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                    ref
                        .read(libraryViewModelProvider.notifier)
                        .refresh(); // Refresh lists
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
