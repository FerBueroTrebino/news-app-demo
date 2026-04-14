import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/edit_article_form.dart';
import '../models/article_publish_mode.dart';
import '../bloc/edit_article/edit_article_cubit.dart';
import '../../../../core/widgets/snackbar_widget.dart';
import '../../domain/entities/article_news_entity.dart';
import '../../../../injection_container.dart';

class EditArticle extends StatefulWidget {
  const EditArticle({
    super.key,
    required this.article,
  });

  final ArticleNewsEntity article;

  static Widget route({
    required ArticleNewsEntity article,
  }) {
    return BlocProvider<EditArticleCubit>(
      create: (_) => sl<EditArticleCubit>(),
      child: EditArticle(article: article),
    );
  }

  @override
  State<EditArticle> createState() => _EditArticleState();
}

class _EditArticleState extends State<EditArticle> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _contentController;
  late ArticlePublishMode _publishMode;
  late String _category;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article.title);
    _descriptionController = TextEditingController(
      text: widget.article.description,
    );
    _contentController = TextEditingController(text: widget.article.content);
    _category = widget.article.category;
    _publishMode = widget.article.status.trim().toLowerCase() == 'published'
        ? ArticlePublishMode.publish
        : ArticlePublishMode.draft;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final shouldPublish = _publishMode == ArticlePublishMode.publish;
    final updated = ArticleNewsEntity(
      articleUid: widget.article.articleUid,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      content: _contentController.text.trim(),
      category: _category,
      status: shouldPublish ? 'published' : 'draft',
      thumbnailUrl: widget.article.thumbnailUrl,
      authorUid: widget.article.authorUid,
      authorName: widget.article.authorName,
      createdAt: widget.article.createdAt,
      publishedAt: shouldPublish ? (widget.article.publishedAt ?? now) : null,
      updatedAt: now,
      viewsCount: widget.article.viewsCount,
    );
    await context.read<EditArticleCubit>().submitEdit(updated);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditArticleCubit, EditArticleState>(
      listenWhen: (previous, current) =>
          previous.submissionStatus != current.submissionStatus,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.submissionStatus == EditArticleSubmissionStatus.success) {
          messenger.showSnackBar(
            buildSnackBar(
              'Article updated successfully.',
              type: AppSnackBarType.success,
            ),
          );
          context.read<EditArticleCubit>().acknowledgeResult();
          Navigator.of(context).pop(true);
        } else if (state.submissionStatus ==
            EditArticleSubmissionStatus.failure) {
          messenger.showSnackBar(
            buildSnackBar(
              state.errorMessage ?? 'Something went wrong.',
              type: AppSnackBarType.error,
            ),
          );
          context.read<EditArticleCubit>().acknowledgeResult();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit article'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: EditArticleForm(
            formKey: _formKey,
            article: widget.article,
            titleController: _titleController,
            descriptionController: _descriptionController,
            contentController: _contentController,
            category: _category,
            publishMode: _publishMode,
            onCategoryChanged: (value) => setState(() => _category = value),
            onPublishModeChanged: (mode) => setState(() => _publishMode = mode),
            onSubmit: _submit,
          ),
        ),
      ),
    );
  }
}
