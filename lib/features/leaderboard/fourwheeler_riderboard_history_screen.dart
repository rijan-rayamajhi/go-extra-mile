import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/features/leaderboard/widgets/leaderboard_history_widget.dart';

class FourWheelerRiderboardHistoryScreen extends StatefulWidget {
  const FourWheelerRiderboardHistoryScreen({super.key});

  @override
  State<FourWheelerRiderboardHistoryScreen> createState() => _FourWheelerRiderboardHistoryScreenState();
}

class _FourWheelerRiderboardHistoryScreenState extends State<FourWheelerRiderboardHistoryScreen> {
  int _selectedFilter = 0; // Track selected filter

  final List<String> _filters = const [
    "Rider of the Week",
    "Rider of the Month", 
    "Rider of the Year",
  ];

  // Dummy data for ride leaderboard - Rider of the Week (Sep 1-7)
  final List<Map<String, String>> _topRideUsersWeek = const [
    {
      "name": "Marcus Johnson",
      "address": "Los Angeles",
      "rides": "25",
      "image": "https://i.pravatar.cc/150?img=1",
    },
    {
      "name": "Sophie Chen",
      "address": "Toronto",
      "rides": "22",
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Ahmed Hassan",
      "address": "Dubai",
      "rides": "19",
      "image": "https://i.pravatar.cc/150?img=3",
    },
  ];

  final Map<String, String> _myselfRideWeek = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "12",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for ride leaderboard - Rider of the Month (September)
  final List<Map<String, String>> _topRideUsersMonth = const [
    {
      "name": "Isabella Rodriguez",
      "address": "Mexico City",
      "rides": "105",
      "image": "https://i.pravatar.cc/150?img=4",
    },
    {
      "name": "James Wilson",
      "address": "Chicago",
      "rides": "98",
      "image": "https://i.pravatar.cc/150?img=5",
    },
    {
      "name": "Yuki Tanaka",
      "address": "Osaka",
      "rides": "92",
      "image": "https://i.pravatar.cc/150?img=6",
    },
  ];

  final Map<String, String> _myselfRideMonth = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "58",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for ride leaderboard - Rider of the Year (2025)
  final List<Map<String, String>> _topRideUsersYear = const [
    {
      "name": "Alexander Petrov",
      "address": "Moscow",
      "rides": "165",
      "image": "https://i.pravatar.cc/150?img=7",
    },
    {
      "name": "Emma Thompson",
      "address": "Sydney",
      "rides": "152",
      "image": "https://i.pravatar.cc/150?img=8",
    },
    {
      "name": "Carlos Mendez",
      "address": "São Paulo",
      "rides": "138",
      "image": "https://i.pravatar.cc/150?img=9",
    },
  ];

  final Map<String, String> _myselfRideYear = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "89",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for distance leaderboard - Rider of the Week (Sep 1-7)
  final List<Map<String, String>> _topDistanceUsersWeek = const [
    {
      "name": "Oliver Brown",
      "address": "Amsterdam",
      "distance": "320 km",
      "image": "https://i.pravatar.cc/150?img=10",
    },
    {
      "name": "Maria Garcia",
      "address": "Madrid",
      "distance": "295 km",
      "image": "https://i.pravatar.cc/150?img=12",
    },
    {
      "name": "David Kim",
      "address": "Seoul",
      "distance": "275 km",
      "image": "https://i.pravatar.cc/150?img=13",
    },
  ];

  final Map<String, String> _myselfDistanceWeek = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "145 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for distance leaderboard - Rider of the Month (September)
  final List<Map<String, String>> _topDistanceUsersMonth = const [
    {
      "name": "Thomas Mueller",
      "address": "Munich",
      "distance": "1,280 km",
      "image": "https://i.pravatar.cc/150?img=14",
    },
    {
      "name": "Anna Kowalski",
      "address": "Warsaw",
      "distance": "1,195 km",
      "image": "https://i.pravatar.cc/150?img=15",
    },
    {
      "name": "Raj Patel",
      "address": "Delhi",
      "distance": "1,125 km",
      "image": "https://i.pravatar.cc/150?img=16",
    },
  ];

