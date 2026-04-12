import 'package:flutter/material.dart';

import '../../../../../core/widgets/article_description_display.dart';

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
    final hasDescription = descriptionText.isNotEmpty;
    final hasContent = contentText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasDescription)
            Text(
              descriptionText,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          if (hasDescription && hasContent) const SizedBox(height: 18),
          if (hasContent) ArticleDescriptionFormatted(raw: contentText),
          if (!hasDescription && !hasContent)
            Text(
              'No content available.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
        ],
      ),
    );
  }
}
