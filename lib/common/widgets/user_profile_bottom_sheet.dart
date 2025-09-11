import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';

// User data model for profile bottom sheet
class UserProfileData {
  final String imageUrl;
  final String name;
  final String address;
  final String totalKm;
  final int totalRides;
  final int totalCoins;

  UserProfileData({
    required this.imageUrl,
    required this.name,
    required this.address,
    required this.totalKm,
    required this.totalRides,
    required this.totalCoins,
  });
}

class UserProfileBottomSheet extends StatelessWidget {
  final UserProfileData user;
  final VoidCallback? onViewProfile;

  const UserProfileBottomSheet({
    super.key,
    required this.user,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          // Profile Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Profile Image
                CircularImage(imageUrl: user.imageUrl, height: 100, width: 100),
                const SizedBox(height: 16),

                // Name
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Address
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      user.address,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSimpleStat("Total KMs", user.totalKm),
                    _buildSimpleStat("Total Rides", "${user.totalRides}"),
                    _buildSimpleStat("Total Coins", "${user.totalCoins}"),
                  ],
                ),

                const SizedBox(height: 30),

                // View Profile Button
                PrimaryButton(
                  text: "View Profile",
                  onPressed: () {
                    Navigator.pop(context);
                    onViewProfile?.call();
                  },
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Helper function to show the user profile bottom sheet
void showUserProfileBottomSheet(
  BuildContext context,
  UserProfileData user, {
  VoidCallback? onViewProfile,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => UserProfileBottomSheet(
      user: user,
      onViewProfile: onViewProfile,
    ),
  );
}
