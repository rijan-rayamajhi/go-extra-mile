import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/user_profile_bottom_sheet.dart';

enum LeaderboardType { rides, distance, referrals }

class LeaderboardWidget extends StatefulWidget {
  final List<Map<String, String>> topUsers;
  final List<Map<String, String>> allOtherUsers;
  final Map<String, String> myself;
  final List<String> filters;
  final LeaderboardType dataType;
  final int selectedFilter;
  final ValueChanged<int>? onFilterChanged;
  
  const LeaderboardWidget({
    super.key,
    required this.topUsers,
    required this.allOtherUsers,
    required this.myself,
    required this.dataType,
    required this.selectedFilter,
    this.onFilterChanged,
    this.filters = const [
      "Last 7 days",
      "This month",
      "This year",
    ],
  });

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _isLoading = false;

  @override
  void didUpdateWidget(LeaderboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset pagination when filter changes
    if (oldWidget.selectedFilter != widget.selectedFilter) {
      _currentPage = 1;
    }
  }

  // Helper method to get the metric value based on data type
  String _getMetricValue(Map<String, String> user) {
    switch (widget.dataType) {
      case LeaderboardType.rides:
        return user["rides"] ?? "0";
      case LeaderboardType.distance:
        return user["distance"] ?? "0 km";
      case LeaderboardType.referrals:
        return user["referrals"] ?? "0";
    }
  }

  // Helper method to get the metric label based on data type
  String _getMetricLabel() {
    switch (widget.dataType) {
      case LeaderboardType.rides:
        return "rides";
      case LeaderboardType.distance:
        return "km";
      case LeaderboardType.referrals:
        return "referrals";
    }
  }


  // Get paginated users for current page
  List<Map<String, String>> get _paginatedUsers {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return widget.allOtherUsers.sublist(
      0, 
      endIndex > widget.allOtherUsers.length ? widget.allOtherUsers.length : endIndex,
    );
  }

  // Check if there are more users to load
  bool get _hasMoreUsers {
    return _currentPage * _itemsPerPage < widget.allOtherUsers.length;
  }

  // Load more users
  Future<void> _loadMoreUsers() async {
    if (_isLoading || !_hasMoreUsers) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _currentPage++;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return
    
    
     NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Auto-load when user scrolls to 80% of the content
        if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent * 0.8) {
          _loadMoreUsers();
        }
        return false;
      },
      child: SingleChildScrollView( // 🔹 Whole body scrollable
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

          // 🔹 Top 3 Users
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: LeaderboardCard(
                    user: widget.topUsers[1],
                    rank: 2,
                    dataType: widget.dataType,
                    small: true,
                    onTap: () => _showUserProfileBottomSheet(context, widget.topUsers[1], 2),
                  ),
                ),
                Expanded(
                  child: LeaderboardCard(
                    user: widget.topUsers[0],
                    rank: 1,
                    dataType: widget.dataType,
                    small: false,
                    onTap: () => _showUserProfileBottomSheet(context, widget.topUsers[0], 1),
                  ),
                ),
                Expanded(
                  child: LeaderboardCard(
                    user: widget.topUsers[2],
                    rank: 3,
                    dataType: widget.dataType,
                    small: true,
                    onTap: () => _showUserProfileBottomSheet(context, widget.topUsers[2], 3),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 🔹 Myself card FULL blue
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () => _showUserProfileBottomSheet(context, widget.myself, 11),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue, // Full blue background
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(color: Colors.white, width: 0.5),
                    ),
                    child: Center(
                      child: Text(
                        "11", // hardcoded for example
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.myself["image"]!),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.myself["name"]!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.myself["address"]!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.dataType == LeaderboardType.distance 
                        ? _getMetricValue(widget.myself)
                        : "${_getMetricValue(widget.myself)} ${_getMetricLabel()}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),

          const SizedBox(height: 20),

          // 🔹 Other users list (paginated)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Display paginated users
                ...List.generate(_paginatedUsers.length, (index) {
                  final user = _paginatedUsers[index];
                  final rank = index + 4; // since top 3 already taken
                  return GestureDetector(
                    onTap: () => _showUserProfileBottomSheet(context, user, rank),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                            border: Border.all(color: Colors.grey, width: 0.5),
                          ),
                          child: Center(
                            child: Text(
                              "$rank",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(user["image"]!),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user["name"]!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Text(
                                user["address"]!,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          widget.dataType == LeaderboardType.distance 
                              ? _getMetricValue(user)
                              : "${_getMetricValue(user)} ${_getMetricLabel()}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
                }),
                
                // Loading indicator for auto-load
                if (_isLoading) ...[
                  const SizedBox(height: 20),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    ));
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
      case LeaderboardType.rides:
        totalRides = int.tryParse(user["rides"] ?? "0") ?? 0;
        totalKm = "0 km"; // Default since rides data doesn't have km
        break;
      case LeaderboardType.distance:
        totalRides = 0; // Default since distance data doesn't have rides
        totalKm = user["distance"] ?? "0 km";
        break;
      case LeaderboardType.referrals:
        totalRides = 0; // Default since referrals data doesn't have rides
        totalKm = "0 km"; // Default since referrals data doesn't have km
        break;
    }
    
    final userProfileData = UserProfileData(
      imageUrl: user["image"]!,
      name: user["name"]!,
      address: user["address"]!,
      totalKm: totalKm,
      totalRides: totalRides,
      totalCoins: 0, // Default value since data doesn't have coins
    );
    
    showUserProfileBottomSheet(context, userProfileData);
  }
}

/// 🔹 Separate widget for filter chips
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
  final LeaderboardType dataType;

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
      case LeaderboardType.rides:
        return user["rides"] ?? "0";
      case LeaderboardType.distance:
        return user["distance"] ?? "0 km";
      case LeaderboardType.referrals:
        return user["referrals"] ?? "0";
    }
  }

  // Helper method to get the metric label based on data type
  String _getMetricLabel() {
    switch (dataType) {
      case LeaderboardType.rides:
        return "rides";
      case LeaderboardType.distance:
        return "km";
      case LeaderboardType.referrals:
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
            dataType == LeaderboardType.distance 
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