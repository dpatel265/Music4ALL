import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers.dart';
import 'library_view_model.dart'; // Import ViewModel
import '../domain/local_track_model.dart';
import '../../search/domain/track_model.dart';
import '../../search/presentation/search_view_model.dart'; // For queueing/playing?

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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Library'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.favorite), text: 'Favorites'),
              Tab(icon: Icon(Icons.history), text: 'History'),
              Tab(icon: Icon(Icons.folder), text: 'Local'),
            ],
            indicatorColor: Color(0xFF256af4),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTrackList(libraryState.favorites, isFavorite: true),
            _buildTrackList(libraryState.history),
            _buildLocalList(localTracks),
          ],
        ),
      ),
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
