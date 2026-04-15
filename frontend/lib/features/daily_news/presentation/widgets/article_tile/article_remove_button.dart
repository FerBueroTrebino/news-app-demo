import 'package:flutter/material.dart';

class ArticleTileRemoveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ArticleTileRemoveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton.filledTonal(
      tooltip: 'Remove from saved',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.error,
        shape: const CircleBorder(),
      ),
      icon: const Icon(
        Icons.bookmark_remove_rounded,
      ),
    );
  }
}
