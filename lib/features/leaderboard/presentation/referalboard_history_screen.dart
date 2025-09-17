import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/features/leaderboard/presentation/widgets/leaderboard_history_widget.dart';

class ReferalboardHistoryScreen extends StatefulWidget {
  const ReferalboardHistoryScreen({super.key});

  @override
  State<ReferalboardHistoryScreen> createState() => _ReferalboardHistoryScreenState();
}

class _ReferalboardHistoryScreenState extends State<ReferalboardHistoryScreen> {
  int _selectedFilter = 0; // Track selected filter

  final List<String> _filters = const [
    "Referrer of the Week",
    "Referrer of the Month", 
    "Referrer of the Year",
  ];

  // Dummy data for referral leaderboard - Referrer of the Week (Sep 1-7)
  final List<Map<String, String>> _topReferralUsersWeek = const [
    {
      "name": "Marcus Johnson",
      "address": "Los Angeles",
      "referrals": "8",
      "image": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Sophie Chen",
      "address": "Toronto",
      "referrals": "6",
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Ahmed Hassan",
      "address": "Dubai",
      "referrals": "5",
      "image": "https://i.pravatar.cc/150?img=3",
    },
  ];

  final Map<String, String> _myselfReferralWeek = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "2",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for referral leaderboard - Referrer of the Month (September)
  final List<Map<String, String>> _topReferralUsersMonth = const [
    {
      "name": "Isabella Rodriguez",
      "address": "Mexico City",
      "referrals": "22",
      "image": "https://i.pravatar.cc/150?img=4",
    },
    {
      "name": "James Wilson",
      "address": "Chicago",
      "referrals": "18",
      "image": "https://i.pravatar.cc/150?img=5",
    },
    {
      "name": "Yuki Tanaka",
      "address": "Osaka",
      "referrals": "16",
      "image": "https://i.pravatar.cc/150?img=6",
    },
  ];

  final Map<String, String> _myselfReferralMonth = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "8",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for referral leaderboard - Referrer of the Year (2025)
  final List<Map<String, String>> _topReferralUsersYear = const [
    {
      "name": "Alexander Petrov",
      "address": "Moscow",
      "referrals": "45",
      "image": "https://i.pravatar.cc/150?img=7",
    },
    {
      "name": "Emma Thompson",
      "address": "Sydney",
      "referrals": "38",
      "image": "https://i.pravatar.cc/150?img=8",
    },
    {
      "name": "Carlos Mendez",
      "address": "São Paulo",
      "referrals": "32",
      "image": "https://i.pravatar.cc/150?img=9",
    },
  ];

  final Map<String, String> _myselfReferralYear = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "15",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Week 2 data (Aug 25-31, 2025)
  final List<Map<String, String>> _topReferralUsersWeek2 = const [
    {
      "name": "Hiroshi Nakamura",
      "address": "Kyoto",
      "referrals": "7",
      "image": "https://i.pravatar.cc/150?img=20",
    },
    {
      "name": "Elena Volkov",
      "address": "Moscow",
      "referrals": "6",
      "image": "https://i.pravatar.cc/150?img=21",
    },
    {
      "name": "Diego Santos",
      "address": "Lisbon",
      "referrals": "4",
      "image": "https://i.pravatar.cc/150?img=22",
    },
  ];

  final Map<String, String> _myselfReferralWeek2 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "1",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Week 3 data (Aug 18-24, 2025)
  final List<Map<String, String>> _topReferralUsersWeek3 = const [
    {
      "name": "Chen Wei",
      "address": "Shanghai",
      "referrals": "6",
      "image": "https://i.pravatar.cc/150?img=26",
    },
    {
      "name": "Amelia Clarke",
      "address": "Dublin",
      "referrals": "5",
      "image": "https://i.pravatar.cc/150?img=27",
    },
    {
      "name": "Rafael Silva",
      "address": "Rio de Janeiro",
      "referrals": "4",
      "image": "https://i.pravatar.cc/150?img=28",
    },
  ];

  final Map<String, String> _myselfReferralWeek3 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "1",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Month 2 data (August 2025)
  final List<Map<String, String>> _topReferralUsersMonth2 = const [
    {
      "name": "Giuseppe Romano",
      "address": "Milan",
      "referrals": "20",
      "image": "https://i.pravatar.cc/150?img=32",
    },
    {
      "name": "Nina Petrov",
      "address": "St. Petersburg",
      "referrals": "17",
      "image": "https://i.pravatar.cc/150?img=33",
    },
    {
      "name": "Kenji Yamamoto",
      "address": "Kyoto",
      "referrals": "15",
      "image": "https://i.pravatar.cc/150?img=34",
    },
  ];

