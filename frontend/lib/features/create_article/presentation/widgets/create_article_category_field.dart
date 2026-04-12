import 'package:flutter/material.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';

class CreateArticleCategoryField extends StatelessWidget {
  const CreateArticleCategoryField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey(value),
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
      ),
      items: ArticleNewsEntity.allowedCategories
          .map(
            (c) => DropdownMenuItem(
              value: c,
              child: Text(c[0].toUpperCase() + c.substring(1)),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
