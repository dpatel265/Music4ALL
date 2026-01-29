// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_track_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalTrackAdapter extends TypeAdapter<LocalTrack> {
  @override
  final int typeId = 1;

  @override
  LocalTrack read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalTrack(
      id: fields[0] as String,
      path: fields[1] as String,
      title: fields[2] as String,
      artist: fields[3] as String,
      album: fields[4] as String,
      durationMs: fields[5] as int,
      dateAdded: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LocalTrack obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.album)
      ..writeByte(5)
      ..write(obj.durationMs)
      ..writeByte(6)
      ..write(obj.dateAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalTrackAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
