import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'widgets/side_nav_bar.dart';
import 'widgets/mini_player.dart';
import '../features/player/presentation/player_expanded_provider.dart';
import '../features/player/presentation/fullscreen_player.dart';
import '../core/providers.dart';
import '../features/search/domain/track_model.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch expansion state
    final isExpanded = ref.watch(playerExpandedProvider);
    final screenSize = MediaQuery.of(context).size;
    // Calculate effective bottom nav height including safe area
    final bottomNavHeight =
        kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;

    // Get current track for Fullscreen Player
    final mediaItemAsync = ref.watch(currentMediaItemProvider);
    final mediaItem = mediaItemAsync.value;

    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      body: Stack(
        children: [
          // Layer 0: Main App Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: (mediaItem != null ? 64 : 0) + bottomNavHeight,
              ),
              child: Row(
                children: [
                  if (screenSize.width > 768) const SideNavBar(),
                  Expanded(child: child),
                ],
              ),
            ),
          ),

          // Layer 1: Mini Player
          if (!isExpanded && mediaItem != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomNavHeight,
              child: const MiniPlayer(),
            ),

          // Layer 2: Bottom Navigation Bar (Mobile Only)
          if (screenSize.width <= 768)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomNavBar(
                selectedIndex: _calculateSelectedIndex(context),
                onTap: (idx) => _onItemTapped(idx, context),
              ),
            ),

          // Layer 2: Fullscreen Player
          // Animated Positioned for slide-up effect
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            top: isExpanded ? 0 : screenSize.height,
            bottom: isExpanded ? 0 : -screenSize.height,
            left: 0,
            right: 0,
            child: mediaItem != null
                ? AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                    opacity: isExpanded ? 1.0 : 0.0,
                    child: FullscreenPlayer(
                      track: TrackModel(
                        id: mediaItem.id,
                        title: mediaItem.title,
                        artist: mediaItem.artist ?? 'Unknown',
                        thumbnailUrl: mediaItem.artUri.toString(),
                      ),
                      onDismiss: () {
                        ref
                            .read(playerExpandedProvider.notifier)
                            .setExpanded(false);
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/search')) return 2;
    if (location.startsWith('/library')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/search');
        break;
      case 3:
        context.go('/library');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }
}

class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const _BottomNavBar({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF111318),
      selectedItemColor: Colors.white,
      unselectedItemColor: const Color(0xFF9ca6ba),
      type: BottomNavigationBarType.fixed,
      currentIndex: selectedIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(
          icon: Icon(Icons.library_music),
          label: 'Library',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
