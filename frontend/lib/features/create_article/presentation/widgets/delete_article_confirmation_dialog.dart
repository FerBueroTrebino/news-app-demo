import 'package:flutter/material.dart';

Future<bool> showDeleteArticleConfirmationDialog(BuildContext context) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (confirmContext) {
      return AlertDialog(
        title: const Text('Delete article'),
        content: const Text('Are you sure you want to delete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(confirmContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(confirmContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return shouldDelete ?? false;
}
