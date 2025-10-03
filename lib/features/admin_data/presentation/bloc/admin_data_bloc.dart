import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_admin_data.dart';
import '../../domain/usecases/get_monetization_settings.dart';
import 'admin_data_event.dart';
import 'admin_data_state.dart';

class AdminDataBloc extends Bloc<AdminDataEvent, AdminDataState> {
  final GetAdminData getAdminData;
  final GetMonetizationSettings getMonetizationSettings;

  AdminDataBloc({
    required this.getAdminData,
    required this.getMonetizationSettings,
  }) : super(AdminDataInitial()) {
    on<FetchAdminDataEvent>(_onFetchAdminData);
  }

  Future<void> _onFetchAdminData(
    FetchAdminDataEvent event,
    Emitter<AdminDataState> emit,
  ) async {
    emit(AdminDataLoading());
    try {
      final appSettings = await getAdminData();
      final monetizationSettings = await getMonetizationSettings();
      emit(AdminDataLoaded(appSettings, monetizationSettings));
    } catch (e) {
      emit(AdminDataError(e.toString()));
    }
  }
}
