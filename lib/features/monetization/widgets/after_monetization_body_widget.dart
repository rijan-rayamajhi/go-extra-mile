import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/monetization/my_earning_screen.dart';

class AfterMonetizationBodyWidget extends StatefulWidget {
  const AfterMonetizationBodyWidget({super.key});

  @override
  State<AfterMonetizationBodyWidget> createState() =>
      _AfterMonetizationBodyWidgetState();
}

class _AfterMonetizationBodyWidgetState
    extends State<AfterMonetizationBodyWidget> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.padding(all: baseScreenPadding),
      child: Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSuccessIconSection(context),
                SizedBox(height: context.baseSpacing(baseLargeSpacing)),
                _buildPremiumCard(
                  context,
                  child: _buildCongratulationInfo(context),
                ),
              ],
            ),
          ),
          SizedBox(height: context.baseSpacing(baseLargeSpacing)),
          _buildPrimaryButton(context),
          SizedBox(height: context.baseSpacing(baseLargeSpacing)),
        ],
      ),
    );
  }

  // 🔹 Premium Card Wrapper
  Widget _buildPremiumCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: context.padding(all: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.borderRadius(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildSuccessIconSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text('🎉', style: TextStyle(fontSize: context.iconSize(50))),
          SizedBox(height: context.baseSpacing(baseSpacing)),
          Text(
            'Congratulations!',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: context.baseSpacing(baseSmallSpacing)),
          Text(
            'Your account is now monetized',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCongratulationInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Row(
        //   children: [
        //     CircleAvatar(
        //       backgroundColor: Colors.green.withOpacity(0.1),
        //       radius: 26,
        //       child: Icon(
        //         FontAwesomeIcons.coins,
        //         color: Colors.green.shade600,
        //         size: context.iconSize(22),
        //       ),
        //     ),
        //     SizedBox(width: context.baseSpacing(baseSpacing)),
        //     Expanded(
        //       child: Text(
        //         'Account Monetized Successfully',
        //         style: Theme.of(context).textTheme.titleLarge?.copyWith(
        //           fontWeight: FontWeight.bold,
        //           color: Colors.black87,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        SizedBox(height: context.baseSpacing(baseSpacing)),
        Text(
          'Your account is monetised, you can earn revenue through various methods like App Referrals, ADs, Daily Rewards, Rides, Vehicle Insurance, 24 Hours Flash Sales, Adding service providers and many more.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        SizedBox(height: context.baseSpacing(baseSpacing)),
        Text(
          'You can also explore options like affiliate marketing, merchandise, and paid sponsorships.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return PrimaryButton(
      text: 'My Earnings', 
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyEarningScreen()),
        );
      },
    );
  }
}
