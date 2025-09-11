import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/app_bar_widget.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/verify_and_earn_screen.dart' show VerifyAndEarnScreen;
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/my_vehicle_details_insurance_image_widget.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/my_vehicle_details_slide_image_widget.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/my_vehicle_details_vehicle_image_widget.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/my_vehicle_details_vehicle_rc_image_widget.dart';

class MyVehicleDetailsScreen extends StatefulWidget {
  final String vehicleId;
  const MyVehicleDetailsScreen({super.key, required this.vehicleId});

  @override
  State<MyVehicleDetailsScreen> createState() => _MyVehicleDetailsScreenState();
}

class _MyVehicleDetailsScreenState extends State<MyVehicleDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadVehiclesIfNeeded();
  }

  void _loadVehiclesIfNeeded() {
    final state = context.read<VehicleBloc>().state;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (state is VehicleInitial && uid != null) {
      context.read<VehicleBloc>().add(LoadUserVehicles(uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is VehicleLoading || state is VehicleInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is VehicleError) return _buildError(state.message);
        if (state is VehicleLoaded) {
          try {
            final vehicle = state.vehicles.firstWhere(
              (v) => v.id == widget.vehicleId,
            );
            return _buildVehicleDetails(vehicle);
          } catch (e) {
            // Vehicle not found, likely deleted - navigate back
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.of(context).pop();
              }
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Scaffold _buildVehicleDetails(VehicleEntity vehicle) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBarWidget(
        title: "${vehicle.vehicleBrandName} ${vehicle.vehicleModelName}",
        centerTitle: false,
        leadingWidth: 24,
        actions: [
          IconButton(
            onPressed: () => _showOptions(vehicle),
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyVehicleDetailsSlideImageWidget(
              imageUrls: vehicle.vehicleSlideImages ?? [],
              vehicleId: vehicle.id,
              userId: uid,
              fieldName: 'vehicleSlideImages',
            ),
            MyVehicleDetailsVehicleImageWidget(
              frontImageUrl: vehicle.vehicleFrontImage,
              backImageUrl: vehicle.vehicleBackImage,
              vehicleId: vehicle.id,
              userId: uid,
              hideDeleteButton: vehicle.verificationStatus == VehicleVerificationStatus.pending ||
                  vehicle.verificationStatus == VehicleVerificationStatus.verified,
            ),
            MyVehicleDetailsInsuranceImageWidget(
              imageUrl: vehicle.vehicleInsuranceImage,
              vehicleId: vehicle.id,
              userId: uid,
              fieldName: 'vehicleInsuranceImage',
              hideDeleteButton: vehicle.verificationStatus == VehicleVerificationStatus.pending ||
                  vehicle.verificationStatus == VehicleVerificationStatus.verified,
            ),

            MyVehicleDetailsVehicleRcImageWidget(
              frontImageUrl: vehicle.vehicleRCFrontImage,
              backImageUrl: vehicle.vehicleRCBackImage,
              vehicleId: vehicle.id,
              userId: uid,
              hideDeleteButton: vehicle.verificationStatus == VehicleVerificationStatus.pending ||
                  vehicle.verificationStatus == VehicleVerificationStatus.verified,
            ),
            const SizedBox(height: 34),
            _buildVerificationSection(vehicle),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationSection(VehicleEntity vehicle) {
    switch (vehicle.verificationStatus) {
      case VehicleVerificationStatus.verified:
        return _buildVerifiedStatus();
      case VehicleVerificationStatus.pending:
        return _buildPendingStatus();
      case VehicleVerificationStatus.rejected:
        return _buildRejectedStatus(vehicle);
      case VehicleVerificationStatus.notVerified:
        return _buildNotVerifiedStatus(vehicle);
    }
  }

  Widget _buildVerifiedStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vehicle Verified!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your vehicle has been successfully verified. You can now earn rewards!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingStatus() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule,
            color: Colors.orange.shade600,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verification Pending',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your vehicle verification is under review. You will be notified once it\'s completed.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedStatus(VehicleEntity vehicle) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cancel,
                color: Colors.red.shade600,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Rejected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your vehicle verification was rejected. Please check your documents and try again.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: 'Resubmit for Verification',
          onPressed: () => _validateAndNavigateToVerifyAndEarn(vehicle),
        ),
      ],
    );
  }

  Widget _buildNotVerifiedStatus(VehicleEntity vehicle) {
    return PrimaryButton(
      text: 'Verify & Earn',
      onPressed: () => _validateAndNavigateToVerifyAndEarn(vehicle),
    );
  }

  void _validateAndNavigateToVerifyAndEarn(VehicleEntity vehicle) {
    final missingImages = _getMissingRequiredImages(vehicle);
    
    if (missingImages.isEmpty) {
      // All required images are present, navigate to VerifyAndEarnScreen
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => VerifyAndEarnScreen(vehicle: vehicle))
      );
    } else {
      // Show dialog with missing images
      _showMissingImagesDialog(missingImages);
    }
  }

  List<String> _getMissingRequiredImages(VehicleEntity vehicle) {
    final List<String> missingImages = [];
    
    if (vehicle.vehicleInsuranceImage == null || vehicle.vehicleInsuranceImage!.isEmpty) {
      missingImages.add('Insurance Image');
    }
    
    if (vehicle.vehicleFrontImage == null || vehicle.vehicleFrontImage!.isEmpty) {
      missingImages.add('Vehicle Front Image');
    }
    
    if (vehicle.vehicleBackImage == null || vehicle.vehicleBackImage!.isEmpty) {
      missingImages.add('Vehicle Back Image');
    }
    
    if (vehicle.vehicleRCFrontImage == null || vehicle.vehicleRCFrontImage!.isEmpty) {
      missingImages.add('Vehicle RC Front Image');
    }
    
    if (vehicle.vehicleRCBackImage == null || vehicle.vehicleRCBackImage!.isEmpty) {
      missingImages.add('Vehicle RC Back Image');
    }
    
    return missingImages;
  }

  void _showMissingImagesDialog(List<String> missingImages) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[600], size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Missing Required Images',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth: MediaQuery.of(context).size.width * 0.8,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please add the following images before proceeding to verification:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ...missingImages.map((image) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          image,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'You can add these images by tapping on the respective image sections above.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[700],
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Scaffold _buildError(String message) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadVehiclesIfNeeded,
            child: const Text('Retry'),
          ),
        ],
      ),
    ),
  );

  void _showOptions(VehicleEntity vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheet(vehicle),
    );
  }

  Widget _buildBottomSheet(VehicleEntity vehicle) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    child: SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Text(
              'Vehicle Options',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),
          ),
          _buildOptionItem(
            icon: Icons.delete,
            title: 'Delete Vehicle',
            subtitle: 'Permanently remove this vehicle',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(vehicle);
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              minimumSize: const Size.fromHeight(0),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );

  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey[400],
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(VehicleEntity vehicle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${vehicle.vehicleBrandName} ${vehicle.vehicleModelName}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                context.read<VehicleBloc>().add(DeleteVehicle(vehicle.id, uid));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
