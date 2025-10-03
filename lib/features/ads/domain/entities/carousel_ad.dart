import 'call_to_action.dart';
import 'location_targeting.dart';
import 'scheduling.dart';

class CarouselAd {
  final String id;
  final String title;
  final String description;
  final CallToAction callToAction;
  final String imageUrl;
  final LocationTargeting locationTargeting;
  final Scheduling scheduling;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;

  const CarouselAd({
    required this.id,
    required this.title,
    required this.description,
    required this.callToAction,
    required this.imageUrl,
    required this.locationTargeting,
    required this.scheduling,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CarouselAd &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.callToAction == callToAction &&
        other.imageUrl == imageUrl &&
        other.locationTargeting == locationTargeting &&
        other.scheduling == scheduling &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.createdBy == createdBy;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        callToAction.hashCode ^
        imageUrl.hashCode ^
        locationTargeting.hashCode ^
        scheduling.hashCode ^
        isActive.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode ^
        createdBy.hashCode;
  }

  @override
  String toString() {
    return 'CarouselAd(id: $id, title: $title, description: $description, '
        'callToAction: $callToAction, imageUrl: $imageUrl, '
        'locationTargeting: $locationTargeting, scheduling: $scheduling, '
        'isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt, '
        'createdBy: $createdBy)';
  }
}
