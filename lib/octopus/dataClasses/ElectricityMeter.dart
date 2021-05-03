import 'package:squiddy/octopus/dataClasses/ElectricityRegister.dart';

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
