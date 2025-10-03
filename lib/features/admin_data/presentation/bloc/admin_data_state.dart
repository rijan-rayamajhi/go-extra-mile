import 'package:equatable/equatable.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/monetization_settings.dart';

abstract class AdminDataState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminDataInitial extends AdminDataState {}

class AdminDataLoading extends AdminDataState {}

class AdminDataLoaded extends AdminDataState {
  final AppSettings appSettings;
  final MonetizationSettings monetizationSettings;

  AdminDataLoaded(this.appSettings, this.monetizationSettings);

  @override
  List<Object?> get props => [appSettings, monetizationSettings];
}

class AdminDataError extends AdminDataState {
  final String message;

  AdminDataError(this.message);

  @override
  List<Object?> get props => [message];
}
