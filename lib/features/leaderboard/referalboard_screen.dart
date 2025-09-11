import 'package:flutter/material.dart';
import 'widgets/leaderboard_widget.dart';
import 'referalboard_history_screen.dart';

class ReferalboardScreen extends StatefulWidget {
  const ReferalboardScreen({super.key});

  @override
  State<ReferalboardScreen> createState() => _ReferalboardScreenState();
}

class _ReferalboardScreenState extends State<ReferalboardScreen> {
  int _selectedFilter = 0; // Track selected filter

  final List<String> _filters = const [
    "Last 7 days",
    "This month",
    "This year",
  ];

  // Dummy data for referral leaderboard - Last 7 days
  final List<Map<String, String>> _topUsers7Days = const [
    {
      "name": "Alice Johnson",
      "address": "New York",
      "referrals": "8",
      "image": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Bob Smith",
      "address": "London",
      "referrals": "6",
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Carol Davis",
      "address": "Sydney",
      "referrals": "5",
      "image": "https://i.pravatar.cc/150?img=3",
    },
  ];

  final List<Map<String, String>> _allOtherUsers7Days = List.generate(
    30,
    (i) => {
      "name": "User ${i + 4}",
      "address": "City ${i + 4}",
      "referrals": "${4 - (i % 3)}",
      "image": "https://i.pravatar.cc/150?img=${(i % 20) + 4}",
    },
  );

  final Map<String, String> _myself7Days = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "2",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for referral leaderboard - This month
  final List<Map<String, String>> _topUsersMonth = const [
    {
      "name": "Alice Johnson",
      "address": "New York",
      "referrals": "22",
      "image": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Bob Smith",
      "address": "London",
      "referrals": "18",
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Carol Davis",
      "address": "Sydney",
      "referrals": "16",
      "image": "https://i.pravatar.cc/150?img=3",
    },
  ];

  final List<Map<String, String>> _allOtherUsersMonth = List.generate(
    40,
    (i) => {
      "name": "User ${i + 4}",
      "address": "City ${i + 4}",
      "referrals": "${12 - (i % 10)}",
      "image": "https://i.pravatar.cc/150?img=${(i % 20) + 4}",
    },
  );

  final Map<String, String> _myselfMonth = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "8",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for referral leaderboard - This year
  final List<Map<String, String>> _topUsersYear = const [
    {
      "name": "Alice Johnson",
      "address": "New York",
      "referrals": "45",
      "image": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Bob Smith",
      "address": "London",
      "referrals": "38",
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Carol Davis",
      "address": "Sydney",
      "referrals": "32",
      "image": "https://i.pravatar.cc/150?img=3",
    },
  ];

  final List<Map<String, String>> _allOtherUsersYear = List.generate(
    50,
    (i) => {
      "name": "User ${i + 4}",
      "address": "City ${i + 4}",
      "referrals": "${25 - (i % 20)}",
      "image": "https://i.pravatar.cc/150?img=${(i % 20) + 4}",
    },
  );

  final Map<String, String> _myselfYear = const {
    "name": "Rijan",
    "address": "Mumbai",
    "referrals": "15",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Helper methods to get current data based on selected filter
  List<Map<String, String>> get _currentTopUsers {
    switch (_selectedFilter) {
      case 0: return _topUsers7Days;
      case 1: return _topUsersMonth;
      case 2: return _topUsersYear;
      default: return _topUsersYear;
    }
  }

  List<Map<String, String>> get _currentAllOtherUsers {
    switch (_selectedFilter) {
      case 0: return _allOtherUsers7Days;
      case 1: return _allOtherUsersMonth;
      case 2: return _allOtherUsersYear;
      default: return _allOtherUsersYear;
    }
  }

  Map<String, String> get _currentMyself {
    switch (_selectedFilter) {
      case 0: return _myself7Days;
      case 1: return _myselfMonth;
      case 2: return _myselfYear;
      default: return _myselfYear;
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
                  'Referalboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReferalboardHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: "History",
          ),
        ],
      ),
      body: LeaderboardWidget(
        key: ValueKey('referral_$_selectedFilter'),
        topUsers: _currentTopUsers,
        allOtherUsers: _currentAllOtherUsers,
        myself: _currentMyself,
        filters: _filters,
        dataType: LeaderboardType.referrals,
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
