import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/features/gem_coin/domain/entities/gem_coin_history_entity.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/bloc/gem_coin_bloc.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/bloc/gem_coin_event.dart';
import 'package:go_extra_mile_new/features/gem_coin/presentation/bloc/gem_coin_state.dart';


class GemCoinHistoryScreens extends StatefulWidget {
  const GemCoinHistoryScreens({super.key});

  @override
  State<GemCoinHistoryScreens> createState() => _GemCoinHistoryScreensState();
}


class _GemCoinHistoryScreensState extends State<GemCoinHistoryScreens> {

    String selectedFilter = 'All';
  String selectedTimeRange = 'All Time';

  final List<String> filterOptions = [
    'All', 
    'Credit', 
    'Debit', 
    'Daily Reward',
    'Ride Reward', 
    'Product Reward',
    'Event Reward',
    'Referral Reward',
    'Other Reward',
    'Premium'
  ];
  final List<String> timeRanges = ['All Time', 'Today', 'This Week', 'This Month', 'Last 3 Months'];

  @override
  void initState() {
    super.initState();
    _loadTransactionHistory();
  }

  void _loadTransactionHistory() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<GemCoinBloc>().add(LoadGemCoinHistory(currentUser.uid));
    }
  }

  // Get filtered transactions based on current filter selections
  List<GEMCoinHistoryEntity> getFilteredTransactions(List<GEMCoinHistoryEntity> transactionHistory) {
    List<GEMCoinHistoryEntity> filtered = transactionHistory;

    // Apply transaction type filter
    if (selectedFilter != 'All') {
      switch (selectedFilter) {
        case 'Credit':
          filtered = filtered.where((t) => t.type == GEMCoinTransactionType.credit).toList();
          break;
        case 'Debit':
          filtered = filtered.where((t) => t.type == GEMCoinTransactionType.debit).toList();
          break;
        case 'Daily Reward':
          filtered = filtered.where((t) => t.rewardType == GEMCoinTransactionRewardType.dailyReward).toList();
          break;
        case 'Ride Reward':
          filtered = filtered.where((t) => t.rewardType == GEMCoinTransactionRewardType.rideReward).toList();
          break;
        case 'Product Reward':
          filtered = filtered.where((t) => t.rewardType == GEMCoinTransactionRewardType.productReward).toList();
          break;
        case 'Event Reward':
          filtered = filtered.where((t) => t.rewardType == GEMCoinTransactionRewardType.eventReward).toList();
          break;
        case 'Referral Reward':
          filtered = filtered.where((t) => t.rewardType == GEMCoinTransactionRewardType.referralReward).toList();
          break;
        case 'Other Reward':
          filtered = filtered.where((t) => t.rewardType == GEMCoinTransactionRewardType.otherReward).toList();
          break;
        case 'Premium':
          // Assuming premium transactions are debit type with specific reason
          filtered = filtered.where((t) => 
            t.type == GEMCoinTransactionType.debit && 
            t.reason.toLowerCase().contains('premium')
          ).toList();
          break;
      }
    }

    // Apply time range filter
    final now = DateTime.now();
    switch (selectedTimeRange) {
      case 'Today':
        filtered = filtered.where((t) => 
          t.date.year == now.year && 
          t.date.month == now.month && 
          t.date.day == now.day
        ).toList();
        break;
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        filtered = filtered.where((t) => t.date.isAfter(startOfWeek.subtract(const Duration(days: 1)))).toList();
        break;
      case 'This Month':
        filtered = filtered.where((t) => 
          t.date.year == now.year && 
          t.date.month == now.month
        ).toList();
        break;
      case 'Last 3 Months':
        final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
        filtered = filtered.where((t) => t.date.isAfter(threeMonthsAgo.subtract(const Duration(days: 1)))).toList();
        break;
    }

    // Sort by date (newest first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  // Calculate current balance from transaction history
  int calculateCurrentBalance(List<GEMCoinHistoryEntity> transactionHistory) {
    int balance = 0;
    for (var transaction in transactionHistory) {
      if (transaction.type == GEMCoinTransactionType.credit) {
        balance += transaction.amount;
      } else {
        balance -= transaction.amount;
      }
    }
    return balance;
  }

  // Calculate credit total
  int calculateCreditTotal(List<GEMCoinHistoryEntity> transactionHistory) {
    return transactionHistory
        .where((t) => t.type == GEMCoinTransactionType.credit)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Calculate debit total
  int calculateDebitTotal(List<GEMCoinHistoryEntity> transactionHistory) {
    return transactionHistory
        .where((t) => t.type == GEMCoinTransactionType.debit)
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Get icon and color for transaction type
  Map<String, dynamic> getTransactionIcon(GEMCoinTransactionRewardType rewardType) {
    switch (rewardType) {
      case GEMCoinTransactionRewardType.rideReward:
        return {'icon': Icons.directions_bike, 'color': Colors.blue};
      case GEMCoinTransactionRewardType.dailyReward:
        return {'icon': Icons.card_giftcard, 'color': Colors.orange};
      case GEMCoinTransactionRewardType.referralReward:
        return {'icon': Icons.people, 'color': Colors.teal};
      case GEMCoinTransactionRewardType.eventReward:
        return {'icon': Icons.event, 'color': Colors.purple};
      case GEMCoinTransactionRewardType.productReward:
        return {'icon': Icons.shopping_bag, 'color': Colors.indigo};
      case GEMCoinTransactionRewardType.otherReward:
        return {'icon': Icons.star, 'color': Colors.amber};
    }
  }

  // Format date for display
  String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${_formatDate(date)}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showFilterModal() {
    // Create temporary variables to hold filter selections
    String tempSelectedFilter = selectedFilter;
    String tempSelectedTimeRange = selectedTimeRange;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Transactions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Transaction Type Filter
                      Text(
                        'Transaction Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filterOptions.map((option) {
                          bool isSelected = tempSelectedFilter == option;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                tempSelectedFilter = option;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                option,
                                style: TextStyle(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.onPrimary 
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Time Range Filter
                      Text(
                        'Time Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: timeRanges.map((range) {
                          bool isSelected = tempSelectedTimeRange == range;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                tempSelectedTimeRange = range;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? Theme.of(context).colorScheme.primary 
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.primary 
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                range,
                                style: TextStyle(
                                  color: isSelected 
                                      ? Theme.of(context).colorScheme.onPrimary 
                                      : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Fixed bottom buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setModalState(() {
                            tempSelectedFilter = 'All';
                            tempSelectedTimeRange = 'All Time';
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Update the main widget's state with the selected filters
                          setState(() {
                            selectedFilter = tempSelectedFilter;
                            selectedTimeRange = tempSelectedTimeRange;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: const Text(
          'Gem Coins History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_alt_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _showFilterModal,
          ),
        ],
      ),
      body: BlocBuilder<GemCoinBloc, GemCoinState>(
        builder: (context, state) {
          if (state is GemCoinLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          } else if (state is GemCoinError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTransactionHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is GemCoinLoaded) {
            final transactionHistory = state.history;
            
            if (transactionHistory.isEmpty) {
              return _buildEmptyState();
            }
            
            final filteredTransactions = getFilteredTransactions(transactionHistory);
            final currentBalance = calculateCurrentBalance(transactionHistory);
            final creditTotal = calculateCreditTotal(transactionHistory);
            final debitTotal = calculateDebitTotal(transactionHistory);

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Filter Indicator Badge
                  if (selectedFilter != 'All' || selectedTimeRange != 'All Time')
                    _buildFilterBadge(),
                  
                  
                  // Header Section with Coin Display 
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Coin Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            'assets/icons/gem_coin.png',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Balance and Label
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentBalance.toString(),
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Gem Coins',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Credit/Debit Summary Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            context: context,
                            title: 'Credit',
                            amount: '+$creditTotal',
                            icon: Icons.trending_up,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            context: context,
                            title: 'Debit',
                            amount: '-$debitTotal',
                            icon: Icons.trending_down,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Transaction History
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Transaction List
                        if (filteredTransactions.isEmpty)
                          _buildEmptyFilterState()
                        else
                          ...filteredTransactions.map((transaction) {
                            final iconData = getTransactionIcon(transaction.rewardType);
                            return _buildTransactionItem(
                              context: context,
                              icon: iconData['icon'],
                              title: transaction.reason,
                              subtitle: _getTransactionSubtitle(transaction),
                              amount: '${transaction.type == GEMCoinTransactionType.credit ? '+' : '-'}${transaction.amount}',
                              isCredit: transaction.type == GEMCoinTransactionType.credit,
                              date: formatDate(transaction.date),
                              iconColor: iconData['color'],
                            );
                          }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/icons/gem_coin.png',
              width: 60,
              height: 60,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start earning Gem Coins by completing rides!',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.filter_list_off,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  String _getTransactionSubtitle(GEMCoinHistoryEntity transaction) {
    switch (transaction.rewardType) {
      case GEMCoinTransactionRewardType.rideReward:
        return 'Ride completed';
      case GEMCoinTransactionRewardType.dailyReward:
        return 'Daily login bonus';
      case GEMCoinTransactionRewardType.referralReward:
        return 'Referral bonus';
      case GEMCoinTransactionRewardType.eventReward:
        return 'Event participation';
      case GEMCoinTransactionRewardType.productReward:
        return 'Product purchase';
      case GEMCoinTransactionRewardType.otherReward:
        return 'Other reward';
    }
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required bool isCredit,
    required String date,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(width: 8),
          Text(
            _getFilterDescription(),
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedFilter = 'All';
                selectedTimeRange = 'All Time';
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.close,
                size: 14,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterDescription() {
    List<String> activeFilters = [];
    
    if (selectedFilter != 'All') {
      activeFilters.add(selectedFilter);
    }
    
    if (selectedTimeRange != 'All Time') {
      activeFilters.add(selectedTimeRange);
    }
    
    if (activeFilters.isEmpty) {
      return 'No filters applied';
    }
    
    return activeFilters.join(' • ');
  }
}