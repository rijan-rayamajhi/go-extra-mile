import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/vehicle_model_screen.dart';

class VehicleBrandScreen extends StatefulWidget {
  final String selectedVehicleType;

  const VehicleBrandScreen({super.key, required this.selectedVehicleType});

  @override
  State<VehicleBrandScreen> createState() => _VehicleBrandScreenState();
}

class _VehicleBrandScreenState extends State<VehicleBrandScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredBrands = [];
  List<Map<String, dynamic>> _requestedBrands = [];
  bool _isSearching = false;

  // 🔹 Using brands from app constants
  List<Map<String, dynamic>> get _allBrands => vehicleBrands;

  final List<Map<String, dynamic>> _allRequestedBrands = [
    {
      "id": "r1",
      "brandName": "Tesla",
      "vehicleType": "Car",
      "imageUrl":
          "https://upload.wikimedia.org/wikipedia/commons/b/bd/Tesla_Motors.svg",
      "status": "pending",
      "userId": "demo-user",
    },
    {
      "id": "r2",
      "brandName": "Suzuki",
      "vehicleType": "Bike",
      "imageUrl":
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
    _filterBrands("");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterBrands(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;

      final filtered = _allBrands
          .where((b) => b["vehicleType"] == widget.selectedVehicleType)
          .toList();

      if (query.isEmpty) {
        _filteredBrands = filtered;
      } else {
        _filteredBrands = filtered
            .where(
              (b) =>
                  b["name"].toLowerCase().contains(query.toLowerCase().trim()),
            )
            .toList();
      }
    });
  }

  void _onBrandTap(Map<String, dynamic> brand) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleModelScreen(
          selectedVehicleType: widget.selectedVehicleType,
          selectedBrand: brand, // still a Map now
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select ${widget.selectedVehicleType} Brand',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(child: _buildContent()),
            const SizedBox(height: 16),
            _buildCantFindBrandSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (query) => _filterBrands(query),
      decoration: InputDecoration(
        hintText: 'Search brands...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterBrands("");
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
    if (_filteredBrands.isEmpty && _isSearching) {
      return const Center(
        child: Text(
          "No brands found",
          style: TextStyle(
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
                  backgroundImage: NetworkImage(brand["logoUrl"]),
                ),
                const SizedBox(height: 8),
                Text(
                  brand["name"],
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
                backgroundImage: NetworkImage(req["imageUrl"]),
              ),
              const SizedBox(height: 8),
              Text(
                req["brandName"],
                style: Theme.of(context).textTheme.bodyMedium,
              ),
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
