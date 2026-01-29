import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'search_view_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      // Defer the search to after the build
      Future.microtask(() => _performSearch());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    ref.read(searchViewModelProvider.notifier).search(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Music4All'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search songs, artists...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: const Color(0xFF282e39),
              ),
              onSubmitted: (_) => _performSearch(),
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state is SearchInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Search for your favorite music'),
          ],
        ),
      );
    } else if (state is SearchLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is SearchError) {
      return Center(child: Text('Error: ${state.message}'));
    } else if (state is SearchLoaded) {
      return ListView.separated(
        itemCount: state.tracks.length,
        separatorBuilder: (_, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final track = state.tracks[index];
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                track.thumbnailUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey[800],
                  child: const Icon(Icons.music_note),
                ),
              ),
            ),
            title: Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              track.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.playlist_add),
              onPressed: () {
                ref.read(searchViewModelProvider.notifier).addToQueue(track);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Added to Queue'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            onTap: () {
              // Navigate to player with the selected track
              // In a real app we'd pass the track object, but directly in GoRouter
              // params is string-only usually. We can pass state via 'extra'.
              context.push('/player', extra: track);
            },
          );
        },
      );
    }
    return const SizedBox.shrink();
  }
}
