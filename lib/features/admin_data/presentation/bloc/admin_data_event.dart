import 'package:equatable/equatable.dart';

abstract class AdminDataEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAdminDataEvent extends AdminDataEvent {}
