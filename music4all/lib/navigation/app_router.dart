import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main_layout.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/player/presentation/player_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/charts/presentation/charts_screen.dart';
import '../features/albums/presentation/album_detail_screen.dart';
import '../features/playlists/presentation/playlist_detail_screen.dart';
import '../features/search/domain/track_model.dart';
import '../features/playlists/domain/playlist_model.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

class AppRouter {
  // Navigator Keys needed for ShellRoute to work independently
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/', // Home is now the default
    debugLogDiagnostics: true, // Enable GoRouter debug logging
    observers: [_NavigationObserver()], // Add navigation observer
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/search',
            builder: (context, state) {
              final query = state.uri.queryParameters['q'];
              return SearchScreen(initialQuery: query);
            },
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: '/library',
            builder: (context, state) => const LibraryScreen(),
          ),
          GoRoute(
            path: '/charts',
            builder: (context, state) => const ChartsScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      // Fullscreen Player Route (outside shell if we want it to cover everything,
      // or inside if we want it to be part of content. Usually full screen player covers everything)
      GoRoute(
        path: '/player',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          // Extra can be TrackModel directly or a Map with track and sourceLocation
          TrackModel? track;
          String? sourceLocation;

          if (state.extra is TrackModel) {
            track = state.extra as TrackModel;
          } else if (state.extra is Map) {
            final data = state.extra as Map;
            track = data['track'] as TrackModel?;
            sourceLocation = data['sourceLocation'] as String?;
          }

          return MaterialPage(
            fullscreenDialog: true,
            child: PlayerScreen(track: track, sourceLocation: sourceLocation),
          );
        },
      ),
      // Album Detail Route
      GoRoute(
        path: '/album',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final album = state.extra as PlaylistModel;
          return MaterialPage(
            fullscreenDialog: true,
            child: AlbumDetailScreen(album: album),
          );
        },
      ),
      // Playlist Detail Route
      GoRoute(
        path: '/playlist/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlaylistDetailScreen(playlistId: id);
        },
      ),
    ],
  );
}

/// Custom navigation observer for debugging
class _NavigationObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('=== NAVIGATION: PUSH ===');
    print('New route: ${route.settings.name}');
    print('Previous route: ${previousRoute?.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('=== NAVIGATION: POP ===');
    print('Popped route: ${route.settings.name}');
    print('New current route: ${previousRoute?.settings.name}');
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    print('=== NAVIGATION: REMOVE ===');
    print('Removed route: ${route.settings.name}');
    print('Previous route: ${previousRoute?.settings.name}');
    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    print('=== NAVIGATION: REPLACE ===');
    print('Old route: ${oldRoute?.settings.name}');
    print('New route: ${newRoute?.settings.name}');
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}