  final Map<String, String> _myselfDistanceMonth = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "680 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Dummy data for distance leaderboard - Rider of the Year (2025)
  final List<Map<String, String>> _topDistanceUsersYear = const [
    {
      "name": "Lucas Silva",
      "address": "São Paulo",
      "distance": "3,850 km",
      "image": "https://i.pravatar.cc/150?img=17",
    },
    {
      "name": "Isabella Rossi",
      "address": "Rome",
      "distance": "3,580 km",
      "image": "https://i.pravatar.cc/150?img=18",
    },
    {
      "name": "Ahmed Hassan",
      "address": "Cairo",
      "distance": "3,250 km",
      "image": "https://i.pravatar.cc/150?img=19",
    },
  ];

  final Map<String, String> _myselfDistanceYear = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "1,450 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Week 2 data (Aug 25-31, 2025)
  final List<Map<String, String>> _topRideUsersWeek2 = const [
    {
      "name": "Hiroshi Nakamura",
      "address": "Kyoto",
      "rides": "23",
      "image": "https://i.pravatar.cc/150?img=20",
    },
    {
      "name": "Elena Volkov",
      "address": "Moscow",
      "rides": "20",
      "image": "https://i.pravatar.cc/150?img=21",
    },
    {
      "name": "Diego Santos",
      "address": "Lisbon",
      "rides": "17",
      "image": "https://i.pravatar.cc/150?img=22",
    },
  ];

  final Map<String, String> _myselfRideWeek2 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "11",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  final List<Map<String, String>> _topDistanceUsersWeek2 = const [
    {
      "name": "Klaus Weber",
      "address": "Hamburg",
      "distance": "315 km",
      "image": "https://i.pravatar.cc/150?img=23",
    },
    {
      "name": "Priya Sharma",
      "address": "Bangalore",
      "distance": "298 km",
      "image": "https://i.pravatar.cc/150?img=24",
    },
    {
      "name": "Marcus Johnson",
      "address": "Stockholm",
      "distance": "275 km",
      "image": "https://i.pravatar.cc/150?img=25",
    },
  ];

  final Map<String, String> _myselfDistanceWeek2 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "138 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Week 3 data (Aug 18-24, 2025)
  final List<Map<String, String>> _topRideUsersWeek3 = const [
    {
      "name": "Chen Wei",
      "address": "Shanghai",
      "rides": "21",
      "image": "https://i.pravatar.cc/150?img=26",
    },
    {
      "name": "Amelia Clarke",
      "address": "Dublin",
      "rides": "18",
      "image": "https://i.pravatar.cc/150?img=27",
    },
    {
      "name": "Rafael Silva",
      "address": "Rio de Janeiro",
      "rides": "15",
      "image": "https://i.pravatar.cc/150?img=28",
    },
  ];

  final Map<String, String> _myselfRideWeek3 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "9",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  final List<Map<String, String>> _topDistanceUsersWeek3 = const [
    {
      "name": "Pierre Dubois",
      "address": "Paris",
      "distance": "305 km",
      "image": "https://i.pravatar.cc/150?img=29",
    },
    {
      "name": "Aisha Ibrahim",
      "address": "Lagos",
      "distance": "288 km",
      "image": "https://i.pravatar.cc/150?img=30",
    },
    {
      "name": "Liam O'Connor",
      "address": "Cork",
      "distance": "265 km",
      "image": "https://i.pravatar.cc/150?img=31",
    },
  ];

  final Map<String, String> _myselfDistanceWeek3 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "130 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Month 2 data (August 2025)
  final List<Map<String, String>> _topRideUsersMonth2 = const [
    {
      "name": "Giuseppe Romano",
      "address": "Milan",
      "rides": "102",
      "image": "https://i.pravatar.cc/150?img=32",
    },
    {
      "name": "Nina Petrov",
      "address": "St. Petersburg",
      "rides": "95",
      "image": "https://i.pravatar.cc/150?img=33",
    },
    {
      "name": "Kenji Yamamoto",
      "address": "Kyoto",
      "rides": "88",
      "image": "https://i.pravatar.cc/150?img=34",
    },
  ];

