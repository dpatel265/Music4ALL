// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'playback_context.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlaybackContextAdapter extends TypeAdapter<PlaybackContext> {
  @override
  final int typeId = 2;

  @override
  PlaybackContext read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlaybackContext(
      currentTrack: fields[0] as TrackModel?,
      queue: (fields[1] as List).cast<TrackModel>(),
      currentIndex: fields[2] as int,
      position: fields[3] as Duration,
      savedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PlaybackContext obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.currentTrack)
      ..writeByte(1)
      ..write(obj.queue)
      ..writeByte(2)
      ..write(obj.currentIndex)
      ..writeByte(3)
      ..write(obj.position)
      ..writeByte(4)
      ..write(obj.savedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaybackContextAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
