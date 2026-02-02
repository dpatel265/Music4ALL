import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'charts_view_model.dart';
import '../../search/domain/track_model.dart';
import '../../player/logic/player_view_model.dart';

class ChartsScreen extends ConsumerWidget {
  const ChartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chartsViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Top Charts')),
      body: Builder(
        builder: (context) {
          if (state is ChartsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChartsError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is ChartsLoaded) {
            final tracks = state.tracks;
            if (tracks.isEmpty) {
              return const Center(child: Text('No charts available'));
            }
            return ListView.builder(
              itemCount: tracks.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildHeader(context, ref, tracks);
                }
                final track = tracks[index - 1];
                final rank = index;
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '#$rank',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          track.thumbnailUrl,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: Colors.grey[800]),
                        ),
                      ),
                    ],
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
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.playlist_add),
                    onPressed: () {
                      // TODO: Add to queue logic if desired, or reuse SearchViewModel logic
                    },
                  ),
                  onTap: () {
                    context.push(
                      '/player',
                      extra: {'track': track, 'sourceLocation': '/charts'},
                    );
                  },
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    List<TrackModel> tracks,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text(
            'Trending Now',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play All'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF256af4),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Play All Logic:
              // 1. Clear queue
              // 2. Add all tracks
              // 3. Play first
              // We need PlayerViewModel or AudioHandler directly.
              _playAll(ref, tracks);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _playAll(WidgetRef ref, List<TrackModel> tracks) async {
    // This requires resolving stream URLs for ALL tracks?
    // Fetching 50 URLs at once is slow and might hit quotas/rate limits.
    // Better: Play first track, add rest to Queue (as media items without URL resolved yet?)
    // Our AudioHandler 'playTrack' resolves URL immediately.
    // 'addToQueue' resolves URL immediately.
    //
    // LIMITATION: We can't batch resolve efficiently without delay.
    // Strategy: Play first one. Add first 5 to queue?
    // Or just Play first one and let user add others?
    // OR: Use 'loadAndPlay' for first, then async Loop to add others?

    if (tracks.isEmpty) return;

    // Just play first for now.
    // Ideally we implement 'playPlaylist' that lazily resolves.
    // For this MVP, Play First.

    // ref.read(playerViewModelProvider.notifier).loadAndPlay(tracks.first);
    // And maybe queue the next 2-3?

    final vm = ref.read(playerViewModelProvider.notifier);
    await vm.loadAndPlay(tracks.first);

    // Queue next few
    // Note: we don't have easy access to 'addToQueue' from here unless we duplicate it
    // or use SearchViewModel.
    // Let's just play first for now.
  }
}
