// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      age: fields[2] as int,
      bio: fields[3] as String,
      location: fields[4] as String,
      interests: (fields[5] as List).cast<String>(),
      avatarEmoji: fields[6] as String,
      postsCount: fields[7] as int,
      followersCount: fields[8] as int,
      followingCount: fields[9] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.age)
      ..writeByte(3)
      ..write(obj.bio)
      ..writeByte(4)
      ..write(obj.location)
      ..writeByte(5)
      ..write(obj.interests)
      ..writeByte(6)
      ..write(obj.avatarEmoji)
      ..writeByte(7)
      ..write(obj.postsCount)
      ..writeByte(8)
      ..write(obj.followersCount)
      ..writeByte(9)
      ..write(obj.followingCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
