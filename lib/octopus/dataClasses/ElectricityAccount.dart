import 'package:squiddy/octopus/dataClasses/ElectricityMeterPoint.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

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
