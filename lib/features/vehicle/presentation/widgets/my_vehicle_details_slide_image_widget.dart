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

class MyVehicleDetailsSlideImageWidget extends StatefulWidget {
  final List<String> imageUrls;
  final String vehicleId, userId, fieldName;

  const MyVehicleDetailsSlideImageWidget({
    super.key,
    required this.imageUrls,
    required this.vehicleId,
    required this.userId,
    required this.fieldName,
  });

  @override
  State<MyVehicleDetailsSlideImageWidget> createState() =>
      _MyVehicleDetailsSlideImageWidgetState();
}

class _MyVehicleDetailsSlideImageWidgetState
    extends State<MyVehicleDetailsSlideImageWidget> {
  int _currentIndex = 0;
  final _pageController = PageController();
  final _picker = ImagePicker();

  late List<String> _localImageUrls;
  bool _isUpdating = false, _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _localImageUrls = List.from(widget.imageUrls);
  }

  bool _isLocalFile(String path) => !path.startsWith('http');

  void _resetIndex() {
    _currentIndex = _currentIndex >= _localImageUrls.length
        ? (_localImageUrls.isEmpty ? 0 : _localImageUrls.length - 1)
        : _currentIndex;
    if (_pageController.hasClients) _pageController.jumpToPage(_currentIndex);
  }

  Future<void> _pickImageFromGallery() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _localImageUrls.add(file.path));
      
      // Auto-upload the selected image
      _autoUploadImage(file);
    }
  }

  void _deleteCurrentImage() {
    if (_localImageUrls.isEmpty) return;

    final img = _localImageUrls[_currentIndex];
    if (_isLocalFile(img)) {
      setState(() {
        _localImageUrls.removeAt(_currentIndex);
        _resetIndex();
      });
    } else {
      setState(() => _isDeleting = true);
      context.read<VehicleBloc>().add(
        DeleteVehicleImage(
          widget.vehicleId,
          widget.userId,
          widget.fieldName,
          img,
        ),
      );
    }
  }

  void _autoUploadImage(XFile file) {
    setState(() => _isUpdating = true);

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
            _localImageUrls = vehicle?.vehicleSlideImages ?? [];
            _resetIndex();
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
              PageView.builder(
                controller: _pageController,
                itemCount: _localImageUrls.length + 1,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  if (index == _localImageUrls.length) {
                    return GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.add, size: 50, color: Colors.blue),
                              SizedBox(height: 8),
                              Text(
                                "Add Vehicle Slide",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return _buildImage(_localImageUrls[index]);
                },
              ),

              if (_localImageUrls.isNotEmpty) ...[
                Positioned(
                  top: 12,
                  left: 12,
                  child: _overlayLabel("Vehicle Slides"),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: _overlayLabel(
                    "${_currentIndex + 1} / ${_localImageUrls.length + 1}",
                  ),
                ),
                if (_currentIndex < _localImageUrls.length)
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
