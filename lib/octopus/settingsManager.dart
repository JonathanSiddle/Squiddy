import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:squiddy/octopus/secureStore.dart';

class SettingsManager extends ChangeNotifier {
  static const String READING_box = 'readings';
  //Keys
  static const String ACTIVE_AGILE_TARIFF_KEY = 'activeAgileTariff';
  static const String SELECTED_AGILE_REGION_KEY = 'selectedAgileRegion';
  static const String SHOW_AGILE_PRICES_KEY = 'showAgilePrices';
  static const String APIKEY_KEY = 'APIKey';
  static const String ACCOUNTID_KEY = 'AccountID';
  static const String METER_POINT_KEY = 'MeterPoint';
  static const String METER_KEY = 'Meter';
  static const String THEME_BRIGHTNESS_KEY = 'THEME_BRIGHTNESS';

  final SquiddyDataStore localStore;
  bool _showAgilePrices;
  String _activeAgileTariff;
  String _selectedAgileRegion;
  bool validated = false;
  String apiKey;
  String accountId;
  String meterPoint;
  String meter;

  ThemeBrightness _themeBrightness;

  SettingsManager({this.localStore, Map<String, dynamic> settingsMap}) {
    _setValuesFromMap(settingsMap);
  }

  _setValuesFromMap(Map<String, dynamic> settings) {
    _showAgilePrices = settings[SHOW_AGILE_PRICES_KEY] == 'true' ? true : false;
    _activeAgileTariff = settings[ACTIVE_AGILE_TARIFF_KEY];
    _selectedAgileRegion = settings[SELECTED_AGILE_REGION_KEY];
    _themeBrightness = _parseThemeBrightness(settings[THEME_BRIGHTNESS_KEY]);
    apiKey = settings[APIKEY_KEY];
    accountId = settings[ACCOUNTID_KEY];
    meterPoint = settings[METER_POINT_KEY];
    meter = settings[METER_KEY];
  }

  ThemeBrightness _parseThemeBrightness(String brightness) {
    ThemeBrightness tBright;

    if (brightness == null || brightness == 'system') {
      tBright = ThemeBrightness.SYSTEM;
    } else if (brightness == 'light') {
      tBright = ThemeBrightness.LIGHT;
    } else if (brightness == 'dark') {
      tBright = ThemeBrightness.DARK;
    }

    return tBright;
  }

  Map<String, String> _valuesToMap() {
    return {
      SHOW_AGILE_PRICES_KEY: showAgilePrices.toString(),
      ACTIVE_AGILE_TARIFF_KEY: _activeAgileTariff,
      SELECTED_AGILE_REGION_KEY: _selectedAgileRegion,
      THEME_BRIGHTNESS_KEY: _themeBrightness.niceString(),
      APIKEY_KEY: apiKey,
      ACCOUNTID_KEY: accountId,
      METER_POINT_KEY: meterPoint,
      METER_KEY: meter,
    };
  }

  set themeBrightness(ThemeBrightness brightness) {
    _themeBrightness = brightness;
    notifyListeners();
  }

  ThemeBrightness get themeBrightness => _themeBrightness;

  // ignore: unnecessary_getters_setters
  bool get showAgilePrices => _showAgilePrices;
  // ignore: unnecessary_getters_setters
  set showAgilePrices(bool b) {
    _showAgilePrices = b;
  }

  // ignore: unnecessary_getters_setters
  String get activeAgileTariff => _activeAgileTariff;
  // ignore: unnecessary_getters_setters
  set activeAgileTariff(String s) {
    _activeAgileTariff = s;
  }

  // ignore: unnecessary_getters_setters
  String get selectedAgileRegion => _selectedAgileRegion;
  // ignore: unnecessary_getters_setters
  set selectedAgileRegion(String s) {
    _selectedAgileRegion = s;
  }

  // saveAgileInformation() {
  //   saveShowAgilePrices(_showAgilePrices);
  //   saveActiveAgileTariff(activeAgileTariff);
  //   saveSelectedAgileRegion(_selectedAgileRegion);
  // }

