import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/youtube_repository.dart';
import '../../domain/track_model.dart';
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

// Controller
class SearchViewModel extends StateNotifier<SearchState> {
  final YoutubeRepository _repository;

  SearchViewModel(this._repository) : super(SearchInitial());

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
final searchViewModelProvider = StateNotifierProvider<SearchViewModel, SearchState>((ref) {
  final repository = ref.watch(youtubeRepositoryProvider);
  return SearchViewModel(repository);
});
