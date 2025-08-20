class GemCoin {
  final List<Action> action;
  final DateTime lastUpdated;

  const GemCoin({
    required this.action,
    required this.lastUpdated,
  });
}

class Action {
  final String id;
  final String name;
  final int coinValue;
  final String description;
  final bool isActive;

  const Action({
    required this.id,
    required this.name,
    required this.coinValue,
    required this.description,
    required this.isActive,
  });
}