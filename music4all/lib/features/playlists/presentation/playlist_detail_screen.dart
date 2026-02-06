import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../playlists/domain/user_playlist_model.dart';
import '../../../core/providers.dart';
import '../../search/domain/track_model.dart';
import '../../player/logic/player_view_model.dart';
import '../../player/presentation/player_expanded_provider.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  ConsumerState<PlaylistDetailScreen> createState() =>
      _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  UserPlaylist? _playlist;
  List<TrackModel> _tracks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    final storage = ref.read(storageServiceProvider);
    final playlist = storage.getPlaylist(widget.playlistId);

    if (playlist != null) {
      final tracks = storage.getPlaylistTracks(widget.playlistId);
      if (mounted) {
        setState(() {
          _playlist = playlist;
          _tracks = tracks;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    // Optimistic update
    setState(() {
      final item = _tracks.removeAt(oldIndex);
      _tracks.insert(newIndex, item);

      // Update playlist object locally to reflect order for UI
      final trackIds = List<String>.from(_playlist!.trackIds);
      final id = trackIds.removeAt(oldIndex);
      trackIds.insert(newIndex, id);
      _playlist = _playlist!.copyWith(trackIds: trackIds);
    });

    // Persist
    final storage = ref.read(storageServiceProvider);
    await storage.reorderPlaylist(widget.playlistId, oldIndex, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF111318),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_playlist == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF111318),
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: const Center(
          child: Text(
            'Playlist not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111318),
        title: Text(_playlist!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Edit playlist dialog
            },
          ),
        ],
      ),
      body: _tracks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_note, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  const Text(
                    'No tracks yet',
                    style: TextStyle(color: Colors.white60, fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ADD SONGS'),
                  ),
                ],
              ),
            )
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: _tracks.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final track = _tracks[index];
                return ListTile(
                  key: ValueKey(track.id),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      track.thumbnailUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[800]),
                    ),
                  ),
                  title: Text(
                    track.title,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    track.artist,
                    style: const TextStyle(color: Colors.white60),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.white30,
                        ),
                        onPressed: () async {
                          final storage = ref.read(storageServiceProvider);
                          await storage.removeTrackFromPlaylist(
                            widget.playlistId,
                            track.id,
                          );
                          _loadPlaylist(); // Refresh
                        },
                      ),
                      const Icon(Icons.drag_handle, color: Colors.white30),
                    ],
                  ),
                  onTap: () {
                    ref
                        .read(playerViewModelProvider.notifier)
                        .loadAndPlay(track);
                    ref.read(playerExpandedProvider.notifier).setExpanded(true);
                  },
                );
              },
            ),
    );
  }
}
