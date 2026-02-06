import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../playlists/domain/playlist_model.dart';
import 'widgets/explore_widgets.dart';
import '../../player/logic/player_view_model.dart';
import '../../player/presentation/player_expanded_provider.dart';
import 'explore_provider.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreDataAsync = ref.watch(exploreProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      body: Builder(
        builder: (context) {
          final state = ref.watch(exploreProvider);
          final viewModel = ref.read(exploreProvider.notifier);

          if (state.isLoading && state.newMusic.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // Header / Top Bar
              SliverAppBar(
                backgroundColor: const Color(0xFF111318).withOpacity(0.9),
                floating: true,
                pinned: true,
                elevation: 0,
                title: const Text(
                  'Explore',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.cast),
                    color: const Color(0xFF9ca6ba),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: const Color(0xFF9ca6ba),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 12),
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCEC2cE0wcyxPFIus_6pJcA5DdSeGeBx3zyZTYnRvpZWTGgfdo5oxemJB_0uqnv13DSof-ekdjl_mb5yo2mceWvSJ3RdmtqFpBAHdnVVwfSUO0sJPkfdrOt6bzILjt43xsR1CGox52Ami3YmVXx7pdPSN-Pn052FmkTh1QRORscPnkITcMojEWo9iJXPBG019wCgOPM3WjgtKCMmVKKnYsNiILyE1-CYxWS9XDdH-nhswcOkbVWd0z-v0mGTIOc6aEwfAsKCYD1SspA',
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),

              // Scrollable Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chips Config
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ExploreChip(
                              label: 'Explore',
                              icon: Icons.explore,
                              isSelected: state.selectedMood == null,
                              onTap: () =>
                                  viewModel.selectMood('Explore'), // Or clear
                              activeColor: AppColors.primary,
                            ),
                            const SizedBox(width: 12),
                            ...[
                              'Chill',
                              'Focus',
                              'Energy',
                              'Workout',
                              'Commute',
                              'Party',
                            ].map((mood) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: ExploreChip(
                                  label: mood,
                                  activeColor: _getMoodColor(mood),
                                  isSelected: state.selectedMood == mood,
                                  onTap: () => viewModel.selectMood(mood),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Content Logic: Mood or Default
                      if (state.selectedMood != null &&
                          state.selectedMood != 'Explore') ...[
                        Text(
                          '${state.selectedMood} Mix',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        state.isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _buildGrid(state.moodTracks, context, ref),
                      ] else ...[
                        // New Music Videos Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'New Music Videos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'SEE ALL',
                                style: TextStyle(color: Color(0xFF9ca6ba)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildGrid(
                          state.newMusic.take(8).toList(),
                          context,
                          ref,
                        ),

                        const SizedBox(height: 32),

                        // Recommended Albums Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Recommended Albums',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'SEE ALL',
                                style: TextStyle(color: Color(0xFF9ca6ba)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildAlbumList(state.recommendedAlbums, context),

                        const SizedBox(height: 32),

                        // Top Charts Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Top Charts (Non-API)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTopCharts(state.topCharts, context, ref),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom padding to account for fixed Player Bar
              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<dynamic> items, BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 900) {
          crossAxisCount = 3;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.9,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final track = items[index];
            return GestureDetector(
              onTap: () {
                ref.read(playerViewModelProvider.notifier).loadAndPlay(track);
                ref.read(playerExpandedProvider.notifier).setExpanded(true);
              },
              child: VideoCard(
                title: track.title,
                subtitle: track.artist,
                imageUrl: track.thumbnailUrl,
                duration: '3:00',
                artistImageUrl: track.thumbnailUrl,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlbumList(List<dynamic> albums, BuildContext context) {
    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          final snippet = album['snippet'];
          final playlistId = album['id']['playlistId'];
          final title = snippet['title'] ?? 'Unknown Album';
          final thumbnailUrl = snippet['thumbnails']?['medium']?['url'] ?? '';
          final channelTitle = snippet['channelTitle'] ?? 'Unknown Artist';

          return GestureDetector(
            onTap: () {
              final albumModel = PlaylistModel(
                id: playlistId,
                title: title,
                description: snippet['description'] ?? '',
                thumbnailUrl: thumbnailUrl,
                channelTitle: channelTitle,
              );
              context.push('/album', extra: albumModel);
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: thumbnailUrl.isNotEmpty
                        ? Image.network(
                            thumbnailUrl,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 160,
                            height: 160,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.album,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    channelTitle,
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
          );
        },
      ),
    );
  }

  Widget _buildTopCharts(
    List<dynamic> tracks,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181b22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF282e39)),
      ),
      child: Column(
        children: tracks.asMap().entries.map((entry) {
          final index = entry.key;
          final track = entry.value;
          return GestureDetector(
            onTap: () {
              ref.read(playerViewModelProvider.notifier).loadAndPlay(track);
              ref.read(playerExpandedProvider.notifier).setExpanded(true);
            },
            child: ChartItem(
              rank: index + 1,
              change: 0,
              changeValue: 0,
              imageUrl: track.thumbnailUrl,
              title: track.title,
              artist: track.artist,
              album: 'Single',
              duration: '3:00',
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Chill':
        return Colors.purple;
      case 'Focus':
        return Colors.blue;
      case 'Energy':
        return Colors.orange;
      case 'Workout':
        return Colors.red;
      case 'Commute':
        return Colors.green;
      case 'Party':
        return Colors.pink;
      default:
        return AppColors.primary;
    }
  }
}
