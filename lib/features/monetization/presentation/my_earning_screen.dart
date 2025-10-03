import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/admin_data/domain/entities/monetization_settings.dart';
import 'package:go_extra_mile_new/features/admin_data/presentation/bloc/admin_data_event.dart';
import 'package:go_extra_mile_new/features/monetization/presentation/my_cashout_transaction.dart';
import '../../admin_data/presentation/bloc/admin_data_bloc.dart';
import '../../admin_data/presentation/bloc/admin_data_state.dart';
import 'widgets/my_earning_buttom_sheet.dart';
import 'bloc/monetization_data_bloc.dart';
import 'bloc/monetization_data_state.dart';
import 'bloc/monetization_data_event.dart';
import '../domain/entities/cashout_transaction_entity.dart';

class MyEarningScreen extends StatefulWidget {
  const MyEarningScreen({super.key});

  @override
  State<MyEarningScreen> createState() => _MyEarningScreenState();
}

class _MyEarningScreenState extends State<MyEarningScreen> {
  int? selectedAmount;

  @override
  void initState() {
    super.initState();
    context.read<AdminDataBloc>().add(FetchAdminDataEvent());
    context.read<MonetizationDataBloc>().add(const LoadMonetizationData());
    context.read<MonetizationDataBloc>().add(const LoadCashoutTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyCashoutTransactionScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<AdminDataBloc, AdminDataState>(
        builder: (context, adminState) {
          return BlocBuilder<MonetizationDataBloc, MonetizationDataState>(
            builder: (context, monetizationState) {
              // Show loading if either admin data or monetization data is loading
              if (adminState is AdminDataLoading ||
                  monetizationState is MonetizationDataLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              // Show error if admin data failed to load
              if (adminState is AdminDataError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading settings',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        adminState.message,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<AdminDataBloc>().add(
                            FetchAdminDataEvent(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              // Show error if monetization data failed to load
              if (monetizationState is MonetizationDataError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading cashout data',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        monetizationState.message,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        onPressed: () {
                          context.read<MonetizationDataBloc>().add(
                            const LoadMonetizationData(),
                          );
                          context.read<MonetizationDataBloc>().add(
                            const LoadCashoutTransactions(),
                          );
                        },
                        text: 'Retry',
                      ),
                    ],
                  ),
                );
              }

              return switch (adminState) {
                AdminDataLoaded(:final monetizationSettings) =>
                  _buildLoadedBody(monetizationSettings, monetizationState),
                _ => const Center(
                  child: Text(
                    'Please wait...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              };
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadedBody(
    MonetizationSettings monetizationSettings,
    MonetizationDataState monetizationState,
  ) {
    // Only proceed if we have complete data
    if (monetizationState is! MonetizationDataLoaded || 
        monetizationState.monetizationData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your balance...'),
          ],
        ),
      );
    }

    final monetizationData = monetizationState.monetizationData!;
    final cashoutTransactions = monetizationState.cashoutTransactions ?? [];

    // Calculate available GEM coins dynamically
    final availableGEMCoins = monetizationData.calculateAvailableGemCoins(
      cashoutTransactions,
    );

    final availableBalance =
        availableGEMCoins / monetizationSettings.cashoutParams.conversionRate;


    final predefinedAmounts = monetizationSettings.predefinedAmounts
        .map((a) => int.tryParse(a) ?? 0)
        .where((a) => a > 0)
        .toList();


    // Calculate available amounts based on limit restrictions
    final availableAmounts = _getAvailableAmounts(
      predefinedAmounts,
      availableBalance,
      monetizationSettings,
      cashoutTransactions,
      monetizationState,
    );

    // Auto-select first available amount that's not disabled
    selectedAmount ??= availableAmounts.firstOrNull;

    // If selected amount is now disabled, select first available
    if (selectedAmount != null && !availableAmounts.contains(selectedAmount)) {
      selectedAmount = availableAmounts.firstOrNull;
    }

    return Column(
      children: [
        Expanded(child: _buildTopSection()),
        _buildBottomCard(
          monetizationSettings,
          availableBalance,
          predefinedAmounts,
          availableAmounts,
          cashoutTransactions,
          monetizationState,
        ),
      ],
    );
  }

  // --- UI Helpers ---

  Widget _buildTopSection() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Redeem Cash of',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '₹ ${selectedAmount ?? 0}',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            BlocBuilder<MonetizationDataBloc, MonetizationDataState>(
              builder: (context, state) {
                final totalCashout = state is MonetizationDataLoaded
                    ? (state.cashoutTransactions ?? [])
                          .where(
                            (t) =>
                                t.status == CashoutTransactionStatus.approved,
                          )
                          .fold(0.0, (sum, t) => sum + t.amount)
                    : 0.0;
                return Text(
                  '₹ ${totalCashout.toStringAsFixed(0)} Cash out so far',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCard(
    MonetizationSettings settings,
    double availableBalance,
    List<int> predefinedAmounts,
    List<int> availableAmounts,
    List<CashoutTransactionEntity> cashoutTransactions,
    MonetizationDataState monetizationState,
  ) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'My Earning',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _balanceCard(availableBalance),
            if (availableAmounts.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Select Amount',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: predefinedAmounts
                    .map(
                      (amount) => _amountOption(
                        amount,
                        availableBalance,
                        settings,
                        cashoutTransactions,
                        monetizationState,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
            ] else
              const SizedBox(height: 20),
            _buildCashoutSection(
              settings,
              availableBalance,
              availableAmounts,
              cashoutTransactions,
              monetizationState,
            ),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard(double availableBalance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${availableBalance.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountOption(
    int amount,
    double availableBalance,
    MonetizationSettings settings,
    List<CashoutTransactionEntity> cashoutTransactions,
    MonetizationDataState monetizationState,
  ) {
    final isSelected = selectedAmount == amount;
    final isDisabledByBalance = amount > availableBalance;
    final isDisabledByLimit = _isAmountDisabledByLimit(
      amount,
      settings,
      cashoutTransactions,
      monetizationState,
    );
    final isDisabled = isDisabledByBalance || isDisabledByLimit;

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () => setState(() => selectedAmount = amount),
        child: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.grey[300]
                : (isSelected ? Colors.black : Colors.grey[200]),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey[400]!
                  : (isSelected ? Colors.black : Colors.grey[300]!),
            ),
          ),
          child: Center(
            child: Text(
              '₹ $amount',
              style: TextStyle(
                color: isDisabled
                    ? Colors.grey[500]
                    : (isSelected ? Colors.white : Colors.black),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCashoutSection(
    MonetizationSettings settings,
    double availableBalance,
    List<int> availableAmounts,
    List<CashoutTransactionEntity> cashoutTransactions,
    MonetizationDataState monetizationState,
  ) {
    // Check limit-based cashout restrictions first
    if (settings.limitBasedCashout) {
      final limitCheckResult = _checkLimitBasedCashout(
        settings,
        cashoutTransactions,
        monetizationState,
      );
      if (limitCheckResult != null) {
        return limitCheckResult;
      }
    }
    // Check minimum cashout limit first
    if (availableBalance < settings.minCashout) {
      return _infoMessage(
        'Minimum cashout amount is ₹${settings.minCashout.toStringAsFixed(0)}. Your available balance is ₹${availableBalance.toStringAsFixed(2)}.',
      );
    }

    if (settings.allowCashout && settings.bankBalance >= availableBalance) {
      if (selectedAmount == null) {
        // Check if it's due to cashout limits
        if (settings.limitBasedCashout && availableAmounts.isEmpty) {
          final totalUsedInLimit = _calculateCashoutInTimeLimit(
            cashoutTransactions,
            settings.timeLimit,
          );
          final remainingLimit = settings.maxLimitCashout - totalUsedInLimit;
          
          if (remainingLimit <= 0) {
            return _infoMessage(
              'You have reached your cashout limit of ₹${settings.maxLimitCashout.toStringAsFixed(0)} for ${settings.timeLimit} days. Please wait for the limit to reset.',
            );
          } else {
            return _infoMessage(
              'No cashout amounts available. You have ₹${remainingLimit.toStringAsFixed(2)} remaining in your ${settings.timeLimit}-day limit, but the minimum predefined amount exceeds this.',
            );
          }
        }
        return _infoMessage('Please select an amount to redeem.');
      }

      return PrimaryButton(
        text: 'Redeem Cash',
        onPressed: () => MyEarningBottomSheet.show(context, selectedAmount!),
      );
    }

    if (!settings.allowCashout) {
      return _infoMessage(
        'Cashout is not allowed. Please contact support for more details.',
      );
    }

    if (settings.bankBalance < availableBalance) {
      return _infoMessage(
        'Cashout is not allowed. Admin bank balance is less than available balance.',
      );
    }

    return const Text(
      'Cashout is not allowed',
      style: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Helper methods for limit-based cashout

  List<int> _getAvailableAmounts(
    List<int> predefinedAmounts,
    double availableBalance,
    MonetizationSettings settings,
    List<CashoutTransactionEntity> cashoutTransactions,
    MonetizationDataState monetizationState,
  ) {
    return predefinedAmounts.where((amount) {
      if (amount > availableBalance) return false;
      if (settings.limitBasedCashout) {
        return !_isAmountDisabledByLimit(
          amount,
          settings,
          cashoutTransactions,
          monetizationState,
        );
      }
      return true;
    }).toList();
  }

  bool _isAmountDisabledByLimit(
    int amount,
    MonetizationSettings settings,
    List<CashoutTransactionEntity> cashoutTransactions,
    MonetizationDataState monetizationState,
  ) {
    if (!settings.limitBasedCashout) return false;

    // Check if user is monetized
    final isUserMonetized = _isUserMonetized(monetizationState, settings);
    if (isUserMonetized) return false; // Monetized users skip limit checks

    // Calculate total cashout amount within time limit
    final totalCashoutInTimeLimit = _calculateCashoutInTimeLimit(
      cashoutTransactions,
      settings.timeLimit,
    );

    // Check if adding this amount would exceed the limit
    return (totalCashoutInTimeLimit + amount) > settings.maxLimitCashout;
  }

  bool _isUserMonetized(
    MonetizationDataState monetizationState,
    MonetizationSettings settings,
  ) {
    if (monetizationState is MonetizationDataLoaded) {
      final monetizationData = monetizationState.monetizationData;
      if (monetizationData != null) {
        return monetizationData.isMonetized(
          targetDistance: settings.cashoutParams.minimumDistance,
          targetReferrals: settings.cashoutParams.minimumReferrals,
          targetRides: settings.cashoutParams.minimumRides,
        );
      }
    }
    return false;
  }

  double _calculateCashoutInTimeLimit(
    List<CashoutTransactionEntity> transactions,
    int timeLimitDays,
  ) {
    final cutoffDate = DateTime.now().subtract(Duration(days: timeLimitDays));

    return transactions
        .where(
          (transaction) =>
              transaction.createdAt.isAfter(cutoffDate) &&
              (transaction.status == CashoutTransactionStatus.approved ||
                  transaction.status == CashoutTransactionStatus.pending),
        )
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  Widget? _checkLimitBasedCashout(
    MonetizationSettings settings,
    List<CashoutTransactionEntity> cashoutTransactions,
    MonetizationDataState monetizationState,
  ) {
    // Check if user is monetized
    final isUserMonetized = _isUserMonetized(monetizationState, settings);
    if (isUserMonetized) return null; // Skip limit checks for monetized users

    // Calculate total cashout amount within time limit
    final totalCashoutInTimeLimit = _calculateCashoutInTimeLimit(
      cashoutTransactions,
      settings.timeLimit,
    );

    // Check if user has exceeded the limit
    if (totalCashoutInTimeLimit >= settings.maxLimitCashout) {
      final remainingDays = _calculateRemainingDays(
        cashoutTransactions,
        settings.timeLimit,
      );

      return _infoMessage(
        'You have reached your cashout limit of ₹${settings.maxLimitCashout.toStringAsFixed(0)} '
        'for ${settings.timeLimit} days. You can cashout again in $remainingDays days.',
      );
    }

    // Check if selected amount would exceed the limit
    if (selectedAmount != null &&
        (totalCashoutInTimeLimit + selectedAmount!) >
            settings.maxLimitCashout) {
      final remainingAmount =
          settings.maxLimitCashout - totalCashoutInTimeLimit;
      return _infoMessage(
        'You can only cashout ₹${remainingAmount.toStringAsFixed(0)} more '
        'within the ${settings.timeLimit}-day limit. Please select a lower amount.',
      );
    }

    return null; // No limit restrictions
  }

  int _calculateRemainingDays(
    List<CashoutTransactionEntity> transactions,
    int timeLimitDays,
  ) {
    if (transactions.isEmpty) return 0;

    // Find the oldest transaction within the time limit
    final cutoffDate = DateTime.now().subtract(Duration(days: timeLimitDays));
    final relevantTransactions = transactions
        .where((transaction) => transaction.createdAt.isAfter(cutoffDate))
        .toList();

    if (relevantTransactions.isEmpty) return 0;

    // Sort by creation date and get the oldest
    relevantTransactions.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final oldestTransaction = relevantTransactions.first;

    // Calculate when the time limit will reset
    final resetDate = oldestTransaction.createdAt.add(
      Duration(days: timeLimitDays),
    );
    final remainingDays = resetDate.difference(DateTime.now()).inDays;

    return remainingDays > 0 ? remainingDays : 0;
  }

  Widget _infoMessage(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.orange[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
