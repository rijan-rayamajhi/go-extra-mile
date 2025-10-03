import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_brand_entity.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/vehicle_model_screen.dart';

class VehicleBrandScreen extends StatefulWidget {
  final String selectedVehicleType;

  const VehicleBrandScreen({super.key, required this.selectedVehicleType});

  @override
  State<VehicleBrandScreen> createState() => _VehicleBrandScreenState();
}

class _VehicleBrandScreenState extends State<VehicleBrandScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<VehicleBrandEntity> _filteredBrands = [];
  List<Map<String, dynamic>> _requestedBrands = [];
  bool _isSearching = false;

  final List<Map<String, dynamic>> _allRequestedBrands = [
    {
      "id": "r1",
      "name": "Tesla",
      "vehicleType": "Car",
      "logoUrl":
          "https://upload.wikimedia.org/wikipedia/commons/b/bd/Tesla_Motors.svg",
      "status": "pending",
      "userId": "demo-user",
    },
    {
      "id": "r2",
      "name": "Suzuki",
      "vehicleType": "Bike",
      "logoUrl":
          "https://upload.wikimedia.org/wikipedia/commons/6/62/Suzuki_logo_2.svg",
      "status": "approved",
      "userId": "demo-user",
    },
  ];

  @override
  void initState() {
    super.initState();
    _requestedBrands = _allRequestedBrands
        .where((r) => r["vehicleType"] == widget.selectedVehicleType)
        .toList();

    // Load vehicle brands from database
    // context.read<VehicleBloc>().add(const LoadVehicleBrands());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBrands(String query, List<VehicleBrandEntity> allBrands) {
    setState(() {
      _isSearching = query.isNotEmpty;

      if (query.isEmpty) {
        _filteredBrands = allBrands;
      } else {
        _filteredBrands = allBrands
            .where(
              (b) => b.name.toLowerCase().contains(query.toLowerCase().trim()),
            )
            .toList();
      }
    });
  }

  String _getReadableVehicleType(String vehicleType) {
    return vehicleType
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
          return word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  void _onBrandTap(VehicleBrandEntity brand) {
    // Convert VehicleBrandEntity to Map for compatibility with existing VehicleModelScreen
    final brandMap = {
      'id': brand.id,
      'name': brand.name,
      'logoUrl': brand.logoUrl,
      'vehicleType': widget.selectedVehicleType,
      'models': brand.models, // Use models from the entity
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleModelScreen(
          selectedVehicleType: widget.selectedVehicleType,
          selectedBrand: brandMap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is VehicleLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is VehicleError) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VehicleBloc>().add(
                        const LoadVehicleBrands(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Get brands from bloc state and filter by vehicle type
        List<VehicleBrandEntity> availableBrands = [];
        if (state is VehicleLoaded) {
          // Filter brands by selected vehicle type
          availableBrands = state.vehicleBrands
              .where(
                (brand) =>
                    brand.vehicleType.value == widget.selectedVehicleType,
              )
              .toList();
        }

        // Initialize filtered brands if not set or if available brands changed
        if (_filteredBrands.isEmpty && availableBrands.isNotEmpty) {
          _filteredBrands = availableBrands;
        } else if (availableBrands.isNotEmpty && _filteredBrands.isNotEmpty) {
          // Check if the filtered brands are still valid for current available brands
          final currentBrandIds = availableBrands.map((b) => b.id).toSet();
          final filteredBrandIds = _filteredBrands.map((b) => b.id).toSet();
          if (!currentBrandIds.containsAll(filteredBrandIds)) {
            // Reset filtered brands if they don't match current available brands
            _filteredBrands = availableBrands;
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select ${_getReadableVehicleType(widget.selectedVehicleType)} Brand',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSearchBar(availableBrands),
                const SizedBox(height: 16),
                Expanded(child: _buildContent()),
                const SizedBox(height: 16),
                _buildCantFindBrandSection(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(List<VehicleBrandEntity> availableBrands) {
    return TextField(
      controller: _searchController,
      onChanged: (query) => _filterBrands(query, availableBrands),
      decoration: InputDecoration(
        hintText: 'Search brands...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterBrands("", availableBrands);
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildContent() {
    // Handle empty brands case
    if (_filteredBrands.isEmpty && !_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.branding_watermark_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No ${_getReadableVehicleType(widget.selectedVehicleType)} brands available",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                fontFamily: 'Gilroy',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "No brands found for ${_getReadableVehicleType(widget.selectedVehicleType)}.\nPlease check your connection or contact support.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontFamily: 'Gilroy',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<VehicleBloc>().add(const LoadVehicleBrands());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredBrands.isEmpty && _isSearching) {
      return Center(
        child: Text(
          "No ${_getReadableVehicleType(widget.selectedVehicleType)} brands found",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: 'Gilroy',
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildBrandsGrid(),
        const SizedBox(height: 24),
        if (!_isSearching && _requestedBrands.isNotEmpty) ...[
          Text(
            "My Requested Brands",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _buildRequestedBrandsGrid(),
        ],
      ],
    );
  }

  Widget _buildBrandsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _filteredBrands.length,
      itemBuilder: (context, index) {
        final brand = _filteredBrands[index];
        return GestureDetector(
          onTap: () => _onBrandTap(brand),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey),
              color: Colors.grey[100],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(brand.logoUrl),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle image loading error
                  },
                  child: brand.logoUrl.isEmpty
                      ? const Icon(Icons.branding_watermark, size: 32)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(
                  brand.name,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestedBrandsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _requestedBrands.map((req) {
        final statusColor = req["status"] == "approved"
            ? Colors.green
            : req["status"] == "pending"
            ? Colors.orange
            : Colors.red;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey),
            color: Colors.grey[100],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(req["logoUrl"]),
              ),
              const SizedBox(height: 8),
              Text(req["name"], style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text(
                req["status"],
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCantFindBrandSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 32),
          Text(
            "Can't find your brand?",
            style: TextStyle(
              color: Colors.grey[800],
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Gilroy',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Request to add a new brand if yours isn't listed",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontFamily: 'Gilroy',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              AppSnackBar.info(context, "Will be available on version 0.0.5");
            },
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            label: const Text(
              'Request New Brand',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Gilroy',
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
