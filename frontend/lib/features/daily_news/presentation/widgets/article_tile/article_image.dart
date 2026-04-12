import 'package:flutter/material.dart';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../../../../../core/widgets/cached_network_image_with_loader.dart';

class ArticleTileImage extends StatelessWidget {
  final String? url;

  final BaseCacheManager? cacheManager;

  const ArticleTileImage({super.key, this.url, this.cacheManager});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const SizedBox.shrink();
    }

    return CachedNetworkImageWithLoader(
      imageUrl: url!,
      cacheManager: cacheManager,
      imageBuilder: (_, imageProvider) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
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
      wrapProgress: (context, indicator) => AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(child: indicator),
        ),
      ),
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
