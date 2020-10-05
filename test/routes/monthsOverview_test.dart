import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Charts/overviewSummary.dart';
import 'package:squiddy/monthDisplayCard.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/routes/monthsOverview.dart';
import 'mocks.dart';

void main() {
  Widget makeWidgetTestable({List<EnergyMonth> testData}) {
    var settingManager = SettingsManager(localStore: MockLocalStore());
    var octoManager =
        OctopusManager(octopusEnergyClient: MockOctopusEnergyCLient());

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsManager>(create: (_) => settingManager),
        ChangeNotifierProvider<OctopusManager>(create: (_) => octoManager),
        Provider<List<EnergyMonth>>(
          create: (_) => testData,
        )
      ],
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('Months Overview'),
          ),
          body: MonthsOverview(),
        ),
      ),
    );
  }

  group('Months overview tests', () {
    testWidgets('Can display one day for one month',
        (WidgetTester tester) async {
      // var twoDayData = TestData.getTwoDayData();
      // var energyMonths = OctopusEnery.getEnergyMonthsFromJsonString(twoDayData);
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
      var widget = makeWidgetTestable(testData: energyMonths);
      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.byIcon(FontAwesomeIcons.cog), findsOneWidget);
      expect(find.text('Last Six Months'), findsOneWidget);
      expect(find.text('6.00kWh'), findsOneWidget);
      expect(find.byType(OverviewSummary), findsOneWidget);

      //have to scroll a little bit to make sure sqiddyCard is found
      await tester.drag(find.text('Last Six Months'), Offset(100, -300));
      await tester.pumpAndSettle();
      // // await tester.pump();
      expect(find.byType(SquiddyCard), findsOneWidget);
      expect(find.widgetWithText(Container, 'Jan 1990'), findsOneWidget);
    });

    testWidgets('Can display three days for three months',
        (WidgetTester tester) async {
      // var twoDayData = TestData.getTwoDayData();
      // var energyMonths = OctopusEnery.getEnergyMonthsFromJsonString(twoDayData);
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
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
        EnergyMonth(
            begin: df.parse('1990-02-01 00:00:00'),
            end: df.parse('1990-02-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
        EnergyMonth(
            begin: df.parse('1990-03-01 00:00:00'),
            end: df.parse('1990-03-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
      ]);
      var widget = makeWidgetTestable(testData: energyMonths);
      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.byIcon(FontAwesomeIcons.cog), findsOneWidget);
      expect(find.text('Last Six Months'), findsOneWidget);
      expect(find.text('54.00kWh'), findsOneWidget);
      expect(find.byType(OverviewSummary), findsOneWidget);

      //have to scroll a little bit to make sure sqiddyCard is found
      await tester.drag(find.text('Last Six Months'), Offset(100, -300));
      await tester.pumpAndSettle();
      // // await tester.pump();
      expect(find.widgetWithText(Container, 'Jan 1990'), findsOneWidget);
      expect(find.widgetWithText(Container, 'Feb 1990'), findsOneWidget);

      await tester.drag(find.text('Last Six Months'), Offset(100, -300));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(Container, 'Mar 1990'), findsOneWidget);
    });

    testWidgets('Can display three days for six months',
        (WidgetTester tester) async {
      // var twoDayData = TestData.getTwoDayData();
      // var energyMonths = OctopusEnery.getEnergyMonthsFromJsonString(twoDayData);
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
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
        EnergyMonth(
            begin: df.parse('1990-02-01 00:00:00'),
            end: df.parse('1990-02-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
        EnergyMonth(
            begin: df.parse('1990-03-01 00:00:00'),
            end: df.parse('1990-03-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
        EnergyMonth(
            begin: df.parse('1990-04-01 00:00:00'),
            end: df.parse('1990-04-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
        EnergyMonth(
            begin: df.parse('1990-05-01 00:00:00'),
            end: df.parse('1990-05-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
        EnergyMonth(
            begin: df.parse('1990-06-01 00:00:00'),
            end: df.parse('1990-06-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
        EnergyMonth(
            begin: df.parse('1990-07-01 00:00:00'),
            end: df.parse('1990-07-03 23:59:30'),
            days: List<EnergyDay>.from([
              EnergyDay(
                  date: df.parse('1990-01-01 00:00:00'),
                  consumption: day1Consumption),
              EnergyDay(
                  date: df.parse('1990-01-02 00:00:00'),
                  consumption: day2Consumption),
              EnergyDay(
                  date: df.parse('1990-01-03 00:00:00'),
                  consumption: day3Consumption),
            ])),
      ]);
      var widget = makeWidgetTestable(testData: energyMonths);
      await tester.pumpWidget(widget);

      await tester.pumpAndSettle();

      expect(find.text('Overview'), findsOneWidget);
      expect(find.byIcon(FontAwesomeIcons.cog), findsOneWidget);
      expect(find.text('Last Six Months'), findsOneWidget);
      expect(find.text('108.00kWh'), findsOneWidget);
      expect(find.byType(OverviewSummary), findsOneWidget);

      //have to scroll a little bit to make sure sqiddyCard is found
      await tester.drag(find.text('Last Six Months'), Offset(100, -300));
      await tester.pumpAndSettle();
      // // await tester.pump();
      expect(find.widgetWithText(Container, 'Jan 1990'), findsOneWidget);
      expect(find.widgetWithText(Container, 'Feb 1990'), findsOneWidget);

      await tester.drag(find.text('Last Six Months'), Offset(100, -500));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(Container, 'Mar 1990'), findsOneWidget);
      expect(find.widgetWithText(Container, 'Apr 1990'), findsOneWidget);
      expect(find.widgetWithText(Container, 'May 1990'), findsOneWidget);

      await tester.drag(find.text('May 1990'), Offset(100, -500));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(Container, 'Jun 1990'), findsOneWidget);
      expect(find.widgetWithText(Container, 'Jul 1990'), findsOneWidget);
    });
  });
}
