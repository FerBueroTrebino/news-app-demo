import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: _onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 140),
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Stack(
                    children: [
                      ArticleTileImage(url: article.urlToImage),
                      if (isRemovable)
                        Positioned(
                          top: 6,
                          right: 6,
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
