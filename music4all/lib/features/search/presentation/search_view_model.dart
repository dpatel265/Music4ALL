import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/youtube_repository.dart';
import '../domain/track_model.dart';
import '../../../core/providers.dart';

// State classes
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<TrackModel> tracks;
  SearchLoaded(this.tracks);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

// Controller - migrated to Notifier for Riverpod 3.x
class SearchViewModel extends Notifier<SearchState> {
  @override
  SearchState build() => SearchInitial();

  YoutubeRepository get _repository => ref.read(youtubeRepositoryProvider);

  Future<void> search(String query) async {
    if (query.isEmpty) return;

    state = SearchLoading();
    try {
      final tracks = await _repository.search(query);
      state = SearchLoaded(tracks);
    } catch (e) {
      state = SearchError(e.toString());
    }
  }
}

// Provider
final searchViewModelProvider = NotifierProvider<SearchViewModel, SearchState>(
  () {
    return SearchViewModel();
  },
);
