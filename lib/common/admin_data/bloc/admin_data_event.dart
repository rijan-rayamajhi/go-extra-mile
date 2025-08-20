import 'package:equatable/equatable.dart';

abstract class AdminDataEvent extends Equatable {
  const AdminDataEvent();
  @override
  List<Object?> get props => [];
}

class LoadAppSettings extends AdminDataEvent {}
class LoadGemCoin extends AdminDataEvent {}
class LoadUserInterests extends AdminDataEvent {}
class LoadVehicleBrands extends AdminDataEvent {}
class LoadVehicleBrandById extends AdminDataEvent {
  final String id;
  const LoadVehicleBrandById(this.id);
  
  @override
  List<Object?> get props => [id];
} 