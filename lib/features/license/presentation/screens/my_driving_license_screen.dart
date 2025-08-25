import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/core/utils/image_picker_utils.dart';
import 'package:go_extra_mile_new/core/utils/date_picker_utils.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_bloc.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_event.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_state.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class MyDrivingLicenseScreen extends StatefulWidget {

  const MyDrivingLicenseScreen({super.key});

  @override
  State<MyDrivingLicenseScreen> createState() => _MyDrivingLicenseScreenState();
}

class _MyDrivingLicenseScreenState extends State<MyDrivingLicenseScreen> {
  File? _frontImage;
  File? _backImage;
  DateTime? _dob;
  String? _selectedVehicleType;
  bool _isAuthorized = false;
  
  // Track cleared network images
  bool _frontImageCleared = false;
  bool _backImageCleared = false;

  final List<String> _vehicleTypes = [
    '2 Wheeler',
    '4 Wheeler',
    '2 & 4 Wheeler',
  ];

  @override
  void initState() {
    _loadDrivingLicense();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Populate fields with existing data when state changes
    final state = context.read<DrivingLicenseBloc>().state;
    if (state is DrivingLicenseLoaded || state is DrivingLicenseSubmitted) {
      final license = state is DrivingLicenseLoaded 
          ? state.license 
          : (state as DrivingLicenseSubmitted).license;
      _populateFieldsFromLicense(license);
    }
  }

  void _populateFieldsFromLicense(DrivingLicenseEntity? license) {
    if (license == null) return;
    
    // Only populate if fields are empty and license has data
    if (_selectedVehicleType == null && license.licenseType.isNotEmpty) {
      _selectedVehicleType = license.licenseType;
    }
    
    if (_dob == null && license.dob != null && !_isDefaultDob(license.dob)) {
      _dob = license.dob;
    }
    
    // Reset cleared flags if we have network images
    if (license.frontImagePath.isNotEmpty && license.frontImagePath.startsWith('http')) {
      _frontImageCleared = false;
    }
    if (license.backImagePath.isNotEmpty && license.backImagePath.startsWith('http')) {
      _backImageCleared = false;
    }
  }

  void _loadDrivingLicense() {
    context.read<DrivingLicenseBloc>().add(GetDrivingLicenseEvent());
  }

  void _saveDrivingLicense() {
    // Check if we have valid images for both sides
    final currentState = context.read<DrivingLicenseBloc>().state;
    bool hasValidFrontImage = _frontImage != null || 
                             (currentState is DrivingLicenseLoaded && 
                              currentState.license?.frontImagePath.isNotEmpty == true && 
                              currentState.license!.frontImagePath.startsWith('http') &&
                              !_frontImageCleared);
    
    bool hasValidBackImage = _backImage != null || 
                            (currentState is DrivingLicenseLoaded && 
                             currentState.license?.backImagePath.isNotEmpty == true && 
                             currentState.license!.backImagePath.startsWith('http') &&
                             !_backImageCleared);

    // Validate required fields
    if (!hasValidFrontImage ||
        !hasValidBackImage ||
        _selectedVehicleType == null ||
        _dob == null) {
      AppSnackBar.info(context, 'Please fill all required fields');
      return;
    }

    // Create driving license entity
    final license = DrivingLicenseEntity(
      licenseType: _selectedVehicleType!,
      frontImagePath: _frontImage?.path ?? 
                     (currentState is DrivingLicenseLoaded && 
                      currentState.license?.frontImagePath.isNotEmpty == true &&
                      currentState.license!.frontImagePath.startsWith('http') &&
                      !_frontImageCleared
                          ? currentState.license!.frontImagePath
                          : ''),
      backImagePath: _backImage?.path ?? 
                    (currentState is DrivingLicenseLoaded && 
                     currentState.license?.backImagePath.isNotEmpty == true &&
                     currentState.license!.backImagePath.startsWith('http') &&
                     !_backImageCleared
                         ? currentState.license!.backImagePath
                         : ''),
      dob: _dob!,
    );

    context.read<DrivingLicenseBloc>().add(SubmitDrivingLicenseEvent(license));
  }



