import 'package:squiddy/octopus/octopusEnergyClient.dart';

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
