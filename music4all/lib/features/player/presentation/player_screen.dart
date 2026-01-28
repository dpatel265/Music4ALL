import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../logic/player_view_model.dart';
import '../../../core/providers.dart';
import 'package:audio_service/audio_service.dart'; // import for playbackState stream
import '../../library/presentation/library_view_model.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final TrackModel? track; // Passed from navigation

  const PlayerScreen({super.key, this.track});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.track != null) {
      _initialized = true;
      // Trigger load on first mount
      Future.microtask(() {
        ref.read(playerViewModelProvider.notifier).loadAndPlay(widget.track!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(playerViewModelProvider);
    final audioHandler = ref.read(audioHandlerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.black,
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Builder(builder: (context) {
              if (state is PlayerLoading) {
                return const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     CircularProgressIndicator(color: Colors.white),
                     SizedBox(height: 20),
                     Text("Loading Audio...", style: TextStyle(color: Colors.white70)),
                  ],
                );
              }

              if (state is PlayerError) {
                 return Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                     const SizedBox(height: 16),
                     Text("Error: ${state.message}", 
                       style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
                   ],
                 );
              }

              if (state is PlayerPlaying || (state is PlayerInitial && widget.track != null)) {
                 final displayTrack = (state is PlayerPlaying) ? state.track : widget.track!;
                 
                 return Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     // Artwork with Shadow
                     Container(
                       decoration: BoxDecoration(
                         borderRadius: BorderRadius.circular(20),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.black.withOpacity(0.5),
                             blurRadius: 20,
                             offset: const Offset(0, 10),
                           ),
                         ],
                       ),
                       child: ClipRRect(
                         borderRadius: BorderRadius.circular(20),
                         child: Image.network(
                           displayTrack.thumbnailUrl,
                           width: 280,
                           height: 280,
                           fit: BoxFit.cover,
                         ),
                       ),
                     ),
                     const SizedBox(height: 40),
                     
                     // Metadata
                     Text(
                       displayTrack.title,
                       style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                         color: Colors.white,
                         fontWeight: FontWeight.bold,
                       ),
                       textAlign: TextAlign.center,
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                     ),
                     const SizedBox(height: 12),
                     Text(
                       displayTrack.artist,
                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
                         color: Colors.white70,
                       ),
                       textAlign: TextAlign.center,
                     ),
                     const SizedBox(height: 60),

                     // Controls
                     StreamBuilder<PlaybackState>(
                       stream: audioHandler.playbackState,
                       builder: (context, snapshot) {
                         final playing = snapshot.data?.playing ?? false;
                         
                         return Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             // Favorite Button (Styled)
                             IconButton(
                               iconSize: 32,
                               icon: Icon(
                                 ref.watch(libraryViewModelProvider).favorites.any((t) => t.id == displayTrack.id)
                                     ? Icons.favorite
                                     : Icons.favorite_border,
                                 color: Colors.redAccent,
                               ),
                               onPressed: () {
                                 ref.read(playerViewModelProvider.notifier).toggleFavorite(displayTrack);
                               },
                             ),
                             const SizedBox(width: 32),
                             
                             // Play/Pause Button (Prominent)
                             Container(
                               decoration: const BoxDecoration(
                                 shape: BoxShape.circle,
                                 color: Colors.white,
                               ),
                               child: IconButton(
                                 iconSize: 48,
                                 color: Colors.black,
                                 icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                                 onPressed: () {
                                   if (playing) {
                                     audioHandler.pause();
                                   } else {
                                     audioHandler.play();
                                   }
                                 },
                               ),
                             ),
                           ],
                         );
                       },
                     ),
                   ],
                 );
              }

              return const Text("No track selected", style: TextStyle(color: Colors.white54));
            }),
          ),
        ),
      ),
    );
  }
}
