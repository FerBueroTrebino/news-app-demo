import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_spacing.dart';
import '../bloc/edit_article/edit_article_cubit.dart';

class EditArticleSubmitButton extends StatelessWidget {
  const EditArticleSubmitButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditArticleCubit, EditArticleState>(
      builder: (context, state) {
        final loading =
            state.submissionStatus == EditArticleSubmissionStatus.loading;
        return FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            padding: AppPadding.verticalXxl,
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update article'),
        );
      },
    );
  }
}
