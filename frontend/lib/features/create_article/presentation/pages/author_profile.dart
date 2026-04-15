import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../widgets/author_profile_content.dart';
import '../../../../../config/routes/routes.dart';
import '../../../../../core/constants/constants.dart';
import '../widgets/author_article_actions_dialog.dart';
import '../../domain/entities/article_news_entity.dart';
import '../bloc/author_profile/author_profile_cubit.dart';
import '../../../../../core/widgets/snackbar_widget.dart';
import '../../../../../config/di/injection_container.dart';
import '../widgets/delete_article_confirmation_dialog.dart';
import '../../../../../features/auth/presentation/bloc/auth/auth_cubit.dart';

class AuthorProfile extends StatelessWidget {
  const AuthorProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated || authState.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My articles'),
        ),
        body: const Center(
          child: Text('Sign in to view your articles.'),
        ),
      );
    }

    final authorUid = authState.user!.uid;

    return BlocProvider(
      create: (_) => sl<AuthorProfileCubit>()..loadAuthorArticles(authorUid),
      child: const _AuthorProfileView(),
    );
  }
}

class _AuthorProfileView extends StatelessWidget {
  const _AuthorProfileView();

  Future<void> _deleteArticle(
    BuildContext context,
    ArticleNewsEntity article,
  ) async {
    final shouldDelete = await showDeleteArticleConfirmationDialog(context);
    if (!shouldDelete || !context.mounted) return;

    final isDeleted = await context
        .read<AuthorProfileCubit>()
        .deleteAuthorArticle(article.articleUid);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      buildSnackBar(
        context,
        isDeleted
            ? 'Article deleted successfully.'
            : 'Could not delete the article. Please try again.',
        type: isDeleted ? AppSnackBarType.success : AppSnackBarType.error,
      ),
    );
  }

  Future<void> _showArticleActions(
    BuildContext context,
    ArticleNewsEntity article,
  ) async {
    await showAuthorArticleActionsDialog(
      context: context,
      article: article,
      onEdit: () =>
          context.read<AuthorProfileCubit>().requestEditArticle(article),
      onPublish: (selectedArticle) {
        return context
            .read<AuthorProfileCubit>()
            .publishAuthorArticle(selectedArticle);
      },
      onDelete: (selectedArticle) {
        return _deleteArticle(context, selectedArticle);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat =
        DateFormat(articleDisplayDatePattern, articleDisplayLocale);

    return BlocListener<AuthorProfileCubit, AuthorProfileState>(
      listenWhen: (previous, current) =>
          previous.publishStatus != current.publishStatus ||
          previous.editActionStatus != current.editActionStatus,
      listener: (context, state) async {
        if (state.editActionStatus == AuthorArticleEditActionStatus.navigate &&
            state.selectedArticleForEdit != null) {
          final cubit = context.read<AuthorProfileCubit>();
          final article = state.selectedArticleForEdit!;
          cubit.acknowledgeEditNavigation();
          await Navigator.of(context).pushNamed(
            AppRouteName.editArticle.path,
            arguments: article,
          );
          return;
        }

        if (state.publishStatus == AuthorArticlePublishStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildSnackBar(
              context,
              'Article published successfully.',
              type: AppSnackBarType.success,
            ),
          );
          context.read<AuthorProfileCubit>().acknowledgePublishResult();
          return;
        }

        if (state.publishStatus == AuthorArticlePublishStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            buildSnackBar(
              context,
              state.publishError ??
                  'Could not publish the article. Please try again.',
              type: AppSnackBarType.error,
            ),
          );
          context.read<AuthorProfileCubit>().acknowledgePublishResult();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My articles'),
        ),
        body: AuthorProfileContent(
          dateFormat: dateFormat,
          onArticleTap: (article) => _showArticleActions(context, article),
        ),
      ),
    );
  }
}
