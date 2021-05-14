import 'package:squiddy/octopus/dataClasses/AgilePrice.dart';
import 'package:squiddy/octopus/dataClasses/EnergyConsumption.dart';

class EnergyDay {
  DateTime date;
  var consumption = Map<String, EnergyConsumption>();
  var prices = Map<String, AgilePrice>();

  EnergyDay({this.date, this.consumption}) {
    if (consumption == null) {
      consumption = Map<String, EnergyConsumption>();
    }
  }

  Map<String, num> getConsumptionByHour() {
    var returnData = Map<String, num>();

    for (String k in consumption.keys) {
      var keyValue = consumption[k];
      var splitKey = k.split(':')[0];

      var returnDataVal = returnData[splitKey];
      if (returnDataVal != null) {
        returnData[splitKey] = (returnDataVal + keyValue.consumption);
      } else {
        returnData[splitKey] = keyValue.consumption;
      }
    }

    return returnData;
  }

  bool get validreading => !(consumption.length < 46);
  bool get validPrice => !(prices.length < 46);

  num get totalCostIncVat {
    var total = 0.0;

    for (var c in consumption.keys) {
      var value = consumption[c];
      var price = prices[c];

      if (price != null) {
        total += value.consumption * price.valueIncVat;
      }
    }

    return total;
  }

  num get totalConsumption {
    var total = 0.0;

    for (var c in consumption.keys) {
      var value = consumption[c];
      total += value.consumption;
    }

    return total;
  }

  addConsumption(String time, EnergyConsumption con) {
    consumption[time] = con;
  }

  addPrice(String time, AgilePrice price) {
    if (price != null) {
      prices[time] = price;
    }
  }
}
