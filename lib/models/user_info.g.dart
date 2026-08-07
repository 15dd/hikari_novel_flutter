// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_info.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class user_info_adapter extends TypeAdapter<UserInfo> {
  @override
  final typeId = 0;

  @override
  UserInfo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return UserInfo(
      avatar: fields[0] as String,
      uid: fields[1] as String,
      username: fields[2] as String,
      userLevel: fields[3] as String,
      email: fields[4] as String,
      registerDate: fields[5] as String,
      contribution: fields[6] as String,
      experience: fields[7] as String,
      point: fields[8] as String,
      maxBookshelfNum: fields[9] as String,
      maxRecommendNum: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserInfo obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.avatar)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.userLevel)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.registerDate)
      ..writeByte(6)
      ..write(obj.contribution)
      ..writeByte(7)
      ..write(obj.experience)
      ..writeByte(8)
      ..write(obj.point)
      ..writeByte(9)
      ..write(obj.maxBookshelfNum)
      ..writeByte(10)
      ..write(obj.maxRecommendNum);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is user_info_adapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
