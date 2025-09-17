import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/features/leaderboard/presentation/fourwheeler_riderboard_history_screen.dart';
import 'widgets/leaderboard_widget.dart';

class FourWheelerRiderboardScreen extends StatefulWidget {
  const FourWheelerRiderboardScreen({super.key});

  @override
  State<FourWheelerRiderboardScreen> createState() => _FourWheelerRiderboardScreenState();
}

class _FourWheelerRiderboardScreenState extends State<FourWheelerRiderboardScreen> {
  int _selectedFilter = 0; // Track selected filter

  final List<String> _filters = const [
    "Last 7 days",
    "This month",
    "This year",
  ];

  // Dummy data for ride leaderboard - Last 7 days
  final List<Map<String, String>> _topRideUsers7Days = const [
    {
      "name": "John Doe",
      "address": "New York",
      "rides": "12",
      "image": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Jane Smith",
      "address": "London",
      "rides": "10",
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Mike",
      "address": "Sydney",
      "rides": "8",
      "image": "https://i.pravatar.cc/150?img=3",
    },
  ];

  final List<Map<String, String>> _allOtherRideUsers7Days = List.generate(
    30,
    (i) => {
      "name": "User ${i + 4}",
      "address": "City ${i + 4}",
      "rides": "${6 - (i % 4)}",
      "image": "https://i.pravatar.cc/150?img=${(i % 20) + 4}",
    },
  );

  final Map<String, String> _myselfRide7Days = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "3",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for ride leaderboard - This month
  final List<Map<String, String>> _topRideUsersMonth = const [
    {
      "name": "John Doe",
      "address": "New York",
      "rides": "55",
      "image": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Jane Smith",
      "address": "London",
      "rides": "48",
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Mike",
      "address": "Sydney",
      "rides": "42",
      "image": "https://i.pravatar.cc/150?img=3",
    },
  ];

  final List<Map<String, String>> _allOtherRideUsersMonth = List.generate(
    40,
    (i) => {
      "name": "User ${i + 4}",
      "address": "City ${i + 4}",
      "rides": "${35 - (i % 20)}",
      "image": "https://i.pravatar.cc/150?img=${(i % 20) + 4}",
    },
  );

  final Map<String, String> _myselfRideMonth = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "22",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for ride leaderboard - This year
  final List<Map<String, String>> _topRideUsersYear = const [
    {
      "name": "John Doe",
      "address": "New York",
      "rides": "120",
      "image": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Jane Smith",
      "address": "London",
      "rides": "98",
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Mike",
      "address": "Sydney",
      "rides": "85",
      "image": "https://i.pravatar.cc/150?img=3",
    },
  ];

  final List<Map<String, String>> _allOtherRideUsersYear = List.generate(
    50,
    (i) => {
      "name": "User ${i + 4}",
      "address": "City ${i + 4}",
      "rides": "${70 - (i % 30)}",
      "image": "https://i.pravatar.cc/150?img=${(i % 20) + 4}",
    },
  );

  final Map<String, String> _myselfRideYear = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "40",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for distance leaderboard - Last 7 days
  final List<Map<String, String>> _topDistanceUsers7Days = const [
    {
      "name": "Alex Chen",
      "address": "Tokyo",
      "distance": "150 km",
      "image": "https://i.pravatar.cc/150?img=5",
    },
    {
      "name": "Sarah Wilson",
      "address": "Berlin",
      "distance": "135 km",
      "image": "https://i.pravatar.cc/150?img=6",
    },
    {
      "name": "David Kim",
      "address": "Seoul",
      "distance": "120 km",
      "image": "https://i.pravatar.cc/150?img=7",
    },
  ];

  final List<Map<String, String>> _allOtherDistanceUsers7Days = List.generate(
    30,
    (i) => {
      "name": "Rider ${i + 4}",
      "address": "Metro ${i + 4}",
      "distance": "${100 - (i % 15) * 4} km",
      "image": "https://i.pravatar.cc/150?img=${(i % 20) + 8}",
    },
  );

  final Map<String, String> _myselfDistance7Days = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "35 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for distance leaderboard - This month
  final List<Map<String, String>> _topDistanceUsersMonth = const [
    {
      "name": "Alex Chen",
      "address": "Tokyo",
      "distance": "750 km",
      "image": "https://i.pravatar.cc/150?img=5",
    },
    {
      "name": "Sarah Wilson",
      "address": "Berlin",
      "distance": "680 km",
      "image": "https://i.pravatar.cc/150?img=6",
    },
    {
      "name": "David Kim",
      "address": "Seoul",
      "distance": "620 km",
      "image": "https://i.pravatar.cc/150?img=7",
    },
  ];

