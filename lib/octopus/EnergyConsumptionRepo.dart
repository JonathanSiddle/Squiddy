import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:squiddy/octopus/dataClasses/EnergyConsumption.dart';

class EnergyConsumptionHiveRepo implements EnergyConsumptionRepo {
  final Box<EnergyConsumption> store;

  EnergyConsumptionHiveRepo({@required this.store});

  Set<EnergyConsumption> getAll() {
    return store.values.toSet();
  }

  save(EnergyConsumption consumption) {
    store.put(consumption.id, consumption);
  }

  saveAll(Iterable<EnergyConsumption> readings) {
    readings.forEach((ec) {
      store.put(ec.id, ec);
    });
  }
}

abstract class EnergyConsumptionRepo {
  Set<EnergyConsumption> getAll();
  save(EnergyConsumption consumption);
  saveAll(Iterable<EnergyConsumption> readings);
}
