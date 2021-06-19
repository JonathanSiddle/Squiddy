import 'dart:convert';

import 'package:biometric_storage/biometric_storage.dart';
import 'package:dynamic_theme/dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show PlatformException, SystemUiOverlayStyle, rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:squiddy/Theme/SquiddyTheme.dart';
import 'package:squiddy/octopus/AgilePriceRepo.dart';
import 'package:squiddy/octopus/EnergyConsumptionRepo.dart';
import 'package:squiddy/octopus/OctopusManager.dart';
import 'package:squiddy/octopus/dataClasses/AgilePrice.dart';
import 'package:squiddy/octopus/dataClasses/ElectricityAccount.dart';
import 'package:squiddy/octopus/dataClasses/EnergyConsumption.dart';
import 'package:squiddy/octopus/secureStore.dart';
import 'package:squiddy/octopus/settingsManager.dart';
import 'package:squiddy/routes/bootstrap.dart';
import 'package:squiddy/routes/monthsOverview.dart';

import '.env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //init hive data store
  await Hive.initFlutter();
  //register type adapters
  Hive.registerAdapter(EnergyConsumptionAdapter());
  Hive.registerAdapter(AgilePriceAdapter());

  //open boxes
  var readingBox =
      await Hive.openBox<EnergyConsumption>(SettingsManager.READING_BOX);
  var pricingBox = await Hive.openBox<AgilePrice>(SettingsManager.PRICE_BOX);
  // pricingBox.deleteFromDisk();
  // readingBox.deleteFromDisk();

  //init error logging
  var sentryURL = environment['sentryURL'] ?? ' ';

  final canAuthenticate = await BiometricStorage().canAuthenticate();
  BiometricStorageFile secureData;
  if (canAuthenticate == CanAuthenticateResponse.success) {
    secureData = await BiometricStorage().getStorage('squiddy_data',
        options: StorageFileInitOptions(authenticationRequired: false));
  } else {
    throw PlatformException(
        code: '1', message: 'Platform does not support authenticated storage');
  }

  var rawData = await secureData.read();

  var settingsManager = SettingsManager(
      localStore: SecureStore(storageFile: secureData),
      settingsMap: rawData == null ? {} : json.decode(rawData));

  var octoManager = OctopusManager(
      priceRepo: AgilePriceHiveRepo(store: pricingBox),
      readingRepo: EnergyConsumptionHiveRepo(store: readingBox),
      logErrors: true);
  // await settingsManager.loadSettings();
  if (settingsManager.accountDetailsSet) {
    //if previously save details, assume they have been validated
    settingsManager.validated = true;
  }

  await settingsManager.saveSettings();

  var bootstrap = MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsManager>(create: (_) => settingsManager),
      ChangeNotifierProvider<OctopusManager>(create: (_) => octoManager),
    ],
    child: MyApp(),
  );

  await SentryFlutter.init((options) {
    options.dsn = sentryURL;
  }, appRunner: () => runApp(bootstrap));
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
  void didChangeDependencies() async {
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
            activeAgileTariff: settings.activeAgileTariff,
            updateAccountSettings: (EnergyAccount ea) {
              if (settings.showAgilePrices == null) {
                if (ea.hasActiveAgileAccount()) {
                  settings.showAgilePrices = true;
                  settings.activeAgileTariff = ea.getAgileTariffCode();
                  settings.selectedAgileRegion = 'AT';
                }
              } else if (settings.showAgilePrices) {
                if (settings.selectedAgileRegion != null &&
                    settings.selectedAgileRegion != '' &&
                    settings.selectedAgileRegion != 'AT') {
                  settings.activeAgileTariff =
                      'E-1R-AGILE-18-02-21${settings.selectedAgileRegion}';
                } else if (ea.hasActiveAgileAccount()) {
                  settings.showAgilePrices = true;
                  settings.activeAgileTariff = ea.getAgileTariffCode();
                  settings.selectedAgileRegion = 'AT';
                }
              } else {
                settings.activeAgileTariff = '';
                settings.selectedAgileRegion = '';
              }
              settings.saveSettings();
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
              // showPerformanceOverlay: true,
              theme: theme, // home: ConsumptionList('Squiddy'),
              // need to return a widget that rebuilds
              navigatorObservers: <NavigatorObserver>[],
              home: (settingsManager.accountDetailsSet &&
                      settingsManager.validated)
                  ? Scaffold(
                      appBar: null,
                      body: MonthsOverview(),
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
                "Getting readings taking a long time.",
                softWrap: true,
              )),
              Text(
                'If the problem continues',
                softWrap: true,
              ),
              Text(
                'Try loging out and logging back in',
                softWrap: true,
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                    child: Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            SquiddyTheme.squiddySecondary)),
                    onPressed: () async {
                      setState(() {
                        octoManager.retryLogin();
                      });
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            SquiddyTheme.squiddySecondary)),
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
                child: ElevatedButton(
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            SquiddyTheme.squiddySecondary)),
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