  final List<Map<String, String>> _allOtherDistanceUsersMonth = List.generate(
    40,
    (i) => {
      "name": "Rider ${i + 4}",
      "address": "Metro ${i + 4}",
      "distance": "${550 - (i % 20) * 12} km",
      "image": "https://i.pravatar.cc/150?img=${(i % 20) + 8}",
    },
  );

  final Map<String, String> _myselfDistanceMonth = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "240 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for distance leaderboard - This year
  final List<Map<String, String>> _topDistanceUsersYear = const [
    {
      "name": "Alex Chen",
      "address": "Tokyo",
      "distance": "2,450 km",
      "image": "https://i.pravatar.cc/150?img=5",
    },
    {
      "name": "Sarah Wilson",
      "address": "Berlin",
      "distance": "2,180 km",
      "image": "https://i.pravatar.cc/150?img=6",
    },
    {
      "name": "David Kim",
      "address": "Seoul",
      "distance": "1,950 km",
      "image": "https://i.pravatar.cc/150?img=7",
    },
  ];

  final List<Map<String, String>> _allOtherDistanceUsersYear = List.generate(
    50,
    (i) => {
      "name": "Rider ${i + 4}",
      "address": "Metro ${i + 4}",
      "distance": "${1800 - (i % 25) * 20} km",
      "image": "https://i.pravatar.cc/150?img=${(i % 20) + 8}",
    },
  );

  final Map<String, String> _myselfDistanceYear = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "650 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Helper methods to get current data based on selected filter
  List<Map<String, String>> get _currentTopRideUsers {
    switch (_selectedFilter) {
      case 0: return _topRideUsers7Days;
      case 1: return _topRideUsersMonth;
      case 2: return _topRideUsersYear;
      default: return _topRideUsersYear;
    }
  }

  List<Map<String, String>> get _currentAllOtherRideUsers {
    switch (_selectedFilter) {
      case 0: return _allOtherRideUsers7Days;
      case 1: return _allOtherRideUsersMonth;
      case 2: return _allOtherRideUsersYear;
      default: return _allOtherRideUsersYear;
    }
  }

  Map<String, String> get _currentMyselfRide {
    switch (_selectedFilter) {
      case 0: return _myselfRide7Days;
      case 1: return _myselfRideMonth;
      case 2: return _myselfRideYear;
      default: return _myselfRideYear;
    }
  }

  List<Map<String, String>> get _currentTopDistanceUsers {
    switch (_selectedFilter) {
      case 0: return _topDistanceUsers7Days;
      case 1: return _topDistanceUsersMonth;
      case 2: return _topDistanceUsersYear;
      default: return _topDistanceUsersYear;
    }
  }

  List<Map<String, String>> get _currentAllOtherDistanceUsers {
    switch (_selectedFilter) {
      case 0: return _allOtherDistanceUsers7Days;
      case 1: return _allOtherDistanceUsersMonth;
      case 2: return _allOtherDistanceUsersYear;
      default: return _allOtherDistanceUsersYear;
    }
  }

  Map<String, String> get _currentMyselfDistance {
    switch (_selectedFilter) {
      case 0: return _myselfDistance7Days;
      case 1: return _myselfDistanceMonth;
      case 2: return _myselfDistanceYear;
      default: return _myselfDistanceYear;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: Ride and Distance
      child: Scaffold(
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
                  Icon(Icons.car_crash, color: Colors.white, size: 22),
                  SizedBox(width: 6),
                  Text(
                    'Riderboard',
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
              const Text(
                'Four Wheeler',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FourWheelerRiderboardHistoryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.history, color: Colors.white),
              tooltip: "History",
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.blueAccent,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            tabs: [
              Tab(text: "Ride"),
              Tab(text: "Distance"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            //for ride
            LeaderboardWidget(
              key: ValueKey('fourwheeler_ride_$_selectedFilter'),
              topUsers: _currentTopRideUsers,
              allOtherUsers: _currentAllOtherRideUsers,
              myself: _currentMyselfRide,
              dataType: LeaderboardType.rides,
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterChanged: (index) {
                setState(() {
                  _selectedFilter = index;
                });
              },
            ),

            LeaderboardWidget(
              key: ValueKey('fourwheeler_distance_$_selectedFilter'),
              topUsers: _currentTopDistanceUsers,
              allOtherUsers: _currentAllOtherDistanceUsers,
              myself: _currentMyselfDistance,
              dataType: LeaderboardType.distance,
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterChanged: (index) {
                setState(() {
                  _selectedFilter = index;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
