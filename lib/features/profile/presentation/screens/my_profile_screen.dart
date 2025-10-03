import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/common/widgets/image_viewer.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/auth/presentation/screens/delete_account_screen.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_event.dart';
import 'package:go_extra_mile_new/features/profile/presentation/bloc/profile_state.dart';
import 'package:go_extra_mile_new/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:go_extra_mile_new/features/profile/presentation/screens/profile_shimmer_loading.dart';
import 'package:go_extra_mile_new/features/profile/data/model/profile_model.dart';
import 'package:go_extra_mile_new/features/profile/domain/entities/profile_entity.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/customer_care_bottom_sheet.dart';
import 'package:go_extra_mile_new/features/profile/presentation/widgets/profile_ride_stats.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_bloc.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_state.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_event.dart';
import 'package:go_extra_mile_new/features/auth/presentation/screens/auth_wrapper.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/ride_memory_grid_view.dart';

import 'package:url_launcher/url_launcher.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen initializes
    context.read<ProfileBloc>().add(const GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && state.justUpdated) {
          AppSnackBar.success(context, 'Profile updated successfully');
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return ProfileShimmerLoading();
          }
          if (state is ProfileError) {
            // If error has profile data, show it with error message
            if (state.profile != null) {
              return _buildProfileScaffold(
                state.profile!,
                ProfileLoaded(state.profile!),
              );
            }
            return Center(child: Text(state.message));
          }
          if (state is ProfileLoaded) {
            return _buildProfileScaffold(state.profile, state);
          }
          return Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () {
                  //log out
                  context.read<KAuthBloc>().add(KSignOutEvent());
                },
                child: const Text('Something went wrong'),
              ),
            ),
          );
        },
      ),
    );
  }

  Scaffold _buildProfileScaffold(
    ProfileEntity profile,
    ProfileLoaded currentState,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leadingWidth: 250,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //back button
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  profile.userName != null
                      ? '@${profile.userName}'.replaceAll('  ', ' ')
                      : 'User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          //toggle switch with loading indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentState.isUpdating)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  IconButton(
                    icon: Icon(
                      (profile.privateProfile ?? false) == true
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: (profile.privateProfile ?? false) == true
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: currentState.isUpdating
                        ? null
                        : () {
                            _showPrivacyConfirmation(context, profile);
                          },
                    tooltip: (profile.privateProfile ?? false) == true
                        ? 'Profile is private - tap to make public'
                        : 'Profile is public - tap to make private',
                  ),
                ],
              ),
            ],
          ),
          // Customer care icon
          IconButton(
            icon: Icon(
              Icons.support_agent,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              CustomerCareBottomSheet.show(context);
            },
            tooltip: 'Customer Care & Support',
          ),
          // Settings/Menu icon
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              _showOptionsBottomSheet(context);
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(baseScreenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircularImage(
                      imageUrl: profile.photoUrl,
                      heroTag: 'profile_image',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => ImageViewer(
                            imageUrl: profile.photoUrl,
                            heroTag: 'profile_image',
                            title: profile.displayName,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.displayName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),

                          //address
                          Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.locationDot,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                (profile.address != null &&
                                        profile.address!.length > 25)
                                    ? '${profile.address!.substring(0, 25)}..'
                                    : profile.address ?? 'India',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                              ),
                            ],
                          ),

                          ///three icons in row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //instagram
                              if (profile.instagramLink != null &&
                                  (profile.showInstagram ?? true)) ...[
                                IconButton(
                                  onPressed: () {
                                    launchUrl(
                                      Uri.parse(profile.instagramLink!),
                                    );
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.instagram,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                SizedBox.shrink(),
                              ],

                              if (profile.youtubeLink != null &&
                                  (profile.showYoutube ?? true)) ...[
                                IconButton(
                                  onPressed: () {
                                    launchUrl(Uri.parse(profile.youtubeLink!));
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.youtube,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                SizedBox.shrink(),
                              ],
                              //youtube

                              //whatsapp
                              if (profile.whatsappLink != null &&
                                  (profile.showWhatsapp ?? true)) ...[
                                IconButton(
                                  onPressed: () {
                                    // Create WhatsApp URL from phone number
                                    final phoneNumber = profile.whatsappLink!;
                                    final whatsappUrl =
                                        'https://wa.me/$phoneNumber';
                                    launchUrl(Uri.parse(whatsappUrl));
                                  },
                                  icon: Icon(
                                    FontAwesomeIcons.whatsapp,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    size: 24,
                                  ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                SizedBox.shrink(),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (profile.bio != null) ...[
                Text(
                  profile.bio!.length > 50
                      ? '${profile.bio!.substring(0, 50)}...'
                      : profile.bio!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 16),
              ] else ...[
                SizedBox.shrink(),
              ],

              PrimaryButton(
                text: 'Edit Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(profile: profile),
                    ),
                  ).then((_) {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser != null && mounted) {
                      // Refresh the profile when returning from edit screen
                      context.read<ProfileBloc>().add(
                        RefreshProfileEvent(currentUser.uid),
                      );
                    }
                  });
                },
              ),

              //ride information
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: RideStatsWidget(
                        value: (profile.totalGemCoins ?? 0).toStringAsFixed(2),
                        label: 'GEM Coins',
                        icon: FontAwesomeIcons.gem,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.18),
                    ),
                    Flexible(
                      child: RideStatsWidget(
                        value: profile.totalDistance != null
                            ? '${(profile.totalDistance! / 1000).toStringAsFixed(2)} km'
                            : '0.00 km',
                        label: 'Total Distance',
                        icon: FontAwesomeIcons.road,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 48,
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.18),
                    ),
                    Flexible(
                      child: RideStatsWidget(
                        value: (profile.totalRide ?? 0).toString(),
                        label: 'Rides',
                        icon: FontAwesomeIcons.motorcycle,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // //profile memory
              SizedBox(
                height: 400, // Fixed height for grid view
                child: RideMemoryGridView(
                  onRideTap: (ride) {
                    // Handle ride tap
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

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
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Text(
                  'Profile Options',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildOptionItem(
                      context,
                      icon: Icons.logout,
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      color: theme.colorScheme.primary,
                      onTap: () {
                        Navigator.pop(context);
                        _showLogoutConfirmation(context);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildOptionItem(
                      context,
                      icon: Icons.delete_forever,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      color: theme.colorScheme.error,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DeleteAccountScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Cancel button
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          BlocBuilder<KAuthBloc, KAuthState>(
            builder: (context, state) {
              return TextButton(
                onPressed: state is KAuthLoading
                    ? null
                    : () {
                        Navigator.pop(context);
                        _performLogout();
                      },
                child: state is KAuthLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Logout'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showPrivacyConfirmation(BuildContext context, ProfileEntity profile) {
    final currentPrivacy = profile.privateProfile ?? false;
    final newPrivacyValue = !currentPrivacy;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          currentPrivacy ? 'Make Profile Public?' : 'Make Profile Private?',
        ),
        content: Text(
          currentPrivacy
              ? 'Your profile will become visible to other users. Are you sure you want to make it public?'
              : 'Your profile will become private and only visible to you. Are you sure you want to make it private?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProfilePrivacy(profile, newPrivacyValue);
            },
            child: Text(currentPrivacy ? 'Make Public' : 'Make Private'),
          ),
        ],
      ),
    );
  }

  void _updateProfilePrivacy(ProfileEntity profile, bool newPrivacyValue) {
    try {
      // Create updated profile with new privacy setting
      final updatedProfile = (profile as ProfileModel).copyWith(
        privateProfile: newPrivacyValue,
      );

      // Log the change for debugging

      context.read<ProfileBloc>().add(UpdateProfileEvent(updatedProfile));
    } catch (e) {
      // Show error message if update fails
      AppSnackBar.error(context, 'Failed to update privacy setting');
    }
  }

  void _performLogout() async {
    try {
      // Use the auth bloc to handle logout
      context.read<KAuthBloc>().add(KSignOutEvent());

      // Navigate to auth screen immediately after logout
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Failed to logout: $e');
      }
    }
  }
}
