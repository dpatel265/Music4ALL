import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'widgets/side_nav_bar.dart';
import 'widgets/mini_player.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive Breakpoint
          final bool isDesktop = constraints.maxWidth > 768;

          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Sidebar (Desktop only)
                    if (isDesktop) const SideNavBar(),

                    // Main Content
                    Expanded(child: child),
                  ],
                ),
              ),

              // Mini Player (Persistent playback surface)
              const MiniPlayer(),

              // Bottom Navigation Bar (Mobile only)
              // Note: The design had sidebar for desktop. For mobile, usually a BottomNav is used.
              // The design `code.html` was desktop-first but showed mobile hidden classes.
              // Let's implement a basic BottomNavigationBar for mobile if not desktop.
              if (!isDesktop)
                BottomNavigationBar(
                  backgroundColor: const Color(0xFF111318),
                  selectedItemColor: Colors.white,
                  unselectedItemColor: const Color(0xFF9ca6ba),
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _calculateSelectedIndex(context),
                  onTap: (int idx) => _onItemTapped(idx, context),
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.explore),
                      label: 'Explore',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.search),
                      label: 'Search',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.library_music),
                      label: 'Library',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profile',
                    ),
                  ],
                ),
            ],
          );
        },
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
