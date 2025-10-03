import '../../domain/entities/call_to_action.dart';

class CallToActionModel extends CallToAction {
  const CallToActionModel({required super.type, required super.value});

  factory CallToActionModel.fromJson(Map<String, dynamic> json) {
    return CallToActionModel(
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'value': value};
  }

  factory CallToActionModel.fromEntity(CallToAction entity) {
    return CallToActionModel(type: entity.type, value: entity.value);
  }
}
