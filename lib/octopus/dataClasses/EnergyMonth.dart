import 'package:squiddy/octopus/dataClasses/EnergyConsumption.dart';
import 'package:squiddy/octopus/dataClasses/EnergyDay.dart';

class EnergyMonth {
  DateTime begin;
  DateTime end;
  List<EnergyDay> days = [];

  EnergyMonth({this.begin, this.end, this.days}) {
    if (days == null) {
      days = [];
    }
  }

  List<EnergyConsumption> get consumption {
    return days
        .map((e) {
          return e.consumption.values.toList();
        })
        .toList()
        .expand((element) => element)
        .toList();
  }

  bool get missingReadings {
    return days.every((d) => d.validreading);
  }

  num get readings {
    num total = 0;

    for (var d in days) {
      var consumption = d.consumption;
      total += consumption.keys.length;
    }

    return total;
  }

  num get totalConsumption {
    num total = 0.0;

    for (var d in days) {
      var consumption = d.consumption;
      for (var c in consumption.keys) {
        var value = consumption[c];
        total += value.consumption;
      }
    }

    return total;
  }
}
