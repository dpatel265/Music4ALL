import 'package:hive_flutter/hive_flutter.dart';
import '../domain/local_track_model.dart';

class LocalLibraryRepository {
  static const String boxName = 'local_tracks';

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(LocalTrackAdapter());
    }
    await Hive.openBox<LocalTrack>(boxName);
  }

  Box<LocalTrack> get _box => Hive.box<LocalTrack>(boxName);

  List<LocalTrack> getAllTracks() {
    return _box.values.toList();
  }

  Future<void> addTrack(LocalTrack track) async {
    await _box.put(track.id, track);
  }

  Future<void> removeTrack(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
