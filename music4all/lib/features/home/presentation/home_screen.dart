import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import 'home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      body: homeDataAsync.when(
        loading: () => _buildLoadingState(context),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        data: (data) => _buildHomeContent(context, ref, data),
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, WidgetRef ref, data) {
    return RefreshIndicator(
      onRefresh: () => ref.refresh(homeDataProvider.future),
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: const Color(0xFF111318).withOpacity(0.9),
            floating: true,
            pinned: true,
            title: const Text(
              'Home',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Continue Listening
                if (data.continueListeningTrack != null) ...[
                  _buildContinueListening(
                    context,
                    ref,
                    data.continueListeningTrack!,
                    data.continueListeningPosition,
                  ),
                  const SizedBox(height: 32),
                ],

                // 2. Quick Picks
                if (data.quickPicks.isNotEmpty) ...[
                  _buildSectionHeader('Quick Picks', onSeeAll: () {}),
                  const SizedBox(height: 16),
                  _buildQuickPicks(context, ref, data.quickPicks),
                  const SizedBox(height: 32),
                ],

                // 3. Mixes
                _buildSectionHeader('Your Mixes', onSeeAll: () {}),
                const SizedBox(height: 16),
                _buildMixes(context, ref, data),
                const SizedBox(height: 32),

                // 4. Recently Added
                if (data.recentlyAdded.isNotEmpty) ...[
                  _buildSectionHeader('Recently Added', onSeeAll: () {}),
                  const SizedBox(height: 16),
                  _buildRecentlyAdded(context, ref, data.recentlyAdded),
                  const SizedBox(height: 100), // Bottom padding for mini player
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'SEE ALL',
              style: TextStyle(color: Color(0xFF9ca6ba)),
            ),
          ),
      ],
    );
  }

  Widget _buildContinueListening(
    BuildContext context,
    WidgetRef ref,
    track,
    Duration? position,
  ) {
    return GestureDetector(
      onTap: () {
        // Navigate to player with this track (playback will resume)
        context.push('/player', extra: track);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF9d4100)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                track.thumbnailUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(width: 80, height: 80, color: Colors.grey[800]),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Continue Listening',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_filled, color: Colors.white, size: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPicks(BuildContext context, WidgetRef ref, List tracks) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tracks.length,
        itemBuilder: (context, index) {
          final track = tracks[index];
          return GestureDetector(
            onTap: () => context.push('/player', extra: track),
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      track.thumbnailUrl,
                      width: 160,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 160,
                        height: 160,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
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

  Widget _buildMixes(BuildContext context, WidgetRef ref, data) {
    final mixes = [
      {
        'title': 'Liked Mix',
        'tracks': data.likedMix,
        'color': Colors.redAccent,
      },
      {
        'title': 'Recent Mix',
        'tracks': data.recentMix,
        'color': AppColors.primary,
      },
      {
        'title': 'Most Played',
        'tracks': data.mostPlayedMix,
        'color': AppColors.accent,
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mixes.length,
        itemBuilder: (context, index) {
          final mix = mixes[index];
          final tracks = mix['tracks'] as List;

          if (tracks.isEmpty) return const SizedBox();

          return GestureDetector(
            onTap: () {
              // Play mix
              if (tracks.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Playing ${mix['title']}')),
                );
                // TODO: Play entire mix as queue
              }
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: mix['color'] as Color,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.music_note,
                        color: Colors.white,
                        size: 32,
                      ),
                      const Spacer(),
                      Text(
                        '${tracks.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mix['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Auto-generated',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentlyAdded(BuildContext context, WidgetRef ref, List tracks) {
    return Column(
      children: tracks.take(5).map((track) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              track.thumbnailUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: 56, height: 56, color: Colors.grey[800]),
            ),
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF9ca6ba)),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
          onTap: () => context.push('/player', extra: track),
        );
      }).toList(),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF111318).withOpacity(0.9),
          floating: true,
          pinned: true,
          title: const Text(
            'Home',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(24.0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Quick Picks Skeleton
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 150, height: 30, color: Colors.white10),
                  Container(width: 60, height: 20, color: Colors.white10),
                ],
              ),
              const SizedBox(height: 16),
              const HorizontalListSkeleton(),
              const SizedBox(height: 32),

              // Recently Added Skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 200, height: 30, color: Colors.white10),
                  Container(width: 60, height: 20, color: Colors.white10),
                ],
              ),
              const SizedBox(height: 16),
              const SongListSkeleton(itemCount: 8),
            ]),
          ),
        ),
      ],
    );
  }
}
