import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../vehicle/domain/entities/vehicle_entiry.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/entities/odometer_entity.dart';
import 'ride_screen.dart';
import 'odometer_camera_screen.dart';
import 'save_ride_screen.dart';
import '../../../../core/service/firebase_storage_service.dart';
import 'package:uuid/uuid.dart';

class OdometerPreviewScreen extends StatefulWidget {
  final String imagePath;
  final VehicleEntity selectedVehicle;
  final RideEntity? rideEntity;
  final OdometerType odometerType;

  const OdometerPreviewScreen({
    super.key,
    required this.imagePath,
    required this.selectedVehicle,
    this.rideEntity,
    required this.odometerType,
  });

  @override
  State<OdometerPreviewScreen> createState() => _OdometerPreviewScreenState();
}

class _OdometerPreviewScreenState extends State<OdometerPreviewScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUploading = false;
  final FirebaseStorageService _storageService = GetIt.instance<FirebaseStorageService>();

  @override
  void initState() {
    super.initState();
    _validateImage();
  }

  void _validateImage() {
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text("Odometer Preview",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(Icons.help_outline, color: Colors.black87),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading
            ? _buildLoading()
            : _errorMessage != null
            ? _buildErrorState()
            : _buildPreviewContent(),
      ),
    );
  }

  Widget _buildLoading() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(strokeWidth: 2),
        SizedBox(height: 12),
        Text(
          "Processing image...",
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    ),
  );

  Widget _buildErrorState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
        const SizedBox(height: 16),
        Text(
          _errorMessage ?? "Failed to process image",
          style: const TextStyle(fontSize: 15),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Go Back"),
        ),
      ],
    ),
  );

  Widget _buildPreviewContent() => Column(
    children: [
      Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => _buildImageError(),
                  ),
                ),
                _buildImageOverlay(),
              ],
            ),
          ),
        ),
      ),
      _buildVehicleInfo(),
      _buildActionButtons(),
    ],
  );

  Widget _buildImageError() => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.broken_image, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Text("Couldn’t load image", style: TextStyle(color: Colors.black54)),
      ],
    ),
  );

  Widget _buildImageOverlay() => Positioned(
    top: 16,
    left: 16,
    right: 16,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.odometerType == OdometerType.beforeRide
                ? "Before Ride Odometer"
                : "After Ride Odometer",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getCaptureTime(),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    ),
  );

  String _getCaptureTime() {
    final now = DateTime.now();
    final timeString =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final dateString = "${now.day}/${now.month}/${now.year}";
    return "Captured on $dateString at $timeString";
  }

  Widget _buildVehicleInfo() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      children: [
        // Vehicle Image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildVehicleImage(),
          ),
        ),
        const SizedBox(width: 16),
        // Vehicle Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.selectedVehicle.vehicleBrandName} ${widget.selectedVehicle.vehicleModelName}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.selectedVehicle.vehicleRegistrationNumber,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildVehicleImage() {
    // Try to get vehicle front image first, then brand image as fallback
    String imageUrl =
        widget.selectedVehicle.vehicleFrontImage ??
        widget.selectedVehicle.vehicleBrandImage;

    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildVehicleImagePlaceholder(),
      );
    }

    return _buildVehicleImagePlaceholder();
  }

  Widget _buildVehicleImagePlaceholder() => Container(
    color: Colors.grey[200],
    child: const Icon(
      Icons.directions_car_outlined,
      color: Colors.grey,
      size: 30,
    ),
  );

  Widget _buildActionButtons() => Container(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isUploading ? null : _retakePhoto,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: Colors.black12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Retake"),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isUploading ? null : _confirmPhoto,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: _isUploading ? Colors.grey : Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: _isUploading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text("Confirm"),
          ),
        ),
      ],
    ),
  );

  void _retakePhoto() => Navigator.pop(context);

  Future<void> _confirmPhoto() async {
    if (_isUploading) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Generate unique file path for Firebase Storage
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final odometerType = widget.odometerType == OdometerType.beforeRide ? 'before' : 'after';
      final fileExtension = widget.imagePath.split('.').last;
      final storagePath = 'odometer_images/${widget.selectedVehicle.id}/${odometerType}_${timestamp}.$fileExtension';

      // Upload image to Firebase Storage
      final imageUrl = await _storageService.uploadFile(
        file: File(widget.imagePath),
        path: storagePath,
        metadata: SettableMetadata(
          contentType: 'image/$fileExtension',
          customMetadata: {
            'vehicleId': widget.selectedVehicle.id,
            'odometerType': odometerType,
            'timestamp': timestamp.toString(),
          },
        ),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Odometer photo uploaded successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate based on odometer type with the uploaded image URL
      if (widget.odometerType == OdometerType.beforeRide) {
        // Before ride: navigate to RideScreen with odometer image URL
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RideScreen(
              selectedVechile: widget.selectedVehicle,
              beforeRideOdometerImage: imageUrl, // Use URL instead of local path
            ),
          ),
        );
      } else {
        // After ride: update ride entity with after ride odometer image URL and navigate to SaveRideScreen
        if (widget.rideEntity != null) {
          final updatedRideEntity = RideEntity(
            id: widget.rideEntity!.id,
            userId: widget.rideEntity!.userId,
            vehicleId: widget.rideEntity!.vehicleId,
            status: widget.rideEntity!.status,
            startedAt: widget.rideEntity!.startedAt,
            startCoordinates: widget.rideEntity!.startCoordinates,
            endCoordinates: widget.rideEntity!.endCoordinates,
            endedAt: widget.rideEntity!.endedAt,
            totalDistance: widget.rideEntity!.totalDistance,
            totalTime: widget.rideEntity!.totalTime,
            totalGEMCoins: widget.rideEntity!.totalGEMCoins,
            rideMemories: widget.rideEntity!.rideMemories,
            rideTitle: widget.rideEntity!.rideTitle,
            rideDescription: widget.rideEntity!.rideDescription,
            topSpeed: widget.rideEntity!.topSpeed,
            averageSpeed: widget.rideEntity!.averageSpeed,
            routePoints: widget.rideEntity!.routePoints,
            isPublic: widget.rideEntity!.isPublic,
            odometer: OdometerEntity(
              id: widget.rideEntity!.odometer?.id ?? const Uuid().v4(),
              beforeRideOdometerImage: widget.rideEntity!.odometer?.beforeRideOdometerImage,
              beforeRideOdometerImageCaptureAt: widget.rideEntity!.odometer?.beforeRideOdometerImageCaptureAt,
              afterRideOdometerImage: imageUrl, // Use URL instead of local path
              afterRideOdometerImageCaptureAt: DateTime.now(),
              verificationStatus: widget.rideEntity!.odometer?.verificationStatus ?? OdometerVerificationStatus.pending,
              reasons: widget.rideEntity!.odometer?.reasons,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SaveRideScreen(
                rideEntity: updatedRideEntity,
                selectedVehicle: widget.selectedVehicle,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // Handle upload error
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to upload image: ${e.toString()}"),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: "Retry",
            textColor: Colors.white,
            onPressed: _confirmPhoto,
          ),
        ),
      );
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Preview Instructions",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInstructionTile(
              Icons.visibility_outlined,
              "Check if the odometer reading is clear and visible.",
            ),
            _buildInstructionTile(
              Icons.refresh_outlined,
              "Tap Retake if it’s not clear.",
            ),
            _buildInstructionTile(
              Icons.check_circle_outline,
              "Tap Confirm if it looks correct.",
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionTile(IconData icon, String text) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon, color: Colors.black87),
    title: Text(text, style: const TextStyle(fontSize: 14)),
  );
}
