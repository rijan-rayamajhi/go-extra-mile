class Scheduling {
  final bool enabled;
  final DateTime? startDate;
  final DateTime? endDate;

  const Scheduling({required this.enabled, this.startDate, this.endDate});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Scheduling &&
        other.enabled == enabled &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode => enabled.hashCode ^ startDate.hashCode ^ endDate.hashCode;

  @override
  String toString() =>
      'Scheduling(enabled: $enabled, startDate: $startDate, endDate: $endDate)';
}
