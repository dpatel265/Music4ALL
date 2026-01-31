import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../logic/lyrics_view_model.dart';
import '../../../../core/theme/app_colors.dart';

class SyncedLyricsView extends ConsumerStatefulWidget {
  final VoidCallback onTap;

  const SyncedLyricsView({super.key, required this.onTap});

  @override
  ConsumerState<SyncedLyricsView> createState() => _SyncedLyricsViewState();
}

class _SyncedLyricsViewState extends ConsumerState<SyncedLyricsView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  bool _userIsScrolling = false;

  @override
  Widget build(BuildContext context) {
    final lyricsState = ref.watch(lyricsViewModelProvider);

    // Listen for line updates to auto-scroll
    ref.listen(lyricsViewModelProvider.select((s) => s.currentLineIndex), (
      _,
      nextIndex,
    ) {
      if (!_userIsScrolling &&
          nextIndex >= 0 &&
          nextIndex < lyricsState.lyrics.length) {
        _scrollToIndex(nextIndex);
      }
    });

    if (lyricsState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (lyricsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lyrics_outlined, size: 48, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              "No lyrics available",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 16,
              ),
            ),
            if (kDebugMode)
              Text(
                lyricsState.error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
          ],
        ),
      );
    }

    if (lyricsState.lyrics.isEmpty) {
      return Center(
        child: Text(
          "Searching for lyrics...",
          style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 16),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: ShaderMask(
        shaderCallback: (rect) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black,
              Colors.black,
              Colors.transparent,
            ],
            stops: [0.0, 0.1, 0.8, 1.0],
          ).createShader(rect);
        },
        blendMode: BlendMode.dstIn,
        child: ScrollablePositionedList.builder(
          itemCount: lyricsState.lyrics.length,
          itemScrollController: _itemScrollController,
          itemPositionsListener: _itemPositionsListener,
          padding: const EdgeInsets.symmetric(
            vertical: 400,
            horizontal: 24,
          ), // Large padding for center focus
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final isCurrent = index == lyricsState.currentLineIndex;
            final line = lyricsState.lyrics[index];

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(bottom: 24),
              child:
                  Text(
                        line.text,
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          fontSize: isCurrent ? 28 : 22,
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.left,
                      )
                      .animate(target: isCurrent ? 1 : 0)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1.0, 1.0),
                      ),
            );
          },
        ),
      ),
    );
  }

  void _scrollToIndex(int index) {
    if (_itemScrollController.isAttached) {
      _itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment:
            0.3, // Position line at 30% from top (simulating Apple Music center-ish)
      );
    }
  }
}
