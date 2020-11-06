import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/main.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/octopus/settingsManager.dart';

import 'mocks.dart';

main() {
  Future<Widget> makeWidgetTestable(
      {OctopusEneryClient octoEnergyClient,
      FlutterSecureStorage store,
      int httpTimeout,
      bool loadSavedSettings}) async {
    if (loadSavedSettings == null) {
      loadSavedSettings = false;
    }
    var ocotManager = OctopusManager(
        octopusEnergyClient: octoEnergyClient ?? MockOctopusEnergyCLient(),
        timeoutDuration: httpTimeout);

    var settingsManager = SettingsManager(localStore: store);
    if (loadSavedSettings) {
      await settingsManager.loadSettings();
      settingsManager.validated = true;
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Bootstrap'),
        ),
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsManager>(
                create: (_) => settingsManager),
            ChangeNotifierProvider<OctopusManager>(create: (_) => ocotManager),
          ],
          child: MyApp(),
        ),
      ),
    );
  }

  group('app integration test', () {
    testWidgets('Can load app', (WidgetTester tester) async {
      var widget = await makeWidgetTestable();
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Squiddy'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets(
        'Display error, retry and logout buttons if getting consumption takes longer than timeout, first login',
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
      when(mockOctoClient.getConsumptionLast30Days(any, any, any)).thenAnswer(
          (_) =>
              Future.delayed(Duration(seconds: 10), () => energyConsumption));
      when(mockOctoClient.getConsumtion(any, any, any)).thenAnswer(
          (realInvocation) =>
              Future.delayed(Duration(seconds: 60), () => null));
      var mockLocalStore = MockLocalStore();
      when(mockLocalStore.read(key: argThat(isNotNull, named: 'key')))
          .thenAnswer((_) => Future.value('test'));

      var widget = await makeWidgetTestable(
          octoEnergyClient: mockOctoClient,
          store: mockLocalStore,
          httpTimeout: 30);
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
      await tester.pump(Duration(seconds: 10));
      // await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pump(Duration(seconds: 30));

      expect(find.byIcon(FontAwesomeIcons.sadTear), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      //pump for extra time to make sure delayed future gets resolved
      await tester.pump(Duration(seconds: 60));

      verify(mockLocalStore.write(
              key: argThat(isNotNull, named: 'key'),
              value: argThat(isNotNull, named: 'value')))
          .called(4);
    });

    testWidgets(
        'Returning no results shows error and logout button, first login',
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
      when(mockOctoClient.getConsumptionLast30Days(any, any, any)).thenAnswer(
          (_) =>
              Future.delayed(Duration(seconds: 10), () => energyConsumption));
      when(mockOctoClient.getConsumtion(any, any, any))
          .thenAnswer((realInvocation) => Future.value(null));
      var mockLocalStore = MockLocalStore();
      when(mockLocalStore.read(key: argThat(isNotNull, named: 'key')))
          .thenAnswer((_) => Future.value('test'));

      var widget = await makeWidgetTestable(
          octoEnergyClient: mockOctoClient,
          store: mockLocalStore,
          httpTimeout: 30);
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
      await tester.pump(Duration(seconds: 10));
      // await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Yes'));

      await tester.pumpAndSettle();
      expect(find.byIcon(FontAwesomeIcons.sadTear), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      verify(mockLocalStore.write(
              key: argThat(isNotNull, named: 'key'),
              value: argThat(isNotNull, named: 'value')))
          .called(4);
    });

    testWidgets(
        'Returning no results shows error and logout button, first login',
        (WidgetTester tester) async {
      var df = DateFormat('yyyy-MM-dd HH:mm:ss');
      var day1Consumption = Map<String, EnergyConsumption>();
      day1Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:00'),
          intervalEnd: df.parse('1990-01-01 10:00:30'),
          consumption: 3);
      day1Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:30'),
          intervalEnd: df.parse('1990-01-01 10:01:00'),
          consumption: 3);
      var day2Consumption = Map<String, EnergyConsumption>();
      day2Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:00'),
          intervalEnd: df.parse('1990-01-02 10:00:30'),
          consumption: 3);
      day2Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:30'),
          intervalEnd: df.parse('1990-01-02 10:01:00'),
          consumption: 3);
      var day3Consumption = Map<String, EnergyConsumption>();
      day3Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:00'),
          intervalEnd: df.parse('1990-01-03 10:00:30'),
          consumption: 3);
      day3Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:30'),
          intervalEnd: df.parse('1990-01-03 10:01:00'),
          consumption: 3);

      var energyMonths = List<EnergyMonth>.from([
        EnergyMonth(
            begin: df.parse('1990-01-01 00:00:00'),
            end: df.parse('1990-01-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
            ])),
      ]);
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
      when(mockOctoClient.getConsumptionLast30Days(any, any, any)).thenAnswer(
          (_) =>
              Future.delayed(Duration(seconds: 10), () => energyConsumption));
      when(mockOctoClient.getConsumtion(any, any, any))
          .thenAnswer((realInvocation) => Future.value(energyMonths));
      var mockLocalStore = MockLocalStore();
      when(mockLocalStore.read(key: argThat(isNotNull, named: 'key')))
          .thenAnswer((_) => Future.value('test'));

      var widget = await makeWidgetTestable(
          octoEnergyClient: mockOctoClient,
          store: mockLocalStore,
          httpTimeout: 30);
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
      await tester.pump(Duration(seconds: 10));
      // await tester.pumpAndSettle();

      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Yes'));

      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);

      verify(mockLocalStore.write(
              key: argThat(isNotNull, named: 'key'),
              value: argThat(isNotNull, named: 'value')))
          .called(4);
    });

    testWidgets('Returning results shows results, has already logged in',
        (WidgetTester tester) async {
      var df = DateFormat('yyyy-MM-dd HH:mm:ss');
      var day1Consumption = Map<String, EnergyConsumption>();
      day1Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:00'),
          intervalEnd: df.parse('1990-01-01 10:00:30'),
          consumption: 3);
      day1Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:30'),
          intervalEnd: df.parse('1990-01-01 10:01:00'),
          consumption: 3);
      var day2Consumption = Map<String, EnergyConsumption>();
      day2Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:00'),
          intervalEnd: df.parse('1990-01-02 10:00:30'),
          consumption: 3);
      day2Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:30'),
          intervalEnd: df.parse('1990-01-02 10:01:00'),
          consumption: 3);
      var day3Consumption = Map<String, EnergyConsumption>();
      day3Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:00'),
          intervalEnd: df.parse('1990-01-03 10:00:30'),
          consumption: 3);
      day3Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:30'),
          intervalEnd: df.parse('1990-01-03 10:01:00'),
          consumption: 3);

      var energyMonths = List<EnergyMonth>.from([
        EnergyMonth(
            begin: df.parse('1990-01-01 00:00:00'),
            end: df.parse('1990-01-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
            ])),
      ]);
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
      when(mockOctoClient.getConsumptionLast30Days(any, any, any)).thenAnswer(
          (_) =>
              Future.delayed(Duration(seconds: 10), () => energyConsumption));
      when(mockOctoClient.getConsumtion(any, any, any))
          .thenAnswer((realInvocation) => Future.value(energyMonths));
      var mockLocalStore = MockLocalStore();
      when(mockLocalStore.read(key: argThat(isNotNull, named: 'key')))
          .thenAnswer((_) => Future.value('test'));

      var widget = await makeWidgetTestable(
          octoEnergyClient: mockOctoClient,
          store: mockLocalStore,
          httpTimeout: 30,
          loadSavedSettings: true);
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);

      verifyNever(mockLocalStore.write(
          key: argThat(isNotNull, named: 'key'),
          value: argThat(isNotNull, named: 'value')));
    });

    testWidgets(
        'Taking longer than time out shows retry and logout, already logged in',
        (WidgetTester tester) async {
      var df = DateFormat('yyyy-MM-dd HH:mm:ss');
      var day1Consumption = Map<String, EnergyConsumption>();
      day1Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:00'),
          intervalEnd: df.parse('1990-01-01 10:00:30'),
          consumption: 3);
      day1Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:30'),
          intervalEnd: df.parse('1990-01-01 10:01:00'),
          consumption: 3);
      var day2Consumption = Map<String, EnergyConsumption>();
      day2Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:00'),
          intervalEnd: df.parse('1990-01-02 10:00:30'),
          consumption: 3);
      day2Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:30'),
          intervalEnd: df.parse('1990-01-02 10:01:00'),
          consumption: 3);
      var day3Consumption = Map<String, EnergyConsumption>();
      day3Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:00'),
          intervalEnd: df.parse('1990-01-03 10:00:30'),
          consumption: 3);
      day3Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:30'),
          intervalEnd: df.parse('1990-01-03 10:01:00'),
          consumption: 3);

      var energyMonths = List<EnergyMonth>.from([
        EnergyMonth(
            begin: df.parse('1990-01-01 00:00:00'),
            end: df.parse('1990-01-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
            ])),
      ]);
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
      when(mockOctoClient.getConsumptionLast30Days(any, any, any)).thenAnswer(
          (_) => Future.delayed(
              Duration(seconds: 60), () => List<EnergyConsumption>()));
      when(mockOctoClient.getConsumtion(any, any, any)).thenAnswer(
          (realInvocation) =>
              Future.delayed(Duration(seconds: 60), () => energyMonths));
      var mockLocalStore = MockLocalStore();
      when(mockLocalStore.read(key: argThat(isNotNull, named: 'key')))
          .thenAnswer((_) => Future.value('test'));

      var widget = await makeWidgetTestable(
          octoEnergyClient: mockOctoClient,
          store: mockLocalStore,
          httpTimeout: 30,
          loadSavedSettings: true);
      await tester.pumpWidget(widget);
      // await tester.pumpAndSettle();
      await tester.pump(Duration(seconds: 45));

      await tester.pump(Duration(seconds: 30));
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.sadTear), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      verifyNever(mockLocalStore.write(
          key: argThat(isNotNull, named: 'key'),
          value: argThat(isNotNull, named: 'value')));
    });

    testWidgets('No results alread logged in shows logout button',
        (WidgetTester tester) async {
      var df = DateFormat('yyyy-MM-dd HH:mm:ss');
      var day1Consumption = Map<String, EnergyConsumption>();
      day1Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:00'),
          intervalEnd: df.parse('1990-01-01 10:00:30'),
          consumption: 3);
      day1Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:30'),
          intervalEnd: df.parse('1990-01-01 10:01:00'),
          consumption: 3);
      var day2Consumption = Map<String, EnergyConsumption>();
      day2Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:00'),
          intervalEnd: df.parse('1990-01-02 10:00:30'),
          consumption: 3);
      day2Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:30'),
          intervalEnd: df.parse('1990-01-02 10:01:00'),
          consumption: 3);
      var day3Consumption = Map<String, EnergyConsumption>();
      day3Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:00'),
          intervalEnd: df.parse('1990-01-03 10:00:30'),
          consumption: 3);
      day3Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:30'),
          intervalEnd: df.parse('1990-01-03 10:01:00'),
          consumption: 3);

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
      when(mockOctoClient.getConsumptionLast30Days(any, any, any)).thenAnswer(
          (_) => Future.delayed(
              Duration(seconds: 60), () => List<EnergyConsumption>()));
      when(mockOctoClient.getConsumtion(any, any, any))
          .thenAnswer((realInvocation) => Future.value(null));
      var mockLocalStore = MockLocalStore();
      when(mockLocalStore.read(key: argThat(isNotNull, named: 'key')))
          .thenAnswer((_) => Future.value('test'));

      var widget = await makeWidgetTestable(
          octoEnergyClient: mockOctoClient,
          store: mockLocalStore,
          httpTimeout: 30,
          loadSavedSettings: true);
      await tester.pumpWidget(widget);
      // await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.sadTear), findsOneWidget);
      expect(find.text('Uh oh, there is no data here or something went wrong!'),
          findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      verifyNever(mockLocalStore.write(
          key: argThat(isNotNull, named: 'key'),
          value: argThat(isNotNull, named: 'value')));
    });

    testWidgets('No results alread logged in shows logout button',
        (WidgetTester tester) async {
      var df = DateFormat('yyyy-MM-dd HH:mm:ss');
      var day1Consumption = Map<String, EnergyConsumption>();
      day1Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:00'),
          intervalEnd: df.parse('1990-01-01 10:00:30'),
          consumption: 3);
      day1Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-01 10:00:30'),
          intervalEnd: df.parse('1990-01-01 10:01:00'),
          consumption: 3);
      var day2Consumption = Map<String, EnergyConsumption>();
      day2Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:00'),
          intervalEnd: df.parse('1990-01-02 10:00:30'),
          consumption: 3);
      day2Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-02 10:00:30'),
          intervalEnd: df.parse('1990-01-02 10:01:00'),
          consumption: 3);
      var day3Consumption = Map<String, EnergyConsumption>();
      day3Consumption['10:00'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:00'),
          intervalEnd: df.parse('1990-01-03 10:00:30'),
          consumption: 3);
      day3Consumption['10:01'] = EnergyConsumption(
          intervalStart: df.parse('1990-01-03 10:00:30'),
          intervalEnd: df.parse('1990-01-03 10:01:00'),
          consumption: 3);

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
      when(mockOctoClient.getConsumptionLast30Days(any, any, any)).thenAnswer(
          (_) => Future.delayed(
              Duration(seconds: 60), () => List<EnergyConsumption>()));
      when(mockOctoClient.getConsumtion(any, any, any))
          .thenAnswer((realInvocation) => Future.value(null));
      var mockLocalStore = MockLocalStore();
      when(mockLocalStore.read(key: argThat(isNotNull, named: 'key')))
          .thenAnswer((_) => Future.value('test'));

      var widget = await makeWidgetTestable(
          octoEnergyClient: mockOctoClient,
          store: mockLocalStore,
          httpTimeout: 30,
          loadSavedSettings: true);
      await tester.pumpWidget(widget);
      // await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      expect(find.byIcon(FontAwesomeIcons.sadTear), findsOneWidget);
      expect(find.text('Uh oh, there is no data here or something went wrong!'),
          findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Squiddy'), findsOneWidget);

      verify(mockLocalStore.write(
              key: argThat(isNotNull, named: 'key'),
              value: argThat(isNotNull, named: 'value')))
          .called(4);
    });
  });
}
