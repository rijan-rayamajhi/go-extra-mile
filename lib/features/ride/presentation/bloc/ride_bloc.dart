import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/odometer_entity.dart';
import '../../domain/entities/ride_memory_entity.dart';
import 'ride_event.dart';
import 'ride_state.dart';
import '../../utils.dart'; // haversine function

class RideBloc extends Bloc<RideEvent, RideState> {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;

  final double minMovementMeters = 5;

  RideBloc() : super(RideState.initial()) {
    _initNotifications();

    on<LoadInitialLocation>(_onLoadInitialLocation);
    on<MoveToCurrentLocation>(_onMoveToCurrentLocation);
    on<SelectVehicle>(_onSelectVehicle);
    on<StartTracking>(_onStartTracking);
    on<SaveBeforeRideOdometerImage>(_onSaveBeforeRideOdometerImage);
    on<SaveAfterRideOdometerImage>(_onSaveAfterRideOdometerImage);
    on<SaveRideMemory>(_onSaveRideMemory);
    on<StopTracking>(_onStopTracking);
    on<Tick>(_onTick);
    on<ResetRide>((event, emit) => emit(RideState.initial()));
  }

  // Helper getter to safely access RideLoaded state
  RideState get _currentState => state;

  void _initNotifications() {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings();
    notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  Future<bool> _requestPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> _onLoadInitialLocation(
    LoadInitialLocation event,
    Emitter<RideState> emit,
  ) async {
    try {
      // Check permissions
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        emit(
          _currentState.copyWith(
            currentRide: (_currentState.currentRide ?? RideEntity()).copyWith(
              startCoordinates: null,
            ),
          ),
        );
        return;
      }

      // Try last known position
      Position? lastPosition = await Geolocator.getLastKnownPosition();

      // Fallback to current position
      final pos =
          lastPosition ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
            ),
          );

