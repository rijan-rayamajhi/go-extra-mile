import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/core/utils/date_picker_utils.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_bloc.dart';
import 'package:go_extra_mile_new/features/license/presentation/bloc/driving_license_state.dart';

class EditProfileDob extends StatelessWidget {
  final VoidCallback? onTap;

  const EditProfileDob({super.key,this.onTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrivingLicenseBloc, DrivingLicenseState>(
      builder: (context, state) {
        String displayText;
        bool hasExistingDob = false;

        if (state is DrivingLicenseLoading) {
          displayText = 'Loading...';
        } else if (state is DrivingLicenseLoaded || state is DrivingLicenseSubmitted) {
          final license = state is DrivingLicenseLoaded 
              ? state.license 
              : (state as DrivingLicenseSubmitted).license;
          
          if (license != null) {
            displayText = DatePickerUtils.formatDate(license.dob, pattern: 'dd MMM, yyyy');
            hasExistingDob = true;
          } else {
            displayText = 'Select Date of Birth';
          }
        } else {
          // Initial state or error state
          displayText = 'Select Date of Birth';
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date of Birth', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.cake, 
                      color: state is DrivingLicenseLoading 
                          ? Colors.grey.shade400
                          : hasExistingDob 
                              ? Theme.of(context).colorScheme.primary 
                              : Colors.grey.shade600, 
                      size: 24
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                                                  color: state is DrivingLicenseLoading 
                            ? Colors.grey.shade400
                            : hasExistingDob 
                                ? Theme.of(context).colorScheme.primary 
                                : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasExistingDob ? 'Edit' : 'Select',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.black),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}