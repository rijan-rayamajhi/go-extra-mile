import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';

class EditProfileYoutubeField extends StatelessWidget {
  final TextEditingController controller;
  final String? validationError;
  final ValueChanged<String>? onChanged;

  const EditProfileYoutubeField({
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
          'Youtube',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          controller: controller,
          enabled: true,
          prefixIcon: FontAwesomeIcons.youtube,
          hintText: 'Enter your YouTube channel link',
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.url,
          onChanged: onChanged,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            'e.g., https://www.youtube.com/@username',
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

