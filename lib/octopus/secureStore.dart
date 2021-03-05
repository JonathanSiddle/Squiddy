import 'package:biometric_storage/biometric_storage.dart';
import 'package:flutter/widgets.dart';

abstract class SquiddyDataStore {
  Future<bool> write({@required String data});
  Future<bool> clearSettings();
}

class SecureStore implements SquiddyDataStore {
  BiometricStorageFile storageFile;

  SecureStore({@required this.storageFile});

  @override
  Future<bool> write({String data}) async {
    await storageFile.write(data);
    return true;
  }

  @override
  Future<bool> clearSettings() async {
    await storageFile.delete();
    return true;
  }
}
