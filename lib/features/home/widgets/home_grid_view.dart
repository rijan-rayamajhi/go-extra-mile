import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/screens/gem_coins_history_screen.dart';
import 'package:go_extra_mile_new/features/license/presentation/screens/my_driving_license_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/my_ride_screen.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/my_vechile_screen.dart';


class HomeGridView extends StatelessWidget {
  const HomeGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 100,
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
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
                height: 1.2,
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
  final VoidCallback onTap;

  GridItemData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
} 