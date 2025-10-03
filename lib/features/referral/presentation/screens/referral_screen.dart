import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/screens/loading_screen.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';
import 'package:go_extra_mile_new/features/main/main_screen.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_bloc.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_event.dart';
import 'package:go_extra_mile_new/features/referral/presentation/bloc/referral_state.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referralController = TextEditingController();

  @override
  void dispose() {
    _referralController.dispose();
    super.dispose();
  }

  void _handleSkip() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }

  void _handleReferralSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<ReferralBloc>().add(
        SubmitReferralCodeEvent(_referralController.text.trim()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReferralBloc, ReferralState>(
      listener: (context, state) {
        if (state is ReferralSuccess) {
          AppSnackBar.success(context, state.message);
          // Navigate back or to next screen after successful submission
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        } else if (state is ReferralError) {
          AppSnackBar.error(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is ReferralLoading) {
          return const Scaffold(body: Center(child: LoadingScreen()));
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              TextButton(
                onPressed: _handleSkip,
                child: Text(
                  'Skip',
                  style: TextStyle(color: Colors.black.withValues(alpha: 0.5)),
                ),
              ),
            ],
            actionsPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(baseScreenPadding),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/undraw_share_1zw4.png',
                            height: 250,
                            width: 250,
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Got a referral code?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your friend\'s referral code to get rewarded',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          CustomTextField(
                            controller: _referralController,
                            hintText: 'Enter your friend\'s referral code',
                            prefixIcon: Icons.card_giftcard_outlined,
                            maxLength: 7,
                            showCounter: false,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a referral code';
                              }
                              if (value.length != 7) {
                                return 'Referral code must be exactly 7 characters';
                              }
                              // Check if it contains only letters and numbers
                              if (!RegExp(r'^[A-Z0-9]+$').hasMatch(value)) {
                                return 'Referral code can only contain letters and numbers';
                              }
                              return null;
                            },
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [UpperCaseTextFormatter()],
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(baseScreenPadding),
                  child: PrimaryButton(
                    onPressed: _handleReferralSubmit,
                    text: 'Continue',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
