import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';

class EditProfileDisplayNameField extends StatelessWidget {
  final TextEditingController controller;
  final String? validationError;
  final ValueChanged<String>? onChanged;

  const EditProfileDisplayNameField({
    super.key,
    required this.controller,
    required this.validationError,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Display Name',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          enabled: true,
          prefixIcon: Icons.person,
          hintText: 'Enter your display name',
          textInputAction: TextInputAction.next,
          onChanged: onChanged,
        ),
        if (validationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              validationError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

