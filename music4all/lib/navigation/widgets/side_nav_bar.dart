import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SideNavBar extends StatelessWidget {
  const SideNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Current route location (simplistic check, ideally use Riverpod/GoRouter state)
    // For simplicity, we'll just style them statically or use GoRouterState if we needed strict active states visually here.
    // However, GoRouter ShellRoute usually keeps state.
    // Let's rely on standard navigation for now.

    // Using GoRouter.of(context).location is deprecated/removed in v10+,
    // we can get location via GoRouterState in the shell wrapper, but passing it down is complex without provider.
    // For now we will just use standard buttons that navigate.

    return Container(
      width: 256,
      color: const Color(0xFF111318),
      child: Column(
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: const [
                Icon(
                  Icons.play_circle_filled,
                  color: Color(0xFF256af4),
                  size: 32,
                ),
                SizedBox(width: 8),
                Text(
                  'Music',
                  style: TextStyle(
                    color: Color(0xFF256af4),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'SplineSans', // Assuming font is set up, fallback defaults
                  ),
                ),
              ],
            ),
          ),

          // Navigation Links
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NavTile(
                    icon: Icons.home,
                    label: 'Home',
                    onTap: () => context.go('/'),
                    // Assuming '/' is Home, but wait, previous code had '/' as SearchScreen.
                    // We might need to adjust routes. Let's assume '/' is Explore or Home.
                    // Implementation plan said '/' -> SearchScreen previously.
                    // Let's map 'Explore' to '/explore'.
                  ),
                  _NavTile(
                    icon: Icons.explore,
                    label: 'Explore',
                    isActive: true,
                    onTap: () => context.go('/explore'),
                  ),
                  _NavTile(
                    icon: Icons.trending_up,
                    label: 'Charts',
                    onTap: () => context.go('/charts'),
                  ),
                  _NavTile(
                    icon: Icons.library_music,
                    label: 'Library',
                    onTap: () => context.go('/library'),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Divider(color: Color(0xFF282e39)),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'PLAYLISTS',
                      style: TextStyle(
                        color: Color(0xFF9ca6ba),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  _NavTile(
                    icon: Icons.add_box,
                    label: 'New Playlist',
                    onTap: () {},
                  ),
                  _NavTile(
                    icon: Icons.favorite,
                    label: 'Liked Songs',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.white : const Color(0xFF9ca6ba);
    final bgColor = isActive ? const Color(0xFF282e39) : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        hoverColor: const Color(0xFF282e39).withOpacity(0.5),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
