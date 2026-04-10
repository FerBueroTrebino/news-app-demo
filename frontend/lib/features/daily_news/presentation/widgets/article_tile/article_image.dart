import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ArticleTileImage extends StatelessWidget {
  final String? url;

  const ArticleTileImage({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const SizedBox.shrink();
    }

    return CachedNetworkImage(
      imageUrl: url!,
      imageBuilder: (_, imageProvider) => Padding(
        padding: const EdgeInsets.all(0),
        child: ClipRRect(
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
      ),
      progressIndicatorBuilder: (_, __, ___) => const Padding(
        padding: EdgeInsets.all(12),
        child: AspectRatio(aspectRatio: 16 / 9),
      ),
      errorWidget: (_, __, ___) => const SizedBox.shrink(),
    );
  }
}
