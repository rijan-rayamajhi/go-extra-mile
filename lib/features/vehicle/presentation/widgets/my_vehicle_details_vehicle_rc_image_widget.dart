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

class MyVehicleDetailsVehicleRcImageWidget extends StatefulWidget {
  final String? frontImageUrl;
  final String? backImageUrl;
  final String vehicleId, userId;
  final bool hideDeleteButton;

  const MyVehicleDetailsVehicleRcImageWidget({
    super.key,
    this.frontImageUrl,
    this.backImageUrl,
    required this.vehicleId,
    required this.userId,
    this.hideDeleteButton = false,
  });

  @override
  State<MyVehicleDetailsVehicleRcImageWidget> createState() =>
      _MyVehicleDetailsVehicleRcImageWidgetState();
}

class _MyVehicleDetailsVehicleRcImageWidgetState
    extends State<MyVehicleDetailsVehicleRcImageWidget> {
  final _picker = ImagePicker();
  String? _localFrontImageUrl;
  String? _localBackImageUrl;
  bool _isUpdating = false, _isDeleting = false;
  String? _updatingImageType;
  String? _deletingImageType;

  @override
  void initState() {
    super.initState();
    _localFrontImageUrl = widget.frontImageUrl;
    _localBackImageUrl = widget.backImageUrl;
  }

  bool _isLocalFile(String path) => !path.startsWith('http');

  Future<void> _pickImageFromGallery(String imageType) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        if (imageType == 'front') {
          _localFrontImageUrl = file.path;
        } else {
          _localBackImageUrl = file.path;
        }
      });
    }
  }

  void _deleteImage(String imageType) {
    if (imageType == 'front' && _localFrontImageUrl == null) return;
    if (imageType == 'back' && _localBackImageUrl == null) return;

    final imageUrl = imageType == 'front' ? _localFrontImageUrl! : _localBackImageUrl!;
    final fieldName = imageType == 'front' ? 'vehicleRcFrontImage' : 'vehicleRcBackImage';

    if (_isLocalFile(imageUrl)) {
      setState(() {
        if (imageType == 'front') {
          _localFrontImageUrl = null;
        } else {
          _localBackImageUrl = null;
        }
      });
    } else {
      setState(() {
        _isDeleting = true;
        _deletingImageType = imageType;
      });
      context.read<VehicleBloc>().add(
        DeleteVehicleImage(
          widget.vehicleId,
          widget.userId,
          fieldName,
          imageUrl,
        ),
      );
    }
  }

  void _commitChanges(String imageType) {
    setState(() {
      _isUpdating = true;
      _updatingImageType = imageType;
    });

    final isFront = imageType == 'front';
    final localImageUrl = isFront ? _localFrontImageUrl : _localBackImageUrl;
    final fieldName = isFront ? 'vehicleRCFrontImage' : 'vehicleRCBackImage';
    final originalImageUrl = isFront ? widget.frontImageUrl : widget.backImageUrl;

    // Upload image if it's local
    if (localImageUrl != null && _isLocalFile(localImageUrl)) {
      context.read<VehicleBloc>().add(
        UploadVehicleImage(
          widget.vehicleId,
          widget.userId,
          File(localImageUrl),
          fieldName,
        ),
      );
    }

    // Delete removed image
    if (originalImageUrl != null && 
        (localImageUrl == null || localImageUrl != originalImageUrl)) {
      context.read<VehicleBloc>().add(
        DeleteVehicleImage(
          widget.vehicleId,
          widget.userId,
          fieldName,
          originalImageUrl,
        ),
      );
    }
  }

  bool _showUpdateButton(String imageType) {
    final localImageUrl = imageType == 'front' ? _localFrontImageUrl : _localBackImageUrl;
    return localImageUrl != null && 
           _isLocalFile(localImageUrl) && 
           _updatingImageType != imageType;
  }

  bool _isImageUpdating(String imageType) {
    return _isUpdating && _updatingImageType == imageType;
  }

  bool _isImageDeleting(String imageType) {
    return _isDeleting && _deletingImageType == imageType;
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

  Widget _buildImageContainer(String imageType, String? imageUrl) {
    final isFront = imageType == 'front';
    final label = isFront ? 'Front' : 'Back';
    final addLabel = isFront ? 'Add RC Front Image' : 'Add RC Back Image';
    
    return Expanded(
      child: Container(
        margin: EdgeInsets.only(
          right: isFront ? 8 : 0,
          left: isFront ? 0 : 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
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
              onTap: imageUrl == null ? () => _pickImageFromGallery(imageType) : null,
              child: imageUrl == null
                  ? Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.grey.shade200,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, size: 30, color: Colors.blue),
                            const SizedBox(height: 4),
                            Text(
                              addLabel,
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: _buildImage(imageUrl),
                    ),
            ),

            if (imageUrl != null) ...[
              Positioned(
                top: 8,
                left: 8,
                child: _overlayLabel("RC $label"),
              ),
              if (!widget.hideDeleteButton)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _isImageDeleting(imageType) ? null : () => _deleteImage(imageType),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _isImageDeleting(imageType) 
                            ? Colors.grey.shade600 
                            : Colors.red.shade600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _isImageDeleting(imageType)
                          ? const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.delete,
                              size: 14,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
              if (_showUpdateButton(imageType) || _isImageUpdating(imageType))
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _isImageUpdating(imageType) ? null : () => _commitChanges(imageType),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _isImageUpdating(imageType) 
                            ? Colors.grey.shade600 
                            : Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: _isImageUpdating(imageType)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(
                              Icons.save,
                              size: 16,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

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
            _updatingImageType = null;
            _deletingImageType = null;
            _localFrontImageUrl = vehicle?.vehicleRCFrontImage;
            _localBackImageUrl = vehicle?.vehicleRCBackImage;
          });
        } else if (state is VehicleError) {
          setState(() {
            _isUpdating = _isDeleting = false;
            _updatingImageType = null;
            _deletingImageType = null;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${state.message}")));
        }
      },
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 8,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  _buildImageContainer('front', _localFrontImageUrl),
                  _buildImageContainer('back', _localBackImageUrl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}