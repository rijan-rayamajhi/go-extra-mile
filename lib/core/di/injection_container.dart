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
import '../../features/admin_data/data/datasources/admin_data_remote_datasource.dart';
import '../../features/admin_data/data/repositories/admin_data_repository_impl.dart';
import '../../features/admin_data/domain/repositories/admin_data_repository.dart';
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
import '../../features/admin_data/domain/usecases/get_admin_data.dart';
import '../../features/admin_data/domain/usecases/get_monetization_settings.dart';
import '../../features/admin_data/presentation/bloc/admin_data_bloc.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/check_username_availability.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/get_current_user_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
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
import '../../features/referral/data/repositories/referral_repository_impl.dart';
import '../../features/vehicle/data/datasource/vehicle_firestore_datasource.dart';
import '../../features/vehicle/data/repositories/vehicle_repository_impl.dart';
import '../../features/vehicle/domain/repositories/vehicle_repository.dart';
import '../../features/vehicle/domain/usecases/add_vehicle.dart';
import '../../features/vehicle/domain/usecases/get_user_vehicles.dart';
import '../../features/vehicle/domain/usecases/get_all_vehicle_brands.dart';
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
import '../../features/notification/domain/usecases/get_unread_notification.dart';
import '../../features/notification/presentation/bloc/notification_bloc.dart';
import '../../features/referral/data/datasources/referral_remote_datasource.dart';
import '../../features/referral/domain/referal_repositories.dart';
import '../../features/referral/domain/usecases/submit_referral_code.dart';
import '../../features/referral/domain/usecases/get_my_referral_data.dart';
import '../../features/referral/presentation/bloc/referral_bloc.dart';
import '../../features/profile/data/datasources/profile_data_source.dart';
import '../../features/reward/data/repositories/daily_reward_repository_impl.dart';
import '../../features/reward/domain/repositories/daily_reward_repository.dart';
import '../../features/reward/domain/usecases/get_user_daily_reward.dart';
import '../../features/reward/domain/usecases/update_reward.dart';
import '../../features/reward/presentation/bloc/daily_reward_bloc.dart';
import '../service/device_info_service.dart';
import '../service/app_version_service.dart';
import '../../features/bugs/data/datasources/bug_report_remote_datasource.dart';
import '../../features/bugs/data/repositories/bug_report_repository_impl.dart';
import '../../features/bugs/domain/repositories/bug_report_repository.dart';
import '../../features/bugs/domain/usecases/submit_bug_report.dart';
import '../../features/bugs/domain/usecases/get_user_bug_reports.dart';
import '../../features/bugs/domain/usecases/get_bug_report_stats.dart';
import '../../features/bugs/domain/usecases/upload_bug_screenshot.dart';
import '../../features/bugs/presentation/bloc/bug_report_bloc.dart';
import '../../features/ads/data/datasources/carousel_ad_datasource.dart';
import '../../features/ads/data/datasources/carousel_ad_firestore_datasource.dart';
import '../../features/ads/data/repository/carousel_ad_repository_impl.dart';
import '../../features/ads/domain/repository/carousel_ad_repository.dart';
import '../../features/ads/domain/usecases/get_carousel_ads_by_location.dart';
import '../../features/ads/presentation/bloc/ads_bloc.dart';
import '../../features/ride/data/datasource/ride_hive_datasource.dart';
import '../../features/ride/data/datasource/ride_firebase_datasource.dart';
import '../../features/ride/domain/repositories/ride_repository.dart';
import '../../features/ride/data/repositories/ride_repository_impl.dart';
import '../../features/ride/domain/usecases/get_all_firebase_rides.dart';
import '../../features/ride/domain/usecases/get_all_hive_rides.dart';
import '../../features/ride/domain/usecases/get_recent_ride.dart';
import '../../features/ride/domain/usecases/get_ride_by_id.dart';
import '../../features/ride/domain/usecases/upload_ride.dart';
import '../../features/ride/domain/usecases/clear_local_ride.dart';
import '../../features/ride/presentation/bloc/ride_bloc.dart';
import '../../features/ride/presentation/bloc/ride_data_bloc.dart';
import '../../features/monetization/data/repositories/monetization_data_repository_impl.dart';
import '../../features/monetization/domain/repositories/monetization_repository.dart';
import '../../features/monetization/domain/usecases/get_monetization_data.dart';
import '../../features/monetization/domain/usecases/update_monetization_status.dart';
import '../../features/monetization/domain/usecases/get_monetization_status.dart';
import '../../features/monetization/domain/usecases/create_cashout_transaction.dart';
import '../../features/monetization/domain/usecases/get_cashout_transactions.dart';
import '../../features/monetization/presentation/bloc/monetization_data_bloc.dart';
import '../../features/others/data/datasources/app_stats_firebase_datasource.dart';
import '../../features/others/data/repositories/app_stats_repository_impl.dart';
import '../../features/others/domain/repositories/app_stats_repository.dart';
import '../../features/others/domain/usecases/get_app_stats.dart';
import '../../features/others/presentation/bloc/app_stats_bloc.dart';

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
  sl.registerLazySingleton<AppVersionService>(() => AppVersionService());

  // Data sources
  sl.registerLazySingleton<UserFirestoreDataSource>(
    () => UserFirestoreDataSource(firestoreService: sl()),
  );

  sl.registerLazySingleton(
    () => FirebaseAuthDataSource(firebaseAuth: sl(), googleSignIn: sl()),
  );

  sl.registerLazySingleton<AdminDataRemoteDataSource>(
    () => AdminDataRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<GemCoinRemoteDataSource>(
    () => GemCoinRemoteDataSourceImpl(firestore: sl()),
  );

  // sl.registerLazySingleton<MonetizationDataSource>(
  //   () => MonetizationDataSourceImpl(
  //     firestore: sl(),
  //     auth: sl(),
  //     adminDataRemoteDataSource: sl(),
  //   ),
  // );

  // Bug Report data sources
  sl.registerLazySingleton<BugReportRemoteDataSource>(
    () => BugReportRemoteDataSourceImpl(
      firestoreService: sl(),
      storageService: sl(),
      firestore: sl(),
    ),
  );

  // sl.registerLazySingleton<MonetizationRepository>(
  //   () => MonetizationRepositoryImpl(dataSource: sl()),
  // );

  // Monetization use case
  // sl.registerLazySingleton(() => GetMonetizationData(repository: sl()));

  sl.registerLazySingleton<ReferralRemoteDataSource>(
    () => ReferralRemoteDataSourceImpl(
      firestore: sl(),
      firebaseAuth: sl(),
      deviceInfoService: sl(),
    ),
  );

  sl.registerLazySingleton<ProfileDataSource>(
    () => ProfileDataSourceImpl(sl(), sl(), sl()),
  );

  sl.registerLazySingleton<DailyRewardRepository>(
    () => DailyRewardRepositoryImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AdminDataRepository>(
    () => AdminDataRepositoryImpl(remoteDataSource: sl()),
  );

  // Admin Data use cases
  sl.registerLazySingleton(() => GetAdminData(sl()));
  sl.registerLazySingleton(() => GetMonetizationSettings(sl()));
  sl.registerLazySingleton<ReferalRepository>(
    () => ReferralRepositoryImpl(remoteDataSource: sl()),
  );

  // Bug Report repository
  sl.registerLazySingleton<BugReportRepository>(
    () => BugReportRepositoryImpl(remoteDataSource: sl()),
  );

  // Bug Report use cases
  sl.registerLazySingleton(() => SubmitBugReport(repository: sl()));
  sl.registerLazySingleton(() => GetUserBugReports(repository: sl()));
  sl.registerLazySingleton(() => GetUserBugReportStats(repository: sl()));
  sl.registerLazySingleton(() => UploadBugScreenshot(repository: sl()));

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

  sl.registerFactory(
    () => AdminDataBloc(getAdminData: sl(), getMonetizationSettings: sl()),
  );

  // Profile dependencies
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => GetCurrentUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => CheckUsernameAvailability(sl()));

  sl.registerFactory(
    () => ProfileBloc(
      getProfile: sl(),
      getCurrentUserProfile: sl(),
      updateProfile: sl(),
      checkUsernameAvailability: sl(),
    ),
  );

  // Ride data sources
  sl.registerLazySingleton<RideHiveDatasource>(() => RideHiveDatasourceImpl());
  sl.registerLazySingleton<RideFirebaseDatasource>(
    () => RideFirebaseDatasourceImpl(),
  );

  // Ride repository
  sl.registerLazySingleton<RideRepository>(
    () => RideRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Ride data use cases
  sl.registerLazySingleton(() => GetAllFirebaseRides(sl()));
  sl.registerLazySingleton(() => GetAllHiveRides(sl()));
  sl.registerLazySingleton(() => GetRecentRide(sl()));
  sl.registerLazySingleton(() => GetRideById(sl()));
  sl.registerLazySingleton(() => UploadRide(sl()));
  sl.registerLazySingleton(() => ClearLocalRide(sl()));

  // Ride BLoC
  sl.registerFactory(() => RideBloc());

  // Ride Data BLoC
  sl.registerFactory(
    () => RideDataBloc(
      getAllFirebaseRides: sl(),
      getAllHiveRides: sl(),
      getRecentRide: sl(),
      getRideById: sl(),
      uploadRide: sl(),
      clearLocalRide: sl(),
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
  sl.registerLazySingleton(() => GetAllVehicleBrands(sl()));
  sl.registerLazySingleton(() => DeleteVehicle(sl()));
  sl.registerLazySingleton(() => UploadVehicleImage(sl()));
  sl.registerLazySingleton(() => DeleteVehicleImage(sl()));
  sl.registerLazySingleton(() => VerifyVehicle(sl()));

  sl.registerFactory(
    () => VehicleBloc(
      getAllVehicleBrands: sl(),
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
    () => NotificationRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => GetNotificationById(sl()));
  sl.registerLazySingleton(() => MarkAsRead(sl()));
  sl.registerLazySingleton(() => MarkAllAsRead(sl()));
  sl.registerLazySingleton(() => DeleteNotification(sl()));
  sl.registerLazySingleton(() => GetUnreadNotification(sl()));

  sl.registerFactory(
    () => NotificationBloc(
      getNotifications: sl(),
      getNotificationById: sl(),
      markAsRead: sl(),
      markAllAsRead: sl(),
      deleteNotification: sl(),
      getUnreadNotification: sl(),
    ),
  );

  // Referral dependencies
  sl.registerFactory(
    () => ReferralBloc(submitReferralCode: sl(), getMyReferralData: sl()),
  );

  // Daily Reward dependencies
  sl.registerLazySingleton(() => GetUserDailyReward(sl()));
  sl.registerLazySingleton(() => UpdateReward(sl()));

  sl.registerFactory(
    () => DailyRewardBloc(getUserDailyReward: sl(), updateReward: sl()),
  );

  // Monetization Data dependencies
  sl.registerLazySingleton<MonetizationRepository>(
    () => MonetizationDataRepositoryImpl(
      getDrivingLicense: sl(),
      getUserVehicles: sl(),
      getAllFirebaseRides: sl(),
      getMyReferralData: sl(),
    ),
  );
  sl.registerLazySingleton(() => GetMonetizationData(sl()));
  sl.registerLazySingleton(() => UpdateMonetizationStatus(sl()));
  sl.registerLazySingleton(() => GetMonetizationStatus(sl()));
  sl.registerLazySingleton(() => CreateCashoutTransaction(sl()));
  sl.registerLazySingleton(() => GetCashoutTransactions(sl()));

  // Monetization Data BLoC
  sl.registerFactory(
    () => MonetizationDataBloc(
      getMonetizationData: sl(),
      updateMonetizationStatus: sl(),
      getMonetizationStatus: sl(),
      createCashoutTransaction: sl(),
      getCashoutTransactions: sl(),
    ),
  );

  // Bug Report BLoC
  sl.registerFactory(
    () => BugReportBloc(
      submitBugReport: sl(),
      getUserBugReports: sl(),
      getUserBugReportStats: sl(),
      uploadBugScreenshot: sl(),
      bugReportRepository: sl(),
    ),
  );

  // Ads dependencies
  sl.registerLazySingleton<CarouselAdDataSource>(
    () => CarouselAdFirestoreDataSource(firestore: sl()),
  );
  sl.registerLazySingleton<CarouselAdRepository>(
    () => CarouselAdRepositoryImpl(dataSource: sl()),
  );
  sl.registerLazySingleton(() => GetCarouselAdsByLocation(sl()));

  // Ads BLoC
  sl.registerFactory(() => AdsBloc(getCarouselAdsByLocation: sl()));

  // App Stats dependencies
  sl.registerLazySingleton<AppStatsFirebaseDatasource>(
    () => AppStatsFirebaseDatasourceImpl(),
  );
  sl.registerLazySingleton<AppStatsRepository>(
    () => AppStatsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetAppStats(sl()));

  // App Stats BLoC
  sl.registerFactory(() => AppStatsBloc(getAppStats: sl()));
}