  final Map<String, String> _myselfRideMonth2 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "52",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  final List<Map<String, String>> _topDistanceUsersMonth2 = const [
    {
      "name": "Fernando Costa",
      "address": "Porto",
      "distance": "1,225 km",
      "image": "https://i.pravatar.cc/150?img=35",
    },
    {
      "name": "Ingrid Bergman",
      "address": "Copenhagen",
      "distance": "1,165 km",
      "image": "https://i.pravatar.cc/150?img=36",
    },
    {
      "name": "Viktor Petrov",
      "address": "Prague",
      "distance": "1,105 km",
      "image": "https://i.pravatar.cc/150?img=37",
    },
  ];

  final Map<String, String> _myselfDistanceMonth2 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "665 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Month 3 data (July 2025)
  final List<Map<String, String>> _topRideUsersMonth3 = const [
    {
      "name": "Antonio Martinez",
      "address": "Valencia",
      "rides": "98",
      "image": "https://i.pravatar.cc/150?img=38",
    },
    {
      "name": "Zoe Williams",
      "address": "Manchester",
      "rides": "92",
      "image": "https://i.pravatar.cc/150?img=39",
    },
    {
      "name": "Sven Andersson",
      "address": "Gothenburg",
      "rides": "85",
      "image": "https://i.pravatar.cc/150?img=40",
    },
  ];

  final Map<String, String> _myselfRideMonth3 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "48",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  final List<Map<String, String>> _topDistanceUsersMonth3 = const [
    {
      "name": "Mikhail Volkov",
      "address": "Kiev",
      "distance": "1,195 km",
      "image": "https://i.pravatar.cc/150?img=41",
    },
    {
      "name": "Claire Dubois",
      "address": "Lyon",
      "distance": "1,135 km",
      "image": "https://i.pravatar.cc/150?img=42",
    },
    {
      "name": "Hassan Al-Rashid",
      "address": "Dubai",
      "distance": "1,075 km",
      "image": "https://i.pravatar.cc/150?img=43",
    },
  ];

  final Map<String, String> _myselfDistanceMonth3 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "620 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Year 2 data (2024)
  final List<Map<String, String>> _topRideUsersYear2 = const [
    {
      "name": "Roberto Ferrari",
      "address": "Florence",
      "rides": "158",
      "image": "https://i.pravatar.cc/150?img=44",
    },
    {
      "name": "Katarina Novak",
      "address": "Vienna",
      "rides": "145",
      "image": "https://i.pravatar.cc/150?img=45",
    },
    {
      "name": "Javier Morales",
      "address": "Buenos Aires",
      "rides": "132",
      "image": "https://i.pravatar.cc/150?img=46",
    },
  ];

  final Map<String, String> _myselfRideYear2 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "78",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  final List<Map<String, String>> _topDistanceUsersYear2 = const [
    {
      "name": "Nikolai Petrov",
      "address": "Moscow",
      "distance": "3,750 km",
      "image": "https://i.pravatar.cc/150?img=47",
    },
    {
      "name": "Elena Rodriguez",
      "address": "Barcelona",
      "distance": "3,480 km",
      "image": "https://i.pravatar.cc/150?img=48",
    },
    {
      "name": "Takeshi Suzuki",
      "address": "Tokyo",
      "distance": "3,250 km",
      "image": "https://i.pravatar.cc/150?img=49",
    },
  ];

  final Map<String, String> _myselfDistanceYear2 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "1,280 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Additional Year 3 data (2023)
  final List<Map<String, String>> _topRideUsersYear3 = const [
    {
      "name": "Wolfgang Mueller",
      "address": "Frankfurt",
      "rides": "148",
      "image": "https://i.pravatar.cc/150?img=50",
    },
    {
      "name": "Fatima Al-Zahra",
      "address": "Cairo",
      "rides": "135",
      "image": "https://i.pravatar.cc/150?img=51",
    },
    {
      "name": "Pavel Novak",
      "address": "Brno",
      "rides": "122",
      "image": "https://i.pravatar.cc/150?img=52",
    },
  ];

