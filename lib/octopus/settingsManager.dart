import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsManager extends ChangeNotifier {
  //Keys
  static const String ACTIVE_AGILE_TARIFF_KEY = 'activeAgileTariff';
  static const String SELECTED_AGILE_REGION_KEY = 'selectedAgileRegion';
  static const String SHOW_AGILE_PRICES_KEY = 'showAgilePrices';

  final FlutterSecureStorage _localStore;
  bool _showAgilePrices;
  String _activeAgileTariff;
  String _selectedAgileRegion;
  bool validated = false;
  String apiKey;
  String accountId;
  String meterPoint;
  String meter;

  ThemeBrightness _themeBrightness;

  SettingsManager({localStore})
      : _localStore = localStore ?? FlutterSecureStorage();

  set themeBrightness(ThemeBrightness brightness) {
    _themeBrightness = brightness;
    notifyListeners();
  }

  ThemeBrightness get themeBrightness => _themeBrightness;

  bool get showAgilePrices => _showAgilePrices;
  set showAgilePrices(bool b) {
    _showAgilePrices = b;

    // notifyListeners();
  }

  String get activeAgileTariff => _activeAgileTariff;
  set activeAgileTariff(String s) {
    _activeAgileTariff = s;
    // notifyListeners();
  }

  String get selectedAgileRegion => _selectedAgileRegion;
  set selectedAgileRegion(String s) {
    _selectedAgileRegion = s;
    // notifyListeners();
  }

  saveAgileInformation() {
    saveShowAgilePrices(_showAgilePrices);
    saveActiveAgileTariff(activeAgileTariff);
    saveSelectedAgileRegion(_selectedAgileRegion);
  }

  bool get accountDetailsSet => (apiKey != null &&
      apiKey.trim() != '' &&
      accountId != null &&
      accountId.trim() != '' &&
      meterPoint != null &&
      meterPoint.trim() != '' &&
      meter != null &&
      meter.trim() != '');

  Future<bool> loadSettings() async {
    apiKey = await _localStore.read(key: 'apiKey');
    accountId = await _localStore.read(key: 'accountId');
    meterPoint = await _localStore.read(key: 'meterPoint');
    meter = await _localStore.read(key: 'meter');
    var tBrightness = await _localStore.read(key: 'themeBrightness');
    if (tBrightness == null || tBrightness == 'system') {
      _themeBrightness = ThemeBrightness.SYSTEM;
    } else if (tBrightness == 'light') {
      _themeBrightness = ThemeBrightness.LIGHT;
    } else if (tBrightness == 'dark') {
      _themeBrightness = ThemeBrightness.DARK;
    }
    //try to load agile setttings
    _activeAgileTariff = await _localStore.read(key: ACTIVE_AGILE_TARIFF_KEY);
    _selectedAgileRegion =
        await _localStore.read(key: SELECTED_AGILE_REGION_KEY);
    var showAgileString = await _localStore.read(key: SHOW_AGILE_PRICES_KEY);
    _showAgilePrices = showAgileString == 'true'
        ? true
        : showAgileString == 'false'
            ? false
            : null;

    return accountDetailsSet;
  }

  Future<bool> saveSettings() async {
    //update secure store from local values...
    _localStore.write(key: 'apiKey', value: apiKey);
    _localStore.write(key: 'accountId', value: accountId);
    _localStore.write(key: 'meterPoint', value: meterPoint);
    _localStore.write(key: 'meter', value: meter);

    //if saving settings, assume they are also validated
    validated = true;
    notifyListeners();
    return true;
  }

  Future<bool> saveThemeBrightnessSystem() async {
    await _saveThemeSetting('system');
    return true;
  }

  Future<bool> saveThemeBrightnessLight() async {
    await _saveThemeSetting('light');
    return true;
  }

  Future<bool> saveThemeBrightnessDark() async {
    await _saveThemeSetting('dark');
    return true;
  }

  Future<bool> _saveThemeSetting(String value) async {
    _localStore.write(key: 'themeBrightness', value: value);
    return true;
  }

  Future<bool> saveActiveAgileTariff(String tariff) async {
    await _localStore.write(key: ACTIVE_AGILE_TARIFF_KEY, value: tariff);
    return true;
  }

  Future<bool> saveSelectedAgileRegion(String tariff) async {
    await _localStore.write(key: SELECTED_AGILE_REGION_KEY, value: tariff);
    return true;
  }

  Future<bool> saveShowAgilePrices(bool showPrices) async {
    await _localStore.write(
        key: SHOW_AGILE_PRICES_KEY, value: showPrices.toString());
    return true;
  }

  Future<bool> cleanSettings() async {
    //update secure store from local values...
    _localStore.write(key: 'apiKey', value: '');
    _localStore.write(key: 'accountId', value: '');
    _localStore.write(key: 'meterPoint', value: '');
    _localStore.write(key: 'meter', value: '');
    _localStore.write(key: ACTIVE_AGILE_TARIFF_KEY, value: '');
    _localStore.write(key: SELECTED_AGILE_REGION_KEY, value: '');
    _localStore.write(key: SHOW_AGILE_PRICES_KEY, value: '');

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
    switch (this) {
      case ThemeBrightness.SYSTEM:
        sm.saveThemeBrightnessSystem();
        break;
      case ThemeBrightness.LIGHT:
        sm.saveThemeBrightnessLight();
        break;
      case ThemeBrightness.DARK:
        sm.saveThemeBrightnessDark();
        break;
      default:
        return Brightness.light;
        break;
    }
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
