// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'EnergyConsumption.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EnergyConsumptionAdapter extends TypeAdapter<EnergyConsumption> {
  @override
  final int typeId = 1;

  @override
  EnergyConsumption read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EnergyConsumption(
      intervalStart: fields[1] as DateTime,
      intervalEnd: fields[2] as DateTime,
      consumption: fields[0] as num,
    )..price = fields[3] as num;
  }

  @override
  void write(BinaryWriter writer, EnergyConsumption obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.consumption)
      ..writeByte(1)
      ..write(obj.intervalStart)
      ..writeByte(2)
      ..write(obj.intervalEnd)
      ..writeByte(3)
      ..write(obj.price);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnergyConsumptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
