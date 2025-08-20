import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_interest.dart';

class UserInterestModel extends UserInterest {
  UserInterestModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.isActive,
  });

  factory UserInterestModel.fromJson(Map<String, dynamic> json) {
    return UserInterestModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'isActive': isActive,
    };
  }
}

class UserInterestsDataModel extends UserInterestsData {
  UserInterestsDataModel({
    required super.interests,
    required super.lastUpdated,
  });

  factory UserInterestsDataModel.fromJson(Map<String, dynamic> json) {
    final interestsList = json['interests'] as List<dynamic>? ?? [];
    
    // Handle lastUpdated field which can be either Timestamp (from Firebase) or String
    DateTime lastUpdated;
    final lastUpdatedData = json['lastUpdated'];
    if (lastUpdatedData is Timestamp) {
      lastUpdated = lastUpdatedData.toDate();
    } else if (lastUpdatedData is String) {
      lastUpdated = DateTime.parse(lastUpdatedData);
    } else {
      lastUpdated = DateTime.now();
    }
    
    return UserInterestsDataModel(
      interests: interestsList
          .map((interestData) => UserInterestModel.fromJson(interestData))
          .where((interest) => interest.isActive) // Only include active interests
          .toList(),
      lastUpdated: lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interests': interests.map((interest) => (interest as UserInterestModel).toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
} 