      // Emit new state
      final updatedRide = (_currentState.currentRide ?? RideEntity()).copyWith(
        startCoordinates: GeoPoint(pos.latitude, pos.longitude),
      );
      emit(_currentState.copyWith(currentRide: updatedRide));
    } catch (e) {
      emit(
        _currentState.copyWith(
          currentRide: (_currentState.currentRide ?? RideEntity()).copyWith(
            startCoordinates: null,
          ),
        ),
      );
    }
  }

  Future<void> _onMoveToCurrentLocation(
    MoveToCurrentLocation event,
    Emitter<RideState> emit,
  ) async {
    if (!await _requestPermissions()) return;

    try {
      Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      emit(
        _currentState.copyWith(
          currentRide: (_currentState.currentRide ?? RideEntity()).copyWith(
            startCoordinates: GeoPoint(pos.latitude, pos.longitude),
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> _onSelectVehicle(
    SelectVehicle event,
    Emitter<RideState> emit,
  ) async {
    final selectedId = event.vehicle?['vehicleId']?.toString();

    emit(
      _currentState.copyWith(
        currentRide: (_currentState.currentRide ?? RideEntity()).copyWith(
          vehicleId: selectedId,
        ),
      ),
    );
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<RideState> emit,
  ) async {
    if (!await _requestPermissions()) return;

    final now = DateTime.now();
    final currentRide = _currentState.currentRide ?? RideEntity();

    emit(
      _currentState.copyWith(
        isTracking: true,
        currentRide: currentRide.copyWith(
          startedAt: now,
          status: 'ongoing',
          routePoints: [],
          totalDistance: 0,
          totalTime: 0,
          rideMemories: currentRide.rideMemories ?? [],
          odometer: currentRide.odometer ?? const OdometerEntity(),
        ),
      ),
    );

    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((pos) => add(Tick(pos)));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(Tick(null)));
  }

  Future<void> _onSaveBeforeRideOdometerImage(
    SaveBeforeRideOdometerImage event,
    Emitter<RideState> emit,
  ) async {
    final odometer =
        (_currentState.currentRide?.odometer ?? const OdometerEntity())
            .copyWith(
              beforeRideOdometerImage: event.image.path,
              beforeRideOdometerImageCaptureAt: event.capturedAt,
              verificationStatus: OdometerVerificationStatus.pending,
            );

    emit(
      _currentState.copyWith(
        currentRide: (_currentState.currentRide ?? RideEntity()).copyWith(
          odometer: odometer,
        ),
      ),
    );
  }

  Future<void> _onSaveAfterRideOdometerImage(
    SaveAfterRideOdometerImage event,
    Emitter<RideState> emit,
  ) async {
    final odometer =
        (_currentState.currentRide?.odometer ?? const OdometerEntity())
            .copyWith(
              afterRideOdometerImage: event.image.path,
              afterRideOdometerImageCaptureAt: event.capturedAt,
              verificationStatus: OdometerVerificationStatus.pending,
            );

    emit(
      _currentState.copyWith(
        currentRide: (_currentState.currentRide ?? RideEntity()).copyWith(
          odometer: odometer,
        ),
      ),
    );
  }

  Future<void> _onSaveRideMemory(
    SaveRideMemory event,
    Emitter<RideState> emit,
  ) async {
    final currentMemories = _currentState.currentRide?.rideMemories ?? [];
    final memoryEntity = RideMemoryEntity(
      id: event.memory['id']?.toString(),
      title: event.memory['title']?.toString(),
      description: event.memory['description']?.toString(),
      imageUrl: event.memory['imageUrl']?.toString(),
      capturedCoordinates: event.memory['coordinates'] as GeoPoint?,
      capturedAt: event.memory['capturedAt'] as DateTime?,
    );

    emit(
      _currentState.copyWith(
        currentRide: (_currentState.currentRide ?? RideEntity()).copyWith(
          rideMemories: [...currentMemories, memoryEntity],
        ),
      ),
    );
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<RideState> emit,
  ) async {
    _positionSubscription?.cancel();
    _timer?.cancel();

    // Get the last route point as end coordinates
    final routePoints = _currentState.currentRide?.routePoints;
    final endCoordinates = (routePoints != null && routePoints.isNotEmpty)
        ? routePoints.last
        : null;

    emit(
      _currentState.copyWith(
        isTracking: false,
        currentRide: (_currentState.currentRide ?? RideEntity()).copyWith(
          endedAt: DateTime.now(),
          endCoordinates: endCoordinates,
        ),
      ),
    );
  }

  void _onTick(Tick event, Emitter<RideState> emit) async {
    if (!_currentState.isTracking || _currentState.currentRide == null) return;

    final ride = _currentState.currentRide!;
    final currentPoints = List<GeoPoint>.from(ride.routePoints ?? []);
    double totalDistance = ride.totalDistance ?? 0;

    if (event.position != null) {
      final point = GeoPoint(
        event.position!.latitude,
        event.position!.longitude,
      );

      if (currentPoints.isNotEmpty) {
        final last = currentPoints.last;
        final distance = haversine(
          last.latitude,
          last.longitude,
          point.latitude,
          point.longitude,
        );

        if (distance >= minMovementMeters) {
          currentPoints.add(point);
          totalDistance += distance;
        }
      } else {
        currentPoints.add(point);
      }
    }

    final totalTime = (ride.totalTime ?? 0) + 1;
    // Calculate GEM coins: 1 meter = 0.001 GEM coins
    final totalGEMCoins = totalDistance * 0.001;

    emit(
      _currentState.copyWith(
        currentRide: ride.copyWith(
          routePoints: currentPoints,
          totalDistance: totalDistance,
          totalTime: totalTime,
          totalGEMCoins: totalGEMCoins,
        ),
      ),
    );

    // Show notification every minute
    if (totalTime % 60 == 0) {
      final km = totalDistance / 1000;
      final hours = totalTime ~/ 3600;
      final minutes = (totalTime % 3600) ~/ 60;
      final seconds = totalTime % 60;
      await notificationsPlugin.show(
        0,
        'Ride Update',
        'Time: ${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} • Distance: ${km.toStringAsFixed(2)} km',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'ride_channel_id',
            'Ride Updates',
            channelDescription: 'Ride updates every minute',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    }
  }
}
