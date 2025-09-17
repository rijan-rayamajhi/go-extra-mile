import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/common/widgets/custome_divider.dart';

class BeforeMonetizationBodyWidget extends StatefulWidget {
  const BeforeMonetizationBodyWidget({super.key});

  @override
  State<BeforeMonetizationBodyWidget> createState() =>
      _BeforeMonetizationBodyWidgetState();
}

class _BeforeMonetizationBodyWidgetState
    extends State<BeforeMonetizationBodyWidget> {
  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'What is monetization?',
      'answer':
          'Monetization allows you to earn real money from your rides and activities in the app.',
    },
    {
      'question': 'How do I qualify for monetization?',
      'answer':
          'You need to complete at least 10 rides, maintain a 4.5+ rating, and have a verified profile.',
    },
    {
      'question': 'When will I receive payments?',
      'answer':
          'Payments are processed weekly every Friday to your registered bank account.',
    },
    {
      'question': 'What is the minimum payout amount?',
      'answer':
          'The minimum payout amount is ₹100. Amounts below this will be carried forward.',
    },
  ];

  final List<Map<String, dynamic>> _requirements = [
    {
      'title': 'Verify DL',
      'description': 'Upload and verify your driving license',
      'current': 0,
      'target': 1,
      'icon': FontAwesomeIcons.idCard,
    },
    {
      'title': 'Verify Vehicle',
      'description': 'Upload and verify your vehicle documents',
      'current': 0,
      'target': 1,
      'icon': FontAwesomeIcons.car,
    },
    {
      'title': '30 Valid Rides',
      'description': 'Complete at least 30 successful rides',
      'current': 7,
      'target': 30,
      'icon': FontAwesomeIcons.route,
    },
    {
      'title': '30 KM Distance',
      'description': 'Complete rides totaling at least 30 kilometers',
      'current': 12,
      'target': 30,
      'icon': FontAwesomeIcons.route,
    },
    {
      'title': 'Refer 30 New Users',
      'description': 'Successfully refer 30 new users to the app',
      'current': 0,
      'target': 30,
      'icon': FontAwesomeIcons.users,
    },
  ];

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
            child: _buildMonetizationInfo(context),
          ),
          SizedBox(height: context.baseSpacing(baseLargeSpacing)),
          _buildRequirementsSection(context),
          SizedBox(height: context.baseSpacing(baseLargeSpacing)),
          _buildFAQsSection(context),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonetizationInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
          'To monetize your Go Extra Mile account, you need to join the Go Extra Mile Partner Program (GEMPP) and meet specific eligibility requirements.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
        ),
        SizedBox(height: context.baseSpacing(baseSpacing)),
        Text(
          'Once accepted, you can earn revenue through App Referrals, ADs, Rewards, Rides, Insurance, Flash Sales, and more. Explore affiliate marketing, merchandise, and sponsorships.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
        ),
      ],
    );
  }

  Widget _buildRequirementsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomeDivider(text: 'Monetization Requirements'),
        SizedBox(height: context.baseSpacing(baseSpacing)),
        ..._requirements.asMap().entries.map(
          (entry) {
            final index = entry.key;
            final req = entry.value;
            return Column(
              children: [
                _buildPremiumCard(
                  context,
                  child: _buildRequirementCard(context, req),
                ),
                if (index < _requirements.length - 1)
                  SizedBox(height: context.baseSpacing(baseSpacing)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRequirementCard(
      BuildContext context, Map<String, dynamic> requirement) {
    final progress = requirement['current'] / requirement['target'];
    final isCompleted = requirement['current'] >= requirement['target'];

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: isCompleted
              ? Colors.green.withOpacity(0.1)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          radius: 28,
          child: Icon(
            requirement['icon'],
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
                requirement['title'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
              ),
              SizedBox(height: context.baseSpacing(6)),
              Text(
                requirement['description'],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
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
                '${requirement['current']}/${requirement['target']}',
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
    );
  }

  Widget _buildFAQsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomeDivider(text: 'Frequently Asked Questions'),
        SizedBox(height: context.baseSpacing(baseSpacing)),
        ..._faqs.asMap().entries.map(
          (entry) {
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
                        faq['question'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                      ),
                      SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                      Text(
                        faq['answer'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
                if (index < _faqs.length - 1)
                  SizedBox(height: context.baseSpacing(baseSpacing)),
              ],
            );
          },
        ),
      ],
    );
  }

}