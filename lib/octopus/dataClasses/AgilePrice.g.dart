// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AgilePrice.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AgilePriceAdapter extends TypeAdapter<AgilePrice> {
  @override
  final int typeId = 2;

  @override
  AgilePrice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AgilePrice(
      validFrom: fields[0] as DateTime,
      validTo: fields[1] as DateTime,
      valueExcVat: fields[2] as double,
      valueIncVat: fields[3] as double,
    );
  }

  @override
  void write(BinaryWriter writer, AgilePrice obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.validFrom)
      ..writeByte(1)
      ..write(obj.validTo)
      ..writeByte(2)
      ..write(obj.valueExcVat)
      ..writeByte(3)
      ..write(obj.valueIncVat);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgilePriceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
