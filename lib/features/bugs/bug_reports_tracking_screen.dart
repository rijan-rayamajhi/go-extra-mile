import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_utils.dart';
import 'presentation/bloc/bug_report_bloc.dart';
import 'presentation/bloc/bug_report_event.dart';
import 'presentation/bloc/bug_report_state.dart';
import 'domain/entities/bug_report_entity.dart';

class BugReportsTrackingScreen extends StatefulWidget {
  const BugReportsTrackingScreen({super.key});

  @override
  State<BugReportsTrackingScreen> createState() =>
      _BugReportsTrackingScreenState();
}

class _BugReportsTrackingScreenState extends State<BugReportsTrackingScreen> {
  String _selectedFilter = 'All';

  final List<String> _filterOptions = [
    'All',
    'Pending',
    'Under Review',
    'In Progress',
    'Fixed',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _loadBugReports();
  }

  void _loadBugReports() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<BugReportBloc>().add(
        GetUserBugReportsEvent(userId: user.uid),
      );
    }
  }

  List<BugReportEntity> get _filteredReports {
    final state = context.read<BugReportBloc>().state;
    if (state is BugReportLoaded) {
      if (_selectedFilter == 'All') {
        return state.bugReports;
      }
      return state.bugReports
          .where((report) => report.status == _selectedFilter)
          .toList();
    }
    return [];
  }

  Map<String, dynamic>? get _stats {
    final state = context.read<BugReportBloc>().state;
    if (state is BugReportStatsLoaded) {
      return state.stats;
    }
    if (state is BugReportLoaded && state.stats != null) {
      return state.stats;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BugReportBloc, BugReportState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'My Bug Reports',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_outlined),
                onPressed: _loadBugReports,
                tooltip: 'Refresh Reports',
              ),
              IconButton(
                icon: const Icon(Icons.filter_list_outlined),
                onPressed: _showFilterDialog,
                tooltip: 'Filter Reports',
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.all(baseScreenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Card
                  Container(
                    padding: context.padding(all: baseSpacing),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Total Reports',
                            _stats?['totalReports']?.toString() ?? '0',
                            Icons.bug_report_outlined,
                            Colors.blue,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Rewards Earned',
                            '${_stats?['totalRewards'] ?? 0} GEM',
                            Icons.stars_outlined,
                            Colors.amber,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.shade300,
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Fixed Issues',
                            _stats?['fixedReports']?.toString() ?? '0',
                            Icons.check_circle_outline,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Filter Chip
                  if (_selectedFilter != 'All')
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Text(
                            'Filter: ',
                            style: TextStyle(
                              fontSize: context.fontSize(baseMediumFontSize),
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _selectedFilter,
                                  style: TextStyle(
                                    fontSize: context.fontSize(
                                      baseSmallFontSize,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedFilter = 'All'),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Bug Reports List
                  Expanded(
                    child: state is BugReportLoading
                        ? const Center(child: CircularProgressIndicator())
                        : state is BugReportError
                        ? _buildErrorState(state.message)
                        : _filteredReports.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () async {
                              _loadBugReports();
                              // Wait a bit for the loading to complete
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                            },
                            child: ListView.builder(
                              itemCount: _filteredReports.length,
                              itemBuilder: (context, index) {
                                final report = _filteredReports[index];
                                return _buildBugReportCard(report);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: context.iconSize(baseLargeIconSize)),
        SizedBox(height: context.baseSpacing(baseSmallSpacing)),
        Text(
          value,
          style: TextStyle(
            fontSize: context.fontSize(baseLargeFontSize + 2),
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: context.fontSize(baseSmallFontSize),
            color: Theme.of(context).colorScheme.secondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBugReportCard(BugReportEntity report) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 1.2),
      ),
      child: InkWell(
        onTap: () => _showReportDetails(report),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.bug_report_outlined,
                      color: _getStatusColor(report.status),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          report.description,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey.shade600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      report.status,
                      style: TextStyle(
                        color: _getStatusColor(report.status),
                        fontSize: context.fontSize(baseSmallFontSize),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Details Row
              Row(
                children: [
                  _buildDetailChip('ID: ${report.id}', Colors.grey),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    report.priority,
                    _getPriorityColor(report.priority),
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(report.category, Colors.blue),
                ],
              ),
              const SizedBox(height: 12),
              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submitted: ${_formatDate(report.createdAt)}',
                    style: TextStyle(
                      fontSize: context.fontSize(baseSmallFontSize),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  if (report.rewardAmount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars, size: 14, color: Colors.amber[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${report.rewardAmount} GEM',
                            style: TextStyle(
                              fontSize: context.fontSize(baseSmallFontSize),
                              fontWeight: FontWeight.w500,
                              color: Colors.amber[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.fontSize(baseSmallFontSize - 1),
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No reports found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'No bug reports match your current filter',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error Loading Reports',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBugReports,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.grey;
      case 'under review':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'fixed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'duplicate':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Reports'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _filterOptions.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() => _selectedFilter = value!);
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showReportDetails(BugReportEntity report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', report.id),
              _buildDetailRow('Status', report.status),
              _buildDetailRow('Priority', report.priority),
              _buildDetailRow('Severity', report.severity),
              _buildDetailRow('Category', report.category),
              _buildDetailRow('Date', _formatDate(report.createdAt)),
              if (report.rewardAmount > 0)
                _buildDetailRow('Reward', '${report.rewardAmount} GEM Coins'),

              // Screenshots Section
              if (report.screenshots.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Screenshots:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                _buildScreenshotsSection(report.screenshots),
              ],

              if (report.stepsToReproduce != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Steps to Reproduce:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(report.stepsToReproduce!),
              ],
              if (report.deviceInfo != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Device Information:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(report.deviceInfo!),
              ],
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(report.description),

              // Admin Notes Section
              if (report.adminNotes != null &&
                  report.adminNotes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Admin Notes:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Text(
                    report.adminNotes!,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildScreenshotsSection(List<String> screenshotUrls) {
    return Column(
      children: screenshotUrls.asMap().entries.map((entry) {
        final index = entry.key;
        final url = entry.value;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Screenshot ${index + 1}:',
                style: TextStyle(
                  fontSize: context.fontSize(baseSmallFontSize),
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () =>
                    _showFullScreenImage(url, 'Screenshot ${index + 1}'),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey.shade100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.grey.shade400,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: context.fontSize(baseSmallFontSize),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showFullScreenImage(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            // Full screen image
            Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.black54,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      color: Colors.black54,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Failed to load image',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            // Title
            Positioned(
              top: 40,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
