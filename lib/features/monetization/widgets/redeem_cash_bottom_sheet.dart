import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/common/widgets/custom_text_field.dart';
import 'package:go_extra_mile_new/core/utils/text_validators.dart';

class RedeemCashBottomSheet extends StatefulWidget {
  final int selectedAmount;
  final VoidCallback? onSuccess;

  const RedeemCashBottomSheet({
    super.key,
    required this.selectedAmount,
    this.onSuccess,
  });

  @override
  State<RedeemCashBottomSheet> createState() => _RedeemCashBottomSheetState();
}

class _RedeemCashBottomSheetState extends State<RedeemCashBottomSheet> {
  // Form controllers
  final TextEditingController upiIdController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController whatsappNumberController = TextEditingController();
  
  // Form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isTermsAccepted = false;
  
  // Validation errors
  String? upiIdError;
  String? userNameError;
  String? phoneNumberError;
  String? whatsappNumberError;
  
  // Validation methods
  String? _validateUpiId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'UPI ID is required';
    }
    final trimmedValue = value.trim();
    // UPI ID format validation (e.g., user@paytm, user@phonepe, user@googlepay)
    const pattern = r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(pattern).hasMatch(trimmedValue)) {
      return 'Please enter a valid UPI ID (e.g., user@paytm)';
    }
    return null;
  }
  
  String? _validateUserName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'User name is required';
    }
    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (trimmedValue.length > 50) {
      return 'Name must be less than 50 characters';
    }
    return null;
  }
  
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final trimmedValue = value.trim();
    const pattern = r'^[0-9]{10}$';
    if (!RegExp(pattern).hasMatch(trimmedValue)) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }
  
  String? _validateWhatsappNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'WhatsApp number is required';
    }
    return TextValidators.whatsapp(value);
  }
  
  void _validateForm() {
    setState(() {
      upiIdError = _validateUpiId(upiIdController.text);
      userNameError = _validateUserName(userNameController.text);
      phoneNumberError = _validatePhoneNumber(phoneNumberController.text);
      whatsappNumberError = _validateWhatsappNumber(whatsappNumberController.text);
    });
  }
  
  bool _isFormValid() {
    return upiIdError == null &&
           userNameError == null &&
           phoneNumberError == null &&
           whatsappNumberError == null &&
           isTermsAccepted;
  }
  
  @override
  void dispose() {
    upiIdController.dispose();
    userNameController.dispose();
    phoneNumberController.dispose();
    whatsappNumberController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green[600],
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Redeem Request Submitted',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your redeem request for ₹${widget.selectedAmount} has been submitted successfully. You will receive the amount within 2-3 business days.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onSuccess?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title and Subtitle
              const Text(
                'Redeem Cash',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your details to redeem ₹${widget.selectedAmount}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Scrollable form content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // UPI ID Field
                      CustomTextField(
                        label: 'UPI ID',
                        controller: upiIdController,
                        prefixIcon: Icons.account_balance_wallet,
                        hintText: 'Enter your UPI ID (e.g., user@paytm)',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: _validateUpiId,
                        onChanged: (value) {
                          setState(() {
                            upiIdError = _validateUpiId(value);
                          });
                        },
                      ),
                      if (upiIdError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 16),
                          child: Text(
                            upiIdError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      // User Name Field
                      CustomTextField(
                        label: 'Full Name',
                        controller: userNameController,
                        prefixIcon: Icons.person,
                        hintText: 'Enter your full name',
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        validator: _validateUserName,
                        onChanged: (value) {
                          setState(() {
                            userNameError = _validateUserName(value);
                          });
                        },
                      ),
                      if (userNameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 16),
                          child: Text(
                            userNameError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      // Phone Number Field
                      CustomTextField(
                        label: 'Phone Number',
                        controller: phoneNumberController,
                        prefixIcon: Icons.phone,
                        hintText: 'Enter your phone number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: _validatePhoneNumber,
                        onChanged: (value) {
                          setState(() {
                            phoneNumberError = _validatePhoneNumber(value);
                          });
                        },
                      ),
                      if (phoneNumberError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 16),
                          child: Text(
                            phoneNumberError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 16),
                      
                      // WhatsApp Number Field
                      CustomTextField(
                        label: 'WhatsApp Number',
                        controller: whatsappNumberController,
                        prefixIcon: Icons.chat,
                        hintText: 'Enter your WhatsApp number',
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        maxLength: 10,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: _validateWhatsappNumber,
                        onChanged: (value) {
                          setState(() {
                            whatsappNumberError = _validateWhatsappNumber(value);
                          });
                        },
                      ),
                      if (whatsappNumberError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 16),
                          child: Text(
                            whatsappNumberError!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 20),
                      
                      // Terms and Conditions Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isTermsAccepted,
                            onChanged: (value) {
                              setState(() {
                                isTermsAccepted = value ?? false;
                              });
                            },
                            activeColor: Colors.black,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: ' for cash redemption.'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              
              // Action button
              PrimaryButton(
                text: 'Redeem ₹${widget.selectedAmount}',
                onPressed: () {
                  _validateForm();
                  if (_isFormValid()) {
                    Navigator.pop(context);
                    _showSuccessDialog(context);
                  }
                },
              ),
              const SizedBox(height: 12),
              
              // Cancel button
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
