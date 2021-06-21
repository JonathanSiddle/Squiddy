import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/dataClasses/AgilePrice.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/octopus/secureStore.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/widgets/agilePriceCard.dart';
import 'package:squiddy/widgets/agilePriceList.dart';

import '../routes/mocks.dart';

main() {
  Future<Widget> makeWidgetTestable(
      {@required OctopusEneryClient octoEnergyClient,
      @required SquiddyDataStore store}) async {
    var octoManager = OctopusManager(octopusEnergyClient: octoEnergyClient);
    var settingsManager = SettingsManager(localStore: store);
    settingsManager.activeAgileTariff = 'testTariff';
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('test')),
        body: MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingsManager>(
                create: (_) => settingsManager),
            ChangeNotifierProvider<OctopusManager>(create: (_) => octoManager),
          ],
          child: AgilePriceSection(),
        ),
      ),
    );
  }

  group('Get data back from agile prices', () {
    testWidgets('Shows loading then displays cards when gets readings back',
        (WidgetTester tester) async {
      var agilePrices = [
        AgilePrice(
            validFrom: DateTime(2990, 1, 1, 9, 0),
            validTo: DateTime(2990, 1, 1, 9, 30),
            valueExcVat: 10.0,
            valueIncVat: 11),
        AgilePrice(
            validFrom: DateTime(2990, 1, 1, 9, 30),
            validTo: DateTime(2990, 1, 1, 10, 0),
            valueExcVat: 10.0,
            valueIncVat: 11),
      ];
      var ec = MockOctopusEnergyCLient();
      when(ec.getAgilePrices(tariffCode: anyNamed('tariffCode')))
          .thenAnswer((_) => Future.value(agilePrices));
      var ls = MockLocalStore();
      var widget = await makeWidgetTestable(octoEnergyClient: ec, store: ls);
      await tester.pumpWidget(widget);

      expect(find.byType(AgilePriceCard), findsNWidgets(4));

      //check loading is displayed
      await tester.pumpWidget(widget);

      expect(find.byType(AgilePriceCard), findsNWidgets(2));
      expect(find.text('09:00'), findsOneWidget);
      expect(find.text('09:30'), findsOneWidget);
    });

    testWidgets('Show error if fails to get data', (WidgetTester tester) async {
      var ec = MockOctopusEnergyCLient();
      when(ec.getAgilePrices(tariffCode: anyNamed('tariffCode')))
          .thenAnswer((_) => Future.error('Error getting data'));
      var ls = MockLocalStore();
      var widget = await makeWidgetTestable(octoEnergyClient: ec, store: ls);
      await tester.pumpWidget(widget);

      expect(find.byType(AgilePriceCard), findsNWidgets(4));

      //check loading is displayed
      await tester.pumpWidget(widget);

      expect(find.text('Uh oh, could not get Agile prices'), findsOneWidget);
    });
  });
}
