import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../bloc/edit_article/edit_article_cubit.dart';
import '../../domain/entities/article_news_entity.dart';

class EditArticleThumbnailField extends StatelessWidget {
  const EditArticleThumbnailField({
    super.key,
    required this.article,
  });

  final ArticleNewsEntity article;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditArticleCubit, EditArticleState>(
      builder: (context, state) {
        final cubit = context.read<EditArticleCubit>();
        final pickedBytes = state.imageBytes;
        final currentUrl = article.thumbnailUrl.trim();

        if (pickedBytes != null) {
          return _PickedThumbnailView(
            bytes: pickedBytes,
            onPickImage: cubit.pickImageFromGallery,
            onReset: cubit.clearPickedImage,
          );
        }

        if (currentUrl.isNotEmpty) {
          return _CurrentThumbnailView(
            imageUrl: currentUrl,
            onPickImage: cubit.pickImageFromGallery,
          );
        }

        return OutlinedButton.icon(
          onPressed: cubit.pickImageFromGallery,
          icon: const Icon(Icons.photo_library_outlined),
          label: const Text('Choose from library'),
        );
      },
    );
  }
}

class _PickedThumbnailView extends StatelessWidget {
  const _PickedThumbnailView({
    required this.bytes,
    required this.onPickImage,
    required this.onReset,
  });

  final Uint8List bytes;
  final VoidCallback onPickImage;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ClickableThumbnail(
          onTap: onPickImage,
          child: Image.memory(bytes, fit: BoxFit.cover),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onReset,
            child: const Text('Use current uploaded image'),
          ),
        ),
      ],
    );
  }
}

class _CurrentThumbnailView extends StatelessWidget {
  const _CurrentThumbnailView({
    required this.imageUrl,
    required this.onPickImage,
  });

  final String imageUrl;
  final VoidCallback onPickImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ClickableThumbnail(
          onTap: onPickImage,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            progressIndicatorBuilder: (_, __, ___) => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            errorWidget: (_, __, ___) => const _ThumbnailPlaceholder(),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onPickImage,
            child: const Text('Change image'),
          ),
        ),
      ],
    );
  }
}

class _ClickableThumbnail extends StatelessWidget {
  const _ClickableThumbnail({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  const _ThumbnailPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
