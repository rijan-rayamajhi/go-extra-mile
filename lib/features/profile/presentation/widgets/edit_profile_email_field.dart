import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';

class EditProfileEmailField extends StatelessWidget {
  final String email;

  const EditProfileEmailField({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        CustomTextField(
          controller: TextEditingController(text: email),
          enabled: false,
          prefixIcon: Icons.email,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 8),
        const Text(
          'Your email cannot be changed.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 13,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

