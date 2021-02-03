import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/routes/bootstrap.dart';
import 'package:squiddy/routes/monthsOverview.dart';

import 'octopus/octopusEnergyClient.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var settingsManager = SettingsManager();
  var octoManager = OctopusManager();
  await settingsManager.loadSettings();
  if (settingsManager.accountDetailsSet) {
    //if previously save details, assume they have been validated
    settingsManager.validated = true;
  }

  var bootstrap = MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsManager>(create: (_) => settingsManager),
      ChangeNotifierProvider<OctopusManager>(create: (_) => octoManager),
    ],
    child: MyApp(),
  );

  runApp(bootstrap);
}

/// Assumes the given path is a text-file-asset.
Future<String> getFileData(String path) async {
  return await rootBundle.loadString(path);
}

class MyApp extends StatefulWidget {
  MyApp();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  OctopusManager octoManager;
  SettingsManager settings;
  Brightness defaultBrightness;

  _MyAppState();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    settings = Provider.of<SettingsManager>(context, listen: true);
    octoManager = Provider.of<OctopusManager>(context);
    if (settings.accountDetailsSet && settings.validated) {
      if (octoManager != null &&
          !octoManager.initialised &&
          !octoManager.errorGettingData) {
        print('Initialising octoManager data');
        print('Using meterpoint: ${settings.meterPoint}');
        octoManager.initData(
            apiKey: settings.apiKey,
            accountId: settings.accountId,
            meterPoint: settings.meterPoint,
            meter: settings.meter,
            updateAccountSettings: (EnergyAccount ea) {
              if (settings.showAgilePrices == null) {
                if (ea.hasActiveAgileAccount()) {
                  settings.showAgilePrices = true;
                  settings.activeAgileTariff = ea.getAgileTariffCode();
                }
              } else if (settings.showAgilePrices) {
                if (ea.hasActiveAgileAccount() &&
                    settings.selectedAgileRegion == 'AT') {
                  settings.showAgilePrices = true;
                  settings.activeAgileTariff = ea.getAgileTariffCode();
                } else if (settings.selectedAgileRegion != null &&
                    settings.selectedAgileRegion != '') {
                  settings.activeAgileTariff =
                      'E-1R-AGILE-18-02-21${settings.selectedAgileRegion}';
                }
              } else {
                settings.activeAgileTariff = '';
                settings.selectedAgileRegion = '';
              }
              settings.saveAgileInformation();
            });
      }
    }

    //try to get saved theme
    var themeBrightness = settings.themeBrightness;
    defaultBrightness = themeBrightness.toBrightness();

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    var settingsManager = Provider.of<SettingsManager>(context);

    return DynamicTheme(
        defaultBrightness: defaultBrightness ?? Brightness.dark,
        data: (brightness) =>
            SquiddyTheme.defaultSquiddyTheme(brightness: brightness),
        themedWidgetBuilder: (context, theme) {
          return AnnotatedRegion(
            value: defaultBrightness == Brightness.light
                ? SystemUiOverlayStyle.dark
                : SystemUiOverlayStyle.light,
            child: MaterialApp(
              title: 'Squiddy',
              theme: theme, // home: ConsumptionList('Squiddy'),
              // need to return a widget that rebuilds
              navigatorObservers: <NavigatorObserver>[],
              home: (settingsManager.accountDetailsSet &&
                      settingsManager.validated)
                  ? Consumer<OctopusManager>(
                      builder: (_, om, child) {
                        return Scaffold(
                          appBar: null,
                          body: om.initialised && !om.errorGettingData
                              ? ProxyProvider<OctopusManager,
                                  List<EnergyMonth>>(
                                  update: (_, om, __) => om.monthConsumption,
                                  child: MonthsOverview(),
                                )
                              : om.timeoutError
                                  ? timeoutErrorView()
                                  : om.errorGettingData
                                      ? errorView(settingsManager)
                                      : Center(
                                          child: CircularProgressIndicator()),
                        );
                      },
                    )
                  : Scaffold(
                      body: BootStrap(),
                    ),
            ),
          );
        });
  }

  Widget timeoutErrorView() {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  FontAwesomeIcons.sadTear,
                  size: 55,
                  color: SquiddyTheme.squiddyPrimary,
                ),
              ),
              Center(
                  child: Text(
                      "uh oh, taking readings was taking an unexpectedly long time.")),
              Text(
                  'If the problem continues, try loging out and logging back in'),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: RaisedButton(
                    child: Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: SquiddyTheme.squiddySecondary,
                    onPressed: () async {
                      setState(() {
                        octoManager.retryLogin();
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: RaisedButton(
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.red,
                    onPressed: () async {
                      await settings.cleanSettings();
                    }),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget errorView(SettingsManager settingsManager) {
    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Icon(
                  FontAwesomeIcons.sadTear,
                  size: 55,
                  color: SquiddyTheme.squiddyPrimary,
                ),
              ),
              Text('Uh oh, there is no data here or something went wrong!'),
              Text('If the problem continues try:'),
              Text(''),
              Text('- Checking connection'),
              Text('- Logging in again'),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: RaisedButton(
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.red,
                    onPressed: () async {
                      await settingsManager.cleanSettings();
                    }),
              )
            ],
          ),
        ],
      ),
    );
  }
}
