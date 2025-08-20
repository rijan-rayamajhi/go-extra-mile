import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';

class EditProfileUsernameField extends StatelessWidget {
  final TextEditingController controller;
  final bool isChecking;
  final bool isAvailable;
  final String? validationError;
  final String? originalUsername;
  final ValueChanged<String>? onChanged;

  const EditProfileUsernameField({
    super.key,
    required this.controller,
    required this.isChecking,
    required this.isAvailable,
    required this.validationError,
    required this.originalUsername,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Username',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          enabled: true,
          prefixIcon: Icons.alternate_email,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          suffixIcon: isChecking
              ? const SizedBox(
                  width: 8,
                  height: 8,
                  child: Center(
                    child: SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                        strokeWidth: 1,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                )
              : controller.text.isNotEmpty &&
                      controller.text != originalUsername &&
                      validationError == null
                  ? Icon(
                      isAvailable ? Icons.check_circle : Icons.cancel,
                      color: isAvailable ? Colors.green : Colors.red,
                    )
                  : null,
        ),
        if (validationError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              validationError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        if (controller.text.isNotEmpty &&
            controller.text != originalUsername &&
            !isChecking &&
            validationError == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              isAvailable ? 'Username is available' : 'Username is already taken',
              style: TextStyle(
                color: isAvailable ? Colors.green : Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}

