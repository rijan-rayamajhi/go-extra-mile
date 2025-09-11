import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/core/utils/image_picker_utils.dart';
import 'package:go_extra_mile_new/core/utils/date_picker_utils.dart';
import 'package:go_extra_mile_new/features/license/domain/entities/driving_license.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_bloc.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_event.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_state.dart';

class MyDrivingLicenseScreen extends StatefulWidget {
  const MyDrivingLicenseScreen({super.key});

  @override
  State<MyDrivingLicenseScreen> createState() => _MyDrivingLicenseScreenState();
}

class _MyDrivingLicenseScreenState extends State<MyDrivingLicenseScreen> {
  File? _frontImage, _backImage;
  DateTime? _dob;
  String? _selectedVehicleType;
  bool _isAuthorized = false;
  bool _frontCleared = false, _backCleared = false;

  final _vehicleTypes = ['2 Wheeler', '4 Wheeler', '2 & 4 Wheeler'];

  @override
  void initState() {
    context.read<DrivingLicenseBloc>().add(GetDrivingLicenseEvent());
    super.initState();
  }

  DrivingLicenseEntity? _getCurrentLicense(DrivingLicenseState state) {
    if (state is DrivingLicenseLoaded) return state.license;
    if (state is DrivingLicenseSubmitted) return state.license;
    return null;
  }

