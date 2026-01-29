import 'package:flutter/material.dart';

class BottomPlayerBar extends StatelessWidget {
  const BottomPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF1e222a),
        border: Border(top: BorderSide(color: Color(0xFF282e39))),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Progress Bar (Absolute Top)
          Positioned(
            top: -2,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                value: 0.33,
                backgroundColor: const Color(0xFF282e39),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF256af4),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;

                if (isMobile) {
                  return Row(
                    children: [
                      // Track Info
                      Expanded(
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuCw8InX1lEGXo3QfRW3J-IgtRfLhtGyYjK6uqh8rVGnxtwFsIjldVg4BeIqdvtYlVawFebVr1HvqBx9vsEB_eXuQ8HS-XI6PfEunicJ-fkphWtNkgG4P-KI34XaLvz7lIY177Q4BWwY9LHNxth6m9-7cb2rZpg1rApxFC1_0Nu2kb5rMzccf57LD6cNOQyKw_D7FYysYs8SKii4A-NZ6hBRBEozePq0e5d6T_Ov1Z1nmT8XlQD4vOh9FKtMUE7qopF1ejSrzF6tbj-y',
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: ColoredBox(color: Colors.grey),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Late Night Talking',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Harry Styles',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Color(0xFF9ca6ba),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Controls
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border),
                            color: const Color(0xFF9ca6ba),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow),
                            color: Colors.white,
                            iconSize: 32,
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    // Track Info
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuCw8InX1lEGXo3QfRW3J-IgtRfLhtGyYjK6uqh8rVGnxtwFsIjldVg4BeIqdvtYlVawFebVr1HvqBx9vsEB_eXuQ8HS-XI6PfEunicJ-fkphWtNkgG4P-KI34XaLvz7lIY177Q4BWwY9LHNxth6m9-7cb2rZpg1rApxFC1_0Nu2kb5rMzccf57LD6cNOQyKw_D7FYysYs8SKii4A-NZ6hBRBEozePq0e5d6T_Ov1Z1nmT8XlQD4vOh9FKtMUE7qopF1ejSrzF6tbj-y',
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    width: 56,
                                    height: 56,
                                    child: ColoredBox(color: Colors.grey),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Late Night Talking',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  'Harry Styles',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Color(0xFF9ca6ba),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.favorite_border),
                            color: const Color(0xFF9ca6ba),
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),

                    // Controls (Center)
                    Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.shuffle),
                            color: const Color(0xFF9ca6ba),
                            iconSize: 20,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.skip_previous),
                            color: Colors.white,
                            iconSize: 28,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.play_arrow),
                              color: Colors.black,
                              iconSize: 28,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.skip_next),
                            color: Colors.white,
                            iconSize: 28,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.repeat),
                            color: const Color(0xFF9ca6ba),
                            iconSize: 20,
                          ),
                        ],
                      ),
                    ),

                    // Volume & Tools (Right)
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.lyrics),
                            color: const Color(0xFF9ca6ba),
                            iconSize: 20,
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.devices),
                            color: const Color(0xFF9ca6ba),
                            iconSize: 20,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.volume_up,
                                color: Color(0xFF9ca6ba),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 80,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF282e39),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: 0.7,
                                  child: Container(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
