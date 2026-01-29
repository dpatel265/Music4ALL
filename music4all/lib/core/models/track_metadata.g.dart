// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_metadata.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrackMetadataAdapter extends TypeAdapter<TrackMetadata> {
  @override
  final int typeId = 1;

  @override
  TrackMetadata read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrackMetadata(
      trackId: fields[0] as String,
      playCount: fields[1] as int,
      lastPlayedAt: fields[2] as DateTime?,
      lastPosition: fields[3] as Duration?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackMetadata obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.trackId)
      ..writeByte(1)
      ..write(obj.playCount)
      ..writeByte(2)
      ..write(obj.lastPlayedAt)
      ..writeByte(3)
      ..write(obj.lastPosition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrackMetadataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
