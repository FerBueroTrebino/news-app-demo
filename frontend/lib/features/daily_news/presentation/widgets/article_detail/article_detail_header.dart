import 'package:flutter/material.dart';

import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/widgets/date_chip.dart';
import '../../../../../core/widgets/reading_time_widget.dart';
import '../../../../../core/utils/date_formatter.dart';

class ArticleDetailHeader extends StatelessWidget {
  final String? title;
  final String? publishedAt;
  final String readingTimeLabel;

  const ArticleDetailHeader({
    super.key,
    this.title,
    this.publishedAt,
    required this.readingTimeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = AppDateFormatter.formatFromIsoString(publishedAt);

    return Padding(
      padding: AppPadding.horizontalXxl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title?.trim().isNotEmpty == true ? title! : 'Untitled story',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xl),
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
