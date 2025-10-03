import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/bugs/find_and_earn_screen.dart';
import 'package:go_extra_mile_new/features/others/insure_and_earn_screen.dart';
import 'package:go_extra_mile_new/features/referral/presentation/screens/refer_and_earn_screen.dart';
import 'package:go_extra_mile_new/features/reward/daily_reward.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/start_ride_screen.dart';

class EarnGemCoinScreen extends StatefulWidget {
  const EarnGemCoinScreen({super.key});

  @override
  State<EarnGemCoinScreen> createState() => _EarnGemCoinScreenState();
}

class _EarnGemCoinScreenState extends State<EarnGemCoinScreen> {
  late List<Map<String, dynamic>> premiumList;

  void _handleScratchAndEarn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DailyRewardScreen()),
    );
  }

  void _handleReferAndEarn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReferAndEarnScreen()),
    );
  }

  void _handleRideAndEarn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StartRideScreen()),
    );
  }

  void _handleFindAndEarn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FindAndEarnScreen()),
    );
  }

  void _handleInsureAndEarn() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InsureAndEarnScreen()),
    );
  }

  @override
  void initState() {
    super.initState();
    premiumList = [
      {
        "title": "Scratch and Earn",
        "icon": Icons.card_giftcard,
        "onTap": () => _handleScratchAndEarn(),
      },
      {
        "title": "Refer & Earn",
        "icon": Icons.person_add,
        "onTap": () => _handleReferAndEarn(),
      },
      {
        "title": "Ride & Earn",
        "icon": Icons.directions_car,
        "onTap": () => _handleRideAndEarn(),
      },
      {
        "title": "Find & Earn",
        "icon": Icons.search,
        "onTap": () => _handleFindAndEarn(),
      },
      {
        "title": "Insure & Earn",
        "icon": Icons.health_and_safety,
        "onTap": () => _handleInsureAndEarn(),
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(baseScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Earn GEM Coins',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: premiumList.length,
                  itemBuilder: (context, index) {
                    final item = premiumList[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.grey.shade100,
                          child: Icon(item["icon"], color: Colors.black87),
                        ),
                        title: Text(
                          item["title"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: item["onTap"],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
