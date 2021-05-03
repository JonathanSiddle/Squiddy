import 'package:flutter_test/flutter_test.dart';
import 'package:squiddy/octopus/dataClasses/ElectricityAccount.dart';
import 'package:squiddy/octopus/dataClasses/ElectricityAgreement.dart';
import 'package:squiddy/octopus/dataClasses/ElectricityMeterPoint.dart';

main() {
  group('Octopus Client tests', () {
    test('Has agile price false, meterpoints null', () {
      var testAccount = EnergyAccount(accountNumber: '12345');
      var hasAgilePrices =
          testAccount.hasActiveAgileAccount(inDateTimeFetcher: () {
        return DateTime(1990, 1, 1);
      });

      expect(false, hasAgilePrices);
    });

    test('Has agreements but no agile tariff returns false', () {
      var agreement1 = ElectricityAgreement(
          tariffCode: 'E-1R-Expensive-18-02-21-M',
          validFrom: DateTime(1990, 1, 1),
          validTo: DateTime(1990, 2, 2));
      var agreement2 = ElectricityAgreement(
          tariffCode: 'E-1R-Variable-18-02-21-M',
          validFrom: DateTime(1990, 1, 1),
          validTo: DateTime(1990, 2, 2));
      var agreement3 = ElectricityAgreement(
          tariffCode: 'E-1R-test-18-02-21-M',
          validFrom: DateTime(1990, 1, 1),
          validTo: DateTime(1990, 2, 2));
      var meterPoint = ElectricityMeterPoint(
          agreements: [agreement1, agreement2, agreement3]);
      var testAccount = EnergyAccount(
          accountNumber: '12345', electricityMeterPoints: [meterPoint]);
      var hasAgilePrices =
          testAccount.hasActiveAgileAccount(inDateTimeFetcher: () {
        return DateTime(1990, 1, 1);
      });

      expect(false, hasAgilePrices);
    });

    test('Has agile price true, one agile meter point', () {
      var agreement1 = ElectricityAgreement(
          tariffCode: 'E-1R-AGILE-18-02-21-M',
          validFrom: DateTime(1990, 1, 1),
          validTo: DateTime(1990, 2, 2));
      var meterPoint = ElectricityMeterPoint(agreements: [agreement1]);
      var testAccount = EnergyAccount(
          accountNumber: '12345', electricityMeterPoints: [meterPoint]);
      var hasAgilePrices =
          testAccount.hasActiveAgileAccount(inDateTimeFetcher: () {
        return DateTime(1990, 1, 1);
      });

      expect(true, hasAgilePrices);
    });

    test('Has agile price false, meterpoints null', () {
      var testAccount = EnergyAccount(accountNumber: '12345');
      var agileTariffCode =
          testAccount.getAgileTariffCode(inDateTimeFetcher: () {
        return DateTime(1990, 1, 1);
      });

      expect(null, agileTariffCode);
    });

    test('Has agile price, get tariff code returns tariff code', () {
      var agreement1 = ElectricityAgreement(
          tariffCode: 'E-1R-AGILE-18-02-21-M',
          validFrom: DateTime(1990, 1, 1),
          validTo: DateTime(1990, 2, 2));
      var meterPoint = ElectricityMeterPoint(agreements: [agreement1]);
      var testAccount = EnergyAccount(
          accountNumber: '12345', electricityMeterPoints: [meterPoint]);
      var tariffCode = testAccount.getAgileTariffCode(inDateTimeFetcher: () {
        return DateTime(1990, 1, 1);
      });

      expect('E-1R-AGILE-18-02-21-M', tariffCode);
    });
  });
}
