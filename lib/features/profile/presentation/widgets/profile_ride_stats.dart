import 'package:flutter/material.dart';
import 'package:go_extra_mile_new/core/utils/responsive_utils.dart';
import 'package:go_extra_mile_new/core/constants/app_constants.dart';

class RideStatsWidget extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const RideStatsWidget({super.key, required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return 
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: context.padding(all: 3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Container(
            padding: context.padding(all: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: context.iconSize(26),
            ),
          ),
        ),
        SizedBox(height: context.spacing(baseSmallSpacing)),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.1,
          ),
        ),
        SizedBox(height: context.spacing(6)),
        Text(
          label,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            height: 1.2,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}