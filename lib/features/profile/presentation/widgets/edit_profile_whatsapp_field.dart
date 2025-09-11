import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';

class EditProfileWhatsappField extends StatelessWidget {
  final TextEditingController controller;
  final String? validationError;
  final ValueChanged<String>? onChanged;

  const EditProfileWhatsappField({
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
        CustomTextField(
          controller: controller,
          enabled: true,
          prefixIcon: FontAwesomeIcons.whatsapp,
          hintText: 'Enter your WhatsApp number',
          keyboardType: TextInputType.phone,
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'e.g., 1234567890',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
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

