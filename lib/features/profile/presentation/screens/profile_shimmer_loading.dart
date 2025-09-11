// Filename: profile_shimmer_screen.dart
// Premium profile shimmer loading screen
// Add in pubspec.yaml: shimmer: ^2.0.0

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';

class ProfileShimmerLoading extends StatelessWidget {
  const ProfileShimmerLoading({super.key});

  static const double _baseAvatarSize = 96;
  static const double _basePadding = 20;

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
          padding: context.padding(all: _basePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(baseColor, context),
              SizedBox(height: context.baseSpacing(28)),
              _buildStatsRow(baseColor, context),
              SizedBox(height: context.baseSpacing(28)),
              _buildBioSection(baseColor, context),
              SizedBox(height: context.baseSpacing(28)),
              Divider(color: baseColor, thickness: 1, height: 1),
              SizedBox(height: context.baseSpacing(20)),
              ...List.generate(6, (_) => _buildListTilePlaceholder(baseColor, context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color baseColor, BuildContext context) {
    return Row(
      children: [
        Container(
          width: context.iconSize(_baseAvatarSize),
          height: context.iconSize(_baseAvatarSize),
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
        SizedBox(width: context.baseSpacing(20)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _roundedBox(baseColor, height: 20, width: 140, context: context),
              SizedBox(height: context.baseSpacing(10)),
              _roundedBox(baseColor, height: 16, width: 100, context: context),
              SizedBox(height: context.baseSpacing(12)),
              Row(
                children: [
                  _roundedBox(baseColor, height: 14, width: 80, context: context),
                  SizedBox(width: context.baseSpacing(14)),
                  _roundedBox(baseColor, height: 14, width: 80, context: context),
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
              _roundedBox(baseColor, height: 16, width: 40, context: context),
              SizedBox(height: context.baseSpacing(10)),
              _roundedBox(baseColor, height: 14, width: double.infinity, context: context),
            ],
          ),
        );
      }).expand((w) sync* {
        yield w;
        yield SizedBox(width: context.baseSpacing(16));
      }).toList()
        ..removeLast(),
    );
  }

  Widget _buildBioSection(Color baseColor, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _roundedBox(baseColor, height: 14, width: double.infinity, context: context),
        SizedBox(height: context.baseSpacing(8)),
        _roundedBox(baseColor, height: 14, width: double.infinity, context: context),
        SizedBox(height: context.baseSpacing(8)),
        _roundedBox(baseColor, height: 14, width: context.width(60), context: context),
      ],
    );
  }

  Widget _buildListTilePlaceholder(Color baseColor, BuildContext context) {
    return Padding(
      padding: context.padding(vertical: 12),
      child: Row(
        children: [
          Container(
            width: context.iconSize(52),
            height: context.iconSize(52),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(context.borderRadius(14)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
          ),
          SizedBox(width: context.baseSpacing(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _roundedBox(baseColor, height: 14, width: double.infinity, context: context),
                SizedBox(height: context.baseSpacing(8)),
                _roundedBox(baseColor, height: 12, width: 120, context: context),
              ],
            ),
          ),
          SizedBox(width: context.baseSpacing(16)),
          _roundedBox(baseColor, height: 26, width: 26, context: context),
        ],
      ),
    );
  }

  Widget _roundedBox(Color color, {required double height, required double width, BuildContext? context}) {
    return Container(
      height: context != null ? context.height(height * 100 / context.screenHeight) : height,
      width: context != null ? context.width(width * 100 / context.screenWidth) : width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(context?.borderRadius(8) ?? 8),
      ),
    );
  }
}
