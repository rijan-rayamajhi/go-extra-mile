import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/main/main_screen.dart';
import 'package:uuid/uuid.dart';
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
  final _registrationController = TextEditingController();

  String _selectedTyreType = '';
  bool _isAuthorized = false;
  String? _registrationValidationError;

  @override
  void dispose() {
    _registrationController.dispose();
    super.dispose();
  }

  void _validateRegistrationNumber(String value) {
    setState(() {
      _registrationValidationError = TextValidators.vehicleRegistrationNumber(
        value,
      );
    });
  }

  bool get _isRegistrationValid =>
      _registrationController.text.isNotEmpty &&
      _registrationValidationError == null;

  Future<void> _handleSubmit() async {
    if (!_isAuthorized) {
      return AppSnackBar.show(
        context,
        message: 'Please authorize that you can add this vehicle',
      );
    }
    if (_selectedTyreType.isEmpty) {
      return AppSnackBar.show(context, message: 'Please select a tyre type');
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return; // handle unauthenticated user
    }

    if (_formKey.currentState!.validate()) {
      try {
        final brandLogo = widget.selectedBrand['logoUrl'] as String?;
        final brandName = widget.selectedBrand['name'] as String?;

        if (brandLogo == null || brandName == null) {
          throw Exception('Invalid brand info');
        }

        final vehicle = VehicleEntity(
          id: const Uuid().v1(),
          vehicleType: widget.selectedVehicleType,
          vehicleBrandImage: brandLogo,
          vehicleBrandName: brandName,
          vehicleModelName: widget.selectedModel,
          vehicleRegistrationNumber: _registrationController.text.trim(),
          vehicleTyreType: _selectedTyreType,
          verificationStatus: VehicleVerificationStatus.notVerified,
        );

        context.read<VehicleBloc>().add(AddNewVehicle(vehicle, userId));
      } catch (e) {
        AppSnackBar.show(context, message: e.toString());
      }
    }
  }

  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listenWhen: (previous, current) {
        // Only listen when transitioning from loading to loaded/error
        return previous is VehicleLoading && 
               (current is VehicleLoaded || current is VehicleError);
      },
      listener: (context, state) {
        if (state is VehicleError) {
          AppSnackBar.error(context, state.message);
        } else if (state is VehicleLoaded && !_hasNavigated) {
          _hasNavigated = true;
          AppSnackBar.success(context, 'Vehicle added successfully!');
          // Use a short delay to ensure snackbar shows before navigation
          Future.microtask(() {
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainScreen()),
                (route) => false,
              );
            }
          });
        }
      },
      child: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          final isLoading = state is VehicleLoading;

          if (isLoading) return _loadingView();

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enter Vehicle Details',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 16),
                              _sectionTitle('Selected Model'),
                              const SizedBox(height: 12),
                              _modelCard(),
                              const SizedBox(height: 24),
                              _sectionTitle('Registration Number'),
                              CustomTextField(
                                hintText:
                                    'Enter vehicle registration number (e.g., XX-XXXX)',
                                controller: _registrationController,
                                textCapitalization:
                                    TextCapitalization.characters,
                                prefixIcon: Icons.confirmation_number_outlined,
                                validator:
                                    TextValidators.vehicleRegistrationNumber,
                                keyboardType: TextInputType.text,
                                onChanged: _validateRegistrationNumber,
                                suffixIcon: _isRegistrationValid
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 20,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'e.g., ABC123456',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.grey.withValues(alpha: 0.7),
                                    ),
                              ),
                              if (_registrationValidationError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _registrationValidationError!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              else if (_isRegistrationValid)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Valid registration number',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 24),
                              _sectionTitle('Tyre Type'),
                              const SizedBox(height: 12),
                              _tyreSelector(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom section with auth checkbox and submit button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _authCheckbox(),
                          const SizedBox(height: 12),
                          PrimaryButton(
                            text: 'Submit',
                            onPressed: _handleSubmit,
                            isLoading: isLoading,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _loadingView() => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            'Adding Vehicle...',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );

  Widget _sectionTitle(String title) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
  );

  Widget _modelCard() {
    final brand = widget.selectedBrand;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          if (brand['logoUrl'] != null)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(brand['logoUrl']),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          const SizedBox(width: 12),
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
                  '${brand['name']} • ${widget.selectedVehicleType}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showEditOptions,
            icon: const Icon(
              Icons.edit_outlined,
              color: Colors.black,
              size: 24,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  Widget _tyreSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: ['Tube', 'Tubeless'].map((type) {
          final isSelected = _selectedTyreType == type;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTyreType = type),
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.black.withValues(alpha: 0.1)
                      : null,
                  borderRadius: BorderRadius.horizontal(
                    left: type == 'Tube'
                        ? const Radius.circular(12)
                        : Radius.zero,
                    right: type == 'Tubeless'
                        ? const Radius.circular(12)
                        : Radius.zero,
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
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _authCheckbox() => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey),
    ),
    child: CheckboxListTile(
      value: _isAuthorized,
      onChanged: (_) async {
        final confirmed = await _showAuthorizationDialog();
        setState(() => _isAuthorized = confirmed ?? false);
      },
      title: const Text(
        'I am authorized to add this vehicle',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      activeColor: Colors.black,
      checkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    ),
  );

  Future<bool?> _showAuthorizationDialog() => showDialog<bool>(
    context: context,
    builder: (context) => Platform.isIOS
        ? CupertinoAlertDialog(
            title: const Text(
              'Vehicle Authorization',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: const Text(
              'By checking this box, you confirm that you are legally authorized to add and operate this vehicle. This includes having valid ownership or permission to use the vehicle.\n\nDo you confirm?',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                isDestructiveAction: true,
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          )
        : AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              'Vehicle Authorization',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            content: const Text(
              'By checking this box, you confirm that you are legally authorized to add and operate this vehicle. This includes having valid ownership or permission to use the vehicle.\n\nDo you confirm?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('CONFIRM'),
              ),
            ],
          ),
  );

  void _showEditOptions() => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Text(
              'Edit Vehicle Details',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _editOption(
              Icons.directions_car_outlined,
              'Change Vehicle Type',
              'Currently: ${widget.selectedVehicleType}',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SelectVehicleTypeScreen(),
                  ),
                );
              },
            ),
            _editOption(
              Icons.branding_watermark_outlined,
              'Change Brand',
              'Currently: ${widget.selectedBrand['name']}',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleBrandScreen(
                      selectedVehicleType: widget.selectedVehicleType,
                    ),
                  ),
                );
              },
            ),
            _editOption(
              Icons.model_training,
              'Change Model',
              'Currently: ${widget.selectedModel}',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleModelScreen(
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

  Widget _editOption(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.withValues(alpha: 0.7)),
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
