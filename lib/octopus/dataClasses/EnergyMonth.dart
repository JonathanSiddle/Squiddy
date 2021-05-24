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

  DateTime get latestReadingDate {
    var lastDay = days?.last;

    if (lastDay != null) {
      return DateTime(lastDay.date.year, lastDay.date.day, 00, 00);
    }

    return null;
  }

  bool get missingReadings {
    return days.every((d) => d.validreading);
  }

  bool get missingPrices {
    return days.any((d) => d?.inValidPrice);
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

  num get totalPrice {
    num total = 0.0;

    for (var d in days) {
      if (d.totalCostIncVat != null) {
        total += d.totalCostIncVat;
      }
    }

    return total;
  }

  num get totalPricePounds {
    num total = totalPrice;

    return num.parse(total.toStringAsFixed(2)) / 100;
  }
}
