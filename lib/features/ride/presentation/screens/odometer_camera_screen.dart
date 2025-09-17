import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../vehicle/domain/entities/vehicle_entiry.dart';
import '../../domain/entities/ride_entity.dart';
import 'odometer_preview_screen.dart';

enum OdometerType { beforeRide, afterRide }

class OdometerCameraScreen extends StatefulWidget {
  final VehicleEntity selectedVehicle;
  final RideEntity? rideEntity;
  final OdometerType odometerType;

  const OdometerCameraScreen({
    super.key, 
    required this.selectedVehicle,
    this.rideEntity,
    required this.odometerType,
  });

  @override
  State<OdometerCameraScreen> createState() => _OdometerCameraScreenState();
}

class _OdometerCameraScreenState extends State<OdometerCameraScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isFlashOn = false;
  bool _isLoading = true;
  String? _errorMessage;
  bool _permissionDenied = false;
  bool _hasFlash = false;

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initCamera();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.status;

      if (status.isDenied || status.isRestricted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          _setError(
            "Camera permission is required to take odometer photos.",
            permissionDenied: true,
          );
          return;
        }
      }

      if (status.isPermanentlyDenied) {
        _setError(
          "Camera permission has been permanently denied. Please enable it in Settings.",
          permissionDenied: true,
        );
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _setError("No cameras available on this device.");
        return;
      }

      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      // Check if device has flash capability
      _hasFlash = await _checkFlashAvailability();

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      _setError("Failed to initialize camera: $e");
    }
  }

  void _setError(String message, {bool permissionDenied = false}) {
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _errorMessage = message;
      _permissionDenied = permissionDenied;
    });
  }

  Future<bool> _checkFlashAvailability() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return false;
    }
    
    try {
      // Try to set flash mode to test availability
      await _cameraController!.setFlashMode(FlashMode.torch);
      await _cameraController!.setFlashMode(FlashMode.off);
      return true;
    } catch (e) {
      debugPrint("Flash not available: $e");
      return false;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera not ready"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (!_hasFlash) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Flash not available on this device"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      
      if (!mounted) return;
      setState(() {});
      
      // Show feedback to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFlashOn ? "Flash ON" : "Flash OFF"),
          duration: const Duration(milliseconds: 1000),
          backgroundColor: _isFlashOn ? Colors.orange : Colors.grey,
        ),
      );
    } catch (e) {
      // Revert flash state if setting failed
      _isFlashOn = !_isFlashOn;
      if (!mounted) return;
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to toggle flash: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _retryPermission() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _permissionDenied = false;
    });
    await _initCamera();
  }

  Future<void> _openSettings() async => openAppSettings();

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Camera not ready"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final image = await _cameraController!.takePicture();
      debugPrint("Captured image path: ${image.path}");
      
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      // Navigate to preview screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OdometerPreviewScreen(
              imagePath: image.path,
              selectedVehicle: widget.selectedVehicle,
              rideEntity: widget.rideEntity,
              odometerType: widget.odometerType,
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) Navigator.pop(context);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to capture image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Go Extra Mile", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return _buildLoading();
    if (_errorMessage != null) return _buildErrorState();
    if (_cameraController?.value.isInitialized ?? false) {
      return _buildCameraView();
    }
    return _buildCameraUnavailable();
  }

  Widget _buildLoading() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Initializing camera..."),
          ],
        ),
      );

  Widget _buildErrorState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _permissionDenied
                    ? Icons.camera_alt_outlined
                    : Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (_permissionDenied) ...[
                _buildPermissionButton("Retry Permission", _retryPermission),
                const SizedBox(height: 12),
                _buildPermissionButton("Open Settings", _openSettings),
              ] else
                _buildPermissionButton("Retry", _retryPermission),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Go Back"),
              ),
            ],
          ),
        ),
      );

  Widget _buildPermissionButton(String text, VoidCallback onPressed) =>
      ElevatedButton(onPressed: onPressed, child: Text(text));

  Widget _buildCameraUnavailable() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text("Camera not available"),
          ],
        ),
      );

  Widget _buildCameraView() => Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_cameraController!),
          _buildOdometerFrame(),
          _buildCaptureControls(context),
        ],
      );

  Widget _buildOdometerFrame() => Align(
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, _) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.height * 0.25,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    "Align Odometer Here",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          offset: Offset(2, 2),
                          blurRadius: 4,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildCaptureControls(BuildContext context) => Positioned(
        bottom: 40,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_hasFlash)
              IconButton(
                icon: Icon(
                  _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  color: _isFlashOn ? Colors.orange : Colors.white,
                  size: 30,
                ),
                onPressed: _toggleFlash,
              )
            else
              const SizedBox(width: 48), // Maintain spacing when flash is not available
            const SizedBox(width: 40),
            GestureDetector(
              onTap: _captureImage,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.black, size: 32),
              ),
            ),
            const SizedBox(width: 40),
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.white, size: 30),
              onPressed: () => _showHelpDialog(context),
            ),
          ],
        ),
      );

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.blue),
            const SizedBox(width: 12),
            const Text("Instructions",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildInstructionCard(
              Icons.leaderboard,
              "We use the odometer to show your ride on leaderboard and monetize your profile.",
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildInstructionCard(
              Icons.camera_alt,
              "Align the odometer inside the frame and press the capture button.",
              Colors.blue,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Got it!", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard(IconData icon, String text, Color color) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          ],
        ),
      );
}