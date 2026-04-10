import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../../core/utils/date_formatter.dart';

class ArticleDetailHeader extends StatelessWidget {
  final String? title;
  final String? publishedAt;

  const ArticleDetailHeader({
    super.key,
    this.title,
    this.publishedAt,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = AppDateFormatter.formatFromIsoString(publishedAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title?.trim().isNotEmpty == true ? title! : 'Untitled story',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                Ionicons.time_outline,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                formattedDate,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