  final Map<String, String> _myselfReferralMonth2 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "6",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Month 3 data (July 2025)
  final List<Map<String, String>> _topReferralUsersMonth3 = const [
    {
      "name": "Antonio Martinez",
      "address": "Valencia",
      "referrals": "19",
      "image": "https://i.pravatar.cc/150?img=38",
    },
    {
      "name": "Zoe Williams",
      "address": "Manchester",
      "referrals": "16",
      "image": "https://i.pravatar.cc/150?img=39",
    },
    {
      "name": "Sven Andersson",
      "address": "Gothenburg",
      "referrals": "14",
      "image": "https://i.pravatar.cc/150?img=40",
    },
  ];

  final Map<String, String> _myselfReferralMonth3 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "5",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Year 2 data (2024)
  final List<Map<String, String>> _topReferralUsersYear2 = const [
    {
      "name": "Roberto Ferrari",
      "address": "Florence",
      "referrals": "42",
      "image": "https://i.pravatar.cc/150?img=44",
    },
    {
      "name": "Katarina Novak",
      "address": "Vienna",
      "referrals": "35",
      "image": "https://i.pravatar.cc/150?img=45",
    },
    {
      "name": "Javier Morales",
      "address": "Buenos Aires",
      "referrals": "28",
      "image": "https://i.pravatar.cc/150?img=46",
    },
  ];

  final Map<String, String> _myselfReferralYear2 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "12",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Year 3 data (2023)
  final List<Map<String, String>> _topReferralUsersYear3 = const [
    {
      "name": "Wolfgang Mueller",
      "address": "Frankfurt",
      "referrals": "38",
      "image": "https://i.pravatar.cc/150?img=50",
    },
    {
      "name": "Fatima Al-Zahra",
      "address": "Cairo",
      "referrals": "32",
      "image": "https://i.pravatar.cc/150?img=51",
    },
    {
      "name": "Pavel Novak",
      "address": "Brno",
      "referrals": "26",
      "image": "https://i.pravatar.cc/150?img=52",
    },
  ];

  final Map<String, String> _myselfReferralYear3 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "10",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Multiple datasets for different periods
  List<List<Map<String, String>>> get _allTopReferralUsers {
    switch (_selectedFilter) {
      case 0: // Multiple weeks
        return [
          _topReferralUsersWeek,
          _topReferralUsersWeek2,
          _topReferralUsersWeek3,
        ];
      case 1: // Multiple months
        return [
          _topReferralUsersMonth,
          _topReferralUsersMonth2,
          _topReferralUsersMonth3,
        ];
      case 2: // Multiple years
        return [
          _topReferralUsersYear,
          _topReferralUsersYear2,
          _topReferralUsersYear3,
        ];
      default: return [_topReferralUsersYear];
    }
  }

  List<Map<String, String>> get _allMyselfReferralData {
    switch (_selectedFilter) {
      case 0: // Multiple weeks
        return [
          _myselfReferralWeek,
          _myselfReferralWeek2,
          _myselfReferralWeek3,
        ];
      case 1: // Multiple months
        return [
          _myselfReferralMonth,
          _myselfReferralMonth2,
          _myselfReferralMonth3,
        ];
      case 2: // Multiple years
        return [
          _myselfReferralYear,
          _myselfReferralYear2,
          _myselfReferralYear3,
        ];
      default: return [_myselfReferralYear];
    }
  }

  // Helper method to get all period headings
  List<String> get _allPeriodHeadings {
    switch (_selectedFilter) {
      case 0: // Multiple weeks
        return [
          "Sep 1-7, 2025",
          "Aug 25-31, 2025",
          "Aug 18-24, 2025",
        ];
      case 1: // Multiple months
        return [
          "September 2025",
          "August 2025",
          "July 2025",
        ];
      case 2: // Multiple years
        return [
          "2025",
          "2024",
          "2023",
        ];
      default: return ["2025"];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.people_alt, color: Colors.amber, size: 22),
                SizedBox(width: 6),
                Text(
                  'Referral History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'Referral Leaderboard',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: LeaderboardHistoryWidget(
        key: ValueKey('referral_history_$_selectedFilter'),
        allTopUsers: _allTopReferralUsers,
        allMyselfData: _allMyselfReferralData,
        allPeriodHeadings: _allPeriodHeadings,
        dataType: LeaderboardHistoryType.referrals,
        filters: _filters,
        selectedFilter: _selectedFilter,
        onFilterChanged: (index) {
          setState(() {
            _selectedFilter = index;
          });
        },
      ),
    );
  }
}
