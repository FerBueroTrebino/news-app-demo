import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/reading_time_estimator.dart';
import '../../domain/entities/article_entity.dart';
import 'article_tile/article_content.dart';
import 'article_tile/article_image.dart';
import 'article_tile/article_remove_button.dart';

class ArticleWidget extends StatelessWidget {
  final ArticleEntity article;
  final bool isRemovable;
  final void Function(ArticleEntity article)? onRemove;
  final void Function(ArticleEntity article)? onArticlePressed;

  const ArticleWidget({
    super.key,
    required this.article,
    this.onArticlePressed,
    this.isRemovable = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: AppPadding.horizontalXxlVerticalSm,
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          onTap: _onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, AppSpacing.sm),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 140),
              child: ListView(
                shrinkWrap: true,
                padding: AppPadding.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Stack(
                    children: [
                      ArticleTileImage(url: article.urlToImage),
                      if (isRemovable)
                        Positioned(
                          top: AppSpacing.xs,
                          right: AppSpacing.xs,
                          child: ArticleTileRemoveButton(
                            onPressed: _onRemove,
                          ),
                        ),
                    ],
                  ),
                  ArticleTileContent(
                    title: article.title,
                    description: article.description,
                    publishedAt: article.publishedAt,
                    readingTimeLabel: ReadingTimeEstimator.formatLabel(
                      title: article.title,
                      description: article.description,
                      content: article.content,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTap() {
    if (onArticlePressed != null) {
      onArticlePressed!(article);
    }
  }

  void _onRemove() {
    if (onRemove != null) {
      onRemove!(article);
    }
  }
}
