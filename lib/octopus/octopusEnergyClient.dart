import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:squiddy/octopus/dataClasses/AgilePrice.dart';
import 'package:squiddy/octopus/dataClasses/ElectricityAccount.dart';
import 'package:squiddy/octopus/dataClasses/EnergyConsumption.dart';
import 'package:squiddy/octopus/dataClasses/EnergyDay.dart';
import 'package:squiddy/octopus/dataClasses/EnergyMonth.dart';

final octopusDateformat = DateFormat('yyyy-MM-ddTHH:mm:ss');
final DateTime Function() defaultDateTimeFetcher = () => DateTime.now();

class OctopusEneryClient {
  DateTime Function() dateTimeFetcher = defaultDateTimeFetcher;
  OctopusEneryClient();

  Map<String, String> getHeaders(String apiKey) {
    return {'authorization': 'Basic ' + base64Encode(utf8.encode('$apiKey:'))};
  }

  Future<EnergyAccount> getAccountDetails(String acId, String key) async {
    var response = await http.get(
        Uri.parse('https://api.octopus.energy/v1/accounts/$acId'),
        headers: {
          'authorization': 'Basic ' + base64Encode(utf8.encode('$key:'))
        });

    if (response.statusCode != 200) {
      return null;
    }

    var jsonData = jsonDecode(response.body)['properties'][0];
    // var dataString =  await rootBundle.loadString('assets/my_text.txt');
    // var jsonData = jsonDecode(dataString)['properties'][0];
    var energyAccount = EnergyAccount.fromJson(jsonData);

    return energyAccount;
  }

  Future<bool> settingsTest(
      String apiKey, String accountId, String meterPoint, String meter) async {
    var accountDetails = await http.get(
        Uri.parse('https://api.octopus.energy/v1/accounts/$accountId'),
        headers: getHeaders(apiKey));
    //make a request far in the past, this will obviously not
    //return any data, but should return status 200 if other details are correct
    var consumptionRequest = await http.get(
        Uri.parse(
            'https://api.octopus.energy/v1/electricity-meter-points/$meterPoint/meters/$meter/consumption/?page_size=1&period_from=1990-01-01T00:00:00&period_to=1990-01-01T00:30:00'),
        headers: getHeaders(apiKey));

    if (accountDetails.statusCode == 200 &&
        consumptionRequest.statusCode == 200) {
      return true;
    }

    return false;
  }

  Future<List<EnergyConsumption>> getConsumptionLast30Days(
      String apiKey, String meterPoint, String meter) async {
    var now = DateTime.now();
    var lastMonth = now.subtract(Duration(days: 30));

    var consumption = await getConsumtion(apiKey, meterPoint, meter,
        periodFrom: lastMonth, periodTo: now);
    var months = getEnergyMonthsFromConsumption(consumption.toList());

    //potentially could be null, init to empty list if this is the case
    if (months == null) {
      months = [];
    }

    return months
        .map((e) => e.consumption)
        .expand((element) => element)
        .toList();
  }

  Future<Set<EnergyConsumption>> getConsumtion(
      String apiKey, String meterPoint, String meter,
      {DateTime periodFrom, DateTime periodTo}) async {
    var fm = DateFormat('yyyy-MM-ddTHH:mm:ss');
    String toFromString;
    if (periodFrom != null) {
      toFromString = 'period_from=${fm.format(periodFrom)}';
    }

    if (periodTo != null) {
      toFromString += '&period_to=${fm.format(periodTo)}';
    }

    http.Response response;
    try {
      response = await http.get(
          Uri.parse(
              'https://api.octopus.energy/v1/electricity-meter-points/$meterPoint/meters/$meter/consumption/?page_size=25000&${toFromString ?? ''}'),
          headers: getHeaders(apiKey));
    } catch (e) {
      return null;
    }

    if (response != null && response.statusCode == 200) {
      List<dynamic> consumptionJson = jsonDecode(response.body)['results'];

      //there is a chance here that results could be null,
      //for example if the meter is valid but there are no readings available
      //if results is null we probably want to return null and treat as an error
      if (consumptionJson == null || consumptionJson.length == 0) {
        return null;
      }

      var consumption =
          consumptionJson.map((c) => EnergyConsumption.fromJson(c)).toSet();
      return consumption;
      // return getEnergyMonthsFromJsonString(response.body);
    }

    return Set();
  }

