import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_bloc.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_event.dart';
import 'package:go_extra_mile_new/features/auth/presentation/bloc/kauth_state.dart';
import 'package:go_extra_mile_new/features/auth/domain/entities/account_deletion_info.dart';
import 'package:go_extra_mile_new/features/auth/presentation/screens/auth_screen.dart';
import 'package:go_extra_mile_new/common/widgets/app_snackbar.dart';

class AccountDeletedScreen extends StatefulWidget {
  const AccountDeletedScreen({super.key});

  @override
  State<AccountDeletedScreen> createState() => _AccountDeletedScreenState();
}

class _AccountDeletedScreenState extends State<AccountDeletedScreen> {
  Timer? _timer;
  Duration _remaining = const Duration(days: 14);

  @override
  void initState() {
    super.initState();
  }

  void _calculateRemainingTime(AccountDeletionInfo? deletionInfo) {
    if (deletionInfo != null) {
      final deletionDate = deletionInfo.createdAt;
      final gracePeriodEnd = deletionDate.add(const Duration(days: 14));
      final now = DateTime.now();
      
      if (now.isBefore(gracePeriodEnd)) {
        _remaining = gracePeriodEnd.difference(now);
      } else {
        _remaining = Duration.zero;
      }
    } else {
      // Fallback to 14 days if no deletion info
      _remaining = const Duration(days: 14);
    }
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel existing timer if any
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  Widget _buildRoundedClock(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: Stack(
        children: [
          // Clock face
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
                width: 2,
              ),
            ),
          ),
          // Center content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Days
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    days.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'DAYS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                // Time (hours:minutes:seconds)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeUnit(hours.toString().padLeft(2, '0'), 'H'),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    _buildTimeUnit(minutes.toString().padLeft(2, '0'), 'M'),
                    const Text(
                      ':',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    _buildTimeUnit(seconds.toString().padLeft(2, '0'), 'S'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  void _showRestoreConfirmationDialog(
    BuildContext context,
    AccountDeletionInfo? deletionInfo,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Restore Account",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Text(
            deletionInfo != null
                ? "Are you sure you want to restore your account?\n\nAccount was deleted on: ${_formatDate(deletionInfo.createdAt)}\nReason: ${deletionInfo.reason}"
                : "Are you sure you want to restore your account?",
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _restoreAccount(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Yes, Restore", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  void _restoreAccount(BuildContext context) {
    // Get the current user's UID from Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<KAuthBloc>().add(KRestoreAccountEvent(user.uid));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<KAuthBloc, KAuthState>(
      listener: (context, state) {
        if (state is KAuthInitial) {
          // Account restored successfully and user signed out
          AppSnackBar.success(context, "Account restored successfully! Please sign in again.");
          // Don't navigate here - let the AuthWrapper handle navigation
          // The AuthWrapper will automatically show the auth screen when state becomes KAuthInitial
        } else if (state is KAuthFailure) {
          AppSnackBar.error(context, "Failed to restore account: ${state.message}");
        }
      },
      child: BlocBuilder<KAuthBloc, KAuthState>(
        builder: (context, state) {
          // Get deletion info from state
          AccountDeletionInfo? deletionInfo;
          if (state is KAuthDeletedUser) {
            deletionInfo = state.deletionInfo;
          }
          
          // Calculate remaining time and start timer when deletion info is available
          if (deletionInfo != null && (_timer == null || !_timer!.isActive)) {
            _calculateRemainingTime(deletionInfo);
            _startTimer();
          }

          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () {
                  context.read<KAuthBloc>().add(KSignOutEvent());
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.close),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Colors.black.withOpacity(
                          0.04,
                        ), // very subtle glass
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.black87,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Account Deleted",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 26,
                                  color: Colors.black87,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            deletionInfo != null
                                ? "Your account was deleted on ${_formatDate(deletionInfo.createdAt)}.\nReason: ${deletionInfo.reason}\n\nYou have 14 days to restore it before it is permanently removed."
                                : "Your account has been deleted.\nYou have 14 days to restore it before it is permanently removed.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildRoundedClock(_remaining),
                          const SizedBox(height: 40),
                          OutlinedButton.icon(
                            onPressed: () {
                              _showRestoreConfirmationDialog(
                                context,
                                deletionInfo,
                              );
                            },
                            icon: const Icon(
                              Icons.restore,
                              color: Colors.black87,
                            ),
                            label: const Text(
                              "Restore Account",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.black26),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ClockProgressPainter extends CustomPainter {
  final double progress;

  ClockProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = Colors.red.withOpacity(0.7)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ClockProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