  final Map<String, String> _myselfRideYear3 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "rides": "68",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  final List<Map<String, String>> _topDistanceUsersYear3 = const [
    {
      "name": "Hans Mueller",
      "address": "Zurich",
      "distance": "3,550 km",
      "image": "https://i.pravatar.cc/150?img=53",
    },
    {
      "name": "Maria Santos",
      "address": "São Paulo",
      "distance": "3,280 km",
      "image": "https://i.pravatar.cc/150?img=54",
    },
    {
      "name": "Alexander Petrov",
      "address": "Minsk",
      "distance": "3,050 km",
      "image": "https://i.pravatar.cc/150?img=55",
    },
  ];

  final Map<String, String> _myselfDistanceYear3 = const {
    "name": "Rijan",
    "address": "Mumbai",
    "distance": "1,150 km",
    "image": "https://i.pravatar.cc/150?img=11",
  };

  // Multiple datasets for different periods
  List<List<Map<String, String>>> get _allTopRideUsers {
    switch (_selectedFilter) {
      case 0: // Multiple weeks
        return [
          _topRideUsersWeek,
          _topRideUsersWeek2,
          _topRideUsersWeek3,
        ];
      case 1: // Multiple months
        return [
          _topRideUsersMonth,
          _topRideUsersMonth2,
          _topRideUsersMonth3,
        ];
      case 2: // Multiple years
        return [
          _topRideUsersYear,
          _topRideUsersYear2,
          _topRideUsersYear3,
        ];
      default: return [_topRideUsersYear];
    }
  }

  List<Map<String, String>> get _allMyselfRideData {
    switch (_selectedFilter) {
      case 0: // Multiple weeks
        return [
          _myselfRideWeek,
          _myselfRideWeek2,
          _myselfRideWeek3,
        ];
      case 1: // Multiple months
        return [
          _myselfRideMonth,
          _myselfRideMonth2,
          _myselfRideMonth3,
        ];
      case 2: // Multiple years
        return [
          _myselfRideYear,
          _myselfRideYear2,
          _myselfRideYear3,
        ];
      default: return [_myselfRideYear];
    }
  }

  List<List<Map<String, String>>> get _allTopDistanceUsers {
    switch (_selectedFilter) {
      case 0: // Multiple weeks
        return [
          _topDistanceUsersWeek,
          _topDistanceUsersWeek2,
          _topDistanceUsersWeek3,
        ];
      case 1: // Multiple months
        return [
          _topDistanceUsersMonth,
          _topDistanceUsersMonth2,
          _topDistanceUsersMonth3,
        ];
      case 2: // Multiple years
        return [
          _topDistanceUsersYear,
          _topDistanceUsersYear2,
          _topDistanceUsersYear3,
        ];
      default: return [_topDistanceUsersYear];
    }
  }

  List<Map<String, String>> get _allMyselfDistanceData {
    switch (_selectedFilter) {
      case 0: // Multiple weeks
        return [
          _myselfDistanceWeek,
          _myselfDistanceWeek2,
          _myselfDistanceWeek3,
        ];
      case 1: // Multiple months
        return [
          _myselfDistanceMonth,
          _myselfDistanceMonth2,
          _myselfDistanceMonth3,
        ];
      case 2: // Multiple years
        return [
          _myselfDistanceYear,
          _myselfDistanceYear2,
          _myselfDistanceYear3,
        ];
      default: return [_myselfDistanceYear];
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
                    'Riderboard History',
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
                'Four Wheeler',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
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
            LeaderboardHistoryWidget(
              key: ValueKey('fourwheeler_history_ride_$_selectedFilter'),
              allTopUsers: _allTopRideUsers,
              allMyselfData: _allMyselfRideData,
              allPeriodHeadings: _allPeriodHeadings,
              dataType: LeaderboardHistoryType.rides,
              filters: _filters,
              selectedFilter: _selectedFilter,
              onFilterChanged: (index) {
                setState(() {
                  _selectedFilter = index;
                });
              },
            ),

            LeaderboardHistoryWidget(
              key: ValueKey('fourwheeler_history_distance_$_selectedFilter'),
              allTopUsers: _allTopDistanceUsers,
              allMyselfData: _allMyselfDistanceData,
              allPeriodHeadings: _allPeriodHeadings,
              dataType: LeaderboardHistoryType.distance,
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
