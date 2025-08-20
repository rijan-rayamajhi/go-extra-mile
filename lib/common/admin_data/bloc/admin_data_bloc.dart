import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_data_event.dart';
import 'admin_data_state.dart';
import '../domain/entities/app_settings.dart';
import '../domain/usecases/get_app_settings.dart';
import '../domain/usecases/get_gem_coin.dart';
import '../domain/usecases/get_user_interests.dart';
import '../domain/usecases/get_vehicle_brand.dart';
import '../domain/usecases/get_vehicle_brand_by_id.dart';

class AdminDataBloc extends Bloc<AdminDataEvent, AdminDataState> {
  final GetAppSettings getAppSettings;
  final GetGemCoin getGemCoin;
  final GetUserInterests getUserInterests;
  final GetVehicleBrand getVehicleBrands;
  final GetVehicleBrandById getVehicleBrandById;

  AdminDataBloc({
    required this.getAppSettings, 
    required this.getGemCoin, 
    required this.getUserInterests,
    required this.getVehicleBrands,
    required this.getVehicleBrandById,
  }) : super(AdminDataInitial()) {
    on<LoadAppSettings>((event, emit) async {
      emit(AdminDataLoading());
      try {
        final appSettings = await getAppSettings();
        emit(AdminDataLoaded(appSettings));
      } catch (e) {
        print(e);
        emit(AdminDataError(e.toString()));
      }
    });

    on<LoadGemCoin>((event, emit) async {
      emit(AdminDataLoading());
      try {
        final gemCoin = await getGemCoin();
        // Get current state to preserve app settings if available
        final currentState = state;
        if (currentState is AdminDataLoaded) {
          emit(AdminDataLoaded(currentState.appSettings, gemCoin: gemCoin));
        } else {
          // If no app settings loaded yet, create a default loaded state with gem coin
          emit(AdminDataLoaded(
            AppSettings(
              appName: '',
              appVersion: '',
              appDescription: '',
              appTagline: '',
              termsAndConditions: '',
              contactEmail: '',
              contactPhone: '',
              website: '',
              supportEmail: '',
              socialMedia: SocialMedia(
                facebook: '',
                twitter: '',
                instagram: '',
                linkedin: '',
                youtube: '',
                whatsapp: '',
              ),
              lastUpdated: DateTime.now(),
              createdBy: '',
              isActive: true, referAndEarnText: '', totalDistance: '0', totalGemCoins: '0', totalRides: '0',
            ),
            gemCoin: gemCoin,
          ));
        }
      } catch (e) {
        print(e);
        emit(AdminDataError(e.toString()));
      }
    });

    on<LoadUserInterests>((event, emit) async {
      emit(AdminDataLoading());
      try {
        final userInterests = await getUserInterests();
        // Get current state to preserve existing data if available
        final currentState = state;
        if (currentState is AdminDataLoaded) {
          emit(AdminDataLoaded(
            currentState.appSettings, 
            gemCoin: currentState.gemCoin,
            userInterests: userInterests,
          ));
        } else {
          // If no data loaded yet, create a default loaded state with user interests
          emit(AdminDataLoaded(
            AppSettings(
              appName: '',
              appVersion: '',
              appDescription: '',
              appTagline: '',
              termsAndConditions: '',
              contactEmail: '',
              contactPhone: '',
              website: '',
              supportEmail: '',
              socialMedia: SocialMedia(
                facebook: '',
                twitter: '',
                instagram: '',
                linkedin: '',
                youtube: '',
                whatsapp: '',
              ),
              lastUpdated: DateTime.now(),
              createdBy: '',
              isActive: true, referAndEarnText: '', totalDistance: '0', totalGemCoins: '0', totalRides: '0',
            ),
            userInterests: userInterests,
          ));
        }
      } catch (e) {
        print(e);
        emit(AdminDataError(e.toString()));
      }
    });

    on<LoadVehicleBrands>((event, emit) async {
      emit(AdminDataLoading());
      try {
        final vehicleBrands = await getVehicleBrands();
        // Get current state to preserve existing data if available
        final currentState = state;
        if (currentState is AdminDataLoaded) {
          emit(AdminDataLoaded(
            currentState.appSettings, 
            gemCoin: currentState.gemCoin,
            userInterests: currentState.userInterests,
            vehicleBrands: vehicleBrands,
          ));
        } else {
          // If no data loaded yet, create a default loaded state with vehicle brands
          emit(AdminDataLoaded(
            AppSettings(
              appName: '',
              appVersion: '',
              appDescription: '',
              appTagline: '',
              termsAndConditions: '',
              contactEmail: '',
              contactPhone: '',
              website: '',
              supportEmail: '',
              socialMedia: SocialMedia(
                facebook: '',
                twitter: '',
                instagram: '',
                linkedin: '',
                youtube: '',
                whatsapp: '',
              ),
              lastUpdated: DateTime.now(),
              createdBy: '',
              isActive: true, referAndEarnText: '', totalDistance: '0', totalGemCoins: '0', totalRides: '0',
            ),
            vehicleBrands: vehicleBrands,
          ));
        }
      } catch (e) {
        print(e);
        emit(AdminDataError(e.toString()));
      }
    });

    on<LoadVehicleBrandById>((event, emit) async {
      emit(AdminDataLoading());
      try {
        final vehicleBrand = await getVehicleBrandById(event.id);
        // Get current state to preserve existing data if available
        final currentState = state;
        if (currentState is AdminDataLoaded) {
          emit(AdminDataLoaded(
            currentState.appSettings, 
            gemCoin: currentState.gemCoin,
            userInterests: currentState.userInterests,
            vehicleBrands: currentState.vehicleBrands,
            selectedVehicleBrand: vehicleBrand,
          ));
        } else {
          // If no data loaded yet, create a default loaded state with selected vehicle brand
          emit(AdminDataLoaded(
            AppSettings(
              appName: '',
              appVersion: '',
              appDescription: '',
              appTagline: '',
              termsAndConditions: '',
              contactEmail: '',
              contactPhone: '',
              website: '',
              supportEmail: '',
              socialMedia: SocialMedia(
                facebook: '',
                twitter: '',
                instagram: '',
                linkedin: '',
                youtube: '',
                whatsapp: '',
              ),
              lastUpdated: DateTime.now(),
              createdBy: '',
              isActive: true, referAndEarnText: '', totalDistance: '0', totalGemCoins: '0', totalRides: '0',
            ),
            selectedVehicleBrand: vehicleBrand,
          ));
        }
      } catch (e) {
        print(e);
        emit(AdminDataError(e.toString()));
      }
    });
  }
} 