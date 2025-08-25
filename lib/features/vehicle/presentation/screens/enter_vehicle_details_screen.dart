import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';
import 'package:go_extra_mile_new/core/utils/text_validators.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/select_vehicle_type_screen.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/vehicle_brand_screen.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/vehicle_model_screen.dart';
import 'package:go_extra_mile_new/features/main_screen.dart';
import 'package:uuid/uuid.dart';

class EnterVehicleDetailsScreen extends StatefulWidget {
  final String selectedVehicleType;
  final Map<String, dynamic> selectedBrand;
  final String selectedModel;

  const EnterVehicleDetailsScreen({
    super.key,
    required this.selectedVehicleType,
    required this.selectedBrand,
    required this.selectedModel,
  });

  @override
  State<EnterVehicleDetailsScreen> createState() =>
      _EnterVehicleDetailsScreenState();
}

class _EnterVehicleDetailsScreenState extends State<EnterVehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _registrationNumberController = TextEditingController();

  String _selectedTyreType = '';
  bool _isAuthorized = false;

  @override
  void dispose() {
    _registrationNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_isAuthorized) {
      AppSnackBar.show(
        context,
        message: 'Please authorize that you can add this vehicle',
      );
      return;
    }

    if (_selectedTyreType.isEmpty) {
      AppSnackBar.show(context, message: 'Please select a tyre type');
      return;
    }

    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    if (userId.isEmpty) {
      //navigate to authscreen
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        // Validate that all required values are present and non-null
        debugPrint('Selected Brand: $widget.selectedBrand');
        debugPrint('Selected Brand Keys: ${widget.selectedBrand.keys}');
        debugPrint(
          'Selected Brand LogoUrl: ${widget.selectedBrand['logoUrl']}',
        );
        debugPrint('Selected Brand Name: ${widget.selectedBrand['name']}');

        final vehicleBrandImage = widget.selectedBrand['logoUrl'] as String?;
        final vehicleBrandName = widget.selectedBrand['name'] as String?;

        if (vehicleBrandImage == null || vehicleBrandName == null) {
          throw Exception(
            'Invalid brand information: logoUrl=${widget.selectedBrand['logoUrl']}, name=${widget.selectedBrand['name']}',
          );
        }

        final vehicle = VehicleEntity(
          id: Uuid().v1(),
          vehicleType: widget.selectedVehicleType,
          vehicleBrandImage: vehicleBrandImage,
          vehicleBrandName: vehicleBrandName,
          vehicleModelName: widget.selectedModel,
          vehicleRegistrationNumber: _registrationNumberController.text.trim(),
          vehicleTyreType: _selectedTyreType,
          verificationStatus: VehicleVerificationStatus.notVerified,
        );

        context.read<VehicleBloc>().add(AddNewVehicle(vehicle, userId));
      } catch (e) {
        debugPrint('Error: ${e.toString()}');
        AppSnackBar.show(context, message: 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state is VehicleError) {
          AppSnackBar.error(context, state.message);
        } else if (state is VehicleAdded) {
          // Navigate back or show success message
          AppSnackBar.success(
            context, 
            'Vehicle added successfully!',
          );
                Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          final isLoading = state is VehicleLoading;
          
          if (isLoading) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Adding Vehicle...', 
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            appBar: AppBar(),
            body: GestureDetector(
              onTap: () {
                // Close keyboard when tapping outside of text fields
                FocusScope.of(context).unfocus();
              },
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            kToolbarHeight -
                            32, // 32 for padding
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          /// Title
                          Text(
                            'Enter Vehicle Details',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          /// Selected model
                          _buildSectionTitle('Selected Model'),
                          const SizedBox(height: 12),
                          _buildModelCard(),
                          const SizedBox(height: 32),

                          /// Registration Number
                          _buildSectionTitle('Registration Number'),

                          const SizedBox(height: 12),
                          _buildRegistrationField(),
                          const SizedBox(height: 4),
                          Text(
                            'e.g., 12345678, 98765432, 45678901',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                          ),
                          const SizedBox(height: 32),

                          /// Tyre Type
                          _buildSectionTitle('Tyre Type'),
                          const SizedBox(height: 12),
                          _buildTyreTypeSelector(),
                          const SizedBox(height: 120),

                          /// Authorization
                          _buildAuthorizationCheckbox(),
                          const SizedBox(height: 12),

                          /// Submit Button
                          PrimaryButton(
                            text: 'Submit',
                            onPressed: _handleSubmit,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------- Widgets ----------------

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildModelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          /// Brand Logo
          if (widget.selectedBrand['logoUrl'] != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(widget.selectedBrand['logoUrl']),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          const SizedBox(width: 12),

          /// Model & Brand Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.selectedModel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.selectedBrand['name']} • ${widget.selectedVehicleType}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          /// Edit Icon
          IconButton(
            onPressed: _showEditOptions,
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.black,
              size: 24,
            ),
            tooltip: 'Edit Vehicle Details',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showEditOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Drag handle
              Container(
                margin: const EdgeInsets.only(top: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              /// Title
              Text(
                'Edit Vehicle Details',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),

              /// Options
              _buildEditOption(
                icon: Icons.directions_car_outlined,
                title: 'Change Vehicle Type',
                subtitle: 'Currently: ${widget.selectedVehicleType}',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SelectVehicleTypeScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
              _buildEditOption(
                icon: Icons.branding_watermark_outlined,
                title: 'Change Brand',
                subtitle: 'Currently: ${widget.selectedBrand['name']}',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleBrandScreen(
                        selectedVehicleType: widget.selectedVehicleType,
                      ),
                    ),
                  );
                },
              ),
              _buildEditOption(
                icon: Icons.model_training,
                title: 'Change Model',
                subtitle: 'Currently: ${widget.selectedModel}',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VehicleModelScreen(
                        selectedVehicleType: widget.selectedVehicleType,
                        selectedBrand: widget.selectedBrand,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            /// Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 16),

            /// Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationField() {
    return CustomTextField(
      hintText: 'Enter vehicle registration number (e.g., XX-XXXX)',
      controller: _registrationNumberController,
      textCapitalization: TextCapitalization.characters,
      prefixIcon: Icons.confirmation_number_outlined,
      validator: TextValidators.vehicleRegistrationNumber,
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildTyreTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTyreTypeOption('Tube')),
          Container(width: 1, height: 56, color: Colors.grey),
          Expanded(child: _buildTyreTypeOption('Tubeless')),
        ],
      ),
    );
  }

  Widget _buildTyreTypeOption(String type) {
    final isSelected = _selectedTyreType == type;

    return InkWell(
      onTap: () => setState(() => _selectedTyreType = type),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? Colors.black.withOpacity(0.1) : null,
          borderRadius: BorderRadius.horizontal(
            left: type == 'Tube' ? const Radius.circular(12) : Radius.zero,
            right: type == 'Tubeless' ? const Radius.circular(12) : Radius.zero,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tire_repair,
              color: isSelected ? Colors.black : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              type,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorizationCheckbox() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: CheckboxListTile(
        value: _isAuthorized,
        onChanged: (value) async {
          final result = await _showAuthorizationDialog();
          if (result == true) {
            setState(() => _isAuthorized = true);
          } else if (result == false && _isAuthorized) {
            setState(() => _isAuthorized = false);
          }
        },
        title: const Text(
          'I am authorized to add this vehicle',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w500,
          ),
        ),
        activeColor: Colors.black,
        checkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Future<bool?> _showAuthorizationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: const Text(
              'Vehicle Authorization',
              style: TextStyle(
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              'By checking this box, you confirm that you are legally authorized '
              'to add and operate this vehicle. This includes having valid ownership '
              'or permission to use the vehicle.\n\nDo you confirm?',
              style: TextStyle(fontFamily: 'Gilroy'),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                isDestructiveAction: true,
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontFamily: 'Gilroy'),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Confirm',
                  style: TextStyle(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Vehicle Authorization',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'Gilroy',
            ),
          ),
          content: const Text(
            'By checking this box, you confirm that you are legally authorized '
            'to add and operate this vehicle. This includes having valid ownership '
            'or permission to use the vehicle.\n\nDo you confirm?',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontFamily: 'Gilroy',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'CONFIRM',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
