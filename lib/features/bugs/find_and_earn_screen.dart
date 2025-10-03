import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_utils.dart';
import '../../core/utils/image_picker_utils.dart';
import '../../common/widgets/custom_text_field.dart';
import '../../common/widgets/primary_button.dart';
import '../../common/widgets/app_snackbar.dart';
import 'bug_reports_tracking_screen.dart';
import 'presentation/bloc/bug_report_bloc.dart';
import 'presentation/bloc/bug_report_event.dart';
import 'presentation/bloc/bug_report_state.dart';

class FindAndEarnScreen extends StatefulWidget {
  const FindAndEarnScreen({super.key});

  @override
  State<FindAndEarnScreen> createState() => _FindAndEarnScreenState();
}

class _FindAndEarnScreenState extends State<FindAndEarnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stepsController = TextEditingController();
  final _deviceController = TextEditingController();

  List<String> _screenshots = []; // List of image file paths

  String _selectedCategory = 'UI/UX';
  String _selectedPriority = 'Medium';
  String _selectedSeverity = 'Minor';

  final List<String> _categories = [
    'UI/UX',
    'Functionality',
    'Performance',
    'Security',
    'Navigation',
    'Data',
    'Other',
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High', 'Critical'];

  final List<String> _severities = ['Minor', 'Major', 'Critical', 'Blocker'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _stepsController.dispose();
    _deviceController.dispose();
    super.dispose();
  }

  void _submitBugReport() {
    if (_formKey.currentState!.validate()) {
      if (_screenshots.isEmpty) {
        AppSnackBar.error(context, 'Please add at least one screenshot');
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppSnackBar.error(context, 'Please log in to submit bug reports');
        return;
      }

      context.read<BugReportBloc>().add(
        SubmitBugReportEvent(
          userId: user.uid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          priority: _selectedPriority,
          severity: _selectedSeverity,
          screenshots: _screenshots,
          stepsToReproduce: _stepsController.text.trim().isNotEmpty
              ? _stepsController.text.trim()
              : null,
          deviceInfo: _deviceController.text.trim().isNotEmpty
              ? _deviceController.text.trim()
              : null,
        ),
      );
    }
  }

  void _trackBugReports() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BugReportsTrackingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BugReportBloc, BugReportState>(
      listener: (context, state) {
        if (state is BugReportSubmitted) {
          _showSuccessDialog();
        } else if (state is BugReportError) {
          AppSnackBar.error(context, state.message);
        }
      },
      child: BlocBuilder<BugReportBloc, BugReportState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Report Bug',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.track_changes_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  onPressed: _trackBugReports,
                  tooltip: 'Track My Bug Reports',
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: context.padding(all: baseScreenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card - Vehicle List Style
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.95),
                            Colors.grey.shade100.withValues(alpha: 0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(baseScreenPadding),
                        child: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              // Bug report icon with badge
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 34,
                                    backgroundColor: Colors.orange[100],
                                    child: Icon(
                                      Icons.bug_report,
                                      color: Colors.orange[700],
                                      size: 28,
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 20),

                              // Bug report details
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Found a Bug?',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Report bugs and earn rewards',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Help us improve the app by reporting bugs. Earn rewards for valid reports!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: context.baseSpacing(baseLargeSpacing)),

                    // Bug Title
                    CustomTextField(
                      label: 'Bug Title *',
                      controller: _titleController,
                      hintText: 'Brief description of the bug',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a bug title';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: context.baseSpacing(
                        baseSpacing + baseSmallSpacing,
                      ),
                    ),

                    // Category and Priority Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Category *', context),
                              SizedBox(
                                height: context.baseSpacing(baseSmallSpacing),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(
                                    context.borderRadius(baseInputRadius),
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    hint: const Text("Select Category"),
                                    isExpanded: true,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                    items: _categories.map((category) {
                                      return DropdownMenuItem(
                                        value: category,
                                        child: Text(category),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: context.baseSpacing(baseSpacing)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Priority *', context),
                              SizedBox(
                                height: context.baseSpacing(baseSmallSpacing),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  borderRadius: BorderRadius.circular(
                                    context.borderRadius(baseInputRadius),
                                  ),
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                  ),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedPriority,
                                    hint: const Text("Select Priority"),
                                    isExpanded: true,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                    items: _priorities.map((priority) {
                                      return DropdownMenuItem(
                                        value: priority,
                                        child: Text(priority),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedPriority = value!;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: context.baseSpacing(
                        baseSpacing + baseSmallSpacing,
                      ),
                    ),

                    // Severity
                    _buildSectionTitle('Severity *', context),
                    SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          context.borderRadius(baseInputRadius),
                        ),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSeverity,
                          hint: const Text("Select Severity"),
                          isExpanded: true,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          items: _severities.map((severity) {
                            return DropdownMenuItem(
                              value: severity,
                              child: Text(severity),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSeverity = value!;
                            });
                          },
                        ),
                      ),
                    ),

                    SizedBox(
                      height: context.baseSpacing(
                        baseSpacing + baseSmallSpacing,
                      ),
                    ),

                    // Description
                    CustomTextField(
                      label: 'Description *',
                      controller: _descriptionController,
                      maxLines: 4,
                      hintText: 'Describe the bug in detail...',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),

                    SizedBox(
                      height: context.baseSpacing(
                        baseSpacing + baseSmallSpacing,
                      ),
                    ),

                    // Steps to Reproduce
                    CustomTextField(
                      label: 'Steps to Reproduce',
                      controller: _stepsController,
                      maxLines: 3,
                      hintText: '1. Go to...\n2. Click on...\n3. Observe...',
                    ),

                    SizedBox(
                      height: context.baseSpacing(
                        baseSpacing + baseSmallSpacing,
                      ),
                    ),

                    // Device Information
                    CustomTextField(
                      label: 'Device Information',
                      controller: _deviceController,
                      hintText: 'e.g., iPhone 14, Android 13, Chrome 120',
                    ),

                    SizedBox(
                      height: context.baseSpacing(
                        baseSpacing + baseSmallSpacing,
                      ),
                    ),

                    // Screenshot Section
                    _buildSectionTitle('Screenshots *', context),
                    SizedBox(height: context.baseSpacing(baseSmallSpacing)),
                    _buildScreenshotSection(),

                    SizedBox(
                      height: context.baseSpacing(
                        baseLargeSpacing + baseSpacing,
                      ),
                    ),

                    // Submit Button
                    PrimaryButton(
                      text: 'Submit Bug Report',
                      onPressed: _submitBugReport,
                    ),

                    SizedBox(height: context.baseSpacing(baseSpacing)),

                    // Info Card
                    Card(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          context.borderRadius(baseInputRadius),
                        ),
                      ),
                      child: Padding(
                        padding: context.padding(all: baseSpacing),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: context.iconSize(
                                baseSmallIconSize + baseSmallSpacing,
                              ),
                            ),
                            SizedBox(
                              width: context.baseSpacing(
                                baseSmallSpacing + baseSmallSpacing / 2,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Valid bug reports may earn you rewards! Make sure to provide detailed information.',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: context.fontSize(
                                    baseSmallFontSize + 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      height: context.baseSpacing(
                        baseSpacing + baseSmallSpacing,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bug Report Submitted'),
        content: const Text(
          'Thank you for reporting this bug! Our team will review it and you may earn rewards for valid reports.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: context.fontSize(baseLargeFontSize),
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildScreenshotSection() {
    return Column(
      children: [
        // Screenshot Grid
        Container(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            color: Colors.grey.shade50,
          ),
          child: _screenshots.isEmpty
              ? _buildUploadPlaceholder()
              : _buildScreenshotGrid(),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return InkWell(
      onTap: _addScreenshot,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade100,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: context.padding(all: baseSpacing),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_photo_alternate_outlined,
                size: context.iconSize(baseLargeIconSize * 1.5),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: context.baseSpacing(baseSpacing)),
            Text(
              'Tap to add screenshots',
              style: TextStyle(
                fontSize: context.fontSize(baseLargeFontSize),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: context.baseSpacing(baseSmallSpacing / 2)),
            Text(
              'Add a screenshot to help us understand the bug',
              style: TextStyle(
                fontSize: context.fontSize(baseMediumFontSize),
                color: Theme.of(context).colorScheme.secondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenshotGrid() {
    return Padding(
      padding: context.padding(all: baseSmallSpacing),
      child: _buildScreenshotItem(0),
    );
  }

  Widget _buildScreenshotItem(int index) {
    final imagePath = _screenshots[index];

    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeScreenshot(index),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 18, color: Colors.white),
              ),
            ),
          ),
          // Image size indicator
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FutureBuilder<double>(
                future: _getImageSizeInMB(imagePath),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(
                      '${snapshot.data!.toStringAsFixed(1)} MB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }
                  return const Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addScreenshot() async {
    if (_screenshots.isNotEmpty) {
      AppSnackBar.info(context, 'Only one screenshot allowed');
      return;
    }

    try {
      // Use the same bottom sheet implementation from ImagePickerUtils
      final capturedImage = await ImagePickerUtils.pickAndCropImage(
        context: context,
        maxSizeInMB: 10.0, // Allow up to 10MB for bug screenshots
        forceCropAspectRatio: true,
        ratioX: 16,
        ratioY: 9, // 16:9 aspect ratio for screenshots
        cropStyle: CropStyle.rectangle, // Use rectangle for screenshots
        imageQuality: 85, // Good quality for screenshots
      );

      if (capturedImage != null) {
        setState(() {
          _screenshots.add(capturedImage.path);
        });

        AppSnackBar.success(context, 'Screenshot added successfully!');
      }
    } catch (e) {
      AppSnackBar.error(context, 'Failed to add screenshot: ${e.toString()}');
    }
  }

  void _removeScreenshot(int index) {
    if (index < _screenshots.length) {
      final imagePath = _screenshots[index];

      // Try to delete the file from storage
      try {
        final file = File(imagePath);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (e) {
        debugPrint('Error deleting image file: $e');
      }

      setState(() {
        _screenshots.removeAt(index);
      });

      AppSnackBar.info(context, 'Screenshot removed');
    }
  }

  Future<double> _getImageSizeInMB(String imagePath) async {
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        final int fileSizeInBytes = await file.length();
        return fileSizeInBytes / (1024 * 1024); // Convert to MB
      }
      return 0.0;
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return 0.0;
    }
  }
}
