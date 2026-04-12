import 'package:flutter/material.dart';

import 'create_article_form_validators.dart';

class CreateArticleTitleField extends StatelessWidget {
  const CreateArticleTitleField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Title',
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.sentences,
      validator: CreateArticleFormValidators.title,
    );
  }
}
