class CallToAction {
  final String type;
  final String value;

  const CallToAction({required this.type, required this.value});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CallToAction && other.type == type && other.value == value;
  }

  @override
  int get hashCode => type.hashCode ^ value.hashCode;

  @override
  String toString() => 'CallToAction(type: $type, value: $value)';
}
