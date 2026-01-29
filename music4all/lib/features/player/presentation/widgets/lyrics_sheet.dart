import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // For ScrollDirection
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../logic/lyrics_view_model.dart';
import '../../../search/domain/track_model.dart';

class LyricsSheet extends ConsumerStatefulWidget {
  final TrackModel track;

  const LyricsSheet({super.key, required this.track});

  @override
  ConsumerState<LyricsSheet> createState() => _LyricsSheetState();
}

class _LyricsSheetState extends ConsumerState<LyricsSheet> {
  final ScrollController _scrollController = ScrollController();
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    // Load lyrics when sheet opens
    Future.microtask(() {
      ref.read(lyricsViewModelProvider.notifier).loadLyrics(widget.track);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Listener for auto-scroll
  void _scrollToCurrentLine(int index) {
    if (_isUserScrolling) return;

    // Rough estimation: item height is dynamic, so exact scroll is hard without specific pkg.
    // However, we can try to center it if we assume average height or just ensure visible.
    // Better UX: Use scroll_to_index package, but I don't want to add deps if I can avoid it.
    // Let's try to animate to a rough position.
    // Actually, with standard ListView, ensuring visible is easiest.

    // A simple hack for centered lyrics:
    // If we use itemExtent, it's easy. But lyrics vary in length.
    // Let's just scroll to make sure it's in view for now.

    // Ideally we'd use ScrollablePositionedList. Since I can't easily add packages without user permission/restart?
    // Wait, I can add packages. `scrollable_positioned_list` is standard for this.
    // But let's try to build it without extra deps first to be safe.

    // We can't easily jump to index with standard List.
    // Alternative: Highlight is enough? No, we need auto-scroll.
    // Let's rely on the user scrolling or a very basic "scroll to bottom" style? No.
    // Let's try calculating offset based on index * approximate height (50px).

    if (_scrollController.hasClients) {
      double offset = index * 40.0; // Rough guess
      // Center it: offset - half screen height
      double height = _scrollController.position.viewportDimension;
      double target = offset - (height / 2) + 20;
      if (target < 0) target = 0;

      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lyricsViewModelProvider);

    // Listen for line changes to trigger scroll
    ref.listen(lyricsViewModelProvider.select((s) => s.currentLineIndex), (
      _,
      nextIndex,
    ) {
      if (nextIndex != -1) {
        _scrollToCurrentLine(nextIndex);
      }
    });

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        // We capture key events on the internal list, but we need the sheet's controller to drag.
        // Actually, we want the list to scroll, so we should merge controllers or just use the sheet's one?
        // DraggableScrollableSheet requires us to pass `scrollController` to the ListView.
        // BUT we also want to control it programmatically. This is tricky with DraggableSheet.
        // If we want auto-scroll, we might need our own controller attached to the list,
        // but then the sheet might not drag via the list.
        // Strategy: Use the sheet's controller for the UI, but we can't easily animate it content-aware.

        // Revised Strategy: Just a standard Full Screen Modal (showModalBottomSheet with isScrollControlled: true)
        // instead of DraggableScrollableSheet if we want precise control.
        // OR simply accept that auto-scroll might conflict with drag.

        // Let's use a standard Container in a showModalBottomSheet(isScrollControlled: true)
        // that takes up height, rather than DraggableScrollableSheet, for better control.
        // But the prompt asked for Draggable.

        // Let's stick to DraggableScrollableSheet but realize our programmatic scroll might be limited.
        // Actually, we can attach the provided `scrollController` to the ListView.
        // But we can't invoke `.animateTo` on it easily if we don't own it?
        // We CAN animate the provided controller!

        return Container(
          decoration: BoxDecoration(
            color: AppColors.background.withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 24),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    const Icon(Icons.lyrics, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Lyrics",
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            widget.track.title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (state.isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white54,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Content
              Expanded(
                child: state.error != null
                    ? Center(
                        child: Text(
                          state.error!,
                          style: const TextStyle(color: Colors.white54),
                        ),
                      )
                    : state.lyrics.isEmpty && !state.isLoading
                    ? const Center(
                        child: Text(
                          "No lyrics found",
                          style: TextStyle(color: Colors.white30),
                        ),
                      )
                    : NotificationListener<UserScrollNotification>(
                        onNotification: (notification) {
                          // If user touches, pause auto-scroll for a bit
                          if (notification.direction != ScrollDirection.idle) {
                            _isUserScrolling = true;
                            // Resume after delay?
                            Future.delayed(const Duration(seconds: 3), () {
                              if (mounted) _isUserScrolling = false;
                            });
                          }
                          return false;
                        },
                        child: ListView.builder(
                          controller:
                              scrollController, // Use the draggable controller
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 40,
                          ),
                          itemCount: state.lyrics.length,
                          itemBuilder: (context, index) {
                            final line = state.lyrics[index];
                            final isActive = index == state.currentLineIndex;

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.white38,
                                  fontSize: isActive ? 24 : 18,
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  height: 1.4,
                                ),
                                child: Text(
                                  line.text,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ).animate().slide(begin: const Offset(0, 0.1), curve: Curves.easeOut);
      },
    );
  }
}
