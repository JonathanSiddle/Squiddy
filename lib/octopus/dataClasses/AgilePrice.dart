import 'dart:convert';

import 'package:squiddy/octopus/octopusEnergyClient.dart';

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
