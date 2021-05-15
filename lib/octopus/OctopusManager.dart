import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:squiddy/octopus/AgilePriceRepo.dart';
import 'package:squiddy/octopus/EnergyConsumptionRepo.dart';
import 'package:squiddy/octopus/dataClasses/AgilePrice.dart';
import 'package:squiddy/octopus/dataClasses/ElectricityAccount.dart';
import 'package:squiddy/octopus/dataClasses/EnergyConsumption.dart';
import 'package:squiddy/octopus/dataClasses/EnergyMonth.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

class OctopusManager extends ChangeNotifier {
  final EnergyConsumptionRepo readingRepo;
  final AgilePriceRepo priceRepo;
  var timeoutDuration = 90;
  var initialised = false;
  var loadingData = false;
  var errorGettingData = false;
  var timeoutError = false;
  DateTime Function() dateTimeFetcher = () => DateTime.now();
  bool logErrors = false;
  SquiddyLogger logger;

  String apiKey;
  OctopusEneryClient octopusEnergyClient;
  EnergyAccount account;
  var consumption = SplayTreeSet<EnergyConsumption>();
  var prices = SplayTreeSet<AgilePrice>();
  // List<EnergyMonth> monthConsumption = [];

  OctopusManager(
      {this.readingRepo,
      this.priceRepo,
      this.octopusEnergyClient,
      this.timeoutDuration,
      DateTime Function() inDateTimeFetcher,
      this.logErrors = false,
      this.logger}) {
    if (octopusEnergyClient == null) {
      octopusEnergyClient = OctopusEneryClient();
    }

    if (timeoutDuration == null) {
      timeoutDuration = 90;
    }

    if (inDateTimeFetcher != null) {
      this.dateTimeFetcher = inDateTimeFetcher;
    }

    if (logErrors && logger == null) {
      logger = DefaultLogger();
    }
  }

  List<EnergyMonth> get monthConsumption {
    var consList = consumption.toList();
    var m = OctopusEneryClient.getEnergyMonthsFromConsumption(consList,
        prices: prices.toList());
    return m.reversed.toList();
  }

  List<AgilePrice> get currentAgilePrices {
    var currentDateTime = dateTimeFetcher();
    var temp = prices.where((p) => p.validTo.isAfter(currentDateTime)).toList();
    return temp.reversed.toList();
  }

