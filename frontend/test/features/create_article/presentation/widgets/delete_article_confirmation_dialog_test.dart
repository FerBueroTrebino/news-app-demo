import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/delete_article_confirmation_dialog.dart';

void main() {
  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () async {
                  await showDeleteArticleConfirmationDialog(context);
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );
  }

  testWidgets('returns true when delete is confirmed', (tester) async {
    await pumpHost(tester);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to delete?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Delete article'), findsNothing);
  });

  testWidgets('returns false when delete is cancelled', (tester) async {
    await pumpHost(tester);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Delete article'), findsNothing);
  });
}
