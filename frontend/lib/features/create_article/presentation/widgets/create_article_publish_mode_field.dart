import 'package:flutter/material.dart';

import '../models/article_publish_mode.dart';

class CreateArticlePublishModeField extends StatelessWidget {
  const CreateArticlePublishModeField({
    super.key,
    required this.selected,
    required this.onSelectionChanged,
  });

  final ArticlePublishMode selected;
  final ValueChanged<ArticlePublishMode> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Status',
          style: theme.textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<ArticlePublishMode>(
          segments: const [
            ButtonSegment<ArticlePublishMode>(
              value: ArticlePublishMode.draft,
              label: Text('Draft'),
              icon: Icon(Icons.edit_note_outlined),
            ),
            ButtonSegment<ArticlePublishMode>(
              value: ArticlePublishMode.publish,
              label: Text('Publish'),
              icon: Icon(Icons.publish_outlined),
            ),
          ],
          selected: {selected},
          onSelectionChanged: (Set<ArticlePublishMode> selection) {
            onSelectionChanged(selection.first);
          },
        ),
      ],
    );
  }
}