  Future<void> initData(
      {@required String apiKey,
      @required String accountId,
      @required String meterPoint,
      @required String meter,
      @required String activeAgileTariff,
      void Function(EnergyAccount) updateAccountSettings,
      DateTime Function() currentDateFetcher =
          DefaultCurrentDateTimeFetcher}) async {
    loadingData = true;
    initialised = false;
    errorGettingData = false;
    timeoutError = false;

    //get account details
    try {
      account = await octopusEnergyClient?.getAccountDetails(accountId, apiKey);
      if (updateAccountSettings != null) {
        updateAccountSettings(account);
      }
    } catch (exception, stackTrace) {
      logger.logError(exception, stackTrace);
    }

    //get any locally stored readings
    var readings = readingRepo.getAll();
    consumption.addAll(readings);
    //convert to months to make checking for
    //missing readings easier
    var monthsCache = monthConsumption;

    try {
      print('Initing data');
      //get consumption for previous day
      // var date = DateTime(2021, 5, 01, 00, 00, 00);
      // var date2 = DateTime(2021, 5, 01 - 1, 00, 00, 00);
      var currentDate = currentDateFetcher();
      //some days in the current month to get data for
      //if the first day of the month, can just get previous results
      if (currentDate.day > 1) {
        var currentMonthCache = monthsCache.firstWhere(
            (em) =>
                em.begin.year == currentDate.year &&
                em.begin.month == currentDate.month,
            orElse: () => null);
        var latestDate =
            DateTime(currentDate.year, currentDate.month, 1, 00, 00);

        if (currentMonthCache != null) {
          var latestRadingDate = currentMonthCache.latestReadingDate;
          if (latestRadingDate != null) {
            latestDate = latestDate;
          }
        }

        // get consumption from the current day to the very start of the current month
        var data = await octopusEnergyClient
            .getConsumtion(apiKey, meterPoint, meter, periodFrom: latestDate)
            .timeout(Duration(seconds: timeoutDuration));

        // var pricingData = await octopusEnergyClient.getCurrentAgilePrices(
        //     tariffCode: tariffCode);

        consumption.addAll(data);
        readingRepo.saveAll(data);

        initialised = true;
        notifyListeners();
      } else {
        //already have local data
        initialised = true;
        notifyListeners();
      }

      // //*****get data for months */
      bool stillHaveData = true;
      while (stillHaveData) {
        print('Getting month data');
        stillHaveData = false;

        var endOfLastMonth =
            DateTime(currentDate.year, currentDate.month, 0, 00, 00);
        var beginningOfLastMonth =
            DateTime(endOfLastMonth.year, endOfLastMonth.month, 1, 00, 00);
        var month = monthsCache.firstWhere(
            (m) =>
                m.begin.year == beginningOfLastMonth.year &&
                m.begin.month == beginningOfLastMonth.month,
            orElse: () => null);

        if (month == null || month.missingReadings) {
          //request readings
          var data = await octopusEnergyClient
              .getConsumtion(apiKey, meterPoint, meter,
                  periodFrom: beginningOfLastMonth, periodTo: endOfLastMonth)
              .timeout(Duration(seconds: timeoutDuration));

          if (data != null && data.length > 0) {
            consumption.addAll(data);
            readingRepo.saveAll(data);
            stillHaveData = true;
          }
        } else {
          //found local data
          stillHaveData = true;
        }

        //update current month
        currentDate = beginningOfLastMonth;
        notifyListeners();
      }
      // //*****get data for months */

      // var data = await octopusEnergyClient
      //     .getConsumtion(apiKey, meterPoint, meter)
      //     .timeout(Duration(seconds: timeoutDuration));
      // consumption.addAll(data);
      // print('Got data');

      // var m = OctopusEneryClient.getEnergyMonthsFromConsumption(consumption);
      // monthConsumption = m;
    } on TimeoutException catch (_) {
      timeoutError = true;
    } catch (exception, stackTrace) {
      loadingData = false;
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }

    if (consumption == null || consumption.length == 0) {
      errorGettingData = true;
    } else {
      initialised = true;
    }

    // await Future.delayed(
    //     const Duration(seconds: 5), () => print("Finished delay"));
    loadingData = false;
    notifyListeners();
    // return 'Got data';
    getPricingInformation(
        apiKey: apiKey,
        accountId: accountId,
        meterPoint: meterPoint,
        meter: meter,
        activeAgileTariff: activeAgileTariff);
  }

