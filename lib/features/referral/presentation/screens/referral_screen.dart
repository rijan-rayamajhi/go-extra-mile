import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/auth_event.dart';
import '../bloc/referral_bloc.dart';
import '../bloc/referral_event.dart';
import '../bloc/referral_state.dart';

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

  String? _validateReferralCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a unique referral code';
    }
    
    final trimmedValue = value.trim();
    
    if (trimmedValue.length != 6) {
      return 'Referral code must be exactly 6 characters';
    }
    
    if (!RegExp(r'^[A-Z0-9]+$').hasMatch(trimmedValue)) {
      return 'Only capital letters and numbers are allowed';
    }
    
    return null;
  }

  void _handleReferralSubmit() {
    if (!_formKey.currentState!.validate()) return;
    
    context.read<ReferralBloc>().add(
      SubmitReferralCode(_referralController.text),
    );
  }

  void _handleSkip() {
    context.read<ReferralBloc>().add(const SkipReferral());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReferralBloc, ReferralState>(
      listener: (context, state) {
        if (state is ReferralError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is ReferralSuccess) {
          // Emit event to auth bloc to mark referral as completed
          context.read<AuthBloc>().add(ReferralCompletedEvent());
        } else if (state is ReferralSkipped) {
          // Emit event to auth bloc to mark referral as completed
          context.read<AuthBloc>().add(ReferralCompletedEvent());
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 16),
                  child: TextButton(
                    onPressed: _handleSkip,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          //TODO : Referral Image
                          const SizedBox(height: 32),
                          const Text(
                            'Got a referral code?',
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Gilroy',
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Enter your friend\'s referral code to get rewarded',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontFamily: 'Gilroy',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          TextFormField(
                            controller: _referralController,
                            validator: _validateReferralCode,
                            textCapitalization: TextCapitalization.characters,
                            autofocus: false,
                            maxLength: 6,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: 'Gilroy',
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Referral Code',
                              hintText: 'Enter friend\'s referral code',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              prefixIcon: Icon(
                                Icons.card_giftcard_outlined,
                              ),
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                child: BlocBuilder<ReferralBloc, ReferralState>(
                  builder: (context, state) {
                    return PrimaryButton(
                      onPressed: _handleReferralSubmit, 
                      text: 'Continue',
                      isLoading: state is ReferralLoading,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
