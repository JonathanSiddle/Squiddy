import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

class OctopusManager extends ChangeNotifier {
  var timeoutDuration = 90;
  var initialised = false;
  var errorGettingData = false;
  var timeoutError = false;
  DateTime Function() dateTimeFetcher = () => DateTime.now();

  String apiKey;
  OctopusEneryClient octopusEnergyClient;
  EnergyAccount account;
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
      @required String meter,
      void Function(EnergyAccount) updateAccountSettings}) async {
    initialised = false;
    errorGettingData = false;
    timeoutError = false;

    //get account details
    try {
      account = await octopusEnergyClient?.getAccountDetails(accountId, apiKey);
      if (updateAccountSettings != null) {
        updateAccountSettings(account);
      }
    } catch (_) {}

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

    if (monthConsumption == null || monthConsumption.length == 0) {
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
      {@required String tariffCode, @required bool onlyAfterDateTime}) async {
    List<AgilePrice> prices;

    if (tariffCode == null) return Future.error('Error - No tariffCode');

    try {
      prices = await octopusEnergyClient.getCurrentAgilePrices(
          tariffCode: tariffCode);
    } catch (_) {
      return Future.error('Error getting tariff data');
    }

    if (prices != null && onlyAfterDateTime) {
      prices.removeWhere((p) => p.validTo.isBefore(dateTimeFetcher()));
      prices.sort((a, b) => a.validFrom.compareTo(b.validFrom));
    }

    return prices;
  }
}
