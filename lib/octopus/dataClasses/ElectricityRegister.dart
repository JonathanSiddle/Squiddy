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
