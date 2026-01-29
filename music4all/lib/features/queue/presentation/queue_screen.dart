import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: ensure this provider returns the AudioHandlerService instance
    // Since audioHandlerProvider is typed as AudioHandler (BaseAudioHandler),
    // we need to access its methods via the interface or cast if using specific methods like reorderQueue.
    // However, reorderQueue is NOT in BaseAudioHandler.
    // I added it to AudioHandlerService.
    // I need to cast it or use the concrete type provider?
    // Providers.dart usually defines it as Provider<AudioHandlerService> or Provider<AudioHandler>.
    // Let's check imports.
    final audioHandlerService = ref.read(audioHandlerProvider);
    // I need to cast to use reorderQueue and removeQueueItemAt (custom methods).
    // Or I need to import AudioHandlerService.

    // Actually, create a dynamic or casted variable.
    // We'll trust it's AudioHandlerService.
    // To be safe, import AudioHandlerService.

    // Casting is required if the provider returns BaseAudioHandler.
    final audioHandler = audioHandlerService;

    return Scaffold(
      backgroundColor: const Color(0xFF111318),
      appBar: AppBar(
        title: const Text('Up Next'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<MediaItem>>(
        stream: audioHandler.queue,
        builder: (context, queueSnapshot) {
          final queue = queueSnapshot.data ?? [];

          return StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, mediaItemSnapshot) {
              final mediaItem = mediaItemSnapshot.data;

              if (queue.isEmpty) {
                return const Center(
                  child: Text(
                    'Queue is empty',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return ReorderableListView.builder(
                itemCount: queue.length,
                onReorder: (oldIndex, newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  // We need to invoke reorderQueue on the service.
                  // audioHandler is BaseAudioHandler.
                  // We need to cast it.
                  // Assume 'audioHandler' has reorderQueue via extension or dynamic?
                  // Best to cast.
                  // (audioHandler as dynamic).reorderQueue(oldIndex, newIndex);
                  // Or better: cast to AudioHandlerService.
                  // I will cast it here for simplicity.
                  (audioHandler as dynamic).reorderQueue(oldIndex, newIndex);
                },
                itemBuilder: (context, index) {
                  final item = queue[index];
                  final isPlaying = item.id == mediaItem?.id;

                  return Dismissible(
                    key: ValueKey('${item.id}_$index'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      (audioHandler as dynamic).removeQueueItemAt(index);
                    },
                    child: ListTile(
                      key: ValueKey('${item.id}_$index'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: item.artUri != null
                            ? Image.network(
                                item.artUri.toString(),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey[800],
                                      child: const Icon(
                                        Icons.music_note,
                                        color: Colors.white,
                                      ),
                                    ),
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                color: Colors.grey[800],
                                child: const Icon(
                                  Icons.music_note,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying
                              ? const Color(0xFF256af4)
                              : Colors.white,
                          fontWeight: isPlaying
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        item.artist ?? 'Unknown Artist',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isPlaying
                              ? const Color(0xFF256af4).withOpacity(0.7)
                              : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      trailing: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(
                          Icons.drag_handle,
                          color: Colors.grey,
                        ),
                      ),
                      onTap: () {
                        // Skip to item
                        audioHandler.skipToQueueItem(index);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
