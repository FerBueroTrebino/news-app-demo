import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../../../core/widgets/cached_network_image_with_loader.dart';

class ArticleDetailImage extends StatelessWidget {
  final String? imageUrl;

  /// Optional cache manager (e.g. test fakes that keep the image in a loading state).
  final BaseCacheManager? cacheManager;

  const ArticleDetailImage({
    super.key,
    this.imageUrl,
    this.cacheManager,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = imageUrl?.trim().isNotEmpty == true;

    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      color: theme.colorScheme.surfaceContainerHighest,
      child: hasImage
          ? CachedNetworkImageWithLoader(
              imageUrl: imageUrl!.trim(),
              cacheManager: cacheManager,
              progressIndicatorSize: 28,
              imageBuilder: (_, imageProvider) => Image(
                image: imageProvider,
                fit: BoxFit.cover,
                width: double.maxFinite,
                height: 250,
              ),
              errorWidget: (_, __, ___) => Icon(
                Icons.image_not_supported_outlined,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : Icon(
              Icons.image_not_supported_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );
  }
}
