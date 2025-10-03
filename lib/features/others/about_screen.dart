import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart';
import 'package:go_extra_mile_new/core/service/app_version_service.dart';
import 'package:go_extra_mile_new/common/screens/web_view.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_bloc.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_event.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_state.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final AppVersionService _appVersionService = sl<AppVersionService>();
  String _currentVersion = '';
  String _latestVersion = '';
  bool _isUpdateAvailable = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch admin data when screen initializes
    context.read<AdminDataBloc>().add(FetchAdminDataEvent());
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final currentVersion = await _appVersionService.getLocalVersion();

      if (mounted) {
        setState(() {
          _currentVersion = currentVersion;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  /// Compare two semantic versions: returns 1 if v1 > v2, -1 if v1 < v2, 0 if equal
  int _compareVersions(String v1, String v2) {
    try {
      final v1Parts = v1.split('.').map(int.parse).toList();
      final v2Parts = v2.split('.').map(int.parse).toList();

      final maxLength = v1Parts.length > v2Parts.length
          ? v1Parts.length
          : v2Parts.length;

      for (int i = 0; i < maxLength; i++) {
        final part1 = i < v1Parts.length ? v1Parts[i] : 0;
        final part2 = i < v2Parts.length ? v2Parts[i] : 0;
        if (part1 > part2) return 1;
        if (part1 < part2) return -1;
      }
      return 0;
    } catch (e) {
      return 0; // If parsing fails, assume versions are equal
    }
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      _isLoading = true;
    });

    await _loadVersionInfo();
    
    // Trigger admin data fetch to get latest version
    if (mounted) {
      context.read<AdminDataBloc>().add(FetchAdminDataEvent());
    }

    if (_isUpdateAvailable) {
      _showUpdateDialog();
    } else {
      _showNoUpdateDialog();
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Version: $_currentVersion'),
            const SizedBox(height: 8),
            Text('Latest Version: $_latestVersion'),
            const SizedBox(height: 16),
            const Text(
              'A new version is available. Please update to the latest version for the best experience.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _openAppStore();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showNoUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Updates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current Version: $_currentVersion'),
            const SizedBox(height: 8),
            Text('Latest Version: $_latestVersion'),
            const SizedBox(height: 16),
            const Text('You are using the latest version of the app.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAppStore() async {
    // For Android, you would typically open Google Play Store
    // For iOS, you would open App Store
    // This is a placeholder - you'll need to implement platform-specific logic
    const String androidUrl =
        'https://play.google.com/store/apps/details?id=com.rijan.goExtraMile';
    const String iosUrl = 'https://apps.apple.com/app/your-app-id';

    final Uri url = Uri.parse(
      Theme.of(context).platform == TargetPlatform.iOS ? iosUrl : androidUrl,
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open app store')),
        );
      }
    }
  }

  void _openTermsAndConditions(String? termsLink) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          url: termsLink ?? 'https://goeleventhmile.com/privacy-policy.html',
          title: 'Terms & Conditions',
        ),
      ),
    );
  }

  // Helper methods to get data from AdminDataBloc state
  String _getAppName(AdminDataState state) {
    if (state is AdminDataLoaded) {
      return state.appSettings.appName;
    }
    return appName; // Fallback to constant
  }

  String _getAppTagline(AdminDataState state) {
    if (state is AdminDataLoaded) {
      return state.appSettings.appTagline;
    }
    return appDescription; // Fallback to constant
  }

  String _getLatestVersion(AdminDataState state) {
    if (state is AdminDataLoaded) {
      return state.appSettings.appVersion;
    }
    return 'Unknown';
  }

  String? _getTermsLink(AdminDataState state) {
    if (state is AdminDataLoaded) {
      return state.appSettings.termsAndConditionLink;
    }
    return null;
  }

  Widget _buildVersionCard(BuildContext context, AdminDataState state) {
    final latestVersion = _getLatestVersion(state);
    
    // Update version info when admin data is loaded
    if (state is AdminDataLoaded && _currentVersion.isNotEmpty) {
      final isUpdateAvailable = _compareVersions(latestVersion, _currentVersion) > 0;
      if (mounted && _latestVersion != latestVersion) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _latestVersion = latestVersion;
              _isUpdateAvailable = isUpdateAvailable;
            });
          }
        });
      }
    }

    return Container(
      padding: context.padding(all: baseCardPadding * 1.5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.borderRadius(baseCardRadius),
        ),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Version',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: context.fontSize(baseLargeFontSize),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: context.iconSize(baseSmallIconSize),
                  height: context.iconSize(baseSmallIconSize),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              else
                Text(
                  _currentVersion.isNotEmpty ? _currentVersion : 'Unknown',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: context.fontSize(baseLargeFontSize),
                  ),
                ),
            ],
          ),
          if (state is AdminDataLoaded && latestVersion.isNotEmpty) ...[
            SizedBox(height: context.baseSpacing(baseSmallSpacing)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Latest Version',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: context.fontSize(baseMediumFontSize),
                  ),
                ),
                Text(
                  latestVersion,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: context.fontSize(baseMediumFontSize),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: context.baseSpacing(baseSpacing)),
          // Update Button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: _isUpdateAvailable ? 'Update Available' : 'Check for Updates',
              onPressed: _isLoading ? () {} : _checkForUpdates,
              isLoading: _isLoading,
              backgroundColor: _isUpdateAvailable
                  ? Colors.orange
                  : Theme.of(context).colorScheme.primary,
              icon: _isUpdateAvailable ? Icons.system_update : Icons.check_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context, AdminDataState state) {
    return Container(
      padding: context.padding(all: baseCardPadding * 1.5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(
          context.borderRadius(baseCardRadius),
        ),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outline.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legal',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: context.fontSize(baseLargeFontSize),
            ),
          ),
          SizedBox(height: context.baseSpacing(baseSpacing)),
          // Terms and Conditions
          InkWell(
            onTap: () => _openTermsAndConditions(_getTermsLink(state)),
            borderRadius: BorderRadius.circular(
              context.borderRadius(baseInputRadius),
            ),
            child: Container(
              padding: context.padding(vertical: baseSmallSpacing),
              child: Row(
                children: [
                  Container(
                    padding: context.padding(all: baseSmallSpacing),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        context.borderRadius(baseInputRadius),
                      ),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: context.iconSize(baseMediumIconSize),
                    ),
                  ),
                  SizedBox(width: context.baseSpacing(baseSpacing)),
                  Expanded(
                    child: Text(
                      'Terms & Conditions',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: context.fontSize(baseLargeFontSize),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: context.iconSize(baseSmallIconSize),
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('About'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation,
        centerTitle: true,
      ),
      body: BlocBuilder<AdminDataBloc, AdminDataState>(
        builder: (context, state) {
          // Handle loading state
          if (state is AdminDataLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading app information...'),
                ],
              ),
            );
          }

          // Handle error state
          if (state is AdminDataError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: context.iconSize(baseXLargeIconSize),
                    color: Colors.red,
                  ),
                  SizedBox(height: context.baseSpacing(baseSpacing)),
                  Text(
                    'Failed to load app information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.baseSpacing(baseLargeSpacing)),
                  PrimaryButton(
                    text: 'Retry',
                    onPressed: () {
                      context.read<AdminDataBloc>().add(FetchAdminDataEvent());
                    },
                    icon: Icons.refresh,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: context.padding(all: baseScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: context.baseSpacing(baseLargeSpacing)),

                // App Logo/Icon
                Container(
                  width: context.iconSize(baseXLargeIconSize * 2.5),
                  height: context.iconSize(baseXLargeIconSize * 2.5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      context.borderRadius(baseCardRadius * 1.5),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      context.borderRadius(baseCardRadius * 1.5),
                    ),
                    child: Image.asset(
                      'assets/images/app_logo.PNG',
                      width: context.iconSize(baseXLargeIconSize * 2.5),
                      height: context.iconSize(baseXLargeIconSize * 2.5),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return Icon(
                          Icons.directions_bike,
                          size: context.iconSize(baseXLargeIconSize),
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                  ),
                ),

                SizedBox(height: context.baseSpacing(baseLargeSpacing)),

                // App Name - Dynamic from AdminDataBloc
                Text(
                  _getAppName(state),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: context.fontSize(baseXXLargeFontSize),
                  ),
                ),

                SizedBox(height: context.baseSpacing(baseSmallSpacing)),

                // App Description - Dynamic from AdminDataBloc
                Text(
                  _getAppTagline(state),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                    fontSize: context.fontSize(baseLargeFontSize),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.baseSpacing(baseLargeSpacing * 1.5)),

                // Version Information Card
                _buildVersionCard(context, state),

                SizedBox(height: context.baseSpacing(baseLargeSpacing)),

                // Terms and Policy Section
                _buildLegalSection(context, state),

                SizedBox(height: context.baseSpacing(baseLargeSpacing)),

                // Copyright
                Text(
                  '© 2025 Go Extra Mile. All rights reserved.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: context.fontSize(baseSmallFontSize),
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: context.baseSpacing(baseSpacing)),
              ],
            ),
          );
        },
      ),
    );
  }
}
