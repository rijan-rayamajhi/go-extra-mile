import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';
import 'package:go_extra_mile_new/core/utils/text_validators.dart';

class RideDetailsForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final bool isPublic;
  final ValueChanged<bool> onPrivacyChanged;

  const RideDetailsForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.isPublic,
    required this.onPrivacyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ride Details",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: "Ride Title",
              hintText: "Enter a title for your ride",
              prefixIcon: Icons.title,
              controller: titleController,
              textCapitalization: TextCapitalization.words,
              validator: TextValidators.rideTitle,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: "Description",
              hintText: "Share your ride experience...",
              prefixIcon: Icons.description,
              controller: descriptionController,
              textCapitalization: TextCapitalization.words,
              validator: TextValidators.rideDescription,
            ),
            const SizedBox(height: 16),
            // Privacy Toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    isPublic ? Icons.public : Icons.lock,
                    color: isPublic ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPublic ? 'Public Ride' : 'Private Ride',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          isPublic
                              ? 'Others can see your ride details and memories'
                              : 'Only you can see this ride',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isPublic,
                    onChanged: onPrivacyChanged,
                    activeColor: Colors.green,
                    inactiveThumbColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
