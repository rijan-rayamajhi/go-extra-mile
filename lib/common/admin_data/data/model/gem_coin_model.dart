import '../../domain/entities/gem_coin.dart';

class GemCoinModel extends GemCoin {
  GemCoinModel({
    required super.action,
    required super.lastUpdated,
  });

  factory GemCoinModel.fromJson(Map<String, dynamic> json) {
    return GemCoinModel(
      action: (json['action'] as List<dynamic>)
          .map((actionJson) => ActionModel.fromJson(actionJson))
          .toList(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'action': action.map((action) => (action as ActionModel).toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class ActionModel extends Action {
  ActionModel({
    required super.id,
    required super.name,
    required super.coinValue,
    required super.description,
    required super.isActive,
  });

  factory ActionModel.fromJson(Map<String, dynamic> json) {
    return ActionModel(
      id: json['id'],
      name: json['name'],
      coinValue: json['coinValue'],
      description: json['description'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coinValue': coinValue,
      'description': description,
      'isActive': isActive,
    };
  }
} 