  getPricingInformation(
      {@required String apiKey,
      @required String accountId,
      @required String meterPoint,
      @required String meter,
      @required String activeAgileTariff,
      void Function(EnergyAccount) updateAccountSettings,
      DateTime Function() currentDateFetcher =
          DefaultCurrentDateTimeFetcher}) async {
    //get any locally stored readings
    var storedPrices = priceRepo.getAll();
    prices.addAll(storedPrices);

    var monthsCache = monthConsumption;

    try {
      print('Initing data');
      //get consumption for previous day
      // var date = DateTime(2021, 5, 01, 00, 00, 00);
      // var date2 = DateTime(2021, 5, 01 - 1, 00, 00, 00);
      var currentDate = currentDateFetcher();
      //some days in the current month to get data for
      //if the first day of the month, can just get previous results
      if (currentDate.day > 1) {
        var latestDate =
            DateTime(currentDate.year, currentDate.month, 1, 00, 00);

        if (activeAgileTariff != null && activeAgileTariff.isNotEmpty) {
          var priceData = await octopusEnergyClient
              .getAgilePrices(
                  tariffCode: activeAgileTariff, periodFrom: latestDate)
              .timeout(Duration(seconds: timeoutDuration));
          print('Hello');

          prices.addAll(priceData);
          priceRepo.saveAll(priceData);
        }

        notifyListeners();
      } else {
        //already have local data
        notifyListeners();
      }

      //*****get data for months */
      bool stillHaveData = true;
      while (stillHaveData) {
        print('Getting month data');
        stillHaveData = false;

        var endOfLastMonth =
            DateTime(currentDate.year, currentDate.month, 0, 00, 00);
        var beginningOfLastMonth =
            DateTime(endOfLastMonth.year, endOfLastMonth.month, 1, 00, 00);
        var month = monthsCache.firstWhere(
            (m) =>
                m.begin.year == beginningOfLastMonth.year &&
                m.begin.month == beginningOfLastMonth.month,
            orElse: () => null);

        if (month == null || month.missingPrices) {
          //request prices
          print(
              'Getting agile prices from ${beginningOfLastMonth.toString()} to ${endOfLastMonth.toString()}');
          if (activeAgileTariff != null && activeAgileTariff.isNotEmpty) {
            var priceData = await octopusEnergyClient
                .getAgilePrices(
                    tariffCode: activeAgileTariff,
                    periodFrom: beginningOfLastMonth,
                    periodTo: endOfLastMonth)
                .timeout(Duration(seconds: timeoutDuration));
            print('Got agile price data');

            prices.addAll(priceData);
            priceRepo.saveAll(priceData);
          }
          stillHaveData = true;
        } else {
          //found local data
          stillHaveData = true;
        }

        //update current month
        currentDate = beginningOfLastMonth;
        notifyListeners();
      }
      // //*****get data for months */

      // var data = await octopusEnergyClient
      //     .getConsumtion(apiKey, meterPoint, meter)
      //     .timeout(Duration(seconds: timeoutDuration));
      // consumption.addAll(data);
      // print('Got data');

      // var m = OctopusEneryClient.getEnergyMonthsFromConsumption(consumption);
      // monthConsumption = m;
    } on TimeoutException catch (_) {
      timeoutError = true;
    } catch (exception, stackTrace) {
      loadingData = false;
      Sentry.captureException(
        exception,
        stackTrace: stackTrace,
      );
    }

    // await Future.delayed(
    //     const Duration(seconds: 5), () => print("Finished delay"));
    loadingData = false;
    notifyListeners();
  }

  Future<EnergyAccount> getAccountDetails(
      String accountId, String apiKey) async {
    try {
      var result =
          await octopusEnergyClient.getAccountDetails(accountId, apiKey);
      return result;
    } catch (exception, stackTrace) {
      logger.logError(exception, stackTrace);
    }
    return null;
  }

  Future<List<EnergyConsumption>> getConsumptionLast30Days(
      String apiKey, String meterPoint, String meter) async {
    try {
      var result = await octopusEnergyClient
          .getConsumptionLast30Days(apiKey, meterPoint, meter)
          .timeout(Duration(seconds: timeoutDuration));
      return result;
    } catch (exception, stackTrace) {
      logger.logError(exception, stackTrace);
    }

    return [];
  }

  retryLogin() {
    // monthConsumption = null;
    consumption = null;
    initialised = false;
    errorGettingData = false;
    timeoutError = false;
    notifyListeners();
  }

  resetState() {
    initialised = false;
    consumption = SplayTreeSet<EnergyConsumption>();

    notifyListeners();
  }

  Future<List<AgilePrice>> getAgilePrices(
      {@required String tariffCode,
      @required bool onlyAfterDateTime,
      DateTime periodFrom}) async {
    List<AgilePrice> prices;

    if (tariffCode == null) return Future.error('Error - No tariffCode');

    try {
      prices = await octopusEnergyClient.getAgilePrices(
          periodFrom: periodFrom, tariffCode: tariffCode);
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

abstract class SquiddyLogger {
  Future<bool> logError(exception, stackTrace);
}

class DefaultLogger implements SquiddyLogger {
  @override
  Future<bool> logError(exception, stackTrace) async {
    var result = await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
    );

    if (result != null) {
      return true;
    } else {
      return false;
    }
  }
}

DateTime DefaultCurrentDateTimeFetcher() {
  return DateTime.now();
}
