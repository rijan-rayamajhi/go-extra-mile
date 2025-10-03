import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_bloc.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_state.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerCareBottomSheet extends StatelessWidget {
  const CustomerCareBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: context.read<AdminDataBloc>(),
        child: const CustomerCareBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AdminDataBloc, AdminDataState>(
      builder: (context, state) {
        String? whatsappNumber;
        String? emailAddress;
        String? phoneNumber;
        String? companyName;

        if (state is AdminDataLoaded) {
          whatsappNumber = state.appSettings.whatsappNumber;
          emailAddress = state.appSettings.email;
          phoneNumber = state.appSettings.phoneNumber;
          companyName = state.appSettings.appName;
        }

        return Container(
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
                  child: Row(
                    children: [
                      // App Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/app_logo.PNG',
                          width: 40,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Title and company name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Customer Support',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[800],
                              ),
                            ),
                            if (companyName != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  companyName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    height: 1.3,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Support options
                if (state is AdminDataLoading)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  )
                else if (state is AdminDataError)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Failed to load support information',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (whatsappNumber != null)
                          _buildSupportOption(
                            context,
                            icon: Icons.chat_bubble_outline,
                            title: 'WhatsApp Support',
                            subtitle: 'Chat with us on WhatsApp',
                            color: const Color(0xFF25D366),
                            onTap: () =>
                                _launchWhatsApp(context, whatsappNumber!),
                          ),
                        if (whatsappNumber != null && emailAddress != null)
                          const SizedBox(height: 12),
                        if (emailAddress != null)
                          _buildSupportOption(
                            context,
                            icon: Icons.email_outlined,
                            title: 'Email Support',
                            subtitle: 'Send us an email',
                            color: theme.colorScheme.primary,
                            onTap: () => _launchEmail(context, emailAddress!),
                          ),
                        if (emailAddress != null && phoneNumber != null)
                          const SizedBox(height: 12),
                        if (phoneNumber != null)
                          _buildSupportOption(
                            context,
                            icon: Icons.phone_outlined,
                            title: 'Phone Support',
                            subtitle: 'Call us directly',
                            color: theme.colorScheme.primary,
                            onTap: () => _launchPhone(context, phoneNumber!),
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
        );
      },
    );
  }

  Widget _buildSupportOption(
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

  Future<void> _launchWhatsApp(BuildContext context, String phoneNumber) async {
    try {
      // Format phone number for WhatsApp (remove any non-digit characters)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Create WhatsApp URL
      final whatsappUrl = 'https://wa.me/$cleanNumber';

      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(
          Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          AppSnackBar.error(context, 'Could not open WhatsApp');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Could not open WhatsApp: $e');
      }
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    try {
      // Create mailto URL
      final mailtoUrl = 'mailto:$email';

      if (await canLaunchUrl(Uri.parse(mailtoUrl))) {
        await launchUrl(
          Uri.parse(mailtoUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          AppSnackBar.error(context, 'Could not open email app');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Could not open email app: $e');
      }
    }
  }

  Future<void> _launchPhone(BuildContext context, String phoneNumber) async {
    try {
      // Create tel URL
      final telUrl = 'tel:$phoneNumber';

      if (await canLaunchUrl(Uri.parse(telUrl))) {
        await launchUrl(
          Uri.parse(telUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (context.mounted) {
          AppSnackBar.error(context, 'Could not open phone app');
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Could not open phone app: $e');
      }
    }
  }
}