  bool get accountDetailsSet => (apiKey != null &&
      apiKey.trim() != '' &&
      accountId != null &&
      accountId.trim() != '' &&
      meterPoint != null &&
      meterPoint.trim() != '' &&
      meter != null &&
      meter.trim() != '');

  // Future<bool> loadSettings() async {
  //   apiKey = await _localStore.read(key: 'apiKey');
  //   accountId = await _localStore.read(key: 'accountId');
  //   meterPoint = await _localStore.read(key: 'meterPoint');
  //   meter = await _localStore.read(key: 'meter');
  //   var tBrightness = await _localStore.read(key: 'themeBrightness');
  //   if (tBrightness == null || tBrightness == 'system') {
  //     _themeBrightness = ThemeBrightness.SYSTEM;
  //   } else if (tBrightness == 'light') {
  //     _themeBrightness = ThemeBrightness.LIGHT;
  //   } else if (tBrightness == 'dark') {
  //     _themeBrightness = ThemeBrightness.DARK;
  //   }
  //   //try to load agile setttings
  //   _activeAgileTariff = await _localStore.read(key: ACTIVE_AGILE_TARIFF_KEY);
  //   _selectedAgileRegion =
  //       await _localStore.read(key: SELECTED_AGILE_REGION_KEY);
  //   var showAgileString = await _localStore.read(key: SHOW_AGILE_PRICES_KEY);
  //   _showAgilePrices = showAgileString == 'true'
  //       ? true
  //       : showAgileString == 'false'
  //           ? false
  //           : null;

  //   return accountDetailsSet;
  // }

  Future<bool> saveSettings() async {
    //update secure store from local values...
    var settingsMap = _valuesToMap();
    await localStore.write(data: json.encode(settingsMap));

    //if saving settings, assume they are also validated
    validated = true;
    notifyListeners();
    return true;
  }

  // Future<bool> saveActiveAgileTariff(String tariff) async {
  //   if (tariff == null) return false;
  //   await _localStore.write(key: ACTIVE_AGILE_TARIFF_KEY, value: tariff);
  //   return true;
  // }

  // Future<bool> saveSelectedAgileRegion(String tariff) async {
  //   if (tariff == null) return false;
  //   await _localStore.write(
  //       key: SELECTED_AGILE_REGION_KEY, value: _selectedAgileRegion);
  //   return true;
  // }

  // Future<bool> saveShowAgilePrices(bool showPrices) async {
  //   if (showPrices == null) return false;
  //   await _localStore.write(
  //       key: SHOW_AGILE_PRICES_KEY, value: showPrices.toString());
  //   return true;
  // }

  Future<bool> cleanSettings() async {
    //update secure store from local values...
    await localStore.clearSettings();
    //clear in memory values...
    validated = false;
    apiKey = null;
    accountId = null;
    meterPoint = null;
    meter = null;
    //agile vars
    _activeAgileTariff = null;
    _selectedAgileRegion = null;
    _showAgilePrices = null;

    notifyListeners();
    return true;
  }
}

enum ThemeBrightness { SYSTEM, LIGHT, DARK }

extension ThemeHelper on ThemeBrightness {
  Brightness toBrightness() {
    Brightness brightness;
    switch (this) {
      case ThemeBrightness.SYSTEM:
        var systemBrightness =
            SchedulerBinding.instance.window.platformBrightness;
        if (systemBrightness != null) {
          brightness = systemBrightness;
        }
        break;
      case ThemeBrightness.LIGHT:
        brightness = Brightness.light;
        break;
      case ThemeBrightness.DARK:
        brightness = Brightness.dark;
        break;
      default:
        return Brightness.light;
        break;
    }

    return brightness;
  }

  saveSetting(SettingsManager sm) {
    sm.themeBrightness = this;
    sm.saveSettings();
  }

  String niceString() {
    var returnString;
    switch (this) {
      case ThemeBrightness.SYSTEM:
        returnString = 'System';
        break;
      case ThemeBrightness.LIGHT:
        returnString = 'Light';
        break;
      case ThemeBrightness.DARK:
        returnString = 'Dark';
        break;
    }
    return returnString;
  }
}
