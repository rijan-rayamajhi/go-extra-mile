import 'location.dart';

class LocationTargeting {
  final bool enabled;
  final Location? location;
  final double? radius;

  const LocationTargeting({required this.enabled, this.location, this.radius});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationTargeting &&
        other.enabled == enabled &&
        other.location == location &&
        other.radius == radius;
  }

  @override
  int get hashCode => enabled.hashCode ^ location.hashCode ^ radius.hashCode;

  @override
  String toString() =>
      'LocationTargeting(enabled: $enabled, location: $location, radius: $radius)';
}
