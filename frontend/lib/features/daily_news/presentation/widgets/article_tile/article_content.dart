import 'package:flutter/material.dart';

import '../../../../../core/widgets/date_chip.dart';
import '../../../../../core/widgets/reading_time_widget.dart';
import '../../../../../core/utils/date_formatter.dart';

class ArticleTileContent extends StatelessWidget {
  final String? title;
  final String? description;
  final String? publishedAt;
  final String readingTimeLabel;

  const ArticleTileContent({
    super.key,
    this.title,
    this.description,
    this.publishedAt,
    required this.readingTimeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = AppDateFormatter.formatFromIsoString(publishedAt);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title?.trim().isNotEmpty == true ? title! : 'Untitled story',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description?.trim().isNotEmpty == true
                ? description!
                : 'Tap to explore the full article and details.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DateChip(
                label: formattedDate,
              ),
              ReadingTimeWidget(
                label: readingTimeLabel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
