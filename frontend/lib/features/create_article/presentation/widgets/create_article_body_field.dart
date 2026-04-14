import 'package:flutter/material.dart';

import '../models/create_article_form_validators.dart';

class CreateArticleBodyField extends StatefulWidget {
  const CreateArticleBodyField({
    super.key,
    required this.controller,
  });

  final TextEditingController controller;

  @override
  State<CreateArticleBodyField> createState() => _CreateArticleBodyFieldState();
}

class _CreateArticleBodyFieldState extends State<CreateArticleBodyField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _insertAtSelection(String insertion) {
    final controller = widget.controller;
    final text = controller.text;
    final selection = controller.selection;

    if (!selection.isValid || !selection.isNormalized) {
      controller.text = text + insertion;
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
      return;
    }

    final start = selection.start;
    final end = selection.end;
    final newText = text.replaceRange(start, end, insertion);
    final newOffset = start + insertion.length;
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
    );
  }

  void _insertSubtitleLine() {
    final text = widget.controller.text;
    final offset = widget.controller.selection.baseOffset;
    final safeOffset = offset.clamp(0, text.length);
    final needsLeadingNewline =
        safeOffset > 0 && text.isNotEmpty && text[safeOffset - 1] != '\n';
    _insertAtSelection('${needsLeadingNewline ? '\n' : ''}## ');
  }

  void _insertBulletLine() {
    final text = widget.controller.text;
    final offset = widget.controller.selection.baseOffset;
    final safeOffset = offset.clamp(0, text.length);
    final needsLeadingNewline =
        safeOffset > 0 && text.isNotEmpty && text[safeOffset - 1] != '\n';
    _insertAtSelection('${needsLeadingNewline ? '\n' : ''}- ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            labelText: 'Article body',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
            helperText:
                'Start a line with ## for a subtitle or - for a bullet (or use the buttons).',
            helperMaxLines: 2,
          ),
          minLines: 8,
          maxLines: 24,
          textCapitalization: TextCapitalization.sentences,
          validator: CreateArticleFormValidators.content,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                _focusNode.requestFocus();
                _insertSubtitleLine();
              },
              icon: const Icon(Icons.title_rounded, size: 18),
              label: const Text('Subtitle'),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                _focusNode.requestFocus();
                _insertBulletLine();
              },
              icon: const Icon(Icons.format_list_bulleted_rounded, size: 18),
              label: const Text('Bullet'),
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
