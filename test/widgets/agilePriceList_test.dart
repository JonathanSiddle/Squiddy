import 'package:fake_async/fake_async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/widgets/agilePriceCard.dart';
import 'package:squiddy/widgets/agilePriceList.dart';

import '../routes/mocks.dart';

main() {
  Future<Widget> makeWidgetTestable(
      {@required OctopusEneryClient octoEnergyClient,
      @required FlutterSecureStorage store}) async {
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
          child: AgilePriceList(),
        ),
      ),
    );
  }

  group('Get data back from agile prices', () {
    testWidgets('Can display list, got readings back',
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
      when(ec.getCurrentAgilePrices(tariffCode: anyNamed('tariffCode')))
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
  });
}
