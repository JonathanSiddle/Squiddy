import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

class OctopusManager extends ChangeNotifier {
  var timeoutDuration = 90;
  var initialised = false;
  var errorGettingData = false;
  var timeoutError = false;
  var showAgilePrices = false;
  String agileTarrifCode;
  DateTime Function() dateTimeFetcher = () => DateTime.now();

  String apiKey;
  OctopusEneryClient octopusEnergyClient;
  List<EnergyMonth> monthConsumption = List();

  OctopusManager(
      {this.octopusEnergyClient,
      this.timeoutDuration,
      DateTime Function() inDateTimeFetcher}) {
    if (octopusEnergyClient == null) {
      octopusEnergyClient = OctopusEneryClient();
    }

    if (timeoutDuration == null) {
      timeoutDuration = 90;
    }

    if (inDateTimeFetcher != null) {
      this.dateTimeFetcher = inDateTimeFetcher;
    }
  }

  Future<void> initData(
      {@required String apiKey,
      @required String accountId,
      @required String meterPoint,
      @required String meter}) async {
    initialised = false;
    errorGettingData = false;
    timeoutError = false;

    try {
      print('Initing data');
      monthConsumption = await octopusEnergyClient
          .getConsumtion(apiKey, meterPoint, meter)
          .timeout(Duration(seconds: timeoutDuration));
    } on TimeoutException catch (_) {
      timeoutError = true;
    } catch (_) {
      print('Uh error getting data');
    }

    if (monthConsumption == null) {
      errorGettingData = true;
    } else {
      initialised = true;
    }

    // await Future.delayed(
    //     const Duration(seconds: 5), () => print("Finished delay"));

    notifyListeners();
    // return 'Got data';
  }

  Future<EnergyAccount> getAccountDetails(
      String accountId, String apiKey) async {
    return await octopusEnergyClient.getAccountDetails(accountId, apiKey);
  }

  Future<List<EnergyConsumption>> getConsumptionLast30Days(
      String apiKey, String meterPoint, String meter) async {
    return await octopusEnergyClient
        .getConsumptionLast30Days(apiKey, meterPoint, meter)
        .timeout(Duration(seconds: timeoutDuration));
  }

  retryLogin() {
    monthConsumption = null;
    initialised = false;
    errorGettingData = false;
    timeoutError = false;
    notifyListeners();
  }

  resetState() {
    initialised = false;
    monthConsumption = List();

    notifyListeners();
  }

  Future<List<AgilePrice>> getAgilePrices(
      {@required String tarrifCode, @required bool onlyAfterDateTime}) async {
    List<AgilePrice> prices;

    if (tarrifCode != null) {
      prices = await octopusEnergyClient.getCurrentAgilePrices(
          tarrifCode: tarrifCode);

      if (prices != null && onlyAfterDateTime) {
        prices.removeWhere((p) => p.validTo.isBefore(dateTimeFetcher()));
        prices.sort((a, b) => a.validFrom.compareTo(b.validFrom));
      }
    }

    return prices;
  }
}
