import 'package:flutter/material.dart';

class ExploreChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color? activeColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const ExploreChip({
    super.key,
    required this.label,
    this.icon,
    this.activeColor,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Colors from design
    final bgDark = const Color(0xFF282e39);
    final textGrey = const Color(0xFF9ca6ba);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : bgDark,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.1))
              : Border(
                  left: activeColor != null
                      ? BorderSide(
                          color: Colors.transparent,
                          width: 4,
                        ) // Reserve space or handle hover
                      : BorderSide.none,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: isSelected ? Colors.white : textGrey),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String duration;
  final String artistImageUrl;

  const VideoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.duration,
    required this.artistImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thumbnail Container
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.music_note, color: Colors.white54),
                  ),
                ),
              ),
              // Hover overlay would go here in a web context with MouseRegion
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Meta row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(artistImageUrl),
              onBackgroundImageError: (context, error) {},
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9ca6ba), // text-grey
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ChartItem extends StatelessWidget {
  final int rank;
  final int change; // 0 = same, 1 = up, -1 = down
  final int changeValue;
  final String imageUrl;
  final String title;
  final String artist;
  final String album;
  final String duration;

  const ChartItem({
    super.key,
    required this.rank,
    required this.change,
    required this.changeValue,
    required this.imageUrl,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF282e39))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Icon(
                  change > 0
                      ? Icons.arrow_drop_up
                      : change < 0
                      ? Icons.arrow_drop_down
                      : Icons.remove,
                  color: change > 0
                      ? Colors.green
                      : change < 0
                      ? Colors.red
                      : Colors.grey,
                  size: 20,
                ),
                if (change != 0)
                  Text(
                    '$changeValue',
                    style: TextStyle(
                      color: change > 0 ? Colors.green : Colors.red,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              imageUrl,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9ca6ba),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Hidden on small screens if needed, but keeping for now
          SizedBox(
            width: 120,
            child: Text(
              album,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF9ca6ba), fontSize: 14),
            ),
          ),
          Text(
            duration,
            style: const TextStyle(
              color: Color(0xFF9ca6ba),
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.more_vert, color: Color(0xFF9ca6ba)),
        ],
      ),
    );
  }
}