  Future<void> _pickImage(bool isFront) async {
    try {
      final File? pickedFile = await ImagePickerUtils.pickAndCropImage(
        context: context,
        maxSizeInMB: 5,
        imageQuality: 80,
        cropStyle: CropStyle.rectangle,
      );

      if (pickedFile != null) {
        setState(() {
          if (isFront) {
            _frontImage = pickedFile;
            _frontImageCleared = false;
          } else {
            _backImage = pickedFile;
            _backImageCleared = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearImage(bool isFront) {
    setState(() {
      if (isFront) {
        _frontImage = null;
        _frontImageCleared = true;
      } else {
        _backImage = null;
        _backImageCleared = true;
      }
    });
  }

  // Helper methods for verification status
  Color _getVerificationStatusColor(DrivingLicenseVerificationStatus status) {
    switch (status) {
      case DrivingLicenseVerificationStatus.pending:
        return Colors.orange;
      case DrivingLicenseVerificationStatus.rejected:
        return Colors.red;
      case DrivingLicenseVerificationStatus.verified:
        return Colors.green;
    }
  }

  IconData _getVerificationStatusIcon(DrivingLicenseVerificationStatus status) {
    switch (status) {
      case DrivingLicenseVerificationStatus.pending:
        return Icons.schedule;
      case DrivingLicenseVerificationStatus.rejected:
        return Icons.cancel;
      case DrivingLicenseVerificationStatus.verified:
        return Icons.verified;
    }
  }

  String _getVerificationStatusText(DrivingLicenseVerificationStatus status) {
    switch (status) {
      case DrivingLicenseVerificationStatus.pending:
        return 'Pending Review';
      case DrivingLicenseVerificationStatus.rejected:
        return 'Rejected';
      case DrivingLicenseVerificationStatus.verified:
        return 'Verified';
    }
  }

  // Helper method to check if DOB is the default placeholder
  bool _isDefaultDob(DateTime? dob) {
    if (dob == null) return true;
    final now = DateTime.now();
    return dob.year == now.year - 18 && dob.month == now.month && dob.day == now.day;
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await DatePickerUtils.pickDate(
      context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
      });
    }
  }

  void _showAuthorizationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authorization Confirmation'),
          content: const Text(
            'By checking this box, you confirm that:\n\n'
            '• You are the legal owner of this driving license\n'
            '• You have the authority to upload this document\n'
            '• All information provided is accurate and current\n'
            '• You consent to the processing of this data',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isAuthorized = true;
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        );
      },
    );
  }
  // ... existing code ...

  Widget _buildUploadCard(
    String label,
    File? file,
    String? imageUrl,
    VoidCallback onTap,
    VoidCallback onRemove,
    bool isFront, // Add isFront parameter to identify which image
  ) {
    return GestureDetector(
      onTap: (file == null && 
              ((isFront && _frontImageCleared) || 
               (!isFront && _backImageCleared) || 
               (imageUrl == null || imageUrl.isEmpty || !imageUrl.startsWith('http')))) ? onTap : null,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: (file == null && 
                  ((isFront && _frontImageCleared) || 
                   (!isFront && _backImageCleared) || 
                   (imageUrl == null || imageUrl.isEmpty || !imageUrl.startsWith('http'))))
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.upload_file,
                      size: 40,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Upload $label",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: file != null
                          ? Image.file(
                              file,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : (!_frontImageCleared && isFront && imageUrl != null && imageUrl.startsWith('http')) || 
                             (!_backImageCleared && !isFront && imageUrl != null && imageUrl.startsWith('http'))
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: Colors.grey.shade300,
                                    child: Icon(
                                      Icons.error,
                                      color: Colors.grey.shade600,
                                      size: 40,
                                    ),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey.shade300,
                                  child: Icon(
                                    Icons.upload_file,
                                    size: 40,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                    ),

                    // Label badge
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Remove cross
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                          padding: EdgeInsets.zero,
                          onPressed: onRemove,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ... existing code ...
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DrivingLicenseBloc, DrivingLicenseState>(
      builder: (context, state) {
        // You can also check for states like Loading, Loaded, Error etc.
        if (state is DrivingLicenseLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading driving license...',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is DrivingLicenseError) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(screenPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Driving License',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.red.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      onPressed: () => _loadDrivingLicense(),
                      text: 'Retry',
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is DrivingLicenseLoaded || state is DrivingLicenseSubmitted) {
          // Default UI - handle both loaded and submitted states
          final license = state is DrivingLicenseLoaded 
              ? state.license 
              : (state as DrivingLicenseSubmitted).license;
          
          // If no license exists, show empty form
          if (license == null) {
            return Scaffold(
              appBar: AppBar(),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Driving License',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please upload your driving license photos.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Show message for new users
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Please upload photos of your driving license.',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Front side DL image
                      _buildUploadCard(
                        "Front Side",
                        _frontImage,
                        null,
                        () => _pickImage(true),
                        () => _clearImage(true),
                        true, // isFront = true
                      ),
                      const SizedBox(height: 20),

                      // Back side DL image
                      _buildUploadCard(
                        "Back Side",
                        _backImage,
                        null,
                        () => _pickImage(false),
                        () => _clearImage(false),
                        false, // isFront = false
                      ),
                      const SizedBox(height: 20),

                      // Vehicle Type Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedVehicleType,
                                  hint: Text(
                                    "Select Vehicle Type",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  isExpanded: true,
                                  items: _vehicleTypes.map((String type) {
                                    return DropdownMenuItem<String>(
                                      value: type,
                                      child: Text(
                                        type,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedVehicleType = newValue;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // DOB Picker
                      GestureDetector(
                        onTap: _pickDob,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                                                          Text(
                              _dob != null
                                  ? DatePickerUtils.formatDate(_dob!, pattern: 'dd MMM, yyyy')
                                  : "Select Date of Birth",
                              style: const TextStyle(fontSize: 16),
                            ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Authorization Checkbox
                      Row(
                        children: [
                          Checkbox(
                            value: _isAuthorized,
                            onChanged: (bool? value) {
                              if (value == true) {
                                _showAuthorizationDialog();
                              } else {
                                setState(() {
                                  _isAuthorized = false;
                                });
                              }
                            },
                            activeColor: theme.primaryColor,
                          ),
                          Expanded(
                            child: Text(
                              'I am authorized to add this Driving Licence',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      PrimaryButton(
                        onPressed: _isAuthorized
                            ? () {
                                _saveDrivingLicense();
                              }
                            : () {
                                AppSnackBar.info(
                                  context,
                                  'Please check the authorization checkbox to Save',
                                );
                              },
                        text: "Save",
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          }
          
          return Scaffold(
            appBar: AppBar(),
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show success message if submitted
                    if (state is DrivingLicenseSubmitted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Driving license saved successfully!',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      'Driving License',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please upload your driving license photos.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    // Show verification status if license exists and has images
                    if ((license.frontImagePath.isNotEmpty && license.frontImagePath.startsWith('http')) || 
                        (license.backImagePath.isNotEmpty && license.backImagePath.startsWith('http')))
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        decoration: BoxDecoration(
                          color: _getVerificationStatusColor(license.verificationStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getVerificationStatusColor(license.verificationStatus).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getVerificationStatusIcon(license.verificationStatus),
                              color: _getVerificationStatusColor(license.verificationStatus),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Verification Status',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _getVerificationStatusColor(license.verificationStatus),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getVerificationStatusText(license.verificationStatus),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: _getVerificationStatusColor(license.verificationStatus),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 32),

                    // Show message for new users
                    if (license.frontImagePath.isEmpty && license.backImagePath.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Please upload photos of your driving license.',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Front side DL image
                    _buildUploadCard(
                      "Front Side",
                      _frontImage,
                      license.frontImagePath,
                      () => _pickImage(true),
                      () => _clearImage(true),
                      true, // isFront = true
                    ),
                    const SizedBox(height: 20),

                    // Back side DL image
                    _buildUploadCard(
                      "Back Side",
                      _backImage,
                      license.backImagePath,
                      () => _pickImage(false),
                      () => _clearImage(false),
                      false, // isFront = false
                    ),
                    const SizedBox(height: 20),

                    // Vehicle Type Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Colors.grey.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedVehicleType ?? 
                                       (license.licenseType.isNotEmpty ? license.licenseType : null),
                                hint: Text(
                                  "Select Vehicle Type",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                isExpanded: true,
                                items: _vehicleTypes.map((String type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(
                                      type,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedVehicleType = newValue;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DOB Picker
                    GestureDetector(
                      onTap: _pickDob,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _dob != null && !_isDefaultDob(_dob)
                                  ? DatePickerUtils.formatDate(_dob!, pattern: 'dd MMM, yyyy')
                                  : "Select Date of Birth",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Authorization Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isAuthorized,
                          onChanged: (bool? value) {
                            if (value == true) {
                              _showAuthorizationDialog();
                            } else {
                              setState(() {
                                _isAuthorized = false;
                              });
                            }
                          },
                          activeColor: theme.primaryColor,
                        ),
                        Expanded(
                          child: Text(
                            'I am authorized to add this Driving Licence',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    PrimaryButton(
                      onPressed: _isAuthorized
                          ? () {
                              _saveDrivingLicense();
                            }
                          : () {
                              AppSnackBar.info(
                                context,
                                'Please check the authorization checkbox to Save',
                              );
                            },
                      text: "Save",
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
