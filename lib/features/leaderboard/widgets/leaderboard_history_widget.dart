import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/user_profile_bottom_sheet.dart';

enum LeaderboardHistoryType { rides, distance, referrals }

class LeaderboardHistoryWidget extends StatefulWidget {
  final List<List<Map<String, String>>> allTopUsers; // Multiple datasets for different periods
  final List<Map<String, String>> allMyselfData; // Multiple myself data
  final List<String> allPeriodHeadings; // Multiple period headings
  final List<String> filters;
  final LeaderboardHistoryType dataType;
  final int selectedFilter;
  final ValueChanged<int>? onFilterChanged;

  const LeaderboardHistoryWidget({
    super.key,
    required this.allTopUsers,
    required this.allMyselfData,
    required this.allPeriodHeadings,
    required this.dataType,
    required this.selectedFilter,
    this.onFilterChanged,
    this.filters = const [
      "Rider of the Week",
      "Rider of the Month",
      "Rider of the Year",
    ],
  });

  @override
  State<LeaderboardHistoryWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardHistoryWidget> {

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        return false;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 🔹 Filters
            _FilterChips(
              filters: widget.filters,
              selected: widget.selectedFilter,
              onChanged: widget.onFilterChanged ?? (index) {},
            ),

            const SizedBox(height: 20),

            // 🔹 Multiple Top Cards for Different Periods
            ...List.generate(widget.allTopUsers.length, (periodIndex) {
              final topUsers = widget.allTopUsers[periodIndex];
              final periodHeading = widget.allPeriodHeadings[periodIndex];
              
              return Column(
                children: [
                  // Period Heading with Blue Vertical Line
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        // Blue vertical line
                        Container(
                          width: 4,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Header text
                        Text(
                          periodHeading,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Top 3 Users for this period
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: LeaderboardCard(
                            user: topUsers[1],
                            rank: 2,
                            dataType: widget.dataType,
                            small: true,
                            onTap: () => _showUserProfileBottomSheet(context, topUsers[1], 2),
                          ),
                        ),
                        Expanded(
                          child: LeaderboardCard(
                            user: topUsers[0],
                            rank: 1,
                            dataType: widget.dataType,
                            small: false,
                            onTap: () => _showUserProfileBottomSheet(context, topUsers[0], 1),
                          ),
                        ),
                        Expanded(
                          child: LeaderboardCard(
                            user: topUsers[2],
                            rank: 3,
                            dataType: widget.dataType,
                            small: true,
                            onTap: () => _showUserProfileBottomSheet(context, topUsers[2], 3),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // Helper method to show user profile bottom sheet
  void _showUserProfileBottomSheet(
    BuildContext context,
    Map<String, String> user,
    int rank,
  ) {
    // Parse values based on data type
    int totalRides = 0;
    String totalKm = "0 km";
    
    switch (widget.dataType) {
      case LeaderboardHistoryType.rides:
        totalRides = int.tryParse(user["rides"] ?? "0") ?? 0;
        totalKm = "0 km";
        break;
      case LeaderboardHistoryType.distance:
        totalRides = 0;
        totalKm = user["distance"] ?? "0 km";
        break;
      case LeaderboardHistoryType.referrals:
        totalRides = 0;
        totalKm = "0 km";
        break;
    }
    
    final userProfileData = UserProfileData(
      imageUrl: user["image"]!,
      name: user["name"]!,
      address: user["address"]!,
      totalKm: totalKm,
      totalRides: totalRides,
      totalCoins: 0,
    );
    
    showUserProfileBottomSheet(context, userProfileData);
  }
}

/// 🔹 Filter Chips widget
class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final int selected;
  final ValueChanged<int> onChanged;

  const _FilterChips({
    required this.filters,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(filters.length, (index) {
          final bool isSelected = selected == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.white,
                  border: Border.all(color: Colors.grey.shade400, width: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// 🔹 User Card widget (for Top 3 podium)
class LeaderboardCard extends StatelessWidget {
  final Map<String, String> user;
  final int rank;
  final bool small;
  final VoidCallback? onTap;
  final LeaderboardHistoryType dataType;

  const LeaderboardCard({
    super.key,
    required this.user,
    required this.rank,
    required this.dataType,
    this.small = false,
    this.onTap,
  });

  // Helper method to get the metric value based on data type
  String _getMetricValue(Map<String, String> user) {
    switch (dataType) {
      case LeaderboardHistoryType.rides:
        return user["rides"] ?? "0";
      case LeaderboardHistoryType.distance:
        return user["distance"] ?? "0 km";
      case LeaderboardHistoryType.referrals:
        return user["referrals"] ?? "0";
    }
  }

  // Helper method to get the metric label based on data type
  String _getMetricLabel() {
    switch (dataType) {
      case LeaderboardHistoryType.rides:
        return "rides";
      case LeaderboardHistoryType.distance:
        return "km";
      case LeaderboardHistoryType.referrals:
        return "referrals";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = small ? 28 : 36;
    final double fontSize = 12;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  radius: avatarSize,
                  backgroundImage: NetworkImage(user["image"]!),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      "$rank",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user["name"]!,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
            Text(
              user["address"]!,
              style: TextStyle(fontSize: fontSize - 1, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              dataType == LeaderboardHistoryType.distance 
                  ? _getMetricValue(user)
                  : "${_getMetricValue(user)} ${_getMetricLabel()}",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 User Card widget (for Top 3 podium)
class LeaderboardHistoryCard extends StatelessWidget {
  final Map<String, String> user;
  final int rank;
  final bool small;
  final VoidCallback? onTap;
  final LeaderboardHistoryType dataType;

  const LeaderboardHistoryCard({
    super.key,
    required this.user,
    required this.rank,
    required this.dataType,
    this.small = false,
    this.onTap,
  });

  // Helper method to get the metric value based on data type
  String _getMetricValue(Map<String, String> user) {
    switch (dataType) {
      case LeaderboardHistoryType.rides:
        return user["rides"] ?? "0";
      case LeaderboardHistoryType.distance:
        return user["distance"] ?? "0 km";
      case LeaderboardHistoryType.referrals:
        return user["referrals"] ?? "0";
    }
  }

  // Helper method to get the metric label based on data type
  String _getMetricLabel() {
    switch (dataType) {
      case LeaderboardHistoryType.rides:
        return "rides";
      case LeaderboardHistoryType.distance:
        return "km";
      case LeaderboardHistoryType.referrals:
        return "referrals";
    }
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = small ? 28 : 36;
    final double fontSize = 12;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                CircleAvatar(
                  radius: avatarSize,
                  backgroundImage: NetworkImage(user["image"]!),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: Center(
                    child: Text(
                      "$rank",
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              user["name"]!,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: fontSize),
              textAlign: TextAlign.center,
            ),
            Text(
              user["address"]!,
              style: TextStyle(fontSize: fontSize - 1, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              "${_getMetricValue(user)} ${_getMetricLabel()}",
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
