import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/mockito.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

class MockLocalStore extends Mock implements FlutterSecureStorage {}
class MockOctopusEnergyCLient extends Mock implements OctopusEneryClient {}