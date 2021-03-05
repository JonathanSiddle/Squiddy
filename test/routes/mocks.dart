import 'package:mockito/mockito.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';
import 'package:squiddy/octopus/secureStore.dart';

class MockLocalStore extends Mock implements SquiddyDataStore {}

class MockOctopusEnergyCLient extends Mock implements OctopusEneryClient {}
