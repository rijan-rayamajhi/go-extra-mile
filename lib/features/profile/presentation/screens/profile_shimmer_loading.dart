// Filename: profile_shimmer_screen.dart
// Premium profile shimmer loading screen
// Add in pubspec.yaml: shimmer: ^2.0.0

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmerLoading extends StatelessWidget {
  const ProfileShimmerLoading({super.key});

  static const double _avatarSize = 96;
  static const double _padding = 20;

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300.withValues(alpha: 0.5);
    final highlightColor = Colors.grey.shade100.withValues(alpha: 0.8);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        period: const Duration(milliseconds: 1200), // smoother animation
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(baseColor),
              const SizedBox(height: 28),
              _buildStatsRow(baseColor, context),
              const SizedBox(height: 28),
              _buildBioSection(baseColor, context),
              const SizedBox(height: 28),
              Divider(color: baseColor, thickness: 1, height: 1),
              const SizedBox(height: 20),
              ...List.generate(6, (_) => _buildListTilePlaceholder(baseColor)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color baseColor) {
    return Row(
      children: [
        Container(
          width: _avatarSize,
          height: _avatarSize,
          decoration: BoxDecoration(
            color: baseColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _roundedBox(baseColor, height: 20, width: 140),
              const SizedBox(height: 10),
              _roundedBox(baseColor, height: 16, width: 100),
              const SizedBox(height: 12),
              Row(
                children: [
                  _roundedBox(baseColor, height: 14, width: 80),
                  const SizedBox(width: 14),
                  _roundedBox(baseColor, height: 14, width: 80),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(Color baseColor, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(3, (index) {
        return Expanded(
          child: Column(
            children: [
              _roundedBox(baseColor, height: 16, width: 40),
              const SizedBox(height: 10),
              _roundedBox(baseColor, height: 14, width: double.infinity),
            ],
          ),
        );
      }).expand((w) sync* {
        yield w;
        yield const SizedBox(width: 16);
      }).toList()
        ..removeLast(),
    );
  }

  Widget _buildBioSection(Color baseColor, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _roundedBox(baseColor, height: 14, width: double.infinity),
        const SizedBox(height: 8),
        _roundedBox(baseColor, height: 14, width: double.infinity),
        const SizedBox(height: 8),
        _roundedBox(baseColor, height: 14, width: MediaQuery.of(context).size.width * 0.6),
      ],
    );
  }

  Widget _buildListTilePlaceholder(Color baseColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _roundedBox(baseColor, height: 14, width: double.infinity),
                const SizedBox(height: 8),
                _roundedBox(baseColor, height: 12, width: 120),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _roundedBox(baseColor, height: 26, width: 26),
        ],
      ),
    );
  }

  Widget _roundedBox(Color color, {required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
