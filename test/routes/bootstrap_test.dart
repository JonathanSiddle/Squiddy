import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/octopus/secureStore.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/routes/bootstrap.dart';

import 'mocks.dart';

main() {
  Widget makeWidgetTestable(
      {OctopusEneryClient octoEnergyClient,
      SquiddyDataStore store,
      int httpTimeout}) {
    var ocotManager = OctopusManager(
        octopusEnergyClient: octoEnergyClient ?? MockOctopusEnergyCLient(),
        timeoutDuration: httpTimeout);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bootstrap'),
        ),
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsManager>(
                create: (_) => SettingsManager(localStore: store)),
            ChangeNotifierProvider<OctopusManager>(create: (_) => ocotManager),
          ],
          child: BootStrap(),
        ),
      ),
    );
  }

  group('Bootstrap page tests', () {
    testWidgets('Test can display page', (WidgetTester tester) async {
      var widget = makeWidgetTestable();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Enter incorrect account details, shows error dialog',
        (WidgetTester tester) async {
      var mockOctoClient = MockOctopusEnergyCLient();
      when(mockOctoClient.getAccountDetails(any, any))
          .thenAnswer((_) => Future.delayed(Duration(seconds: 10), null));

      var widget = makeWidgetTestable(octoEnergyClient: mockOctoClient);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(Key('apiKey')), Offset(100, -800));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('apiKey')), 'testKey');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('accountId')), 'testAccount');
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(Key('apiKey')), Offset(100, -300));

      await tester.tap(find.text('Go'));
      await tester.pump(Duration(seconds: 5));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();

      expect(find.text('Uh oh'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('apiKey')), findsOneWidget);
      expect(find.byKey(Key('accountId')), findsOneWidget);
    });

    testWidgets(
        'Can correctly enter account details and selecter meter point and meter',
        (WidgetTester tester) async {
      var energyConsumption = List<EnergyConsumption>.from(
          [EnergyConsumption(), EnergyConsumption()]);
      var meterPoints = List<ElectricityMeterPoint>.from([
        ElectricityMeterPoint(
            mpan: 'meter1',
            meters: List<ElectricityMeter>.from([
              ElectricityMeter(serialNumber: '111'),
              ElectricityMeter(serialNumber: '112'),
              ElectricityMeter(serialNumber: '113'),
            ])),
        ElectricityMeterPoint(
            mpan: 'meter2',
            meters: List<ElectricityMeter>.from([
              ElectricityMeter(serialNumber: '211'),
              ElectricityMeter(serialNumber: '212'),
              ElectricityMeter(serialNumber: '213'),
            ])),
      ]);
      var accountDetails = EnergyAccount(
          accountNumber: 'a123', electricityMeterPoints: meterPoints);
      var mockOctoClient = MockOctopusEnergyCLient();
      when(mockOctoClient.getAccountDetails(any, any)).thenAnswer(
          (_) => Future.delayed(Duration(seconds: 10), () => accountDetails));
      when(mockOctoClient.getConsumptionLast30Days(any, any, any))
          .thenAnswer((_) => Future.value(energyConsumption));
      var mockLocalStore = MockLocalStore();

      var widget = makeWidgetTestable(
          octoEnergyClient: mockOctoClient, store: mockLocalStore);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      await tester.drag(find.byKey(Key('apiKey')), Offset(100, -800));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(Key('apiKey')), 'testKey');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(Key('accountId')), 'testAccount');
      await tester.pumpAndSettle();
      await tester.drag(find.byKey(Key('apiKey')), Offset(100, -300));

      await tester.tap(find.text('Go'));
      await tester.pump(Duration(seconds: 5));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      await tester.drag(find.text('Squiddy'), Offset(100, -800));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test'));
      // await tester.pump(Duration(seconds: 5));
      await tester.pump(Duration(seconds: 5));

      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      //make sure to pump enough time to avoid pending timers
      await tester.pump(Duration(seconds: 10));

      verify(mockLocalStore.write(data: anyNamed('data'))).called(7);
    });
  });
}
