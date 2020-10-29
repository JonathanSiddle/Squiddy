import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsManager extends ChangeNotifier {
  final dynamic _localStore;
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

  Future<bool> cleanSettings() async {
    //update secure store from local values...
    _localStore.write(key: 'apiKey', value: '');
    _localStore.write(key: 'accountId', value: '');
    _localStore.write(key: 'meterPoint', value: '');
    _localStore.write(key: 'meter', value: '');

    //clear in memory values...
    validated = false;
    apiKey = null;
    accountId = null;
    meterPoint = null;
    meter = null;

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
