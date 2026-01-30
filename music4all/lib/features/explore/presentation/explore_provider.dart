import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../../../core/providers.dart';
import '../../search/domain/track_model.dart';
import '../../search/data/youtube_repository.dart';

class ExploreState {
  final bool isLoading;
  final String? selectedMood;
  final List<TrackModel> newMusic;
  final List<TrackModel> topCharts;
  final List<dynamic> recommendedAlbums;
  final List<TrackModel> moodTracks;

  ExploreState({
    required this.isLoading,
    this.selectedMood,
    required this.newMusic,
    required this.topCharts,
    required this.recommendedAlbums,
    required this.moodTracks,
  });

  factory ExploreState.initial() {
    return ExploreState(
      isLoading: true,
      newMusic: [],
      topCharts: [],
      recommendedAlbums: [],
      moodTracks: [],
    );
  }

  ExploreState copyWith({
    bool? isLoading,
    String? selectedMood,
    List<TrackModel>? newMusic,
    List<TrackModel>? topCharts,
    List<dynamic>? recommendedAlbums,
    List<TrackModel>? moodTracks,
  }) {
    return ExploreState(
      isLoading: isLoading ?? this.isLoading,
      selectedMood: selectedMood, // Allow null to clear
      newMusic: newMusic ?? this.newMusic,
      topCharts: topCharts ?? this.topCharts,
      recommendedAlbums: recommendedAlbums ?? this.recommendedAlbums,
      moodTracks: moodTracks ?? this.moodTracks,
    );
  }
}

class ExploreViewModel extends Notifier<ExploreState> {
  YoutubeRepository get _repository => ref.read(youtubeRepositoryProvider);

  @override
  ExploreState build() {
    _loadInitialData();
    return ExploreState.initial();
  }

  Future<void> _loadInitialData() async {
    try {
      // Fetch data independently so one failure doesn't break everything
      List<TrackModel> newMusic = [];
      try {
        newMusic = await _repository.search('New Music Videos');
      } catch (e) {
        debugPrint('ExploreProvider: Failed newMusic: $e');
      }

      List<TrackModel> topCharts = [];
      try {
        topCharts = await _repository.getTrendingTracks();
      } catch (e) {
        debugPrint('ExploreProvider: Failed topCharts: $e');
      }

      List<dynamic> albums = [];
      try {
        albums = await _repository.searchPlaylists('Full Album Music');
      } catch (e) {
        debugPrint('ExploreProvider: Failed albums: $e');
      }

      state = state.copyWith(
        isLoading: false,
        newMusic: newMusic,
        topCharts: topCharts.take(10).toList(),
        recommendedAlbums: albums,
      );
    } catch (e) {
      debugPrint('ExploreProvider: Critical Error in loadInitialData: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> selectMood(String mood) async {
    if (state.selectedMood == mood) {
      // Deselect
      state = state.copyWith(selectedMood: null, moodTracks: []);
      return;
    }

    state = state.copyWith(selectedMood: mood, isLoading: true);

    final tracks = await _repository.getMoodTracks(mood);

    state = state.copyWith(
      isLoading: false,
      selectedMood: mood,
      moodTracks: tracks,
    );
  }
}

final exploreProvider = NotifierProvider<ExploreViewModel, ExploreState>(() {
  return ExploreViewModel();
});
