import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/enter_vehicle_details_screen.dart';

class VehicleModelScreen extends StatefulWidget {
  final String selectedVehicleType;
  final Map<String, dynamic> selectedBrand;

  const VehicleModelScreen({
    super.key,
    required this.selectedVehicleType,
    required this.selectedBrand,
  });

  @override
  State<VehicleModelScreen> createState() => _VehicleModelScreenState();
}

class _VehicleModelScreenState extends State<VehicleModelScreen> {
  String? selectedModel;
  final List<Map<String, dynamic>> _requestedModels = [];
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredModels = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filterModels("");
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterModels(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;

      final allModels = widget.selectedBrand['models'] as List<String>;

      if (query.isEmpty) {
        _filteredModels = allModels;
      } else {
        _filteredModels = allModels
            .where(
              (model) =>
                  model.toLowerCase().contains(query.toLowerCase().trim()),
            )
            .toList();
      }
    });
  }

  Future<void> _onRequestModel() async {
    AppSnackBar.info(context, "Will be available on version 0.0.5");
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.selectedBrand;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Text(
              'Select your ${brand['name']} model',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSearchBar(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Admin Models Section
                  if (_filteredModels.isEmpty && _isSearching)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          "No models found",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ),
                    )
                  else if (_filteredModels.isEmpty && !_isSearching)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_car_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No models available",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                                fontFamily: 'Gilroy',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Models for this brand will be loaded from the database.\nPlease check back later or contact support.",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                                fontFamily: 'Gilroy',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _filteredModels.map<Widget>((model) {
                        final isSelected = selectedModel == model;
                        return GestureDetector(
                          onTap: () {
                            setState(() => selectedModel = model);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EnterVehicleDetailsScreen(
                                  selectedVehicleType:
                                      widget.selectedVehicleType,
                                  selectedBrand: widget.selectedBrand,
                                  selectedModel: model,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            constraints: const BoxConstraints(minWidth: 120),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black.withValues(alpha: 0.1)
                                    : Colors.grey.withValues(alpha: 0.1),
                                width: isSelected ? 2 : 1,
                              ),
                              color: isSelected
                                  ? Colors.black.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                            ),
                            child: Text(
                              model,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: isSelected ? Colors.black : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 32),

                  // My Requested Models Section
                  if (!_isSearching && _requestedModels.isNotEmpty) ...[
                    _buildSectionHeader('My Requested Models'),
                    const SizedBox(height: 16),
                    _buildRequestedModelsGrid(),
                    const SizedBox(height: 32),
                  ],

                  // Can't Find Model Section
                  if (!_isSearching)
                    _buildCantFindModelSection(brand['logoUrl']),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (query) => _filterModels(query),
      decoration: InputDecoration(
        hintText: 'Search models...',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _filterModels("");
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontFamily: 'Gilroy',
      ),
    );
  }

  Widget _buildRequestedModelsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _requestedModels.map((request) {
        return _RequestedModelCard(request: request);
      }).toList(),
    );
  }

  Widget _buildCantFindModelSection(String brandImageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          const Divider(height: 1),
          const SizedBox(height: 32),
          Text(
            "Can't find your model?",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontFamily: 'Gilroy',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Request to add a new model if yours isn't listed",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              fontFamily: 'Gilroy',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _onRequestModel,
            icon: const Icon(Icons.add_circle_outline, color: Colors.black),
            label: Text(
              'Request New Model',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.black,
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

class _RequestedModelCard extends StatelessWidget {
  final Map<String, dynamic> request;

  const _RequestedModelCard({required this.request});

  String _getStatusText() {
    switch (request['status'].toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Color _getStatusColor() {
    switch (request['status'].toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey, width: 1),
        color: Colors.grey,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            request['modelName'],
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getStatusColor().withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              _getStatusText(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w600,
                color: _getStatusColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
