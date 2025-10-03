import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/features/ride/presentation/screens/odometer_preview_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class OdometerCameraScreen extends StatefulWidget {
  final bool isBeforeRide;

  const OdometerCameraScreen({super.key, required this.isBeforeRide});

  @override
  State<OdometerCameraScreen> createState() => _OdometerCameraScreenState();
}

enum CameraState { loading, ready, error, unavailable }

class _OdometerCameraScreenState extends State<OdometerCameraScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  CameraState _state = CameraState.loading;
  String? _errorMessage;

  bool _isFlashOn = false;
  bool _hasFlash = false;
  bool _permissionDenied = false;

  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initCamera();
  }

  void _initAnimations() {
    _animController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnim = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _opacityAnim = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    setState(() => _state = CameraState.loading);

    if (!await _checkCameraPermission()) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        return _setError("No cameras available on this device.");
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
      _hasFlash = await _checkFlashAvailability();

      if (mounted) setState(() => _state = CameraState.ready);
    } catch (e) {
      _setError("Failed to initialize camera: $e");
    }
  }

  Future<bool> _checkCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) return true;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.camera.request();
      if (status.isGranted) return true;
    }

    _setError(
      status.isPermanentlyDenied
          ? "Camera permission permanently denied. Enable it in Settings."
          : "Camera permission required to take odometer photos.",
      permissionDenied: true,
    );
    return false;
  }

  Future<bool> _checkFlashAvailability() async {
    try {
      await _cameraController?.setFlashMode(FlashMode.torch);
      await _cameraController?.setFlashMode(FlashMode.off);
      return true;
    } catch (_) {
      return false;
    }
  }

  void _setError(String message, {bool permissionDenied = false}) {
    if (!mounted) return;
    setState(() {
      _state = CameraState.error;
      _errorMessage = message;
      _permissionDenied = permissionDenied;
    });
  }

  void _showSnack(String msg, {Color color = Colors.red}) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  Future<void> _toggleFlash() async {
    if (!(_cameraController?.value.isInitialized ?? false)) {
      return _showSnack("Camera not ready");
    }
    if (!_hasFlash) return _showSnack("Flash not available");

    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      setState(() {});
      _showSnack(
        _isFlashOn ? "Flash ON" : "Flash OFF",
        color: _isFlashOn ? Colors.orange : Colors.grey,
      );
    } catch (e) {
      _showSnack("Failed to toggle flash: $e");
    }
  }

  // ... previous imports and setup

  Future<void> _captureImage() async {
    if (!(_cameraController?.value.isInitialized ?? false))
      return _showSnack("Camera not ready");

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final image = await _cameraController!.takePicture();

      if (mounted) Navigator.pop(context);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OdometerPreviewScreen(
              imageFile: File(image.path),
              isBeforeRide: widget.isBeforeRide,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showSnack("Failed to capture image: $e");
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Go Extra Mile",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            // Return null to indicate user cancelled
            Navigator.pop(context, null);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: switch (_state) {
        CameraState.loading => _buildLoading(),
        CameraState.ready => _buildCameraView(),
        CameraState.error => _buildErrorState(),
        CameraState.unavailable => _buildUnavailable("Camera not available"),
      },
    );
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

  Widget _buildErrorState() => _ErrorView(
    errorMessage: _errorMessage!,
    permissionDenied: _permissionDenied,
    onRetry: _initCamera,
  );

  Widget _buildUnavailable(String msg) =>
      _ErrorView(errorMessage: msg, onRetry: _initCamera);

  Widget _buildCameraView() => Stack(
    fit: StackFit.expand,
    children: [
      CameraPreview(_cameraController!),
      _buildOdometerFrame(),
      _buildControls(),
    ],
  );

  Widget _buildOdometerFrame() => Align(
    alignment: Alignment.center,
    child: AnimatedBuilder(
      animation: _animController,
      builder: (_, __) => Transform.scale(
        scale: _scaleAnim.value,
        child: Opacity(
          opacity: _opacityAnim.value,
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

  Widget _buildControls() => Positioned(
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
          const SizedBox(width: 48),
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
          onPressed: _showHelpDialog,
        ),
      ],
    ),
  );

  void _showHelpDialog() {
    final instructions = [
      (
        Icons.leaderboard,
        "We use the odometer to show your ride on leaderboard and monetize your profile.",
        Colors.green,
      ),
      (
        Icons.camera_alt,
        "Align the odometer inside the frame and press the capture button.",
        Colors.blue,
      ),
    ];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue),
            SizedBox(width: 12),
            Text("Instructions", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var (icon, text, color) in instructions)
              _InstructionCard(icon: icon, text: text, color: color),
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
            child: const Text(
              "Got it!",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Error View
class _ErrorView extends StatelessWidget {
  final String errorMessage;
  final bool permissionDenied;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.errorMessage,
    required this.onRetry,
    this.permissionDenied = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              permissionDenied
                  ? Icons.camera_alt_outlined
                  : Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(errorMessage, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (permissionDenied) ...[
              ElevatedButton(
                onPressed: onRetry,
                child: const Text("Retry Permission"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: openAppSettings,
                child: const Text("Open Settings"),
              ),
            ] else
              ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text("Go Back"),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Instruction Card
class _InstructionCard extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InstructionCard({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
}
