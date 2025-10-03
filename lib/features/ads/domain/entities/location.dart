class Location {
  final double latitude;
  final double longitude;
  final String address;

  const Location({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Location &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.address == address;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode ^ address.hashCode;

  @override
  String toString() =>
      'Location(latitude: $latitude, longitude: $longitude, address: $address)';
}
