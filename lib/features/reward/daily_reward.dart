import 'dart:ui';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scratcher/scratcher.dart';
import 'package:go_extra_mile_new/features/reward/presentation/bloc/daily_reward_bloc.dart';
import 'package:go_extra_mile_new/features/reward/presentation/bloc/daily_reward_event.dart';
import 'package:go_extra_mile_new/features/reward/presentation/bloc/daily_reward_state.dart';
import 'package:go_extra_mile_new/features/reward/domain/entities/daily_reward_entity.dart';

class DailyRewardScreen extends StatefulWidget {
  const DailyRewardScreen({super.key});

  @override
  State<DailyRewardScreen> createState() => _DailyRewardScreenState();
}

enum RewardState { available, notAvailable, scratched }

class _DailyRewardScreenState extends State<DailyRewardScreen> {
  RewardState rewardState = RewardState.available;
  int? randomGemAmount; // Store the random gem amount
  DailyRewardEntity? dailyRewardData;

  String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  @override
  void initState() {
    super.initState();
    // Load daily reward data when screen initializes
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      context.read<DailyRewardBloc>().add(GetDailyRewardEvent(currentUser.uid));
    }
  }

  void _generateRandomGemAmount() {
    final random = Random();
    randomGemAmount = random.nextInt(100) + 1; // Random number between 1-100
  }

  void _determineRewardState() {
    if (dailyRewardData == null) return;
    
    final now = DateTime.now();
    final nextAvailable = dailyRewardData!.nextAvailableAt;
    
    if (now.isBefore(nextAvailable)) {
      rewardState = RewardState.notAvailable;
    } else if (dailyRewardData!.lastScratchAt != null) {
      // Check if user already scratched today
      final lastScratch = dailyRewardData!.lastScratchAt!;
      final today = DateTime(now.year, now.month, now.day);
      final lastScratchDay = DateTime(lastScratch.year, lastScratch.month, lastScratch.day);
      
      if (today.isAtSameMomentAs(lastScratchDay)) {
        rewardState = RewardState.scratched;
        randomGemAmount = dailyRewardData!.rewardAmount;
      } else {
        rewardState = RewardState.available;
      }
    } else {
      rewardState = RewardState.available;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DailyRewardBloc, DailyRewardState>(
      listener: (context, state) {
        if (state is DailyRewardLoaded) {
          setState(() {
            dailyRewardData = state.dailyReward;
            _determineRewardState();
          });
        } else if (state is DailyRewardError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: BlocBuilder<DailyRewardBloc, DailyRewardState>(
        builder: (context, state) {
          if (state is DailyRewardLoading) {
            return Scaffold(
              body: Stack(
                children: [
                  // Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Loading indicator
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            );
          }

          return Scaffold(
            body: Stack(
              children: [
                // 🔹 Background to blur
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.white],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),

                // 🔹 Glassy overlay
                ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.white.withOpacity(0.2), // frosted glass tint
                    ),
                  ),
                ),

                // 🔹 Foreground back button
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                // 🔹 Main content based on reward state
                _buildRewardContent(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardContent() {
    switch (rewardState) {
      case RewardState.available:
        return _buildRewardLayout(
          card: _scratchCard(),
          description:
              "Scratch the card to reveal your special daily reward. Come back every day for more surprises!",
        );

      case RewardState.notAvailable:
        final nextAvailable = dailyRewardData?.nextAvailableAt ?? DateTime.now().add(const Duration(days: 1));

        return _buildRewardLayout(
          card: _lockedCard(nextAvailable),
          description:
              "You can scratch the card again on ${_getDayName(nextAvailable.weekday)}",
        );

      case RewardState.scratched:
        return _buildRewardLayout(
          card: _scratchedCard(),
          description:
              "Hurray! You have scratched the card and won $randomGemAmount gem coins.",
        );
    }
  }

  /// 🔹 Common Layout: Scratch/Locked/Scratched Card + Bottom Sheet
  Widget _buildRewardLayout({
    required Widget card,
    required String description,
  }) {
    return Stack(
      children: [
        Align(
          alignment: const Alignment(0, -0.2), // slightly above center
          child: card,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _bottomSheet(description),
        ),
      ],
    );
  }

  /// 🔹 Bottom Sheet (Reusable)
  Widget _bottomSheet(String description) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    "assets/images/app_logo.PNG",
                    height: 50,
                    width: 50,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Go Extra Mile",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Daily Reward 🎁",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// 🔹 Scratchable Card (Before scratching)
  Widget _scratchCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: 250,
        height: 250,
        child: Scratcher(
          brushSize: 60,
          threshold: 40, // Percentage of area that needs to be scratched
          image: Image.asset(
            "assets/images/scratch_card.JPG",
            fit: BoxFit.cover,
            width: 250,
            height: 250,
          ), // This is the overlay image that gets scratched away
          onChange: (value) {
            // Provide light haptic feedback during scratching
            if (value % 10 == 0 && value > 0) { // Every 10% progress
              HapticFeedback.lightImpact();
            }
          },
          onThreshold: () {
            // Called when threshold is reached
            _generateRandomGemAmount();
            
            // Provide haptic feedback for the reward reveal
            HapticFeedback.heavyImpact();
            
            final currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null && randomGemAmount != null) {
              // Update reward in the backend
              context.read<DailyRewardBloc>().add(
                UpdateRewardEvent(currentUser.uid, randomGemAmount!),
              );
            }
            setState(() {
              rewardState = RewardState.scratched;
            });
          },
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              // image: const DecorationImage(
              //   image: AssetImage("assets/icons/gem_coin.png" ,),
              //   fit: BoxFit.cover,
                
              // ),
            ),
            child: Column (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/icons/gem_coin.png",
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
                 Text(
                 '🫣',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Locked Card (Not available yet)
  Widget _lockedCard(DateTime nextAvailable) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            Image.asset(
              "assets/images/scratch_card.JPG",
              fit: BoxFit.cover,
              width: 250,
              height: 250,
            ),
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black.withOpacity(0.6),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    "Available At",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${nextAvailable.day}/${nextAvailable.month}/${nextAvailable.year}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDayName(nextAvailable.weekday),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Scratched Card (Reward revealed)
  Widget _scratchedCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/icons/gem_coin.png",
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 32),
            Text(
              randomGemAmount?.toString() ?? "0",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
