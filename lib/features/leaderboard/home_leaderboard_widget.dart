import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/common/widgets/custome_divider.dart';
import 'package:go_extra_mile_new/common/widgets/user_profile_bottom_sheet.dart';
import 'package:go_extra_mile_new/features/leaderboard/presentation/fourwheeler_riderboard_screen.dart';
import 'package:go_extra_mile_new/features/leaderboard/presentation/twowheeler_riderboard_screen.dart';
import 'package:go_extra_mile_new/features/leaderboard/presentation/referalboard_screen.dart';

// User data model for leaderboard
class LeaderboardUser {
  final String imageUrl;
  final String name;
  final String address;
  final String totalKm;
  final int totalRides;
  final int totalCoins;
  final String label;

  LeaderboardUser({
    required this.imageUrl,
    required this.name,
    required this.address,
    required this.totalKm,
    required this.totalRides,
    required this.totalCoins,
    required this.label,
  });
}

class HomeLeaderboardWidget extends StatelessWidget {
  const HomeLeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CustomeDivider(text: 'Top Riders of the week'),
              SizedBox(height: 12),
            ],
          ),
        ),

        // 🔹 Horizontal Scrollable Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              _buildLeaderboardCategory(
                context: context,
                title: "Two Wheeler",
                icon: Icons.pedal_bike,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TwoWhellerRiderboardScreen()),
                  );
                },
                users: [
                  LeaderboardUser(
                    imageUrl: "https://i.pravatar.cc/100?img=1",
                    name: "Alex Johnson",
                    address: "Kathmandu, Nepal",
                    totalKm: "120 km",
                    totalRides: 45,
                    totalCoins: 1250,
                    label: "120 km",
                  ),
                  LeaderboardUser(
                    imageUrl: "https://i.pravatar.cc/100?img=2",
                    name: "Sarah Wilson",
                    address: "Pokhara, Nepal",
                    totalKm: "95 km",
                    totalRides: 38,
                    totalCoins: 980,
                    label: "95 km",
                  ),
                  LeaderboardUser(
                    imageUrl: "https://i.pravatar.cc/100?img=3",
                    name: "Mike Chen",
                    address: "Lalitpur, Nepal",
                    totalKm: "80 km",
                    totalRides: 32,
                    totalCoins: 850,
                    label: "80 km",
                  ),
                ],
              ),
              const SizedBox(width: 12),
              _buildLeaderboardCategory(
                context: context,
                title: "Four Wheeler",
                icon: Icons.directions_car,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FourWheelerRiderboardScreen()),
                  );
                },
                users: [
                  LeaderboardUser(
                    imageUrl: "https://i.pravatar.cc/100?img=4",
                    name: "David Kumar",
                    address: "Bhaktapur, Nepal",
                    totalKm: "340 km",
                    totalRides: 68,
                    totalCoins: 2100,
                    label: "340 km",
                  ),
                  LeaderboardUser(
                    imageUrl: "https://i.pravatar.cc/100?img=5",
                    name: "Emma Thompson",
                    address: "Chitwan, Nepal",
                    totalKm: "300 km",
                    totalRides: 60,
                    totalCoins: 1850,
                    label: "300 km",
                  ),
                  LeaderboardUser(
                    imageUrl: "https://i.pravatar.cc/100?img=6",
                    name: "Raj Patel",
                    address: "Bharatpur, Nepal",
                    totalKm: "260 km",
                    totalRides: 52,
                    totalCoins: 1600,
                    label: "260 km",
                  ),
                ],
              ),
              const SizedBox(width: 12),
              _buildLeaderboardCategory(
                context: context,
                title: "Referral",
                icon: Icons.people_alt,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReferalboardScreen()),
                  );
                },
                users: [
                  LeaderboardUser(
                    imageUrl: "https://i.pravatar.cc/100?img=7",
                    name: "Lisa Sharma",
                    address: "Dharan, Nepal",
                    totalKm: "180 km",
                    totalRides: 42,
                    totalCoins: 3200,
                    label: "15 referrals",
                  ),
                  LeaderboardUser(
                    imageUrl: "https://i.pravatar.cc/100?img=8",
                    name: "Tom Anderson",
                    address: "Birgunj, Nepal",
                    totalKm: "150 km",
                    totalRides: 35,
                    totalCoins: 2800,
                    label: "10 referrals",
                  ),
                  LeaderboardUser(
                    imageUrl: "https://i.pravatar.cc/100?img=9",
                    name: "Priya Singh",
                    address: "Janakpur, Nepal",
                    totalKm: "120 km",
                    totalRides: 28,
                    totalCoins: 2400,
                    label: "8 referrals",
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildLeaderboardCategory({
    required BuildContext context,
    required String title,
    required List<LeaderboardUser> users,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 350,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        // gradient: LinearGradient(
        //   colors: [
        //     Colors.white.withValues(alpha: 0.95),
        //     Colors.grey.shade100.withValues(alpha: 0.9),
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Header Row (Icon - Title - See All)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.blueAccent, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: onPressed,
                child: const Text(
                  "See all",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 🔹 Top 3 Users Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildUserRank(context, users[1], 2),
              _buildUserRank(context, users[0], 1, isFirst: true),
              _buildUserRank(context, users[2], 3),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildUserRank(
    BuildContext context,
    LeaderboardUser user,
    int rank, {
    bool isFirst = false,
  }) {
    return Column(
      children: [
        CircularImage(
          imageUrl: user.imageUrl,
          height: isFirst ? 92 : 82,
          width: isFirst ? 92 : 82,
          onTap: () => _showUserProfileBottomSheet(context, user),
        ),
        const SizedBox(height: 6),
        Text(
          "#$rank",
          style: TextStyle(
            fontSize: isFirst ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isFirst ? Colors.amber[700] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  static void _showUserProfileBottomSheet(
    BuildContext context,
    LeaderboardUser user,
  ) {
    final userProfileData = UserProfileData(
      imageUrl: user.imageUrl,
      name: user.name,
      address: user.address,
      totalKm: user.totalKm,
      totalRides: user.totalRides,
      totalCoins: user.totalCoins,
    );
    
    showUserProfileBottomSheet(context, userProfileData);
  }
}

