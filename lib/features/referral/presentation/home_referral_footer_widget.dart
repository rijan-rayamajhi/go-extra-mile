import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/secondary_button.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_bloc.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_event.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_state.dart';

class HomeReferrallFooterWidget extends StatefulWidget {
  const HomeReferrallFooterWidget({super.key});

  @override
  State<HomeReferrallFooterWidget> createState() =>
      _HomeReferrallFooterWidgetState();
}

class _HomeReferrallFooterWidgetState extends State<HomeReferrallFooterWidget> {
  @override
  void initState() {
    super.initState();
    // Load referral data when widget initializes
    context.read<ReferralBloc>().add(GetReferralDataEvent());
  }

  void _copyReferralCode(String referralCode) {
    Clipboard.setData(ClipboardData(text: referralCode));
    AppSnackBar.info(context, 'Referral code copied to clipboard!');
  }

  void _shareReferralCode(String referralCode) {
    final String shareText = '''
🚗 Join Go Extra Mile and start earning!

Use my referral code: $referralCode

📱 Download the app and win up to 100 GEM Coins!
💰 I'll also get up to 100 GEM Coins when you join!

Let's earn together! 🎉
''';

    Share.share(
      shareText,
      subject: 'Join Go Extra Mile - Referral Code: $referralCode',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Refer and Earn',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.black87),
              children: [
                TextSpan(
                  text: 'Earn rewards by referring friends. They win upto ',
                ),
                TextSpan(
                  text: '100 GEM Coins',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ', You win upto '),
                TextSpan(
                  text: '100 GEM Coins',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<ReferralBloc, ReferralState>(
            builder: (context, state) {
              String referralCode = 'Loading...';
              bool isLoading = true;

              if (state is ReferralDataLoaded) {
                referralCode = state.referralCode;
                isLoading = false;
              } else if (state is ReferralError) {
                referralCode = 'Error loading code';
                isLoading = false;
              }

              return Row(
                children: [
                  const Flexible(
                    child: Text(
                      'Referral Code: ',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      referralCode,
                      style: TextStyle(
                        fontSize: 14,
                        color: isLoading ? Colors.grey : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isLoading
                        ? null
                        : () => _copyReferralCode(referralCode),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: isLoading ? Colors.grey : Colors.blue,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<ReferralBloc, ReferralState>(
            builder: (context, state) {
              String referralCode = '';
              bool isLoading = true;

              if (state is ReferralDataLoaded) {
                referralCode = state.referralCode;
                isLoading = false;
              }

              return SizedBox(
                height: 95,
                width: double.infinity,
                child: Stack(
                  children: [
                    // Button positioned on the left, centered vertically
                    SizedBox(
                      width: 100,
                      child: SecondaryButton(
                        text: 'Invite',
                        onPressed: () {
                          if (!isLoading) {
                            _shareReferralCode(referralCode);
                          }
                        },
                      ),
                    ),
                    // Image positioned on the right
                    Align(
                      alignment: Alignment.topRight,
                      child: Image.asset(
                        'assets/images/undraw_share_1zw4.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
