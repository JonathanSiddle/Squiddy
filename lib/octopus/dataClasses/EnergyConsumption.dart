import 'package:hive/hive.dart';
import 'package:quiver/core.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

part 'EnergyConsumption.g.dart';

@HiveType(typeId: 1)
class EnergyConsumption implements Comparable {
  @HiveField(0)
  num consumption;
  @HiveField(1)
  DateTime intervalStart;
  @HiveField(2)
  DateTime intervalEnd;
  // @HiveField(3)
  // num price;

  String get id {
    return '${intervalStart.toString()}|${intervalEnd.toString()}';
  }

  EnergyConsumption({this.intervalStart, this.intervalEnd, this.consumption});

  EnergyConsumption.fromJson(Map<String, dynamic> json) {
    consumption = json['consumption'];
    intervalStart = octopusDateformat.parse(json['interval_start']);
    intervalEnd = octopusDateformat.parse(json['interval_end']);
  }

  bool operator ==(o) =>
      o is EnergyConsumption &&
      o.consumption == consumption &&
      o.intervalStart == intervalStart &&
      o.intervalEnd == intervalEnd;
  int get hashCode =>
      hash3(consumption.hashCode, intervalStart.hashCode, intervalEnd.hashCode);

  @override
  int compareTo(other) {
    int start = other.intervalStart.compareTo(intervalStart);

    return start != 0 ? start : other.intervalEnd.compareTo(intervalEnd);
  }
}
