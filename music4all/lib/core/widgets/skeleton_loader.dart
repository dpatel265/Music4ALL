import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class SkeletonContainer extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class SongListSkeleton extends StatelessWidget {
  final int itemCount;

  const SongListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              // Thumbnail
              const SkeletonContainer(
                width: 50,
                height: 50,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const SkeletonContainer(width: 200, height: 16),
                    const SizedBox(height: 8),
                    // Artist
                    const SkeletonContainer(width: 120, height: 12),
                  ],
                ),
              ),
              // More Icon placeholder
              const SizedBox(width: 16),
              const SkeletonContainer(width: 24, height: 24),
            ],
          ),
        );
      },
    );
  }
}

class AlbumCardSkeleton extends StatelessWidget {
  const AlbumCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Album Art
          const SkeletonContainer(
            width: 140,
            height: 140,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          const SizedBox(height: 8),
          // Title
          const SkeletonContainer(width: 120, height: 14),
          const SizedBox(height: 4),
          // Subtitle
          const SkeletonContainer(width: 80, height: 12),
        ],
      ),
    );
  }
}

class HorizontalListSkeleton extends StatelessWidget {
  const HorizontalListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        itemBuilder: (context, index) {
          return const AlbumCardSkeleton();
        },
      ),
    );
  }
}
