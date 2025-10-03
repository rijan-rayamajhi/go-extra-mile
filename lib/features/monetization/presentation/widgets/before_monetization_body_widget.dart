import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/common/widgets/custome_divider.dart';
import 'package:go_extra_mile_new/features/admin_data/domain/entities/monetization_settings.dart';
import 'package:go_extra_mile_new/features/admin_data/domain/entities/faq.dart';
import 'package:go_extra_mile_new/features/monetization/domain/entities/monetization_data_entity.dart';
import 'package:go_extra_mile_new/features/monetization/presentation/my_earning_screen.dart';

class BeforeMonetizationBodyWidget extends StatefulWidget {
  final MonetizationDataEntity monetizationData;
  final MonetizationSettings monetizationSettings;
  const BeforeMonetizationBodyWidget({
    super.key,
    required this.monetizationData,
    required this.monetizationSettings,
  });

  @override
  State<BeforeMonetizationBodyWidget> createState() =>
      _BeforeMonetizationBodyWidgetState();
}

class _BeforeMonetizationBodyWidgetState
    extends State<BeforeMonetizationBodyWidget> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.padding(all: baseScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGemIconSection(context),
          SizedBox(height: context.baseSpacing(baseLargeSpacing)),
          _buildPremiumCard(
            context,
            child: _buildMonetizationInfo(
              context,
              widget.monetizationSettings.monetizationMessage,
            ),
          ),
          SizedBox(height: context.baseSpacing(baseLargeSpacing)),
          const CustomeDivider(text: 'Monetization Requirements'),
          SizedBox(height: context.baseSpacing(baseSpacing)),
          _buildVerifyDLCard(context),
          SizedBox(height: context.baseSpacing(baseSpacing)),
          _buildVerifyVehicleCard(context),
          SizedBox(height: context.baseSpacing(baseSpacing)),
          _buildValidRidesCard(
            context,
            widget.monetizationSettings.cashoutParams.minimumRides,
          ),
          SizedBox(height: context.baseSpacing(baseSpacing)),
          _buildDistanceCard(
            context,
            widget.monetizationSettings.cashoutParams.minimumDistance,
          ),
          SizedBox(height: context.baseSpacing(baseSpacing)),
          _buildReferralCard(
            context,
            widget.monetizationSettings.cashoutParams.minimumReferrals,
          ),
          SizedBox(height: context.baseSpacing(baseLargeSpacing)),
          _buildFAQsSection(context, widget.monetizationSettings.faqs),
          SizedBox(height: context.baseSpacing(baseLargeSpacing)),
          _buildCashoutButton(context),
          SizedBox(height: context.baseSpacing(baseLargeSpacing)),
        ],
      ),
    );
  }

  // 🔹 Premium Card Wrapper
  Widget _buildPremiumCard(BuildContext context, {required Widget child}) {
    return Container(
      padding: context.padding(all: 20),
      width: double.infinity,
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

  Widget _buildGemIconSection(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Image.asset(
            'assets/icons/gem_coin.png',
            width: context.iconSize(100),
            height: context.iconSize(100),
            fit: BoxFit.contain,
          ),
          SizedBox(height: context.baseSpacing(baseSpacing)),
          Text(
            'Monetization',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: context.baseSpacing(baseSmallSpacing)),
          Text(
            'Start earning from your rides',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildMonetizationInfo(
    BuildContext context,
    String monetizationMessage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              radius: 26,
              child: Icon(
                FontAwesomeIcons.coins,
                color: Theme.of(context).colorScheme.primary,
                size: context.iconSize(22),
              ),
            ),
            SizedBox(width: context.baseSpacing(baseSpacing)),
            Expanded(
              child: Text(
                'Monetize Your Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: context.baseSpacing(baseSpacing)),
        Text(
          monetizationMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyDLCard(BuildContext context) {
    int current = widget.monetizationData.isDLVerified ? 1 : 0;
    const target = 1;

    final progress = current / target;
    final isCompleted = current >= target;

    return _buildPremiumCard(
      context,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCompleted
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            radius: 28,
            child: Icon(
              FontAwesomeIcons.idCard,
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              size: context.iconSize(22),
            ),
          ),
          SizedBox(width: context.baseSpacing(baseSpacing)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify DL',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  'Upload and verify your driving license',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  '$current/$target',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: context.iconSize(baseMediumIconSize),
            ),
        ],
      ),
    );
  }

  Widget _buildVerifyVehicleCard(BuildContext context) {
    int current = widget.monetizationData.hasVerifiedVehicle ? 1 : 0;
    const target = 1;

    final progress = current / target;
    final isCompleted = current >= target;

    return _buildPremiumCard(
      context,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCompleted
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            radius: 28,
            child: Icon(
              FontAwesomeIcons.car,
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              size: context.iconSize(22),
            ),
          ),
          SizedBox(width: context.baseSpacing(baseSpacing)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verify Vehicle',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  'Upload and verify your vehicle documents',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  '$current/$target',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: context.iconSize(baseMediumIconSize),
            ),
        ],
      ),
    );
  }

  Widget _buildValidRidesCard(BuildContext context, int target) {
    int current = widget.monetizationData.verifiedRidesCount;

    final progress = current / target;
    final isCompleted = current >= target;

    return _buildPremiumCard(
      context,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCompleted
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            radius: 28,
            child: Icon(
              FontAwesomeIcons.route,
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              size: context.iconSize(22),
            ),
          ),
          SizedBox(width: context.baseSpacing(baseSpacing)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$target Valid Rides',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  'Complete at least $target successful rides with verified odometer',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  '$current/$target',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: context.iconSize(baseMediumIconSize),
            ),
        ],
      ),
    );
  }

  Widget _buildDistanceCard(BuildContext context, int target) {
    double current = widget.monetizationData.totalVerifiedDistance;

    final progress = current / target;
    final isCompleted = current >= target;

    return _buildPremiumCard(
      context,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCompleted
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            radius: 28,
            child: Icon(
              FontAwesomeIcons.route,
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              size: context.iconSize(22),
            ),
          ),
          SizedBox(width: context.baseSpacing(baseSpacing)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$target KM Distance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  'Complete rides totaling at least $target kilometers with verified odometer',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  '${current.toStringAsFixed(1)}/$target KM',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: context.iconSize(baseMediumIconSize),
            ),
        ],
      ),
    );
  }

  Widget _buildReferralCard(BuildContext context, int target) {
    int current = widget.monetizationData.referralCount;

    final progress = current / target;
    final isCompleted = current >= target;

    return _buildPremiumCard(
      context,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCompleted
                ? Colors.green.withOpacity(0.1)
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            radius: 28,
            child: Icon(
              FontAwesomeIcons.users,
              color: isCompleted
                  ? Colors.green
                  : Theme.of(context).colorScheme.primary,
              size: context.iconSize(22),
            ),
          ),
          SizedBox(width: context.baseSpacing(baseSpacing)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Refer $target New Users',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  'Successfully refer $target new users to the app',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: context.baseSpacing(6)),
                Text(
                  '$current/$target',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCompleted ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isCompleted)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: context.iconSize(baseMediumIconSize),
            ),
        ],
      ),
    );
  }

  Widget _buildFAQsSection(BuildContext context, List<Faq> faqs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomeDivider(text: 'Frequently Asked Questions'),
        SizedBox(height: context.baseSpacing(baseSpacing)),
        ...faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          return Column(
            children: [
              _buildPremiumCard(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq.question,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                    Text(
                      faq.answer,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              if (index < faqs.length - 1)
                SizedBox(height: context.baseSpacing(baseSpacing)),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildCashoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyEarningScreen()),
          );
        },
        text: 'Cashout Anyway',
      ),
    );
  }
}
