import 'package:equatable/equatable.dart';

abstract class EnergyMonthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class EnergyMonthFetched extends EnergyMonthEvent {}
