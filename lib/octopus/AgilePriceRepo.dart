import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:squiddy/octopus/dataClasses/AgilePrice.dart';

class AgilePriceHiveRepo implements AgilePriceRepo {
  final Box<AgilePrice> store;

  AgilePriceHiveRepo({@required this.store});

  @override
  Set<AgilePrice> getAll() {
    return store.values.toSet();
  }

  @override
  Set<AgilePrice> getCurrentAndFuturePrices(DateTime currentTime) {
    return store.values
        .toSet()
        .where((price) => price.validTo.isAfter(currentTime))
        .toSet();
  }

  @override
  save(AgilePrice price) {
    store.put(price.id, price);
  }

  @override
  saveAll(Iterable<AgilePrice> prices) {
    prices.forEach((p) {
      store.put(p.id, p);
    });
  }
}

abstract class AgilePriceRepo {
  Set<AgilePrice> getAll();
  Set<AgilePrice> getCurrentAndFuturePrices(DateTime currentTime);
  save(AgilePrice price);
  saveAll(Iterable<AgilePrice> prices);
}
