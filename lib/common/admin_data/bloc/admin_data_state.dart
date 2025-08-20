import 'package:equatable/equatable.dart';
import '../domain/entities/app_settings.dart';
import '../domain/entities/gem_coin.dart';
import '../domain/entities/user_interest.dart';
import '../domain/entities/vehicle_brand.dart';

abstract class AdminDataState extends Equatable {
  const AdminDataState();
  @override
  List<Object?> get props => [];
}

class AdminDataInitial extends AdminDataState {}
class AdminDataLoading extends AdminDataState {}
class AdminDataLoaded extends AdminDataState {
  final AppSettings appSettings;
  final GemCoin? gemCoin;
  final UserInterestsData? userInterests;
  final Map<String, VehicleBrand>? vehicleBrands;
  final VehicleBrand? selectedVehicleBrand;
  const AdminDataLoaded(this.appSettings, {this.gemCoin, this.userInterests, this.vehicleBrands, this.selectedVehicleBrand});
  @override
  List<Object?> get props => [appSettings, gemCoin, userInterests, vehicleBrands, selectedVehicleBrand];
}
class AdminDataError extends AdminDataState {
  final String message;
  const AdminDataError(this.message);
  @override
  List<Object?> get props => [message];
} 