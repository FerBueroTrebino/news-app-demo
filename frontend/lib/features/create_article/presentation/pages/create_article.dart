import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/routes/routes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/enums/news_category.dart';
import '../../../../core/widgets/snackbar_widget.dart';
import '../bloc/create_article/create_article_cubit.dart';
import '../../../../features/auth/presentation/bloc/auth/auth_cubit.dart';
import '../../../../features/create_article/domain/entities/article_news_entity.dart';

import '../models/article_publish_mode.dart';
import '../widgets/create_article_body_field.dart';
import '../widgets/create_article_title_field.dart';
import '../widgets/create_article_category_field.dart';
import '../widgets/create_article_submit_button.dart';
import '../widgets/create_article_thumbnail_field.dart';
import '../widgets/create_article_description_field.dart';
import '../widgets/create_article_publish_mode_field.dart';

class CreateArticle extends StatefulWidget {
  const CreateArticle({super.key});

  @override
  State<CreateArticle> createState() => _CreateArticleState();
}

class _CreateArticleState extends State<CreateArticle> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  ArticlePublishMode _publishMode = ArticlePublishMode.draft;
  String _category = NewsCategory.general.apiValue;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<CreateArticleCubit>();
    final thumbnailBytes = cubit.state.imageBytes;
    if (thumbnailBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        buildSnackBar(
          context,
          'Please choose an image from your library.',
          type: AppSnackBarType.alert,
        ),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    final user = authState.user;
    if (user == null) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final content = _contentController.text.trim();
    final authorName = cubit.resolveAuthorDisplayName(user);
    final publish = _publishMode == ArticlePublishMode.publish;
    final now = DateTime.now();

    final draft = ArticleNewsEntity(
      articleUid: '',
      title: title,
      description: description,
      content: content,
      category: _category,
      status: publish ? 'published' : 'draft',
      thumbnailUrl: '',
      authorUid: user.uid,
      authorName: authorName,
      createdAt: now,
      publishedAt: publish ? now : null,
      updatedAt: now,
      viewsCount: 0,
    );

    await cubit.submitArticle(
      author: user,
      draft: draft,
      thumbnailBytes: thumbnailBytes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateArticleCubit, CreateArticleState>(
      listenWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.submissionStatus == CreateArticleSubmissionStatus.success) {
          final status = state.createdArticleStatus ?? '';
          final verifiedMessage = status == 'published'
              ? 'Article published successfully.'
              : 'Draft saved successfully in your profile.';
          messenger.showSnackBar(
            buildSnackBar(
              context,
              verifiedMessage,
              type: AppSnackBarType.success,
            ),
          );
          final cubit = context.read<CreateArticleCubit>();
          cubit.acknowledgeSubmissionResult();
          if (status == 'draft') {
            Navigator.of(context).popAndPushNamed(
              AppRouteName.authorProfile.path,
            );
          } else if (status == 'published') {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouteName.home.path,
              (route) => false,
            );
          }
        } else if (state.submissionStatus ==
            CreateArticleSubmissionStatus.failure) {
          messenger.showSnackBar(
            buildSnackBar(
              context,
              state.errorMessage ?? 'Something went wrong.',
              type: AppSnackBarType.error,
            ),
          );
          context.read<CreateArticleCubit>().acknowledgeSubmissionResult();
        }
      },
      child: SingleChildScrollView(
        padding: AppPadding.allGiant,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CreateArticleTitleField(controller: _titleController),
              const SizedBox(height: 20),
              CreateArticleCategoryField(
                value: _category,
                onChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 20),
              const CreateArticleThumbnailField(),
              const SizedBox(height: 12),
              CreateArticleDescriptionField(
                controller: _descriptionController,
              ),
              const SizedBox(height: 20),
              CreateArticleBodyField(controller: _contentController),
              const SizedBox(height: 20),
              CreateArticlePublishModeField(
                selected: _publishMode,
                onSelectionChanged: (mode) =>
                    setState(() => _publishMode = mode),
              ),
              const SizedBox(height: 28),
              CreateArticleSubmitButton(onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
