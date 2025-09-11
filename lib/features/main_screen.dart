import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/screens/earn_gem_coin_screen.dart';
import 'package:go_extra_mile_new/features/home/presentation/home_screen.dart';
import 'package:go_extra_mile_new/features/redeem/redeem_screen.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/ride_vehicle_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isNavigating = false;

  // List of pages for each tab
  late final List<Widget> _pages = [
    const HomeScreen(),
    EarnGemCoinScreen(),
    const RideVehicleScreen(), // This won't be used directly due to navigation logic
    const RedeemScreen(),
    const Center(
      child: Text(
        'Rewards',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      ),
    ),
  ];

  void _onItemTapped(int index) async {
    if (_isNavigating) return; // Prevent multiple taps

    if (index == 2) {
      // Ride tab
      setState(() => _isNavigating = true);

      try {
        // Check if user is authenticated

        if (mounted) {
          // Navigate to RideVehicleScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RideVehicleScreen()),
          );
        }
      } catch (e) {
        // Handle any errors gracefully
        debugPrint('Error in ride navigation: $e');
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RideVehicleScreen()),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isNavigating = false);
        }
      }
    } else {
      // Regular tab navigation
      if (mounted) {
        setState(() {
          _selectedIndex = index;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: PremiumBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        isNavigating: _isNavigating,
      ),
    );
  }
}

class PremiumBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final bool isNavigating;

  const PremiumBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isNavigating = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 25),
      height: 70,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: FontAwesomeIcons.house,
                  label: 'Home',
                  index: 0,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: FontAwesomeIcons.coins,
                  label: 'Earn',
                  index: 1,
                  theme: theme,
                ),
                _buildRideFAB(theme),
                _buildNavItem(
                  icon: FontAwesomeIcons.gift,
                  label: 'Redeem',
                  index: 3,
                  theme: theme,
                ),
                _buildNavItem(
                  icon: FontAwesomeIcons.trophy,
                  label: 'Rewards',
                  index: 4,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRideFAB(ThemeData theme) {
    return GestureDetector(
      onTap: isNavigating ? null : () => onItemTapped(2),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isNavigating
                ? [
                    theme.primaryColor.withOpacity(0.6),
                    theme.primaryColor.withOpacity(0.4),
                  ]
                : [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.2),
              blurRadius: 25,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
          ],
        ),
        child: isNavigating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(
                Icons.navigation_rounded,
                color: Colors.white,
                size: 28,
              ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required ThemeData theme,
  }) {
    final bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: isSelected
                    ? BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withOpacity(0.2),
                            theme.primaryColor.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      )
                    : null,
                child: FaIcon(
                  icon,
                  color: isSelected ? theme.primaryColor : Colors.grey.shade600,
                  size: isSelected ? 18 : 16,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSelected ? 10 : 9,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? theme.primaryColor : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
