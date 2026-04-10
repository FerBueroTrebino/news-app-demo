import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class ArticleDetailSaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ArticleDetailSaveButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Ionicons.bookmark),
    );
  }
}
