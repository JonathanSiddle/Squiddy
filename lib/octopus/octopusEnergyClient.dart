import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final octopusDateformat = DateFormat('yyyy-MM-ddTHH:mm:ss');
final DateTime Function() defaultDateTimeFetcher = () => DateTime.now();

class OctopusEneryClient {
  DateTime Function() dateTimeFetcher = defaultDateTimeFetcher;
  OctopusEneryClient();

  Map<String, String> getHeaders(String apiKey) {
    return {'authorization': 'Basic ' + base64Encode(utf8.encode('$apiKey:'))};
  }

  Future<EnergyAccount> getAccountDetails(String acId, String key) async {
    var response = await http
        .get('https://api.octopus.energy/v1/accounts/$acId', headers: {
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
        'https://api.octopus.energy/v1/accounts/$accountId',
        headers: getHeaders(apiKey));
    //make a request far in the past, this will obviously not
    //return any data, but should return status 200 if other details are correct
    var consumptionRequest = await http.get(
        'https://api.octopus.energy/v1/electricity-meter-points/$meterPoint/meters/$meter/consumption/?page_size=1&period_from=1990-01-01T00:00:00&period_to=1990-01-01T00:30:00',
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

    var months = await getConsumtion(apiKey, meterPoint, meter,
        periodFrom: lastMonth, periodTo: now);

    //potentially could be null, init to empty list if this is the case
    if (months == null) {
      months = List<EnergyMonth>();
    }

    return months
        .map((e) => e.consumption)
        .expand((element) => element)
        .toList();
  }

  Future<List<EnergyMonth>> getConsumtion(
      String apiKey, String meterPoint, String meter,
      {DateTime periodFrom, DateTime periodTo}) async {
    var fm = DateFormat('yyyy-MM-ddTHH:mm:ss');
    String toFromString;
    if (periodTo != null && periodFrom != null) {
      toFromString =
          'period_from=${fm.format(periodFrom)}&peropd_to=${fm.format(periodTo)}';
    }

    http.Response response;
    try {
      response = await http.get(
          'https://api.octopus.energy/v1/electricity-meter-points/$meterPoint/meters/$meter/consumption/?page_size=25000&${toFromString ?? ''}',
          headers: getHeaders(apiKey));
    } catch (e) {
      return null;
    }

    if (response != null && response.statusCode == 200) {
      return getEnergyMonthsFromJsonString(response.body);
    }

    return null;
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
        consumptionJson.map((c) => EnergyConsumption.fromJson(c)).toList();

    var energyMonths = getEnergyMonthsFromConsumption(consumption);

    return energyMonths;
  }

  Future<List<AgilePrice>> getCurrentAgilePrices(
      {@required String tariffCode}) async {
    var agilePrices = List<AgilePrice>();

    http.Response response;
    try {
      response = await http.get(
          'https://api.octopus.energy/v1/products/AGILE-18-02-21/electricity-tariffs/$tariffCode/standard-unit-rates');
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
      return List<EnergyMonth>();
    } else {
      var dateFormat = DateFormat('HH:mm');
      //assume consumption in reverse order, so flip to go from the earliest date first
      var energyMonths = List<EnergyMonth>();

      var consump = consumption.reversed.toList();

      var currentEnergyMonth = EnergyMonth();
      energyMonths.add(currentEnergyMonth);
      var currentEnergyDay = EnergyDay();
      currentEnergyDay.date = consump[0].intervalStart;
      currentEnergyMonth.begin = consump[0].intervalStart;
      currentEnergyMonth.days.add(currentEnergyDay);

      var currentDate = currentEnergyMonth.begin;
      var currentDay = currentEnergyMonth.begin.day;
      var currentMonth = currentEnergyMonth.begin.month;
      consump.removeRange(0, 0);

      for (var c in consump) {
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

//App data objects
class EnergyMonth {
  DateTime begin;
  DateTime end;
  var days = List<EnergyDay>();

  EnergyMonth({this.begin, this.end, this.days}) {
    if (days == null) {
      days = List<EnergyDay>();
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

class EnergyDay {
  DateTime date;
  var consumption = Map<String, EnergyConsumption>();

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
}

class EnergyAccount {
  DateTime Function() dateTimeFetcher = defaultDateTimeFetcher;

  String accountNumber;
  num id;
  DateTime movedInAt;
  DateTime movedOutAt;
  String addressLine1;
  String addressLine2;
  String addressLine3;
  String town;
  String county;
  String postcode;
  List<ElectricityMeterPoint> electricityMeterPoints;

  EnergyAccount(
      {this.accountNumber,
      this.id,
      this.movedInAt,
      this.movedOutAt,
      this.addressLine1,
      this.addressLine2,
      this.addressLine3,
      this.town,
      this.county,
      this.postcode,
      this.electricityMeterPoints});

  EnergyAccount.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    addressLine1 = json['address_line_1'];
    addressLine2 = json['address_line_2'];
    addressLine3 = json['address_line_3'];
    town = json['town'];
    county = json['county'];
    postcode = json['postcode'];
    List<dynamic> meterPoints = json['electricity_meter_points'];
    electricityMeterPoints =
        meterPoints.map((p) => ElectricityMeterPoint.fromJson(p)).toList();
  }

  bool hasActiveAgileAccount({DateTime Function() inDateTimeFetcher}) {
    DateTime cTime;
    if (inDateTimeFetcher == null) {
      cTime = dateTimeFetcher();
    } else {
      cTime = inDateTimeFetcher();
    }
    if (electricityMeterPoints == null) return false;

    // electricityMeterPoints.retainWhere((element) => element.agreements != null);
    var agileMeters = electricityMeterPoints
        .where((element) => element.agreements != null)
        .toList();

    var agreements =
        agileMeters?.map((e) => e?.agreements)?.expand((el) => el)?.toList();

    return agreements.any(
        (a) => (a.validTo.isAfter(cTime) && a.tariffCode.contains('AGILE')));
  }

  ///This method will return the first active AGLIE tariff code, if available
  String getAgileTariffCode({DateTime Function() inDateTimeFetcher}) {
    DateTime cTime;
    if (inDateTimeFetcher == null) {
      cTime = dateTimeFetcher();
    } else {
      cTime = inDateTimeFetcher();
    }

    if (electricityMeterPoints == null) return null;

    var agreements = electricityMeterPoints
        ?.map((e) => e.agreements)
        ?.expand((el) => el)
        ?.toList();

    return agreements
        ?.firstWhere(
            (a) => (a.validTo.isAfter(cTime) && a.tariffCode.contains('AGILE')),
            orElse: null)
        ?.tariffCode;
  }
}

class ElectricityMeterPoint {
  String mpan;
  num profileClass;
  num consumptionStandard;
  List<ElectricityMeter> meters;
  List<ElectricityAgreement> agreements;

  ElectricityMeterPoint({this.mpan, this.meters, this.agreements});

  ElectricityMeterPoint.fromJson(Map<String, dynamic> json) {
    mpan = json['mpan'];
    profileClass = json['profile_class'];
    consumptionStandard = json['consumption_standard'];
    List<dynamic> metersJson = json['meters'];
    meters = metersJson.map((m) => ElectricityMeter.fromJson(m)).toList();
    List<dynamic> agreementsJson = json['agreements'];
    agreements =
        agreementsJson.map((a) => ElectricityAgreement.fromJson(a)).toList();
  }
}

class ElectricityMeter {
  String serialNumber;
  List<ElectricityRegister> registers;

  ElectricityMeter({this.serialNumber});

  ElectricityMeter.fromJson(Map<String, dynamic> json) {
    serialNumber = json['serial_number'];
    List<dynamic> registersJson = json['registers'];
    registers =
        registersJson.map((r) => ElectricityRegister.fromJson(r)).toList();
  }
}

class ElectricityRegister {
  String identifier;
  String rate;
  bool isSettlementRegister;

  ElectricityRegister({this.identifier, this.rate, this.isSettlementRegister});

  ElectricityRegister.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    rate = json['rate'];
    isSettlementRegister = json['is_settlement_register'];
  }
}

class ElectricityAgreement {
  String tariffCode;
  DateTime validFrom;
  DateTime validTo;

  ElectricityAgreement({this.tariffCode, this.validFrom, this.validTo});

  ElectricityAgreement.fromJson(Map<String, dynamic> json) {
    tariffCode = json['tariff_code'];
    try {
      validFrom = octopusDateformat.parse(json['valid_from']);
    } catch (e) {
      validFrom = null;
    }

    try {
      validTo = octopusDateformat.parse(json['valid_to']);
    } catch (e) {
      validTo = null;
    }
  }
}

//Default units for Octopus energy are: kWh.
class EnergyConsumption {
  num consumption;
  DateTime intervalStart;
  DateTime intervalEnd;

  EnergyConsumption({this.intervalStart, this.intervalEnd, this.consumption});

  EnergyConsumption.fromJson(Map<String, dynamic> json) {
    consumption = json['consumption'];
    intervalStart = octopusDateformat.parse(json['interval_start']);
    intervalEnd = octopusDateformat.parse(json['interval_end']);
  }
}

class AgilePrice {
  DateTime validFrom;
  DateTime validTo;
  double valueExcVat;
  double valueIncVat;

  AgilePrice({
    this.validFrom,
    this.validTo,
    this.valueExcVat,
    this.valueIncVat,
  });

  AgilePrice copyWith({
    DateTime validFrom,
    DateTime validTo,
    double valueExcVat,
    double valueIncVat,
  }) {
    return AgilePrice(
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      valueExcVat: valueExcVat ?? this.valueExcVat,
      valueIncVat: valueIncVat ?? this.valueIncVat,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'valid_from': validFrom?.millisecondsSinceEpoch,
      'valid_to': validTo?.millisecondsSinceEpoch,
      'value_exc_vat': valueExcVat,
      'value_inc_vat': valueIncVat,
    };
  }

  factory AgilePrice.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return AgilePrice(
      validFrom: octopusDateformat.parse(map['valid_from']),
      validTo: octopusDateformat.parse(map['valid_to']),
      valueExcVat: map['value_exc_vat'],
      valueIncVat: map['value_inc_vat'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AgilePrice.fromJson(String source) =>
      AgilePrice.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AgilePrice(validFrom: $validFrom, validTo: $validTo, valueExcVat: $valueExcVat, valueIncVat: $valueIncVat)';
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is AgilePrice &&
        o.validFrom == validFrom &&
        o.validTo == validTo &&
        o.valueExcVat == valueExcVat &&
        o.valueIncVat == valueIncVat;
  }

  @override
  int get hashCode {
    return validFrom.hashCode ^
        validTo.hashCode ^
        valueExcVat.hashCode ^
        valueIncVat.hashCode;
  }
}
