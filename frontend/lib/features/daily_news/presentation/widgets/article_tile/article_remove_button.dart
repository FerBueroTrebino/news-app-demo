import 'package:flutter/material.dart';

class ArticleTileRemoveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ArticleTileRemoveButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: 'Remove from saved',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.red,
        shape: const CircleBorder(),
      ),
      icon: const Icon(
        Icons.bookmark_remove_rounded,
      ),
    );
  }
}
