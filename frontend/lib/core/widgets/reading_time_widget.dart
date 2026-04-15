import 'package:flutter/material.dart';

class ReadingTimeWidget extends StatelessWidget {
  final String label;

  const ReadingTimeWidget({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.0,
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
