import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/date_chip.dart';
import '../../domain/entities/article_news_entity.dart';

class AuthorArticleTile extends StatelessWidget {
  const AuthorArticleTile({
    super.key,
    required this.article,
    required this.dateFormat,
    this.onTap,
  });

  final ArticleNewsEntity article;
  final DateFormat dateFormat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: AppPadding.horizontalXxlVerticalSm,
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0),
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
          child: InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 140),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AuthorArticleThumbnail(imageUrl: article.thumbnailUrl),
                  Padding(
                    padding: AppPadding.allLg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title.trim().isNotEmpty
                              ? article.title
                              : 'Untitled story',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          article.description.trim().isNotEmpty
                              ? article.description
                              : 'No description yet.',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            Expanded(
                              child: _MetaChip(
                                icon: Icons.topic_rounded,
                                label: _formatCategoryLabel(article.category),
                                foregroundColor: theme.colorScheme.primary,
                                truncateLabel: true,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _StatusChip(status: article.status),
                            const SizedBox(width: AppSpacing.sm),
                            DateChip(
                              label: dateFormat.format(article.updatedAt),
                            ),
                          ],
                        ),
                      ],
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
}

String _formatCategoryLabel(String category) {
  final t = category.trim();
  if (t.isEmpty) return 'General';
  return '${t[0].toUpperCase()}${t.length > 1 ? t.substring(1).toLowerCase() : ''}';
}

class _AuthorArticleThumbnail extends StatelessWidget {
  const _AuthorArticleThumbnail({required this.imageUrl});

  /// Resolved network URL (empty when missing or unresolved upstream).
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = imageUrl.trim();
    if (url.isEmpty) {
      return _ThumbnailPlaceholder(theme: theme);
    }

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (_, imageProvider) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusSm),
          topRight: Radius.circular(AppSpacing.radiusSm),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      progressIndicatorBuilder: (_, __, ___) => AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => _ThumbnailPlaceholder(theme: theme),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(AppSpacing.radiusSm),
        topRight: Radius.circular(AppSpacing.radiusSm),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.surfaceContainerHighest,
                theme.colorScheme.surfaceContainerHigh,
              ],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    this.truncateLabel = false,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;
  final bool truncateLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: Row(
        mainAxisSize: truncateLabel ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foregroundColor),
          const SizedBox(width: AppSpacing.xxs),
          Flexible(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: foregroundColor),
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: truncateLabel
                    ? TextOverflow.ellipsis
                    : TextOverflow.visible,
                style: theme.textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalized = status.trim().toLowerCase();
    final bg = _statusBackground(normalized, theme);
    final fg = _statusForeground(normalized, theme);
    final icon = _statusIcon(normalized);

    return Container(
      padding: AppPadding.horizontalMdVerticalXxs,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.08),
        ),
      ),
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xxs),
            DefaultTextStyle.merge(
              style: TextStyle(color: fg),
              child: Text(
                _formatStatusLabel(status),
                style: theme.textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusBackground(String normalized, ThemeData theme) {
    switch (normalized) {
      case 'published':
        return theme.colorScheme.primary.withValues(alpha: 0.12);
      case 'draft':
        return theme.colorScheme.surfaceContainerHighest;
      case 'archived':
        return theme.colorScheme.tertiary.withValues(alpha: 0.1);
      default:
        return theme.colorScheme.surfaceContainerHighest;
    }
  }

  Color _statusForeground(String normalized, ThemeData theme) {
    switch (normalized) {
      case 'published':
        return theme.colorScheme.primary;
      case 'draft':
        return theme.colorScheme.onSurfaceVariant;
      case 'archived':
        return theme.colorScheme.tertiary;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  IconData _statusIcon(String normalized) {
    switch (normalized) {
      case 'published':
        return Icons.verified_outlined;
      case 'draft':
        return Icons.edit_note_rounded;
      case 'archived':
        return Icons.inventory_2_outlined;
      default:
        return Icons.label_outline_rounded;
    }
  }

  String _formatStatusLabel(String raw) {
    final t = raw.trim().toLowerCase();
    if (t.isEmpty) return 'Unknown';
    return '${t[0].toUpperCase()}${t.length > 1 ? t.substring(1) : ''}';
  }
}
