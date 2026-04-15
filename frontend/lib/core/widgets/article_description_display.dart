import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../utils/article_description_markup.dart';

class ArticleDescriptionFormatted extends StatelessWidget {
  const ArticleDescriptionFormatted({
    super.key,
    required this.raw,
  });

  final String raw;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final segments = ArticleDescriptionMarkup.parse(raw);
    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.md),
          _segmentWidget(context, theme, segments[i]),
        ],
      ],
    );
  }

  Widget _segmentWidget(
    BuildContext context,
    ThemeData theme,
    ArticleDescriptionSegment segment,
  ) {
    switch (segment.kind) {
      case ArticleDescriptionSegmentKind.subtitle:
        return Text(
          segment.text,
          style: theme.textTheme.titleMedium,
        );
      case ArticleDescriptionSegmentKind.bullet:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppPadding.topXs,
              child: Icon(
                Icons.circle,
                size: 6,
                color: theme.colorScheme.primary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                segment.text,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        );
      case ArticleDescriptionSegmentKind.paragraph:
        return Text(
          segment.text,
          style: theme.textTheme.bodyLarge,
        );
    }
  }
}
