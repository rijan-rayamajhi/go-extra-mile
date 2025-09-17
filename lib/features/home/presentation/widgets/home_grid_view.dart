import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/screens/gem_coins_history_screen.dart';
import 'package:go_extra_mile_new/features/license/presentation/screens/my_driving_license_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/my_ride_screen.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/my_vechile_screen.dart';


class HomeGridView extends StatelessWidget {
  final String unverifiedVehicleCount;
  final String unreadNotificationCount;
  
  const HomeGridView({
    super.key,
    this.unverifiedVehicleCount = '0',
    this.unreadNotificationCount = '0',
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.9,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return _buildGridItem(context, index);
      },
      itemCount: 4,
    );
  }

  Widget _buildGridItem(BuildContext context, int index) {
    final List<GridItemData> gridItems = [
      GridItemData(
        icon: FontAwesomeIcons.car,
        label: 'My Vehicles',
        color: Theme.of(context).colorScheme.onSurface,
        badgeCount: unverifiedVehicleCount,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyVehicleScreen()));
        }
      ),
      GridItemData(
        icon: FontAwesomeIcons.idCard,
        label: 'My Driving\nLicense',
        color: Theme.of(context).colorScheme.onSurface,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyDrivingLicenseScreen()));
        }
      ),
      GridItemData(
        icon: FontAwesomeIcons.motorcycle,
        label: 'My Rides',
        color: Theme.of(context).colorScheme.onSurface,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => MyRideScreen()));
        }
      ),
      GridItemData(
        icon: FontAwesomeIcons.gem,
        label: 'Gem Coin\nHistory',
        color: Theme.of(context).colorScheme.onSurface,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => GemCoinHistoryScreens()));
        }
      ),
      // GridItemData(
      //   icon: FontAwesomeIcons.gift,
      //   label: 'Daily\nReward',
      //   color: Theme.of(context).colorScheme.onSurface,
      //   onTap: () {
      //     // Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationScreen()));
      //   }
      // ),
      // GridItemData(
      //   icon: FontAwesomeIcons.ticket,
      //   label: 'Scratch\nCard',
      //   color: Theme.of(context).colorScheme.onSurface,
      //   onTap: () {
      //     AppSnackBar.show(context, message: 'Coming Soon', type: AppSnackBarType.info);
      //   }
      // ),
      // GridItemData(
      //   icon: FontAwesomeIcons.coins,
      //   label: 'Earn Gem\nCoins',
      //   color: Theme.of(context).colorScheme.onSurface,
      //   onTap: () {
         
      //   }
      // ),
      // GridItemData(
      //   icon: FontAwesomeIcons.trophy,
      //   label: 'Redeem Gem\nCoins',
      //   color: Theme.of(context).colorScheme.onSurface,
      //   onTap: () {
      //     AppSnackBar.show(context, message: 'Coming Soon', type: AppSnackBarType.info);
      //   }
      // ),
    ];

    final item = gridItems[index];
    
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        height: 1.1,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Show badge if there's a count
            if (item.badgeCount != null && 
                item.badgeCount!.isNotEmpty && 
                int.tryParse(item.badgeCount!) != null && 
                int.parse(item.badgeCount!) > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      item.badgeCount!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GridItemData {
  final IconData icon;
  final String label;
  final Color color;
  final String? badgeCount;
  final VoidCallback onTap;

  GridItemData({
    required this.icon,
    required this.label,
    required this.color,
    this.badgeCount,
    required this.onTap,
  });
} 