import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/my_vehicle_details_vehicle_image_widget.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/my_vehicle_details_insurance_image_widget.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/widgets/my_vehicle_details_vehicle_rc_image_widget.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';

class VerifyAndEarnScreen extends StatelessWidget {
  final VehicleEntity vehicle;
  const VerifyAndEarnScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return BlocListener<VehicleBloc, VehicleState>(
      listener: (context, state) {
        if (state is VehicleVerificationSubmitted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          // Navigate back after successful verification
          Navigator.pop(context);
        } else if (state is VehicleError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(baseScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verify and Earn',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Vehicle card
            _buildVehicleCard(context),

            const SizedBox(height: 24),

            // Vehicle images section
            Text(
              'Vehicle Images',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MyVehicleDetailsVehicleImageWidget(
              frontImageUrl: vehicle.vehicleFrontImage,
              backImageUrl: vehicle.vehicleBackImage,
              vehicleId: vehicle.id,
              userId: uid,
              hideDeleteButton: true,
            ),

            const SizedBox(height: 24),

            // Insurance image section
            Text(
              'Insurance Document',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MyVehicleDetailsInsuranceImageWidget(
              imageUrl: vehicle.vehicleInsuranceImage,
              vehicleId: vehicle.id,
              userId: uid,
              fieldName: 'vehicleInsuranceImage',
              hideDeleteButton: true,
            ),

            const SizedBox(height: 24),

            // RC images section
            Text(
              'RC Document',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            MyVehicleDetailsVehicleRcImageWidget(
              frontImageUrl: vehicle.vehicleRCFrontImage,
              backImageUrl: vehicle.vehicleRCBackImage,
              vehicleId: vehicle.id,
              userId: uid,
              hideDeleteButton: true,
            ),

            const SizedBox(height: 32),

            // Reward message
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: Colors.green.shade600,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Earn Rewards!',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete verification to receive GEM coins and unlock exclusive rewards.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.green.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Verify & Earn button
            BlocBuilder<VehicleBloc, VehicleState>(
              builder: (context, state) {
                return PrimaryButton(
                  text: 'Verify & Earn',
                  isLoading: state is VehicleLoading,
                  onPressed: () {
                    context.read<VehicleBloc>().add(
                      VerifyVehicleEvent(vehicle.id, uid),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildVehicleCard(BuildContext context) {
    return Container(
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(baseScreenPadding),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Brand logo with badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundImage: CachedNetworkImageProvider(
                      vehicle.vehicleBrandImage,
                    ),
                    backgroundColor: Colors.white,
                  ),
                  if (vehicle.verificationStatus ==
                      VehicleVerificationStatus.verified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 18,
                        ),
                      ),
                    ),
                  if (vehicle.verificationStatus ==
                      VehicleVerificationStatus.pending)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: Colors.orange,
                          size: 18,
                        ),
                      ),
                    ),
                  if (vehicle.verificationStatus ==
                      VehicleVerificationStatus.rejected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 18,
                        ),
                      ),
                    ),
                  if (vehicle.verificationStatus ==
                      VehicleVerificationStatus.notVerified)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.help_outline,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 20),

              // Vehicle details
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      vehicle.vehicleBrandName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vehicle.vehicleModelName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vehicle.vehicleRegistrationNumber,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';

// class VerifyAndEarnScreen extends StatefulWidget {
//   final VehicleEntity vehicle;
//   const VerifyAndEarnScreen({super.key, required this.vehicle});

//   @override
//   State<VerifyAndEarnScreen> createState() => _VerifyAndEarnScreenState();
// }

// class _VerifyAndEarnScreenState extends State<VerifyAndEarnScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text('Verify and Earn'),
//       ),
//     );
//   }
// }