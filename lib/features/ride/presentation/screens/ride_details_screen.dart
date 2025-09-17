// ride_details_screen.dart
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';

import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/core/di/injection_container.dart';
import 'package:go_extra_mile_new/core/service/location_service.dart' as location_service;
import 'package:go_extra_mile_new/features/ride/domain/entities/ride_entity.dart';
import 'package:go_extra_mile_new/features/ride/domain/entities/odometer_entity.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_section.dart';
import 'package:go_extra_mile_new/features/ride/presentation/widgets/save_ride_info_row.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/repositories/vehicle_repository.dart';

class RideDetailsScreen extends StatefulWidget {
  final RideEntity ride;
  const RideDetailsScreen({super.key, required this.ride});

  @override
  State<RideDetailsScreen> createState() => _RideDetailsScreenState();
}

class _RideDetailsScreenState extends State<RideDetailsScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final location_service.LocationService _locationService = location_service.LocationService();

  List<LatLng> _routePoints = [];
  String? _startAddress;
  String? _endAddress;
  bool _isLoadingAddresses = false;

  VehicleEntity? _vehicle;
  bool _isLoadingVehicle = false;
  bool _vehicleNotFound = false;

  @override
  void initState() {
    super.initState();

    // populate route points from ride (defensive: handle null)
    if (widget.ride.routePoints != null && widget.ride.routePoints!.isNotEmpty) {
      _routePoints = widget.ride.routePoints!
          .map((p) => LatLng(p.latitude, p.longitude))
          .toList();
    }

    // Load both in parallel
    Future.wait([
      _loadAddresses(),
      _loadVehicle(),
    ]);
  }

  Future<void> _loadAddresses() async {
    if (!mounted) return;
    setState(() => _isLoadingAddresses = true);
    try {
      final start = await _locationService.getFormattedAddressFromCoordinates(
        widget.ride.startCoordinates.latitude,
        widget.ride.startCoordinates.longitude,
      );

      String? end;
      if (widget.ride.endCoordinates != null) {
        end = await _locationService.getFormattedAddressFromCoordinates(
          widget.ride.endCoordinates!.latitude,
          widget.ride.endCoordinates!.longitude,
        );
      }

      if (!mounted) return;
      setState(() {
        _startAddress = start;
        _endAddress = end;
        _isLoadingAddresses = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _loadVehicle() async {
    if (!mounted) return;
    setState(() {
      _isLoadingVehicle = true;
      _vehicleNotFound = false;
    });

    try {
      final repo = sl<VehicleRepository>();
      final result = await repo.getUserVehicles(widget.ride.userId);

      result.fold(
        (failure) {
          if (!mounted) return;
          setState(() {
            _vehicleNotFound = true;
            _isLoadingVehicle = false;
          });
        },
        (vehicles) {
          if (!mounted) return;
          try {
            final found = vehicles.firstWhere((v) => v.id == widget.ride.vehicleId);
            setState(() {
              _vehicle = found;
              _isLoadingVehicle = false;
            });
          } catch (e) {
            setState(() {
              _vehicleNotFound = true;
              _isLoadingVehicle = false;
            });
          }
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _vehicleNotFound = true;
        _isLoadingVehicle = false;
      });
    }
  }

  String _formatSpeed(double? speed) {
    if (speed == null || speed.isNaN || speed.isInfinite || speed <= 0) {
      return "0.0 km/h";
    }
    return "${speed.toStringAsFixed(1)} km/h";
  }

  LatLngBounds _computeBounds(List<LatLng> points) {
    if (points.isEmpty) {
      // default to Bangalore if no points
      return LatLngBounds(
        southwest: const LatLng(12.9716, 77.5946),
        northeast: const LatLng(12.9716, 77.5946),
      );
    }
    if (points.length == 1) {
      final p = points.first;
      final delta = 0.01; // small box around single point
      return LatLngBounds(
        southwest: LatLng(p.latitude - delta, p.longitude - delta),
        northeast: LatLng(p.latitude + delta, p.longitude + delta),
      );
    }
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLng = math.min(minLng, p.longitude);
      maxLng = math.max(maxLng, p.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> _shareRideDetails() async {
    try {
      final ride = widget.ride;
      String rideSummary = '🚴‍♂️ Ride Details\n\n';

      if (ride.rideTitle?.isNotEmpty ?? false) {
        rideSummary += '📝 ${ride.rideTitle}\n';
      }
      if (ride.rideDescription?.isNotEmpty ?? false) {
        rideSummary += '📖 ${ride.rideDescription}\n\n';
      }

      rideSummary += '📊 Performance\n';
      if (ride.totalDistance != null) {
        rideSummary += '📍 Distance: ${(ride.totalDistance! / 1000).toStringAsFixed(2)} km\n';
      }
      if (ride.totalTime != null) {
        rideSummary += '⏱️ Duration: ${(ride.totalTime! / 60).toStringAsFixed(2)} min\n';
      }
      if (ride.topSpeed != null) {
        rideSummary += '🏃 Top Speed: ${ride.topSpeed!.toStringAsFixed(1)} km/h\n';
      }
      if (ride.averageSpeed != null) {
        rideSummary += '📈 Avg Speed: ${ride.averageSpeed!.toStringAsFixed(1)} km/h\n';
      }

      final gemCoins = ride.totalGEMCoins?.toStringAsFixed(2) ??
          ((ride.totalDistance ?? 0) / 1000).toStringAsFixed(2);
      rideSummary += '💎 GEM Coins: $gemCoins\n';
      rideSummary += '🔒 Privacy: ${(ride.isPublic ?? true) ? "Public" : "Private"}\n';
      
      // Add odometer status if available
      if (ride.odometer != null) {
        String odometerStatus = '';
        switch (ride.odometer!.verificationStatus) {
          case OdometerVerificationStatus.verified:
            odometerStatus = '✅ Odometer Verified';
            break;
          case OdometerVerificationStatus.pending:
            odometerStatus = '⏳ Odometer Pending Review';
            break;
          case OdometerVerificationStatus.rejected:
            odometerStatus = '❌ Odometer Rejected';
            break;
        }
        rideSummary += '$odometerStatus\n';
      }
      
      rideSummary += '\n';

      rideSummary += '🗺️ Route\n';
      if (_startAddress != null) rideSummary += '🚀 Start: $_startAddress\n';
      if (_endAddress != null) rideSummary += '🏁 End: $_endAddress\n';

      rideSummary += '\n---\nShared from Go Extra Mile App';

      await Share.share(rideSummary, subject: 'Check out my ride!');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to share ride details'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        titleSpacing: 0,
        title: const Text(
          'Ride Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: _shareRideDetails,
            icon: const Icon(Icons.share, color: Colors.black),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(baseScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RideHeaderCard(ride: widget.ride),
            const SizedBox(height: 16),
            VehicleCard(
              isLoading: _isLoadingVehicle,
              notFound: _vehicleNotFound,
              vehicle: _vehicle,
            ),
            const SizedBox(height: 16),
            if (_routePoints.isNotEmpty)
              RideMap(
                routePoints: _routePoints,
                mapController: _mapController,
                computeBounds: _computeBounds,
              ),
            const SizedBox(height: 16),
            RouteSection(
              startAddress: _isLoadingAddresses
                  ? 'Loading...'
                  : (_startAddress ?? widget.ride.startCoordinates.toString()),
              endAddress: _isLoadingAddresses
                  ? 'Loading...'
                  : (_endAddress ?? widget.ride.endCoordinates?.toString() ?? 'Ongoing'),
              routePointsCount: widget.ride.routePoints?.length ?? 0,
              theme: theme,
            ),
            const SizedBox(height: 16),
            PerformanceSection(ride: widget.ride, formatSpeed: _formatSpeed, theme: theme),
            const SizedBox(height: 16),
            // Odometer Section
            if (widget.ride.odometer != null && 
                ((widget.ride.odometer!.beforeRideOdometerImage != null && widget.ride.odometer!.beforeRideOdometerImage!.isNotEmpty) ||
                 (widget.ride.odometer!.afterRideOdometerImage != null && widget.ride.odometer!.afterRideOdometerImage!.isNotEmpty)))
              OdometerSection(odometer: widget.ride.odometer!),
            const SizedBox(height: 16),
            if (widget.ride.rideMemories != null && widget.ride.rideMemories!.isNotEmpty)
              RideMemoriesSection(
                rideMemories: widget.ride.rideMemories!
                    .map((m) => {'imageUrl': m.imageUrl, 'title': m.title})
                    .toList(),
                startAddress: _isLoadingAddresses ? 'Loading...' : (_startAddress ?? widget.ride.startCoordinates.toString()),
                endAddress: _isLoadingAddresses ? 'Loading...' : (_endAddress ?? widget.ride.endCoordinates?.toString() ?? 'Destination'),
              ),
            const SizedBox(height: 16),
            GEMCoinsSection(ride: widget.ride),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// -------------------- Header --------------------
class RideHeaderCard extends StatelessWidget {
  final RideEntity ride;
  const RideHeaderCard({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(baseScreenPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1), width: 1),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ride.rideTitle ?? 'Untitled Ride',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              _privacyBadge(ride.isPublic ?? true),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ride.rideDescription ?? 'No description',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyBadge(bool isPublic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPublic ? Colors.green.shade100 : Colors.orange.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isPublic ? Colors.green.shade300 : Colors.orange.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPublic ? Icons.public : Icons.lock, size: 16, color: isPublic ? Colors.green.shade700 : Colors.orange.shade700),
          const SizedBox(width: 6),
          Text(
            isPublic ? 'Public' : 'Private',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isPublic ? Colors.green.shade700 : Colors.orange.shade700),
          ),
        ],
      ),
    );
  }
}

/// -------------------- Vehicle Card --------------------
class VehicleCard extends StatelessWidget {
  final bool isLoading;
  final bool notFound;
  final VehicleEntity? vehicle;
  const VehicleCard({
    super.key,
    required this.isLoading,
    required this.notFound,
    required this.vehicle,
  });

  @override
  Widget build(BuildContext context) {
    return _wrapper(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (notFound || vehicle == null)
              ? Row(
                  children: [
                    _vehicleIcon(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Vehicle Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                          const SizedBox(height: 6),
                          Text('Vehicle details not available', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _vehicleImage(vehicle!),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${vehicle!.vehicleBrandName} ${vehicle!.vehicleModelName}',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                          const SizedBox(height: 6),
                          Text(vehicle!.vehicleRegistrationNumber, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                          const SizedBox(height: 4),
                          Text(vehicle!.vehicleType, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    _verificationBadge(vehicle!),
                  ],
                ),
    );
  }

  Widget _wrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(baseScreenPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
        color: Colors.white,
      ),
      child: child,
    );
  }

  Widget _vehicleIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
      child: Icon(Icons.directions_bike, size: 30, color: Colors.grey.shade600),
    );
  }

  Widget _vehicleImage(VehicleEntity v) {
    return SizedBox(
      width: 60,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: v.vehicleBrandImage.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: v.vehicleBrandImage,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade200,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade200,
                  child: Icon(Icons.directions_bike, size: 30, color: Colors.grey.shade600),
                ),
              )
            : Container(color: Colors.grey.shade200, child: Icon(Icons.directions_bike, size: 30, color: Colors.grey.shade600)),
      ),
    );
  }

  Widget _verificationBadge(VehicleEntity v) {
    final status = v.verificationStatus;
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    String statusText;

    switch (status) {
      case VehicleVerificationStatus.verified:
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green.shade300;
        textColor = Colors.green.shade700;
        statusText = 'Verified';
        break;
      case VehicleVerificationStatus.pending:
        backgroundColor = Colors.orange.shade100;
        borderColor = Colors.orange.shade300;
        textColor = Colors.orange.shade700;
        statusText = 'Pending';
        break;
      case VehicleVerificationStatus.rejected:
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red.shade300;
        textColor = Colors.red.shade700;
        statusText = 'Rejected';
        break;
      case VehicleVerificationStatus.notVerified:
        backgroundColor = Colors.grey.shade100;
        borderColor = Colors.grey.shade300;
        textColor = Colors.grey.shade700;
        statusText = 'Not Verified';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Text(statusText,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: textColor)),
    );
  }
}

/// -------------------- Map Widget --------------------
class RideMap extends StatefulWidget {
  final List<LatLng> routePoints;
  final Completer<GoogleMapController> mapController;
  final LatLngBounds Function(List<LatLng>) computeBounds;

  const RideMap({
    super.key,
    required this.routePoints,
    required this.mapController,
    required this.computeBounds,
  });

  @override
  State<RideMap> createState() => _RideMapState();
}

class _RideMapState extends State<RideMap> {
  late final CameraPosition _initialCamera;

  @override
  void initState() {
    super.initState();
    _initialCamera = CameraPosition(
      target: widget.routePoints.isNotEmpty ? widget.routePoints.first : const LatLng(12.9716, 77.5946),
      zoom: 12,
    );
  }

  Set<Marker> get _markers {
    if (widget.routePoints.isEmpty) return {};
    return {
      Marker(
        markerId: const MarkerId('start'),
        position: widget.routePoints.first,
        infoWindow: const InfoWindow(title: 'Start'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('end'),
        position: widget.routePoints.last,
        infoWindow: const InfoWindow(title: 'End'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };
  }

  Set<Polyline> get _polylines => {
        Polyline(
          polylineId: const PolylineId('route'),
          points: widget.routePoints,
          width: 5,
          geodesic: true,
        ),
      };

  Future<void> _fitToRoute(GoogleMapController controller) async {
    if (widget.routePoints.isEmpty) return;
    final bounds = widget.computeBounds(widget.routePoints);
    try {
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
    } catch (e) {
      // If newLatLngBounds fails (rare on some older devices), fallback to center.
      final center = widget.routePoints[0];
      await controller.animateCamera(CameraUpdate.newLatLngZoom(center, 12));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      height: 400,
      child: GoogleMap(
        initialCameraPosition: _initialCamera,
        onMapCreated: (controller) async {
          if (!widget.mapController.isCompleted) widget.mapController.complete(controller);
          await Future.delayed(const Duration(milliseconds: 250));
          await _fitToRoute(controller);
        },
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: false,
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
        mapType: MapType.normal,
        myLocationButtonEnabled: false,
      ),
    );
  }
}

/// -------------------- Route Section --------------------
class RouteSection extends StatelessWidget {
  final String startAddress;
  final String endAddress;
  final int routePointsCount;
  final ThemeData theme;

  const RouteSection({
    super.key,
    required this.startAddress,
    required this.endAddress,
    required this.routePointsCount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SaveRideSection(
      title: 'Route',
      gradient: [Colors.white, Colors.grey.shade50],
      children: [
        SaveRideInfoRow(icon: Icons.location_on_outlined, label: 'Start', value: startAddress, theme: theme),
        SaveRideInfoRow(icon: Icons.flag_outlined, label: 'End', value: endAddress, theme: theme),
        SaveRideInfoRow(icon: Icons.route, label: 'Route Points', value: '$routePointsCount points', theme: theme),
      ],
    );
  }
}

/// -------------------- Performance Section --------------------
class PerformanceSection extends StatelessWidget {
  final RideEntity ride;
  final String Function(double?) formatSpeed;
  final ThemeData theme;

  const PerformanceSection({super.key, required this.ride, required this.formatSpeed, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SaveRideSection(
      title: 'Performance',
      gradient: [Colors.white, Colors.grey.shade50],
      children: [
        SaveRideInfoRow(
          icon: Icons.route_outlined,
          label: 'Distance',
          value: ride.totalDistance != null ? '${(ride.totalDistance! / 1000).toStringAsFixed(2)} km' : '0.00 km',
          theme: theme,
        ),
        SaveRideInfoRow(
          icon: Icons.access_time,
          label: 'Duration',
          value: ride.totalTime != null ? '${(ride.totalTime! / 60).toStringAsFixed(2)} min' : '0.00 min',
          theme: theme,
        ),
        SaveRideInfoRow(
          icon: Icons.speed,
          label: 'Top Speed',
          value: ride.topSpeed != null ? '${ride.topSpeed!.toStringAsFixed(1)} km/h' : '0.0 km/h',
          theme: theme,
        ),
        SaveRideInfoRow(icon: Icons.directions_bike_outlined, label: 'Average Speed', value: formatSpeed(ride.averageSpeed), theme: theme),
      ],
    );
  }
}

/// -------------------- Ride Memories Section --------------------
class RideMemoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> rideMemories;
  final String startAddress;
  final String endAddress;

  const RideMemoriesSection({
    super.key,
    required this.rideMemories,
    required this.startAddress,
    required this.endAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SaveRideSection(
      title: 'Ride Memories',
      gradient: [Colors.white, Colors.grey.shade50],
      children: [
        RideMemoryRoad(rideMemory: rideMemories, startAddress: startAddress, endAddress: endAddress),
      ],
    );
  }
}

/// -------------------- GEM Coins Section --------------------
class GEMCoinsSection extends StatelessWidget {
  final RideEntity ride;
  const GEMCoinsSection({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final display = ride.totalGEMCoins?.toStringAsFixed(2) ?? ((ride.totalDistance ?? 0) / 1000).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: [Colors.amber.shade100, Colors.orange.shade50], begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: Colors.amber.shade200, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/icons/gem_coin.png', width: 32, height: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My GEM Coins Earning', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.amber.shade800)),
              Text('$display GEM Coins', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.amber.shade700)),
            ],
          )
        ],
      ),
    );
  }
}

