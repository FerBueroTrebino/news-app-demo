import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/create_article/create_article_cubit.dart';

class CreateArticleThumbnailField extends StatelessWidget {
  const CreateArticleThumbnailField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateArticleCubit, CreateArticleState>(
      builder: (context, state) {
        final bytes = state.imageBytes;
        final cubit = context.read<CreateArticleCubit>();
        if (bytes == null) {
          return OutlinedButton.icon(
            onPressed: () => cubit.pickImageFromGallery(),
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Choose from library'),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => cubit.pickImageFromGallery(),
                borderRadius: BorderRadius.circular(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => cubit.clearImage(),
                child: const Text('Remove image'),
              ),
            ),
          ],
        );
      },
    );
  }
}
