import 'package:flutter/material.dart';

class ArticleDetailContent extends StatelessWidget {
  final String? description;
  final String? content;

  const ArticleDetailContent({
    super.key,
    this.description,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final descriptionText = description?.trim() ?? '';
    final contentText = content?.trim() ?? '';
    final fullText = '$descriptionText\n\n$contentText'.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: Text(
        fullText.isNotEmpty ? fullText : 'No content available.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }
}
