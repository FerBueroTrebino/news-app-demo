import 'package:flutter/material.dart';

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
          if (i > 0) const SizedBox(height: 10),
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
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
            height: 1.3,
          ),
        );
      case ArticleDescriptionSegmentKind.bullet:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Icon(
                Icons.circle,
                size: 6,
                color: theme.colorScheme.primary.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                segment.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  height: 1.45,
                ),
              ),
            ),
          ],
        );
      case ArticleDescriptionSegmentKind.paragraph:
        return Text(
          segment.text,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            height: 1.45,
          ),
        );
    }
  }
}
