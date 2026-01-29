import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'main_layout.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/player/presentation/player_screen.dart';
import '../features/explore/presentation/explore_screen.dart';
import '../features/charts/presentation/charts_screen.dart';
import '../features/search/domain/track_model.dart';

class AppRouter {
  // Navigator Keys needed for ShellRoute to work independently
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation:
        '/explore', // Changed to Explore as per user request context
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const SearchScreen()),
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
    ],
  );
}
