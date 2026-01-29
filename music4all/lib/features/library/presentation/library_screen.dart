import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers.dart';
import 'library_view_model.dart'; // Import ViewModel
import '../domain/local_track_model.dart';
import '../../search/domain/track_model.dart';

import '../../playlists/domain/user_playlist_model.dart';
import '../../playlists/presentation/widgets/create_playlist_dialog.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  List<LocalTrack> localTracks = [];

  @override
  void initState() {
    super.initState();
    _loadLocalTracks();
  }

  void _loadLocalTracks() {
    final repo = ref.read(localLibraryRepositoryProvider);
    setState(() {
      localTracks = repo.getAllTracks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryViewModelProvider);

    return DefaultTabController(
      length: 4, // Increased to 4
      child: Scaffold(
        backgroundColor: const Color(0xFF111318),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111318),
          title: const Text(
            'Your Library',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(icon: Icon(Icons.playlist_play), text: 'Playlists'),
              Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(icon: Icon(Icons.folder), text: 'Local'),
            ],
            indicatorColor: Color(0xFF256af4),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (context) => const CreatePlaylistDialog(),
                );

                if (result != null) {
                  await ref
                      .read(libraryViewModelProvider.notifier)
                      .createPlaylist(result['name']!, result['description']);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Playlist "${result['name']}" created'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            _buildPlaylistsList(libraryState.playlists),
            _buildTrackList(libraryState.favorites, isFavorite: true),
            _buildTrackList(libraryState.history),
            _buildLocalList(localTracks),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsList(List<UserPlaylist> playlists) {
    if (playlists.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.playlist_add, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Playlists Yet',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await showDialog<Map<String, String>>(
                  context: context,
                  builder: (context) => const CreatePlaylistDialog(),
                );
                if (result != null) {
                  await ref
                      .read(libraryViewModelProvider.notifier)
                      .createPlaylist(result['name']!, result['description']);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text('CREATE PLAYLIST'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
              image: playlist.coverImageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(playlist.coverImageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: playlist.coverImageUrl == null
                ? const Icon(Icons.music_note, color: Colors.white)
                : null,
          ),
          title: Text(
            playlist.name,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            '${playlist.trackIds.length} tracks',
            style: const TextStyle(color: Colors.grey),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.grey),
            onPressed: () async {
              // Confirm delete
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1e2024),
                  title: const Text(
                    'Delete Playlist',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: Text(
                    'Are you sure you want to delete "${playlist.name}"?',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'DELETE',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref
                    .read(libraryViewModelProvider.notifier)
                    .deletePlaylist(playlist.id);
              }
            },
          ),
          onTap: () {
            context.push('/playlist/${playlist.id}');
          },
        );
      },
    );
  }

  Widget _buildTrackList(List<TrackModel> tracks, {bool isFavorite = false}) {
    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFavorite ? Icons.favorite_border : Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isFavorite ? 'No Favorites Yet' : 'No History Yet',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: track.thumbnailUrl.isNotEmpty
                ? Image.network(
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
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white),
                  ),
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () {
            context.push('/player', extra: track);
          },
          trailing: isFavorite
              ? IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.redAccent),
                  onPressed: () {
                    ref
                        .read(libraryViewModelProvider.notifier)
                        .toggleFavorite(track);
                  },
                )
              : null,
        );
      },
    );
  }

  Widget _buildLocalList(List<LocalTrack> tracks) {
    if (tracks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Local Files Found',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: tracks.length,
      itemBuilder: (context, index) {
        final track = tracks[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.audio_file, color: Colors.white),
          ),
          title: Text(track.title),
          subtitle: Text(track.artist),
          onTap: () {
            // Convert to TrackModel for Player
            final trackModel = TrackModel(
              id: track.id,
              title: track.title,
              artist: track.artist,
              thumbnailUrl: '',
              audioUrl: track.path,
            );
            context.push('/player', extra: trackModel);
          },
        );
      },
    );
  }
}
