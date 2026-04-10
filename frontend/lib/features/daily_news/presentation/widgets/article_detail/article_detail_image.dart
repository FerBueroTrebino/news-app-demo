import 'package:flutter/material.dart';

class ArticleDetailImage extends StatelessWidget {
  final String? imageUrl;

  const ArticleDetailImage({
    super.key,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl?.trim().isNotEmpty == true;

    return Container(
      width: double.maxFinite,
      height: 250,
      margin: const EdgeInsets.only(top: 14),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: hasImage
          ? Image.network(imageUrl!, fit: BoxFit.cover)
          : Icon(
              Icons.image_not_supported_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
    );
  }
}
