import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/explore_widgets.dart';
import 'explore_provider.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exploreDataAsync = ref.watch(exploreProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      body: exploreDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (data) => CustomScrollView(
          slivers: [
            // Header / Top Bar
            SliverAppBar(
              backgroundColor: const Color(0xFF111318).withOpacity(0.9),
              floating: true,
              pinned: true,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(color: const Color(0xFF282e39), height: 1.0),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFF282e39),
                          hintText: 'Search songs, albums, artists',
                          hintStyle: const TextStyle(color: Color(0xFF9ca6ba)),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9ca6ba),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        onSubmitted: (query) {
                          // TODO: Navigate to search results with this query
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
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
                ],
              ),
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
                        children: const [
                          ExploreChip(
                            label: 'Explore',
                            icon: Icons.explore,
                            isSelected: true,
                          ),
                          SizedBox(width: 12),
                          ExploreChip(
                            label: 'Chill',
                            activeColor: Colors.purple,
                          ),
                          SizedBox(width: 12),
                          ExploreChip(label: 'Focus', activeColor: Colors.blue),
                          SizedBox(width: 12),
                          ExploreChip(
                            label: 'Energy',
                            activeColor: Colors.orange,
                          ),
                          SizedBox(width: 12),
                          ExploreChip(
                            label: 'Workout',
                            activeColor: Colors.red,
                          ),
                          SizedBox(width: 12),
                          ExploreChip(
                            label: 'Commute',
                            activeColor: Colors.green,
                          ),
                          SizedBox(width: 12),
                          ExploreChip(label: 'Party', activeColor: Colors.pink),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

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

                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Simple responsive grid logic
                        int crossAxisCount = 1;
                        if (constraints.maxWidth > 1200) {
                          crossAxisCount = 4;
                        } else if (constraints.maxWidth > 900) {
                          crossAxisCount = 3;
                        } else if (constraints.maxWidth > 600) {
                          crossAxisCount = 2;
                        }

                        // Just take first 4-8 items to display in grid
                        final displayItems = data.newMusic.take(8).toList();

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 24,
                                crossAxisSpacing: 24,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: displayItems.length,
                          itemBuilder: (context, index) {
                            final track = displayItems[index];
                            return GestureDetector(
                              onTap: () =>
                                  context.push('/player', extra: track),
                              child: VideoCard(
                                title: track.title,
                                subtitle: track.artist,
                                imageUrl: track.thumbnailUrl,
                                duration:
                                    '3:00', // API doesn't return duration in search snippet
                                artistImageUrl: track.thumbnailUrl, // Fallback
                              ),
                            );
                          },
                        );
                      },
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

                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: data.recommendedAlbums.length,
                        itemBuilder: (context, index) {
                          final album = data.recommendedAlbums[index];
                          final snippet = album['snippet'];
                          final playlistId = album['id']['playlistId'];
                          final title = snippet['title'] ?? 'Unknown Album';
                          final thumbnailUrl =
                              snippet['thumbnails']?['medium']?['url'] ?? '';
                          final channelTitle =
                              snippet['channelTitle'] ?? 'Unknown Artist';

                          return GestureDetector(
                            onTap: () {
                              // TODO: Navigate to album detail screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Album: $title')),
                              );
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
                    ),
                    const SizedBox(height: 32),

                    // Top Charts Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Charts',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'GLOBAL TOP 50',
                            style: TextStyle(color: Color(0xFF9ca6ba)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF181b22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF282e39)),
                      ),
                      child: Column(
                        children: data.topCharts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final track = entry.value;
                          return GestureDetector(
                            onTap: () => context.push('/player', extra: track),
                            child: ChartItem(
                              rank: index + 1,
                              change: 0,
                              changeValue: 0,
                              imageUrl: track.thumbnailUrl,
                              title: track.title,
                              artist: track.artist,
                              album: 'Single', // API limitation
                              duration: '3:00', // API limitation
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom padding to account for fixed Player Bar
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
    );
  }
}
