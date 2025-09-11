import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/common/widgets/primary_button.dart';
import 'package:go_extra_mile_new/features/auth/presentation/screens/auth_wrapper.dart';
import '../bloc/kauth_bloc.dart';
import '../bloc/kauth_event.dart';
import '../bloc/kauth_state.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  String? selectedReason;
  bool _isLoading = false;

  final List<String> reasons = [
    "Privacy concerns",
    "Too many notifications",
    "Creating a new account",
    "Not satisfied with service",
    "App crashes frequently",
    "Poor customer support",
    "Found a better alternative",
    "No longer need the service",
    "Technical issues",
    "Account security concerns",
    "Other"
  ];

  void _deleteAccount(BuildContext context) {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a reason for deletion"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No user logged in"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<KAuthBloc>().add(
      KDeleteAccountEvent(user.uid, selectedReason!),
    );

            if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    //
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Confirm Account Deletion",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: const Text(
            "Take a deep breath... Are you sure you want to delete your account? This action cannot be undone.",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : () {
                Navigator.of(context).pop();
                _deleteAccount(context);

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    "Yes, Delete",
                    style: TextStyle(fontSize: 16),
                  ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KAuthBloc, KAuthState>(
      listener: (context, state) {
        if (state is KAuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is KAuthInitial) {
          setState(() {
            _isLoading = false;
          });
          // Account successfully deleted and user signed out
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
          // Don't navigate here - let the AuthWrapper handle navigation
          // The AuthWrapper will automatically show the auth screen when state becomes KAuthInitial
        } else if (state is KAuthFailure) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete account: ${state.message}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<KAuthBloc, KAuthState>(
        builder: (context, state) {
          return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Delete Account",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sad goodbye message
            Text(
              "😔 Sad to see you go!",
              style: TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Before you delete your account, please let us know why. "
              "We'd also like to share recovery options with you.",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 25),

            // Reason of deletion
            Text(
              "Reason for deletion",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) => SafeArea(
                    child: Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.6,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Select Reason",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...reasons.map((reason) => ListTile(
                                title: Text(
                                  reason,
                                  style: const TextStyle(color: Colors.black),
                                ),
                                leading: Radio<String>(
                                  value: reason,
                                  groupValue: selectedReason,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedReason = value;
                                    });
                                    Navigator.pop(context);
                                  },
                                  activeColor: Colors.black,
                                ),
                                onTap: () {
                                  setState(() {
                                    selectedReason = reason;
                                  });
                                  Navigator.pop(context);
                                },
                              )),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        selectedReason ?? "Select a reason",
                        style: TextStyle(
                          color: selectedReason != null ? Colors.black : Colors.black45,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // Recovery steps
            Text(
              "Recovery steps",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "If you delete your account, you will lose access to your data. "
                "You may recover your account within 14 days by signing in again "
                "with your registered phone number.",
                style: TextStyle(color: Colors.black87, fontSize: 14),
              ),
            ),


            const Spacer(),
             PrimaryButton(
               text: _isLoading ? 'Deleting Account...' : 'Delete Account',
               onPressed: _isLoading 
                 ? () {} // Empty function when loading
                 : () {
                     _showDeleteConfirmationDialog(context);
                   },
             ),
            const SizedBox(height: 20),
          ],
        ),
      ),
          );
        },
      ),
    );
  }
}