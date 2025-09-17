import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';

class MyVehicleDetailsInsuranceImageWidget extends StatefulWidget {
  final String? imageUrl;
  final String vehicleId, userId, fieldName;
  final bool hideDeleteButton;

  const MyVehicleDetailsInsuranceImageWidget({
    super.key,
    this.imageUrl,
    required this.vehicleId,
    required this.userId,
    required this.fieldName,
    this.hideDeleteButton = false,
  });

  @override
  State<MyVehicleDetailsInsuranceImageWidget> createState() =>
      _MyVehicleDetailsInsuranceImageWidgetState();
}

class _MyVehicleDetailsInsuranceImageWidgetState
    extends State<MyVehicleDetailsInsuranceImageWidget> {
  final _picker = ImagePicker();
  String? _localImageUrl;
  bool _isUpdating = false, _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _localImageUrl = widget.imageUrl;
  }

  bool _isLocalFile(String path) => !path.startsWith('http');

  Future<void> _pickImageFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _localImageUrl = file.path);
      
      // Auto-upload the selected image
      _autoUploadImage(file);
    }
  }

  void _deleteCurrentImage() {
    if (_localImageUrl == null) return;

    if (_isLocalFile(_localImageUrl!)) {
      setState(() => _localImageUrl = null);
    } else {
      setState(() => _isDeleting = true);
      context.read<VehicleBloc>().add(
        DeleteVehicleImage(
          widget.vehicleId,
          widget.userId,
          widget.fieldName,
          _localImageUrl!,
        ),
      );
    }
  }

  void _autoUploadImage(XFile file) {
    setState(() => _isUpdating = true);

    // Delete the original image if it exists
    if (widget.imageUrl != null) {
      context.read<VehicleBloc>().add(
        DeleteVehicleImage(
          widget.vehicleId,
          widget.userId,
          widget.fieldName,
          widget.imageUrl!,
        ),
      );
    }

    // Upload the new image
    context.read<VehicleBloc>().add(
      UploadVehicleImage(
        widget.vehicleId,
        widget.userId,
        File(file.path),
        widget.fieldName,
      ),
    );
  }


  Widget _overlayLabel(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _buildImage(String img) => _isLocalFile(img)
      ? Image.file(File(img), fit: BoxFit.cover)
      : CachedNetworkImage(
          imageUrl: img,
          fit: BoxFit.cover,
          placeholder: (c, _) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(color: Colors.grey.shade300),
          ),
          errorWidget: (_, __, ___) =>
              const Icon(Icons.error, color: Colors.red),
        );

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state is VehicleLoaded) {
          final vehicle = state.vehicles.cast<VehicleEntity?>().firstWhere(
            (v) => v?.id == widget.vehicleId,
            orElse: () => state.vehicles.first,
          );
          setState(() {
            _isUpdating = _isDeleting = false;
            _localImageUrl = vehicle?.vehicleInsuranceImage;
          });
        } else if (state is VehicleError) {
          setState(() => _isUpdating = _isDeleting = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${state.message}")));
        }
      },
      child: AspectRatio(
        aspectRatio: 16 / 12,
        child: Container(
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
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              GestureDetector(
                onTap: _localImageUrl == null ? _pickImageFromGallery : null,
                child: _localImageUrl == null
                    ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 50, color: Colors.blue),
                              SizedBox(height: 8),
                              Text(
                                "Add Insurance Image",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: _buildImage(_localImageUrl!),
                      ),
              ),

              if (_localImageUrl != null) ...[
                Positioned(
                  top: 12,
                  left: 12,
                  child: _overlayLabel("Insurance Image"),
                ),
                if (!widget.hideDeleteButton)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: _deleteCurrentImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.delete,
                                size: 18,
                                color: Colors.white,
                              ),
                      ),
                    ),
                  ),
              ],


              if (_isUpdating)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
