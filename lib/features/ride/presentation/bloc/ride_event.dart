import 'dart:io';

import 'package:geolocator/geolocator.dart';

abstract class RideEvent {}

//ui events
class LoadInitialLocation extends RideEvent {}

class MoveToCurrentLocation extends RideEvent {}

class SelectVehicle extends RideEvent {
  final Map<String, dynamic>? vehicle;
  SelectVehicle(this.vehicle);
}

class StartTracking extends RideEvent {}

class SaveBeforeRideOdometerImage extends RideEvent {
  final File image;
  final DateTime capturedAt;

  SaveBeforeRideOdometerImage(this.image, this.capturedAt);
}

class SaveAfterRideOdometerImage extends RideEvent {
  final File image;
  final DateTime capturedAt;
  SaveAfterRideOdometerImage(this.image, this.capturedAt);
}

class SaveRideMemory extends RideEvent {
  final Map<String, dynamic> memory;
  SaveRideMemory(this.memory);
}

class StopTracking extends RideEvent {}

class ResetRide extends RideEvent {}

class Tick extends RideEvent {
  final Position? position;
  Tick(this.position);
}
