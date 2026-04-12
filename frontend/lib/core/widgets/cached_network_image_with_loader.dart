import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachedNetworkImageWithLoader extends StatelessWidget {
  const CachedNetworkImageWithLoader({
    super.key,
    required this.imageUrl,
    required this.imageBuilder,
    this.errorWidget,
    this.wrapProgress,
    this.progressIndicatorSize = 24,
    this.cacheManager,
  });

  final String imageUrl;
  final ImageWidgetBuilder imageBuilder;
  final LoadingErrorWidgetBuilder? errorWidget;

  final Widget Function(BuildContext context, Widget progressIndicator)?
      wrapProgress;

  final double progressIndicatorSize;

  /// When set (e.g. in tests), bypasses the default disk cache / HTTP stack.
  final BaseCacheManager? cacheManager;

  @override
  Widget build(BuildContext context) {
    final indicator =
        _NetworkImageProgressIndicator(size: progressIndicatorSize);
    final progressBody = wrapProgress != null
        ? wrapProgress!(context, indicator)
        : Center(child: indicator);

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: imageBuilder,
      progressIndicatorBuilder: (_, __, ___) => progressBody,
      errorWidget: errorWidget,
      cacheManager: cacheManager,
    );
  }
}

class _NetworkImageProgressIndicator extends StatelessWidget {
  const _NetworkImageProgressIndicator({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: theme.colorScheme.primary.withValues(alpha: 0.6),
      ),
    );
  }
}
