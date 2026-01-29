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

class AppRouter {
  // Navigator Keys needed for ShellRoute to work independently
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/', // Home is now the default
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
        ],
      ),
      // Fullscreen Player Route (outside shell if we want it to cover everything,
      // or inside if we want it to be part of content. Usually full screen player covers everything)
      GoRoute(
        path: '/player',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final track = state.extra as TrackModel?;
          return MaterialPage(
            fullscreenDialog: true,
            child: PlayerScreen(track: track),
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
