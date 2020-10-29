import 'package:flutter/widgets.dart';

class LocalStore {
  var store = Map<String, String>();

  Future<String> read({@required String key}) {
    return Future.value(store[key]);
  }

  Future<void> write({@required String key, @required String value}) {
    store[key] = value;
    return Future.value();
  }
}