/// -------------------- RideMemoryRoad & Painter --------------------
class RideMemoryRoad extends StatefulWidget {
  final String startAddress;
  final String? endAddress;
  final List<Map<String, dynamic>> rideMemory;

  const RideMemoryRoad({super.key, required this.rideMemory, required this.startAddress, this.endAddress});

  @override
  State<RideMemoryRoad> createState() => _RideMemoryRoadState();
}

class _RideMemoryRoadState extends State<RideMemoryRoad> {
  final ScrollController _controller = ScrollController();
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateProgress);
  }

  void _updateProgress() {
    if (!_controller.hasClients || !_controller.position.hasContentDimensions) return;
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    setState(() {
      _progress = (maxScroll == 0) ? 0.0 : (currentScroll / maxScroll).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(children: [
          SingleChildScrollView(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 24),
                _buildMilestone(widget.startAddress),
                for (int i = 0; i < widget.rideMemory.length; i++) ...[
                  _roadSegment(),
                  _memoryPoint(widget.rideMemory[i], i),
                ],
                _roadSegment(),
                _buildMilestone(widget.endAddress ?? 'Destination'),
                const SizedBox(width: 24),
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _fadeEdge(Alignment.centerLeft),
                  _fadeEdge(Alignment.centerRight),
                ],
              ),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fadeEdge(Alignment alignment) {
    return Container(
      width: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: alignment,
          end: alignment == Alignment.centerLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: [Colors.white, Colors.white.withOpacity(0.0)],
        ),
      ),
    );
  }

  Widget _buildMilestone(String label) {
    return Column(
      children: [
        Image.asset('assets/icons/road_milestone.png', width: 60, height: 60),
        const SizedBox(height: 6),
        SizedBox(width: 100, child: Text(label, textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _memoryPoint(Map<String, dynamic> memory, int index) {
    final imageUrl = memory['imageUrl'] as String?;
    final title = (memory['title'] ?? '');

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), borderRadius: BorderRadius.circular(12)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover, errorBuilder: (c, e, s) {
                    return Container(width: 70, height: 70, color: Colors.grey.shade300, child: const Icon(Icons.image, color: Colors.grey));
                  })
                : Container(width: 70, height: 70, color: Colors.grey.shade300, child: const Icon(Icons.image, color: Colors.grey)),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(width: 120, child: Text(title, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _roadSegment() {
    return SizedBox(
      width: 140,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: CustomPaint(painter: DottedRoadPainter()),
      ),
    );
  }
}

class DottedRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade800
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 6;
    const double dashSpace = 4;

    final path = Path()
      ..moveTo(0, size.height * 0.5)
      ..cubicTo(
        size.width * 0.25,
        -size.height * 0.8,
        size.width * 0.75,
        size.height * 1.3,
        size.width,
        size.height * 0.5,
      );

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = math.min(distance + dashWidth, metric.length);
        final segment = metric.extractPath(distance, end, startWithMoveTo: true);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }

      final startPos = metric.getTangentForOffset(0)?.position;
      if (startPos != null) {
        canvas.drawCircle(startPos, 5, Paint()..color = Colors.black);
      }

      final endPos = metric.getTangentForOffset(metric.length)?.position;
      if (endPos != null) {
        canvas.drawCircle(endPos, 5, Paint()..color = Colors.black);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// -------------------- Odometer Section --------------------
class OdometerSection extends StatelessWidget {
  final OdometerEntity odometer;
  
  const OdometerSection({super.key, required this.odometer});

  @override
  Widget build(BuildContext context) {
    return SaveRideSection(
      title: 'Odometer Reading',
      gradient: [Colors.white, Colors.grey.shade50],
      children: [
        // Verification Status Badge
        _buildVerificationStatusBadge(),
        const SizedBox(height: 16),
        // Odometer Images
        Row(
          children: [
            if (odometer.beforeRideOdometerImage != null && odometer.beforeRideOdometerImage!.isNotEmpty)
              Expanded(
                child: _buildOdometerImage(
                  odometer.beforeRideOdometerImage!,
                  "Before Ride",
                  odometer.beforeRideOdometerImageCaptureAt,
                ),
              ),
            if (odometer.beforeRideOdometerImage != null && odometer.beforeRideOdometerImage!.isNotEmpty &&
                odometer.afterRideOdometerImage != null && odometer.afterRideOdometerImage!.isNotEmpty)
              const SizedBox(width: 16),
            if (odometer.afterRideOdometerImage != null && odometer.afterRideOdometerImage!.isNotEmpty)
              Expanded(
                child: _buildOdometerImage(
                  odometer.afterRideOdometerImage!,
                  "After Ride",
                  odometer.afterRideOdometerImageCaptureAt,
                ),
              ),
          ],
        ),
        // Reasons if rejected
        if (odometer.verificationStatus == OdometerVerificationStatus.rejected && 
            odometer.reasons != null && odometer.reasons!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_outlined, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Rejection Reason: ${odometer.reasons}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildVerificationStatusBadge() {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String statusText;

    switch (odometer.verificationStatus) {
      case OdometerVerificationStatus.verified:
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green.shade300;
        textColor = Colors.green.shade700;
        icon = Icons.check_circle;
        statusText = 'Verified';
        break;
      case OdometerVerificationStatus.pending:
        backgroundColor = Colors.orange.shade100;
        borderColor = Colors.orange.shade300;
        textColor = Colors.orange.shade700;
        icon = Icons.schedule;
        statusText = 'Pending Review';
        break;
      case OdometerVerificationStatus.rejected:
        backgroundColor = Colors.red.shade100;
        borderColor = Colors.red.shade300;
        textColor = Colors.red.shade700;
        icon = Icons.cancel;
        statusText = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOdometerImage(String imageUrl, String label, DateTime? captureTime) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.grey,
                    size: 48,
                  ),
                ),
              ),
            ),
            // Overlay with label and timestamp
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (captureTime != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _formatCaptureTime(captureTime),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCaptureTime(DateTime captureTime) {
    final now = DateTime.now();
    final difference = now.difference(captureTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}