  static List<EnergyMonth> getEnergyMonthsFromJsonString(String json) {
    List<dynamic> consumptionJson = jsonDecode(json)['results'];

    //there is a chance here that results could be null,
    //for example if the meter is valid but there are no readings available
    //if results is null we probably want to return null and treat as an error
    if (consumptionJson == null || consumptionJson.length == 0) {
      return null;
    }

    var consumption =
        consumptionJson.map((c) => EnergyConsumption.fromJson(c)).toSet();

    var energyMonths = getEnergyMonthsFromConsumption(consumption.toList());

    return energyMonths;
  }

  Future<List<AgilePrice>> getCurrentAgilePrices(
      {@required String tariffCode, @required DateTime periodFrom}) async {
    var fm = DateFormat('yyyy-MM-ddTHH:mm:ss');
    List<AgilePrice> agilePrices = [];

    String periodFromString;
    if (periodFrom != null) {
      periodFromString = 'period_from=${fm.format(periodFrom)}';
    }

    http.Response response;
    try {
      response = await http.get(Uri.parse(
          'https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/$tariffCode/standard-unit-rates?page_size=25000&$periodFromString'));
    } catch (e) {
      return null;
    }

    if (response != null && response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body)['results'];
      agilePrices = json.map((ap) => AgilePrice.fromMap(ap)).toList();
    }

    return agilePrices;
  }

  static List<EnergyMonth> getEnergyMonthsFromConsumption(
      List<EnergyConsumption> consumption) {
    if (consumption == null || consumption.length <= 0) {
      return [];
    } else {
      var dateFormat = DateFormat('HH:mm');
      //assume consumption in reverse order, so flip to go from the earliest date first
      List<EnergyMonth> energyMonths = [];

      // var consump = consumption.toList().reversed.toList();
      var currentEnergyMonth = EnergyMonth();
      energyMonths.add(currentEnergyMonth);
      var currentEnergyDay = EnergyDay();
      currentEnergyDay.date = consumption[0].intervalStart;
      currentEnergyMonth.begin = consumption[0].intervalStart;
      currentEnergyMonth.days.add(currentEnergyDay);

      var currentDate = currentEnergyMonth.begin;
      var currentDay = currentEnergyMonth.begin.day;
      var currentMonth = currentEnergyMonth.begin.month;
      consumption.removeRange(0, 0);

      for (var c in consumption) {
        var start = c.intervalStart;
        // print(start);

        if (start.month == currentMonth) {
          if (start.day == currentDay) {
            currentEnergyDay.addConsumption(dateFormat.format(start), c);
          } else {
            currentEnergyDay = EnergyDay();
            currentEnergyMonth.days.add(currentEnergyDay);
            currentEnergyDay.date = c.intervalStart;
            currentDate = c.intervalStart;
            var formattedDate = dateFormat.format(start);
            currentEnergyDay.addConsumption(formattedDate, c);
          }
        } else {
          currentEnergyMonth.end = currentDate;
          currentEnergyMonth = EnergyMonth();
          energyMonths.add(currentEnergyMonth);
          currentEnergyDay = EnergyDay();
          currentEnergyDay.date = start;
          currentEnergyMonth.begin = start;
          currentEnergyMonth.days.add(currentEnergyDay);

          currentEnergyDay.date = c.intervalStart;
          currentEnergyDay.addConsumption(dateFormat.format(start), c);
        }

        currentDate = c.intervalStart;
        currentDay = c.intervalStart.day;
        currentMonth = c.intervalStart.month;
      }

      return energyMonths.reversed.toList();
    }
  }
}
