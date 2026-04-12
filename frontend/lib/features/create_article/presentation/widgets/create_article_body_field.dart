import 'package:flutter/material.dart';

import 'create_article_form_validators.dart';

class CreateArticleBodyField extends StatelessWidget {
  const CreateArticleBodyField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Article body',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
      minLines: 8,
      maxLines: 24,
      textCapitalization: TextCapitalization.sentences,
      validator: CreateArticleFormValidators.content,
    );
  }
}
