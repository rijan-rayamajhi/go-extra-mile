class UserInterest {
  final String id;
  final String name;
  final String description;
  final String category;
  final bool isActive;

  UserInterest({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.isActive,
  });
}

class UserInterestsData {
  final List<UserInterest> interests;
  final DateTime lastUpdated;

  UserInterestsData({
    required this.interests,
    required this.lastUpdated,
  });
} 