import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../service/firebase_firestore_service.dart';
import '../service/firebase_storage_service.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/datasources/user_firestore_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_with_google.dart';
import '../../features/auth/domain/usecases/sign_in_with_apple.dart';
import '../../features/auth/domain/usecases/check_if_user_exists.dart';
import '../../features/auth/domain/usecases/check_if_account_deleted.dart';
import '../../features/auth/domain/usecases/create_new_user.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/delete_account.dart';
import '../../features/auth/domain/usecases/restore_account.dart';
import '../../features/auth/domain/usecases/update_fcm_token.dart';
import '../../features/auth/domain/usecases/clear_fcm_token.dart';
import '../../features/auth/presentation/bloc/kauth_bloc.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/check_username_availability.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/ride/data/datasources/ride_firestore_datasource.dart';
import '../../features/ride/data/datasources/ride_local_datasource.dart';
import '../../features/ride/data/repositories/ride_repository_impl.dart';
import '../../features/ride/domain/repositories/ride_repository.dart';
import '../../features/ride/domain/usecases/get_all_rides_by_user_id.dart';
import '../../features/ride/domain/usecases/get_recent_rides_by_user_id.dart';
import '../../features/ride/domain/usecases/upload_ride.dart';
import '../../features/ride/domain/usecases/get_recent_ride_memories_by_user_id.dart';
import '../../features/ride/domain/usecases/save_ride_locally.dart';
import '../../features/ride/domain/usecases/get_ride_locally.dart';
import '../../features/ride/presentation/bloc/ride_bloc.dart';
import '../../features/license/data/repositories/driving_license_repository_impl.dart';
import '../../features/license/domain/repositories/driving_license_repository.dart';
import '../../features/license/domain/usecases/get_driving_license.dart';
import '../../features/license/domain/usecases/submit_driving_license.dart';
import '../../features/license/presentation/bloc/driving_license_bloc.dart';
import '../../features/gem_coin/data/datasource/gem_coin_remote_datasource.dart';
import '../../features/gem_coin/data/repository/gem_coin_repository_impl.dart';
import '../../features/gem_coin/domain/repositories/gem_coin_repository.dart';
import '../../features/gem_coin/domain/usecases/get_transaction_history.dart';
import '../../features/gem_coin/presentation/bloc/gem_coin_bloc.dart';
import '../../common/admin_data/data/repository/admin_data_repository_impl.dart';
import '../../common/admin_data/domain/repository/admin_data_repository.dart';
import '../../common/admin_data/domain/usecases/get_app_settings.dart';
import '../../common/admin_data/domain/usecases/get_gem_coin.dart';
import '../../common/admin_data/domain/usecases/get_user_interests.dart';
import '../../common/admin_data/domain/usecases/get_vehicle_brand.dart';
import '../../common/admin_data/domain/usecases/get_vehicle_brand_by_id.dart';
import '../../common/admin_data/bloc/admin_data_bloc.dart';
import '../../features/vehicle/data/datasource/vehicle_firestore_datasource.dart';
import '../../features/vehicle/data/repositories/vehicle_repository_impl.dart';
import '../../features/vehicle/domain/repositories/vehicle_repository.dart';
import '../../features/vehicle/domain/usecases/add_vehicle.dart';
import '../../features/vehicle/domain/usecases/get_user_vehicles.dart';
import '../../features/vehicle/domain/usecases/delete_vehicle.dart';
import '../../features/vehicle/domain/usecases/upload_vehicle_image.dart';
import '../../features/vehicle/domain/usecases/delete_vehicle_image.dart';
import '../../features/vehicle/domain/usecases/verify_vehicle.dart';
import '../../features/vehicle/presentation/bloc/vehicle_bloc.dart';
import '../../features/notification/data/datasources/notification_remote_datasource.dart';
import '../../features/notification/data/repositories/notification_repository_impl.dart';
import '../../features/notification/domain/notification_repository.dart';
import '../../features/notification/domain/usecases/get_notifications.dart';
import '../../features/notification/domain/usecases/get_notification_by_id.dart';
import '../../features/notification/domain/usecases/mark_as_read.dart';
import '../../features/notification/domain/usecases/mark_all_as_read.dart';
import '../../features/notification/domain/usecases/delete_notification.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/referral/data/datasources/referral_remote_datasource.dart';
import '../../features/referral/data/repositories/referral_repository_impl.dart';
import '../../features/referral/domain/referal_repositories.dart';
import '../../features/referral/domain/usecases/submit_referral_code.dart';
import '../../features/referral/domain/usecases/get_my_referral_data.dart';
import '../../features/referral/presentation/bloc/referral_bloc.dart';
import '../../features/home/data/home_reposotries_impl.dart';
import '../../features/home/domain/home_repositories.dart';
import '../../features/home/domain/usecases/get_user_profile_image.dart';
import '../../features/home/domain/usecases/get_unread_notification.dart';
import '../../features/home/domain/usecases/get_unverified_vehicle.dart';
import '../../features/home/domain/usecases/get_recent_rides.dart';
import '../../features/home/domain/usecases/get_statistics.dart';
import '../../features/home/domain/usecases/get_referral_code.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/profile/data/datasources/profile_data_source.dart';
import '../../features/reward/data/repositories/daily_reward_repository_impl.dart';
import '../../features/reward/domain/repositories/daily_reward_repository.dart';
import '../../features/reward/domain/usecases/get_user_daily_reward.dart';
import '../../features/reward/domain/usecases/update_reward.dart';
import '../../features/reward/presentation/bloc/daily_reward_bloc.dart';
import '../service/device_info_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Core services
  sl.registerLazySingleton<FirebaseFirestoreService>(
    () => FirebaseFirestoreService(),
  );
  sl.registerLazySingleton<FirebaseStorageService>(
    () => FirebaseStorageService(),
  );
  sl.registerLazySingleton<DeviceInfoService>(() => DeviceInfoService());

  // Data sources
  sl.registerLazySingleton<UserFirestoreDataSource>(
    () => UserFirestoreDataSource(firestoreService: sl()),
  );

  sl.registerLazySingleton(() => RideFirestoreDataSource());
  sl.registerLazySingleton(() => RideLocalDatasource());

  sl.registerLazySingleton(
    () => FirebaseAuthDataSource(firebaseAuth: sl(), googleSignIn: sl()),
  );

  sl.registerLazySingleton<GemCoinRemoteDataSource>(
    () => GemCoinRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<ReferralRemoteDataSource>(
    () => ReferralRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      deviceInfoService: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileDataSource>(
    () => ProfileDataSourceImpl(sl(), sl()),
  );

  sl.registerLazySingleton<DailyRewardRepository>(
    () => DailyRewardRepositoryImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ReferalRepository>(
    () => ReferralRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HomeRepository>(
    () => HomeRepositoriesImpl(
      sl<ProfileDataSource>(),
      sl<NotificationRemoteDataSource>(),
      sl<VehicleFirestoreDataSource>(),
      sl<RideFirestoreDataSource>(),
      sl<RideLocalDatasource>(),
      sl<ReferalRepository>(),
      sl<FirebaseFirestore>(),
    ),
  );

  // Usecases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignInWithApple(sl()));
  sl.registerLazySingleton(() => CheckIfUserExists(sl()));
  sl.registerLazySingleton(() => CheckIfAccountDeleted(sl()));
  sl.registerLazySingleton(() => CreateNewUser(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => DeleteAccount(sl()));
  sl.registerLazySingleton(() => RestoreAccount(sl()));
  sl.registerLazySingleton(() => UpdateFCMToken(sl()));
  sl.registerLazySingleton(() => ClearFCMToken(sl()));

  sl.registerLazySingleton(() => SubmitReferralCode(sl()));
  sl.registerLazySingleton(() => GetMyReferralData(sl()));

  // // Bloc
  // sl.registerFactory(() => AuthBloc(
  //   signInWithGoogle: sl(),
  //   signInWithApple: sl(),
  //   checkIfUserExists: sl(),
  //   checkIfAccountDeleted: sl(),
  //   authRepository: sl(),
  // ));

  sl.registerFactory(
    () => KAuthBloc(
      signInWithGoogle: sl(),
      signInWithApple: sl(),
      checkIfUserExists: sl(),
      checkIfAccountDeleted: sl(),
      createNewUser: sl(),
      signOut: sl(),
      deleteAccount: sl(),
      restoreAccount: sl(),
      updateFCMToken: sl(),
      clearFCMToken: sl(),
    ),
  );

  // Profile dependencies
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => CheckUsernameAvailability(sl()));

  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl(),
      updateProfile: sl(),
      checkUsernameAvailability: sl(),
    ),
  );

  // Ride dependencies
  sl.registerLazySingleton<RideRepository>(
    () => RideRepositoryImpl(sl<RideFirestoreDataSource>(), sl<RideLocalDatasource>()),
  );
  sl.registerLazySingleton(() => GetAllRidesByUserId(sl()));
  sl.registerLazySingleton(() => GetRecentRidesByUserId(sl()));
  sl.registerLazySingleton(() => GetRecentRideMemoriesByUserId(sl()));
  sl.registerLazySingleton(() => UploadRide(sl()));
  sl.registerLazySingleton(() => SaveRideLocally(sl()));
  sl.registerLazySingleton(() => GetRideLocally(sl()));

  sl.registerFactory(
    () => RideBloc(
      getAllRidesByUserId: sl(),
      getRecentRidesByUserId: sl(),
      getRecentRideMemoriesByUserId: sl(),
      uploadRide: sl(),
      saveRideLocally: sl(),
      getRideLocally: sl(),
    ),
  );

  // License dependencies
  sl.registerLazySingleton<DrivingLicenseRepository>(
    () => DrivingLicenseRepositoryImpl(),
  );
  sl.registerLazySingleton(() => GetDrivingLicense(sl()));
  sl.registerLazySingleton(() => SubmitDrivingLicense(sl()));

  sl.registerFactory(
    () =>
        DrivingLicenseBloc(getDrivingLicense: sl(), submitDrivingLicense: sl()),
  );

  // Gem Coin dependencies
  sl.registerLazySingleton<GemCoinRepository>(
    () => GemCoinRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetTransactionHistory(sl()));

  sl.registerFactory(() => GemCoinBloc(getTransactionHistory: sl()));

  // Vehicle dependencies
  sl.registerLazySingleton<VehicleFirestoreDataSource>(
    () => VehicleFirestoreDataSource(),
  );
  sl.registerLazySingleton<VehicleRepository>(
    () => VehicleRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => AddVehicle(sl()));
  sl.registerLazySingleton(() => GetUserVehicles(sl()));
  sl.registerLazySingleton(() => DeleteVehicle(sl()));
  sl.registerLazySingleton(() => UploadVehicleImage(sl()));
  sl.registerLazySingleton(() => DeleteVehicleImage(sl()));
  sl.registerLazySingleton(() => VerifyVehicle(sl()));

  sl.registerFactory(
    () => VehicleBloc(
      getUserVehicles: sl(),
      addVehicle: sl(),
      deleteVehicle: sl(),
      uploadVehicleImage: sl(),
      deleteVehicleImage: sl(),
      verifyVehicle: sl(),
    ),
  );

  // Notification dependencies
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => GetNotificationById(sl()));
  sl.registerLazySingleton(() => MarkAsRead(sl()));
  sl.registerLazySingleton(() => MarkAllAsRead(sl()));
  sl.registerLazySingleton(() => DeleteNotification(sl()));

  sl.registerFactory(
    () => NotificationBloc(
      getNotifications: sl(),
      getNotificationById: sl(),
      markAsRead: sl(),
      markAllAsRead: sl(),
      deleteNotification: sl(),
    ),
  );

  // Admin Data dependencies
  sl.registerLazySingleton<AdminDataRepository>(
    () => AdminDataRepositoryImpl(),
  );
  sl.registerLazySingleton(() => GetAppSettings(sl()));
  sl.registerLazySingleton(() => GetGemCoin(sl()));
  sl.registerLazySingleton(() => GetUserInterests(sl()));
  sl.registerLazySingleton(() => GetVehicleBrand(sl()));
  sl.registerLazySingleton(() => GetVehicleBrandById(sl()));

  sl.registerFactory(
    () => AdminDataBloc(
      getAppSettings: sl(),
      getGemCoin: sl(),
      getUserInterests: sl(),
      getVehicleBrands: sl(),
      getVehicleBrandById: sl(),
    ),
  );

  // Referral dependencies
  sl.registerFactory(
    () => ReferralBloc(
      submitReferralCode: sl(),
      getMyReferralData: sl(),
    ),
  );

  // Home dependencies
  sl.registerLazySingleton(() => GetUserProfileImage(sl()));
  sl.registerLazySingleton(() => GetUnreadNotification(sl()));
  sl.registerLazySingleton(() => GetUnverifiedVehicle(sl()));
  sl.registerLazySingleton(() => GetRecentRidesUseCase(sl()));
  sl.registerLazySingleton(() => GetStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => GetReferralCodeUseCase(sl()));

  sl.registerFactory(
    () => HomeBloc(
      getUserProfileImage: sl(),
      getUnreadNotification: sl(),
      getUnverifiedVehicle: sl(),
      getRecentRides: sl(),
      getStatistics: sl(),
      getReferralCode: sl(),
    ),
  );

  // Daily Reward dependencies
  sl.registerLazySingleton(() => GetUserDailyReward(sl()));
  sl.registerLazySingleton(() => UpdateReward(sl()));

  sl.registerFactory(
    () => DailyRewardBloc(
      getUserDailyReward: sl(),
      updateReward: sl(),
    ),
  );
}
