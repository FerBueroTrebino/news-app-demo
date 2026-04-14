import 'package:flutter/material.dart';

import '../models/create_article_form_validators.dart';

class CreateArticleDescriptionField extends StatelessWidget {
  const CreateArticleDescriptionField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Summary',
        alignLabelWithHint: true,
        border: OutlineInputBorder(),
      ),
      minLines: 4,
      maxLines: 10,
      textCapitalization: TextCapitalization.sentences,
      validator: CreateArticleFormValidators.description,
    );
  }
}
