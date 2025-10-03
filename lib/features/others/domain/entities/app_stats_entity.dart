class AppStatsEntity {
  final int totalGemCoins;
  final double totalDistance;
  final int totalRides;

  const AppStatsEntity({
    required this.totalGemCoins,
    required this.totalDistance,
    required this.totalRides,
  });

  @override
  String toString() {
    return 'AppStatsEntity(totalGemCoins: $totalGemCoins, totalDistance: $totalDistance, totalRides: $totalRides)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppStatsEntity &&
        other.totalGemCoins == totalGemCoins &&
        other.totalDistance == totalDistance &&
        other.totalRides == totalRides;
  }

  @override
  int get hashCode {
    return totalGemCoins.hashCode ^ totalDistance.hashCode ^ totalRides.hashCode;
  }

  AppStatsEntity copyWith({
    int? totalGemCoins,
    double? totalDistance,
    int? totalRides,
  }) {
    return AppStatsEntity(
      totalGemCoins: totalGemCoins ?? this.totalGemCoins,
      totalDistance: totalDistance ?? this.totalDistance,
      totalRides: totalRides ?? this.totalRides,
    );
  }
}
