import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/common/screens/web_view.dart';

class AuthTermsCondition extends StatelessWidget {
  final String termsAndConditionLink;
  const AuthTermsCondition({super.key, required this.termsAndConditionLink});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: [
            TextSpan(
              text: 'By continuing, you agree to our ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextSpan(
              text: 'Terms & Policy.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                decoration: TextDecoration.underline,
                color: Theme.of(context).primaryColor,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WebViewScreen(
                        url: termsAndConditionLink,
                        title: 'Terms & Conditions',
                      ),
                    ),
                  );
                },
            ),
          ],
        ),
      ),
    );
  }
}
