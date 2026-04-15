import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../bloc/create_article/create_article_cubit.dart';

class CreateArticleSubmitButton extends StatelessWidget {
  const CreateArticleSubmitButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateArticleCubit, CreateArticleState>(
      builder: (context, state) {
        final loading =
            state.submissionStatus == CreateArticleSubmissionStatus.loading;
        return FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: AppPadding.verticalXxl,
          ),
          child: loading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create article'),
        );
      },
    );
  }
}
