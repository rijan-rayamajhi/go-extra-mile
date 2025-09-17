import 'package:flutter/material.dart';

class MyEarningHistoryScreen extends StatefulWidget {
  const MyEarningHistoryScreen({super.key});

  @override
  State<MyEarningHistoryScreen> createState() => _MyEarningHistoryScreenState();
}

class _MyEarningHistoryScreenState extends State<MyEarningHistoryScreen> {
  // Pagination state
  int currentPage = 1;
  final int itemsPerPage = 10;
  bool isLoading = false;
  bool hasMoreData = true;
  
  // All gem coin to cash conversion history data (simulating a large dataset)
  final List<PaymentHistoryItem> allPaymentHistory = [
    PaymentHistoryItem(
      amount: 250.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 2500 gems on Dec 15, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 12, 15),
    ),
    PaymentHistoryItem(
      amount: 150.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 1500 gems on Dec 10, 2024',
      status: PaymentStatus.pending,
      date: DateTime(2024, 12, 10),
    ),
    PaymentHistoryItem(
      amount: 300.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 3000 gems on Dec 5, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 12, 5),
    ),
    PaymentHistoryItem(
      amount: 100.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 1000 gems on Nov 28, 2024',
      status: PaymentStatus.failed,
      date: DateTime(2024, 11, 28),
    ),
    PaymentHistoryItem(
      amount: 200.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 2000 gems on Nov 20, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 11, 20),
    ),
    PaymentHistoryItem(
      amount: 175.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 1750 gems on Nov 15, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 11, 15),
    ),
    // Adding more dummy data for pagination demonstration
    PaymentHistoryItem(
      amount: 320.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 3200 gems on Nov 10, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 11, 10),
    ),
    PaymentHistoryItem(
      amount: 180.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 1800 gems on Nov 5, 2024',
      status: PaymentStatus.pending,
      date: DateTime(2024, 11, 5),
    ),
    PaymentHistoryItem(
      amount: 220.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 2200 gems on Oct 30, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 10, 30),
    ),
    PaymentHistoryItem(
      amount: 140.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 1400 gems on Oct 25, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 10, 25),
    ),
    PaymentHistoryItem(
      amount: 280.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 2800 gems on Oct 20, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 10, 20),
    ),
    PaymentHistoryItem(
      amount: 160.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 1600 gems on Oct 15, 2024',
      status: PaymentStatus.failed,
      date: DateTime(2024, 10, 15),
    ),
    PaymentHistoryItem(
      amount: 240.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 2400 gems on Oct 10, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 10, 10),
    ),
    PaymentHistoryItem(
      amount: 190.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 1900 gems on Oct 5, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 10, 5),
    ),
    PaymentHistoryItem(
      amount: 310.00,
      title: 'Gem Coins to Cash',
      subtitle: 'Converted 3100 gems on Sep 30, 2024',
      status: PaymentStatus.completed,
      date: DateTime(2024, 9, 30),
    ),
  ];
  
  // Currently displayed conversion history (paginated)
  List<PaymentHistoryItem> paymentHistory = [];
  
  @override
  void initState() {
    super.initState();
    _loadMoreData();
  }
  
  // Simulate loading more data (in real app, this would be an API call)
  Future<void> _loadMoreData() async {
    if (isLoading || !hasMoreData) return;
    
    setState(() {
      isLoading = true;
    });
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    
    if (startIndex < allPaymentHistory.length) {
      final newItems = allPaymentHistory.sublist(
        startIndex,
        endIndex > allPaymentHistory.length ? allPaymentHistory.length : endIndex,
      );
      
      setState(() {
        paymentHistory.addAll(newItems);
        currentPage++;
        hasMoreData = endIndex < allPaymentHistory.length;
        isLoading = false;
      });
    } else {
      setState(() {
        hasMoreData = false;
        isLoading = false;
      });
    }
  }
  
  // Get paginated conversion history for display
  List<PaymentHistoryItem> get paginatedPaymentHistory {
    return paymentHistory;
  }
  
  // Build auto loading indicator
  Widget _buildAutoLoadingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // Loading indicator
          Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                strokeWidth: 2,
              ),
            ),
          ),
          
          // Loading text
          Text(
            'Loading more conversions...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Pagination info
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Showing ${paginatedPaymentHistory.length} of ${allPaymentHistory.length} conversions',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Conversion History'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          // Trigger loading when user scrolls to bottom
          if (!isLoading && 
              hasMoreData && 
              scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            _loadMoreData();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            // Summary Card as SliverToBoxAdapter
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  // gradient: const LinearGradient(
                  //   colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  //   begin: Alignment.topLeft,
                  //   end: Alignment.bottomRight,
                  // ),
                  borderRadius: BorderRadius.circular(16),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.1),
                  //     blurRadius: 10,
                  //     offset: const Offset(0, 4),
                  //   ),
                  // ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Cash Converted',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${allPaymentHistory.where((item) => item.status == PaymentStatus.completed).fold(0.0, (sum, item) => sum + item.amount).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: Colors.white,
                    size: 24,
                  ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Payment History List as SliverList
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  // Show loading indicator at the end if there's more data
                  if (index == paginatedPaymentHistory.length) {
                    return _buildAutoLoadingIndicator();
                  }
                  
                  final item = paginatedPaymentHistory[index];
                  final isLast = index == paginatedPaymentHistory.length - 1;
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: PaymentHistoryListItem(
                      item: item,
                      isLast: isLast,
                    ),
                  );
                },
                childCount: paginatedPaymentHistory.length + (hasMoreData ? 1 : 0),
              ),
            ),
            
            // Bottom padding for better scrolling experience
            const SliverToBoxAdapter(
              child: SizedBox(height: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentHistoryItem {
  final double amount;
  final String title;
  final String subtitle;
  final PaymentStatus status;
  final DateTime date;

  PaymentHistoryItem({
    required this.amount,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.date,
  });
}

enum PaymentStatus {
  completed,
  pending,
  failed,
}

class PaymentHistoryListItem extends StatelessWidget {
  final PaymentHistoryItem item;
  final bool isLast;

  const PaymentHistoryListItem({
    super.key,
    required this.item,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vertical line with status indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getStatusColor(item.status),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(item.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getStatusText(item.status),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: _getStatusColor(item.status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Amount
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${item.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(item.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}