import 'package:scoped_model/scoped_model.dart';
import 'package:squiddy/octopus/octopusEnergyClient.dart';

class Clients extends Model {
  OctopusEneryClient octopusEnery;

  Clients(this.octopusEnery);
}
