import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:quiver/core.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

part 'AgilePrice.g.dart';

@HiveType(typeId: 2)
class AgilePrice implements Comparable {
  @HiveField(0)
  DateTime validFrom;
  @HiveField(1)
  DateTime validTo;
  @HiveField(2)
  double valueExcVat;
  @HiveField(3)
  double valueIncVat;

  String get id {
    return '${validFrom.toString()}|${validTo.toString()}';
  }

  AgilePrice({
    this.validFrom,
    this.validTo,
    this.valueExcVat,
    this.valueIncVat,
  });

  // AgilePrice copyWith({
  //   DateTime validFrom,
  //   DateTime validTo,
  //   double valueExcVat,
  //   double valueIncVat,
  // }) {
  //   return AgilePrice(
  //     validFrom: validFrom ?? this.validFrom,
  //     validTo: validTo ?? this.validTo,
  //     valueExcVat: valueExcVat ?? this.valueExcVat,
  //     valueIncVat: valueIncVat ?? this.valueIncVat,
  //   );
  // }

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

  // @override
  // String toString() {
  //   return 'AgilePrice(validFrom: $validFrom, validTo: $validTo, valueExcVat: $valueExcVat, valueIncVat: $valueIncVat)';
  // }

  bool operator ==(Object o) {
    return o is AgilePrice && o.validFrom == validFrom && o.validTo == validTo;
    // o.valueExcVat == valueExcVat &&
    // o.valueIncVat == valueIncVat;
  }

  int get hashCode => hash2(validFrom.hashCode, validTo.hashCode);

  @override
  int compareTo(other) {
    int start = other.validFrom.compareTo(validFrom);

    return start != 0 ? start : other.validTo.compareTo(validTo);
  }
}
