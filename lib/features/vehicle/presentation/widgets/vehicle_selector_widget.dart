import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/circular_image.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/vehicle/domain/entities/vehicle_entiry.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_bloc.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_state.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/bloc/vehicle_event.dart';
import 'package:go_extra_mile_new/features/vehicle/presentation/screens/select_vehicle_type_screen.dart';

class VehicleSelectorWidget extends StatefulWidget {
  final ValueChanged<VehicleEntity>? onVehicleSelected;

  const VehicleSelectorWidget({super.key, this.onVehicleSelected});

  @override
  State<VehicleSelectorWidget> createState() => _VehicleSelectorWidgetState();
}

class _VehicleSelectorWidgetState extends State<VehicleSelectorWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.4);
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<VehicleBloc>().add(LoadUserVehicles(currentUser.uid));
    }
  }

  void _notifySelectedVehicle(List<VehicleEntity> vehicles, int index) {
    if (widget.onVehicleSelected != null && vehicles.isNotEmpty) {
      widget.onVehicleSelected!(vehicles[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is VehicleLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is VehicleError) {
          return Center(child: Text(state.message));
        } else if (state is VehicleLoaded) {
          final vehicles = state.vehicles;

          if (vehicles.isEmpty) {
            return Column(
              children: [
                const Text(
                  'Please add at least one vehicle to start a ride.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  text: 'Add Vehicle',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectVehicleTypeScreen(),
                      ),
                    );
                  },
                ),
              ],
            );
          }

          // Notify parent of initial selected vehicle after layout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _notifySelectedVehicle(vehicles, _currentIndex);
          });

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Vehicle',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Icon(
                Icons.arrow_drop_down,
                size: 24,
                color: Colors.black54,
              ),
              SizedBox(
                height: 180,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: vehicles.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    _notifySelectedVehicle(vehicles, index);
                  },
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double scale = 0.7;
                        if (_pageController.hasClients &&
                            _pageController.position.haveDimensions) {
                          final page =
                              _pageController.page ?? _currentIndex.toDouble();
                          final diff = (index - page).abs();
                          scale = 1 - (diff * 0.3);
                          if (scale < 0.7) scale = 0.7;
                        } else {
                          scale = index == _currentIndex ? 1.0 : 0.7;
                        }

                        final size = 60 + (110 - 60) * (scale - 0.7) / 0.3;
                        final fontSize = 12 + (16 - 12) * (scale - 0.7) / 0.3;
                        final textColor = Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6 + 0.4 * ((scale - 0.7) / 0.3));

                        return Center(
                          child: GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeOutCubic,
                              );
                              setState(() {
                                _currentIndex = index;
                              });
                              _notifySelectedVehicle(vehicles, index);
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: size,
                                  height: size,
                                  child: CircularImage(
                                    imageUrl: vehicles[index].vehicleBrandImage,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    '${vehicles[index].vehicleBrandName} ${vehicles[index].vehicleModelName}',
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: index == _currentIndex
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