  // ----------------- IMAGE HANDLING -----------------
  Future<void> _pickImage(bool isFront) async {
    try {
      final file = await ImagePickerUtils.pickAndCropImage(
        context: context,
        maxSizeInMB: 5,
        imageQuality: 80,
        cropStyle: CropStyle.rectangle,
      );
      if (file != null) {
        setState(() {
          if (isFront) {
            _frontImage = file;
            _frontCleared = false;
          } else {
            _backImage = file;
            _backCleared = false;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(context, 'Error: ${e.toString()}');
      }
    }
  }

  void _clearImage(bool isFront) {
    setState(() {
      if (isFront) {
        _frontImage = null;
        _frontCleared = true;
      } else {
        _backImage = null;
        _backCleared = true;
      }
    });
  }

  // ----------------- LICENSE SAVE -----------------
  void _saveLicense(DrivingLicenseEntity? old) {
    final hasFront =
        _frontImage != null ||
        (old?.frontImagePath.startsWith('http') == true && !_frontCleared);
    final hasBack =
        _backImage != null ||
        (old?.backImagePath.startsWith('http') == true && !_backCleared);

    if (!hasFront || !hasBack || _selectedVehicleType == null || _dob == null) {
      AppSnackBar.info(context, 'Please fill all required fields');
      return;
    }

    final license = DrivingLicenseEntity(
      licenseType: _selectedVehicleType ?? old?.licenseType ?? '',
      dob: _dob ?? old?.dob ?? DateTime.now(),
      frontImagePath:
          _frontImage?.path ?? (hasFront ? old?.frontImagePath ?? '' : ''),
      backImagePath:
          _backImage?.path ?? (hasBack ? old?.backImagePath ?? '' : ''),
    );

    context.read<DrivingLicenseBloc>().add(SubmitDrivingLicenseEvent(license));
  }

  // ----------------- HELPERS -----------------
  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await DatePickerUtils.pickDate(
      context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _confirmAuthorization() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Authorization Confirmation'),
        content: const Text(
          'By confirming you acknowledge:\n\n'
          '• You are the license owner\n'
          '• Information is correct\n'
          '• You consent to processing',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _isAuthorized = true);
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  // Verification UI helpers
  final _statusData = {
    DrivingLicenseVerificationStatus.pending: {
      'color': Colors.orange,
      'icon': Icons.schedule,
      'text': 'Pending Review',
    },
    DrivingLicenseVerificationStatus.rejected: {
      'color': Colors.red,
      'icon': Icons.cancel,
      'text': 'Rejected',
    },
    DrivingLicenseVerificationStatus.verified: {
      'color': Colors.green,
      'icon': Icons.verified,
      'text': 'Verified',
    },
  };

  bool _isEditingDisabled(DrivingLicenseVerificationStatus s) =>
      s == DrivingLicenseVerificationStatus.pending ||
      s == DrivingLicenseVerificationStatus.verified;

  // ----------------- WIDGETS -----------------
  Widget _buildUploadCard(
    String label,
    File? file,
    String? url,
    bool isFront,
    bool disabled,
  ) {
    final showUpload =
        file == null &&
        ((isFront && _frontCleared) ||
            (!isFront && _backCleared) ||
            url?.startsWith('http') != true);

    return GestureDetector(
      onTap: !disabled && showUpload ? () => _pickImage(isFront) : null,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 200,
          maxHeight: 400,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade100,
        ),
        child: showUpload
            ? _buildUploadPlaceholder(label)
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: file != null
                        ? Image.file(
                            file, 
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                          )
                        : CachedNetworkImage(
                            imageUrl: url ?? '',
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            placeholder: (_, __) => Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(color: Colors.grey.shade300),
                            ),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.error, size: 40),
                          ),
                  ),
                  _buildLabelBadge(label),
                  if (!disabled)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                          onPressed: () => _clearImage(isFront),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildUploadPlaceholder(String label) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.upload_file, size: 40, color: Colors.grey.shade600),
        const SizedBox(height: 8),
        Text(
          "Upload $label",
          style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
        ),
      ],
    ),
  );

  Widget _buildLabelBadge(String label) => Positioned(
    bottom: 8,
    left: 8,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );

  Widget _buildInfoBox(Color color, IconData icon, String text) => Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      border: Border.all(color: color.withValues(alpha: .3)),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  // ----------------- BUILD -----------------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<DrivingLicenseBloc, DrivingLicenseState>(
      builder: (context, state) {
        if (state is DrivingLicenseLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is DrivingLicenseError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade400,
                    size: 60,
                  ),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    onPressed: () {
                      context.read<DrivingLicenseBloc>().add(
                        GetDrivingLicenseEvent(),
                      );
                    },
                    text: 'Retry',
                  ),
                ],
              ),
            ),
          );
        }

        final license = _getCurrentLicense(state);
        final disabled =
            license != null && _isEditingDisabled(license.verificationStatus);

        return Scaffold(
          appBar: AppBar(title: const Text("Driving License")),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(baseScreenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state is DrivingLicenseSubmitted)
                  _buildInfoBox(
                    Colors.green,
                    Icons.check_circle,
                    "Driving license saved successfully!",
                  ),

                _buildUploadCard(
                  "Front Side",
                  _frontImage,
                  license?.frontImagePath,
                  true,
                  disabled,
                ),
                const SizedBox(height: 16),
                _buildUploadCard(
                  "Back Side",
                  _backImage,
                  license?.backImagePath,
                  false,
                  disabled,
                ),
                const SizedBox(height: 20),

                // Vehicle type dropdown
                _buildDropdown(theme, license, disabled),
                const SizedBox(height: 20),

                // DOB picker
                _buildDobPicker(disabled, license),
                const SizedBox(height: 20),

                // Verification status
                if (license != null &&
                    (license.frontImagePath.isNotEmpty ||
                        license.backImagePath.isNotEmpty))
                  _buildInfoBox(
                    _statusData[license.verificationStatus]!['color'] as Color,
                    _statusData[license.verificationStatus]!['icon']
                        as IconData,
                    _statusData[license.verificationStatus]!['text'] as String,
                  ),

                if (!disabled) ...[
                  Row(
                    children: [
                      Checkbox(
                        value: _isAuthorized,
                        onChanged: (v) => v == true
                            ? _confirmAuthorization()
                            : setState(() => _isAuthorized = false),
                      ),
                      const Expanded(
                        child: Text(
                          "I am authorized to add this Driving Licence",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    onPressed: _isAuthorized
                        ? () => _saveLicense(license)
                        : () {
                            AppSnackBar.info(
                              context,
                              "Please authorize before saving",
                            );
                          },
                    text: "Save",
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown(
    ThemeData theme,
    DrivingLicenseEntity? license,
    bool disabled,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: disabled ? Colors.grey.shade200 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedVehicleType ?? license?.licenseType,
          hint: const Text("Select Vehicle Type"),
          isExpanded: true,
          items: _vehicleTypes
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: disabled
              ? null
              : (v) => setState(() => _selectedVehicleType = v),
        ),
      ),
    );
  }

  Widget _buildDobPicker(bool disabled, DrivingLicenseEntity? license) {
    final effectiveDob = _dob ?? license?.dob;
    return GestureDetector(
      onTap: disabled ? null : _pickDob,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: disabled ? Colors.grey.shade200 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            Text(
              effectiveDob != null
                  ? DatePickerUtils.formatDate(
                      effectiveDob,
                      pattern: 'dd MMM, yyyy',
                    )
                  : "Select Date of Birth",
            ),
          ],
        ),
      ),
    );
  }
}
