import 'package:squiddy/octopus/dataClasses/ElectricityAgreement.dart';
import 'package:squiddy/octopus/dataClasses/ElectricityMeter.dart';

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
