import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  var sentryURL = Platform.environment['sentryURL'];
  print('Sentry URL: $sentryURL');
  final config = {
    'sentryURL': sentryURL,
  };

  final filename = 'lib/.env.dart';
  File(filename).writeAsString('final environment = ${json.encode(config)};');
}
