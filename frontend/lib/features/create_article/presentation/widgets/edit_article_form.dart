import 'package:flutter/material.dart';

import '../models/article_publish_mode.dart';
import '../widgets/create_article_body_field.dart';
import '../widgets/create_article_title_field.dart';
import '../widgets/edit_article_submit_button.dart';
import '../widgets/edit_article_thumbnail_field.dart';
import '../widgets/create_article_category_field.dart';
import '../../domain/entities/article_news_entity.dart';
import '../widgets/create_article_description_field.dart';
import '../widgets/create_article_publish_mode_field.dart';

class EditArticleForm extends StatelessWidget {
  const EditArticleForm({
    super.key,
    required this.formKey,
    required this.article,
    required this.titleController,
    required this.descriptionController,
    required this.contentController,
    required this.category,
    required this.publishMode,
    required this.onCategoryChanged,
    required this.onPublishModeChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final ArticleNewsEntity article;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController contentController;
  final String category;
  final ArticlePublishMode publishMode;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<ArticlePublishMode> onPublishModeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CreateArticleTitleField(controller: titleController),
          const SizedBox(height: 20),
          CreateArticleCategoryField(
            value: category,
            onChanged: onCategoryChanged,
          ),
          const SizedBox(height: 20),
          EditArticleThumbnailField(article: article),
          const SizedBox(height: 12),
          CreateArticleDescriptionField(controller: descriptionController),
          const SizedBox(height: 20),
          CreateArticleBodyField(controller: contentController),
          const SizedBox(height: 20),
          CreateArticlePublishModeField(
            selected: publishMode,
            onSelectionChanged: onPublishModeChanged,
          ),
          const SizedBox(height: 28),
          EditArticleSubmitButton(onPressed: onSubmit),
        ],
      ),
    );
  }
}
