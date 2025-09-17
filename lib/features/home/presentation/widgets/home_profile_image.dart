import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:go_extra_mile_new/features/monetization/monetization_screen.dart';

class HomeProfileImage extends StatelessWidget {
  final String? profileImageUrl;

  const HomeProfileImage({super.key, this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CircularImage(
        key: ValueKey(profileImageUrl),
        imageUrl: profileImageUrl,
        onTap: () => _showProfileBottomSheet(context),
        height: 50,
        width: 50,
      ),
    );
  }

  void _showProfileBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    ProfileTile(
                      imageUrl: profileImageUrl,
                      title: 'My Profile',
                      subtitle: 'View your complete profile',
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => _navigate(context, '/profile'),
                    ),
                    const SizedBox(height: 12),
                    CompactOptionTile(
                      icon: Icons.account_balance_wallet,
                      title: 'My Earnings',
                      color: Colors.green,
                      onTap: () => _navigateToMonetization(context),
                    ),
                    CompactOptionTile(
                      icon: Icons.motorcycle,
                      title: 'My Rides',
                      color: Colors.blue,
                      onTap: () => _navigate(context, '/rides'),
                    ),
                    CompactOptionTile(
                      icon: Icons.directions_car,
                      title: 'My Vehicles',
                      color: Colors.purple,
                      onTap: () => _navigate(context, '/vehicles'),
                    ),
                    CompactOptionTile(
                      icon: Icons.credit_card,
                      title: 'My Driving License',
                      color: Colors.orange,
                      onTap: () => _navigate(context, '/license'),
                    ),
                    CompactOptionTile(
                      icon: Icons.location_on,
                      title: 'Order and Address',
                      color: Colors.red,
                      onTap: () => _navigate(context, '/addresses'),
                    ),
                    CompactOptionTile(
                      icon: Icons.info_outline,
                      title: 'About',
                      color: Colors.teal,
                      onTap: () => _navigate(context, '/about'),
                    ),
                    CompactOptionTile(
                      icon: Icons.help_outline,
                      title: 'FAQ',
                      color: Colors.indigo,
                      onTap: () => _navigate(context, '/faq'),
                    ),
                    CompactOptionTile(
                      icon: Icons.share,
                      title: 'Refer and Earn',
                      color: Colors.pink,
                      onTap: () => _navigate(context, '/referral'),
                    ),
                    CompactOptionTile(
                      icon: Icons.business,
                      title: 'Register Your Business',
                      color: Colors.brown,
                      onTap: () => _navigate(context, '/business-register'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Version
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    
    // Handle profile navigation specifically
    if (route == '/profile') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MyProfileScreen()),
      );
    } else {
      // For other routes, you can add specific navigation logic here
      // For now, just show a placeholder
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation to $route not implemented yet'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _navigateToMonetization(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MonetizationScreen()),
    );
  }
}

/// Tile with profile image + title + subtitle
class ProfileTile extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ProfileTile({
    super.key,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OptionTile(
      onTap: onTap,
      leading: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.person, color: color, size: 24),
              )
            : Icon(Icons.person, color: color, size: 24),
      ),
      title: title,
      subtitle: subtitle,
      color: color,
    );
  }
}

/// General reusable option tile
class OptionTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const OptionTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: leading,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        )),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact version for most options
class CompactOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const CompactOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      )),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.grey[400], size: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}