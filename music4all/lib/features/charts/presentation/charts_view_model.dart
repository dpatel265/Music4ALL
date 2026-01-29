import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../search/domain/track_model.dart';
import '../../../core/providers.dart';

abstract class ChartsState {}

class ChartsInitial extends ChartsState {}

class ChartsLoading extends ChartsState {}

class ChartsLoaded extends ChartsState {
  final List<TrackModel> tracks;
  ChartsLoaded(this.tracks);
}

class ChartsError extends ChartsState {
  final String message;
  ChartsError(this.message);
}

class ChartsViewModel extends Notifier<ChartsState> {
  @override
  ChartsState build() {
    // Ideally use FutureProvider, but Notifier gives more control.
    // Trigger load on build (careful with side effects).
    // Better to use microtask or just let UI call it?
    // Riverpod 2.0: build() can align with initial fetch.
    Future.microtask(() => loadCharts());
    return ChartsLoading();
  }

  Future<void> loadCharts() async {
    state = ChartsLoading();
    try {
      final repo = ref.read(youtubeRepositoryProvider);
      final tracks = await repo.getTrendingTracks();
      state = ChartsLoaded(tracks);
    } catch (e) {
      state = ChartsError(e.toString());
    }
  }
}

final chartsViewModelProvider = NotifierProvider<ChartsViewModel, ChartsState>(
  () => ChartsViewModel(),
);
