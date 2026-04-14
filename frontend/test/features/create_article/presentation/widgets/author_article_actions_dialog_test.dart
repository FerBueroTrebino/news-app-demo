import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/author_article_actions_dialog.dart';

void main() {
  ArticleNewsEntity buildArticle({required String status}) => ArticleNewsEntity(
        articleUid: 'article-1',
        title: 'Title',
        description: 'Description',
        content: 'Content',
        category: 'general',
        status: status,
        thumbnailUrl: '',
        authorUid: 'author-1',
        authorName: 'Author',
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 1),
      );

  Future<void> openDialog(
    WidgetTester tester, {
    required ArticleNewsEntity article,
    required VoidCallback onEdit,
    required ArticleActionCallback onPublish,
    required ArticleActionCallback onDelete,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return TextButton(
                onPressed: () {
                  showAuthorArticleActionsDialog(
                    context: context,
                    article: article,
                    onEdit: onEdit,
                    onPublish: onPublish,
                    onDelete: onDelete,
                  );
                },
                child: const Text('open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows publish action only for draft article', (tester) async {
    await openDialog(
      tester,
      article: buildArticle(status: 'draft'),
      onEdit: () {},
      onPublish: (_) async {},
      onDelete: (_) async {},
    );
    expect(find.text('Publish article'), findsOneWidget);
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();

    await openDialog(
      tester,
      article: buildArticle(status: 'published'),
      onEdit: () {},
      onPublish: (_) async {},
      onDelete: (_) async {},
    );
    expect(find.text('Publish article'), findsNothing);
  });

  testWidgets('edit action triggers callback', (tester) async {
    var editCalled = 0;
    await openDialog(
      tester,
      article: buildArticle(status: 'draft'),
      onEdit: () => editCalled++,
      onPublish: (_) async {},
      onDelete: (_) async {},
    );

    await tester.tap(find.text('Edit article'));
    await tester.pumpAndSettle();

    expect(editCalled, 1);
  });

  testWidgets('publish action asks for confirmation and calls callback',
      (tester) async {
    var publishCalled = 0;
    await openDialog(
      tester,
      article: buildArticle(status: 'draft'),
      onEdit: () {},
      onPublish: (_) async => publishCalled++,
      onDelete: (_) async {},
    );

    await tester.tap(find.text('Publish article').first);
    await tester.pumpAndSettle();
    expect(find.text('Are you sure you want to publish this article?'),
        findsOneWidget);

    await tester.tap(find.text('Publish').last);
    await tester.pumpAndSettle();

    expect(publishCalled, 1);
  });

  testWidgets('delete action triggers callback', (tester) async {
    var deleteCalled = 0;
    await openDialog(
      tester,
      article: buildArticle(status: 'draft'),
      onEdit: () {},
      onPublish: (_) async {},
      onDelete: (_) async => deleteCalled++,
    );

    await tester.tap(find.text('Delete article'));
    await tester.pumpAndSettle();

    expect(deleteCalled, 1);
  });
}
