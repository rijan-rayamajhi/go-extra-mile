import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/monetization/presentation/my_earning_screen.dart';
import 'package:go_extra_mile_new/features/others/about_screen.dart';
import 'package:go_extra_mile_new/features/others/faq_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/my_ride_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/features/profile/presentation/screens/my_profile_screen.dart';
import 'package:go_extra_mile_new/features/monetization/presentation/monetization_screen.dart';
import 'package:go_extra_mile_new/features/monetization/presentation/bloc/monetization_data_bloc.dart';
import 'package:go_extra_mile_new/features/monetization/presentation/bloc/monetization_data_event.dart';
import 'package:go_extra_mile_new/features/monetization/presentation/bloc/monetization_data_state.dart';

import 'package:go_extra_mile_new/features/vehicle/presentation/screens/my_vechile_screen.dart';
import 'package:go_extra_mile_new/features/license/presentation/screens/my_driving_license_screen.dart';
import 'package:go_extra_mile_new/features/referral/presentation/screens/refer_and_earn_screen.dart';

class HomeProfileImage extends StatefulWidget {
  final String? profileImageUrl;

  const HomeProfileImage({super.key, this.profileImageUrl});

  @override
  State<HomeProfileImage> createState() => _HomeProfileImageState();
}

class _HomeProfileImageState extends State<HomeProfileImage> {
  @override
  void initState() {
    super.initState();
    // Load complete monetization data when widget initializes
    context.read<MonetizationDataBloc>().add(const LoadMonetizationData());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CircularImage(
        key: ValueKey(widget.profileImageUrl),
        imageUrl: widget.profileImageUrl,
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
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
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

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        // Options
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              ProfileTile(
                                imageUrl: widget.profileImageUrl,
                                title: 'My Profile',
                                subtitle: 'View your complete profile',
                                color: Theme.of(context).colorScheme.primary,
                                onTap: () => _navigate(context, '/profile'),
                              ),
                              const SizedBox(height: 12),
                              BlocBuilder<
                                MonetizationDataBloc,
                                MonetizationDataState
                              >(
                                builder: (context, state) {
                                  // Always show monetization option, but determine which one based on state
                                  bool isMonetized = false;

                                  if (state is MonetizationDataLoaded &&
                                      state.hasMonetizationStatus) {
                                    isMonetized = state.isMonetized ?? false;
                                  }

                                  return CompactOptionTile(
                                    icon: Icons.account_balance_wallet,
                                    title: isMonetized
                                        ? 'My Earning'
                                        : 'Monetization',
                                    color: Colors.green,
                                    onTap: () {
                                      if (isMonetized) {
                                        _navigate(context, '/myearning');
                                      } else {
                                        _navigate(context, '/monetization');
                                      }
                                    },
                                  );
                                },
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
                                icon: Icons.share,
                                title: 'Refer and Earn',
                                color: Colors.pink,
                                onTap: () => _navigate(context, '/referral'),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Support & Info Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Support & Info',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
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
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Enterprise Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enterprise',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 12),
                              CompactOptionTile(
                                icon: Icons.person_outline,
                                title: 'Employee Portal',
                                color: Colors.indigo,
                                onTap: () =>
                                    _navigate(context, '/employee-portal'),
                              ),
                              CompactOptionTile(
                                icon: Icons.business_center,
                                title: 'Business Portal',
                                color: Colors.deepPurple,
                                onTap: () =>
                                    _navigate(context, '/business-portal'),
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
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);

    // Handle specific route navigation
    switch (route) {
      case '/profile':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyProfileScreen()),
        );
        break;
      case '/rides':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyRideScreen()),
        );
        break;
      case '/vehicles':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyVehicleScreen()),
        );
        break;
      case '/license':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MyDrivingLicenseScreen(),
          ),
        );
        break;
      case '/referral':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReferAndEarnScreen()),
        );
        break;
      case '/monetization':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MonetizationScreen()),
        );
        break;

      case '/myearning':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyEarningScreen()),
        );
        break;
      case '/about':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutScreen()),
        );
        break;
      case '/faq':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FAQScreen()),
        );
        break;
      case '/addresses':
        // Address/Order management screen - show placeholder for now
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address management feature coming soon'),
            duration: Duration(seconds: 2),
          ),
        );
        break;
      case '/employee-portal':
        // Navigate to employee portal web view
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewScreen(
              url: 'https://gem-admin-five.vercel.app/login',
              title: 'Employee Portal',
            ),
          ),
        );
        break;
      case '/business-portal':
        // Business portal screen - show placeholder for now
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewScreen(
              url: 'https://gem-business.vercel.app/',
              title: 'business Portal',
            ),
          ),
        );
        break;
      default:
        // For unknown routes, show a placeholder
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation to $route not implemented yet'),
            duration: const Duration(seconds: 2),
          ),
        );
        break;
    }
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
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
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey[400],
                size: 16,
              ),
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
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// WebView Screen for displaying web content
class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}
