import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';

class DateChip extends StatelessWidget {
  final String label;

  const DateChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 12,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.xs),
        MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.0,
          child: Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
