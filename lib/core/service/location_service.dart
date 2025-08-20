import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service to manage location permissions, get device location using Geolocator,
/// and handle geocoding operations.
class LocationService {
  /// Checks if location services are enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks the current permission status for location.
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Requests location permission from the user.
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Gets the current position of the device.
  /// Returns a Position object with latitude, longitude, accuracy, etc.
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return null;
    }

    LocationPermission permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return null;
    }

    // Permissions granted, get the position
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Returns a stream of location updates.
  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Converts an address string to coordinates (latitude and longitude).
  /// Returns a list of Location objects, each containing coordinates and address details.
  Future<List<Location>> getCoordinatesFromAddress(String address) async {
    try {
      return await locationFromAddress(address);
    } catch (e) {
      throw Exception('Failed to get coordinates from address: $e');
    }
  }

  /// Converts coordinates (latitude and longitude) to an address.
  /// Returns a list of Placemark objects, each containing address details.
  Future<List<Placemark>> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      return await placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      throw Exception('Failed to get address from coordinates: $e');
    }
  }

  /// Gets a formatted address string from coordinates.
  /// Returns a formatted address string or null if failed.
  Future<String?> getFormattedAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await getAddressFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return _formatPlacemark(place);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Gets coordinates from an address string.
  /// Returns a LatLng object or null if failed.
  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      final locations = await getCoordinatesFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations[0];
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Formats a Placemark object into a readable address string.
  String _formatPlacemark(Placemark place) {
    final parts = <String>[];
    
    if (place.street?.isNotEmpty == true) {
      parts.add(place.street!);
    }
    if (place.locality?.isNotEmpty == true) {
      parts.add(place.locality!);
    }
    if (place.administrativeArea?.isNotEmpty == true) {
      parts.add(place.administrativeArea!);
    }
    // if (place.country?.isNotEmpty == true) {
    //   parts.add(place.country!);
    // }
    
    return parts.join(', ');
  }
}

/// Simple class to represent latitude and longitude coordinates.
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng(lat: $latitude, lng: $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LatLng &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}
