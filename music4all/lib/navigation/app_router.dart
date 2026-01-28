import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/player/presentation/player_screen.dart';
import '../features/search/domain/track_model.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/player',
        builder: (context, state) {
          final track = state.extra as TrackModel?;
          return PlayerScreen(track: track);
        },
      ),
    ],
  );
}
