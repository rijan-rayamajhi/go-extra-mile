import '../../domain/entities/carousel_ad.dart';
import 'call_to_action_model.dart';
import 'location_targeting_model.dart';
import 'scheduling_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CarouselAdModel extends CarouselAd {
  const CarouselAdModel({
    required super.id,
    required super.title,
    required super.description,
    required super.callToAction,
    required super.imageUrl,
    required super.locationTargeting,
    required super.scheduling,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
  });

  factory CarouselAdModel.fromJson(Map<String, dynamic> json) {
    return CarouselAdModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      callToAction: CallToActionModel.fromJson(
        json['callToAction'] as Map<String, dynamic>? ?? {},
      ),
      imageUrl: json['imageUrl']?.toString() ?? '',
      locationTargeting: LocationTargetingModel.fromJson(
        json['locationTargeting'] as Map<String, dynamic>? ?? {},
      ),
      scheduling: SchedulingModel.fromJson(
        json['scheduling'] as Map<String, dynamic>? ?? {},
      ),
      isActive: json['isActive'] as bool? ?? false,
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      createdBy: json['createdBy']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'callToAction': (callToAction as CallToActionModel).toJson(),
      'imageUrl': imageUrl,
      'locationTargeting': (locationTargeting as LocationTargetingModel)
          .toJson(),
      'scheduling': (scheduling as SchedulingModel).toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory CarouselAdModel.fromEntity(CarouselAd entity) {
    return CarouselAdModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      callToAction: CallToActionModel.fromEntity(entity.callToAction),
      imageUrl: entity.imageUrl,
      locationTargeting: LocationTargetingModel.fromEntity(
        entity.locationTargeting,
      ),
      scheduling: SchedulingModel.fromEntity(entity.scheduling),
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
    );
  }

  /// Helper method to parse DateTime from various formats (Timestamp, String, etc.)
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    if (dateValue is Timestamp) {
      return dateValue.toDate();
    }

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }

    if (dateValue is DateTime) {
      return dateValue;
    }

    return DateTime.now();
  }
}
