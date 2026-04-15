import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../domain/entities/article_news_entity.dart';

typedef ArticleActionCallback = Future<void> Function(
    ArticleNewsEntity article);

Future<bool> _showPublishArticleConfirmationDialog(BuildContext context) async {
  final shouldPublish = await showDialog<bool>(
    context: context,
    builder: (confirmContext) {
      return AlertDialog(
        title: const Text('Publish article'),
        content: const Text(
          'Are you sure you want to publish this article?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(confirmContext).pop(true),
            child: const Text('Publish'),
          ),
        ],
      );
    },
  );

  return shouldPublish ?? false;
}

Future<void> showAuthorArticleActionsDialog({
  required BuildContext context,
  required ArticleNewsEntity article,
  required VoidCallback onEdit,
  required ArticleActionCallback onPublish,
  required ArticleActionCallback onDelete,
}) async {
  final isDraft = article.status.trim().toLowerCase() == 'draft';
  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      var isPublishing = false;
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Article actions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton(
                  onPressed: isPublishing
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                          onEdit();
                        },
                  child: const Text('Edit article'),
                ),
                if (isDraft) ...[
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: isPublishing
                        ? null
                        : () async {
                            final shouldPublish =
                                await _showPublishArticleConfirmationDialog(
                              dialogContext,
                            );
                            if (!shouldPublish) return;
                            setDialogState(() => isPublishing = true);
                            await onPublish(article);
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                            }
                          },
                    child: isPublishing
                        ? const SizedBox(
                            height: AppSpacing.huge,
                            width: AppSpacing.huge,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Publish article'),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: isPublishing
                      ? null
                      : () async {
                          Navigator.of(dialogContext).pop();
                          await onDelete(article);
                        },
                  child: const Text('Delete article'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
