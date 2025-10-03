import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'bloc/monetization_data_bloc.dart';
import 'bloc/monetization_data_event.dart';
import 'bloc/monetization_data_state.dart';
import '../domain/entities/cashout_transaction_entity.dart';

class MyCashoutTransactionScreen extends StatefulWidget {
  const MyCashoutTransactionScreen({super.key});

  @override
  State<MyCashoutTransactionScreen> createState() =>
      _MyCashoutTransactionScreenState();
}

class _MyCashoutTransactionScreenState
    extends State<MyCashoutTransactionScreen> {
  @override
  void initState() {
    super.initState();
    // Load cashout transactions when screen initializes
    context.read<MonetizationDataBloc>().add(const LoadCashoutTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(
          'My Cashout Transactions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<MonetizationDataBloc, MonetizationDataState>(
        builder: (context, state) {
          return switch (state) {
            MonetizationDataLoading() => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            MonetizationDataError(:final message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: $message',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MonetizationDataBloc>().add(
                        const LoadCashoutTransactions(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            MonetizationDataLoaded(:final cashoutTransactions) =>
              _buildLoadedBody(cashoutTransactions ?? []),
            _ => Center(
              child: Text(
                'Please wait...',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          };
        },
      ),
    );
  }

  Widget _buildLoadedBody(List<CashoutTransactionEntity> transactions) {
    final totalEarnings = _calculateTotalEarnings(transactions);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Total Earnings Header
            _buildTotalEarningsHeader(totalEarnings, transactions.length),
            
            // Transactions List
            transactions.isEmpty
                ? _buildEmptyState()
                : _buildTransactionsList(transactions),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalEarningsHeader(double totalEarnings, int transactionCount) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '₹ ${totalEarnings.toStringAsFixed(2)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Total Earnings • $transactionCount transactions',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Transactions Yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your cashout history will appear here',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(List<CashoutTransactionEntity> transactions) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction History',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${transactions.length} transactions',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: transactions.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return _buildTransactionCard(transaction);
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTransactionCard(CashoutTransactionEntity transaction) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Status Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getStatusColor(transaction.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getStatusIcon(transaction.status),
                color: _getStatusColor(transaction.status),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            
            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹ ${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _buildStatusBadge(transaction.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID: ${transaction.id}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(transaction.createdAt),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(CashoutTransactionStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper methods for status styling
  Color _getStatusColor(CashoutTransactionStatus status) {
    switch (status) {
      case CashoutTransactionStatus.pending:
        return Colors.orange;
      case CashoutTransactionStatus.approved:
        return Colors.green;
      case CashoutTransactionStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(CashoutTransactionStatus status) {
    switch (status) {
      case CashoutTransactionStatus.pending:
        return Icons.schedule;
      case CashoutTransactionStatus.approved:
        return Icons.check_circle;
      case CashoutTransactionStatus.rejected:
        return Icons.cancel;
    }
  }

  String _getStatusText(CashoutTransactionStatus status) {
    switch (status) {
      case CashoutTransactionStatus.pending:
        return 'PENDING';
      case CashoutTransactionStatus.approved:
        return 'APPROVED';
      case CashoutTransactionStatus.rejected:
        return 'REJECTED';
    }
  }

  double _calculateTotalEarnings(List<CashoutTransactionEntity> transactions) {
    return transactions
        .where(
          (transaction) =>
              transaction.status == CashoutTransactionStatus.approved,
        )
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
}
