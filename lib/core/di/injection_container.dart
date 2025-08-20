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
import '../../features/auth/presentation/bloc/auth_bloc.dart';
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
import '../../features/ride/domain/usecases/start_ride.dart';
import '../../features/ride/domain/usecases/get_current_ride.dart';
import '../../features/ride/domain/usecases/get_all_rides_by_user_id.dart';
import '../../features/ride/domain/usecases/get_recent_rides_by_user_id.dart';
import '../../features/ride/domain/usecases/upload_ride.dart';
import '../../features/ride/domain/usecases/discard_ride.dart';
import '../../features/ride/domain/usecases/update_ride_fields.dart';
import '../../features/ride/domain/usecases/get_ride_memories_by_user_id.dart';
import '../../features/ride/domain/usecases/get_recent_ride_memories_by_user_id.dart';
import '../../features/ride/presentation/bloc/ride_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Core services
  sl.registerLazySingleton<FirebaseFirestoreService>(() => FirebaseFirestoreService());
  sl.registerLazySingleton<FirebaseStorageService>(() => FirebaseStorageService());

  // Data sources
  sl.registerLazySingleton<UserFirestoreDataSource>(() => UserFirestoreDataSource(
    firestoreService: sl(),
  ));

  sl.registerLazySingleton(() => RideFirestoreDataSource());
  sl.registerLazySingleton(() => RideLocalDatasource());

  sl.registerLazySingleton(() => FirebaseAuthDataSource(
    firebaseAuth: sl(),
    googleSignIn: sl(),
    userFirestoreDataSource: sl(),
  ));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Usecases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));

  // Bloc
  sl.registerFactory(() => AuthBloc(
    signInWithGoogle: sl(),
    authRepository: sl(),
  ));

  // Profile dependencies
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => UpdateProfile(sl()));
  sl.registerLazySingleton(() => CheckUsernameAvailability(sl()));
  
  sl.registerFactory(() => ProfileBloc(
    getProfile: sl(),
    updateProfile: sl(),
    checkUsernameAvailability: sl(),
  ));

  // Ride dependencies
  sl.registerLazySingleton<RideRepository>(() => RideRepositoryImpl(
    sl(),
    sl(),
  ));
  sl.registerLazySingleton(() => StartRide(sl()));
  sl.registerLazySingleton(() => GetCurrentRide(sl()));
  sl.registerLazySingleton(() => GetAllRidesByUserId(sl()));
  sl.registerLazySingleton(() => GetRecentRidesByUserId(sl()));
  sl.registerLazySingleton(() => GetRideMemoriesByUserId(sl()));
  sl.registerLazySingleton(() => GetRecentRideMemoriesByUserId(sl()));
  sl.registerLazySingleton(() => UploadRide(sl()));
  sl.registerLazySingleton(() => DiscardRide(sl()));
  sl.registerLazySingleton(() => UpdateRideFields(sl()));
  
  sl.registerFactory(() => RideBloc(
    startRide: sl(),
    getCurrentRide: sl(),
    getAllRidesByUserId: sl(),
    getRecentRidesByUserId: sl(),
    getRideMemoriesByUserId: sl(),
    getRecentRideMemoriesByUserId: sl(),
    uploadRide: sl(),
    discardRide: sl(),
    updateRideFields: sl(),
  ));
}
