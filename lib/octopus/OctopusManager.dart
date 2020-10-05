import 'package:flutter/widgets.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

class OctopusManager extends ChangeNotifier {
  var initialised = false;
  var errorGettingData = false;
  String apiKey;
  OctopusEneryClient octopusEnergyClient;
  List<EnergyMonth> monthConsumption = List();

  OctopusManager({this.octopusEnergyClient}) {
    if (octopusEnergyClient == null) {
      octopusEnergyClient = OctopusEneryClient();
    }
  }

  Future<void> initData(
      {@required String apiKey,
      @required String accountId,
      @required String meterPoint,
      @required String meter}) async {
    initialised = false;
    errorGettingData = false;
    monthConsumption = await octopusEnergyClient.getConsumtion(apiKey, meterPoint, meter);

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

  Future<EnergyAccount> getAccountDetails(String accountId, String apiKey) async {
    return await octopusEnergyClient.getAccountDetails(accountId, apiKey);
  }

  Future<List<EnergyConsumption>> getConsumptionLast30Days(String apiKey, String meterPoint, String meter) async {
    return await octopusEnergyClient.getConsumptionLast30Days(apiKey, meterPoint, meter);
  }

  resetState() {
    initialised = false;
    monthConsumption = List();

    notifyListeners();
  }
}
