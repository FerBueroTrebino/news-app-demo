import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
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
      padding: AppPadding.allLg,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title?.trim().isNotEmpty == true ? title! : 'Untitled story',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description?.trim().isNotEmpty == true
                ? description!
                : 'Tap to explore the full article and details.',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
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
