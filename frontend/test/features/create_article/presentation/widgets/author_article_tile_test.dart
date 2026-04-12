import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/core/widgets/date_chip.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/author_article_tile.dart';

void main() {
  final dateFormat = DateFormat.yMMMd();

  ArticleNewsEntity buildArticle({
    String title = 'My story',
    String description = 'A short summary.',
    String category = 'technology',
    String status = 'published',
    String thumbnailUrl = '',
  }) {
    final now = DateTime.utc(2024, 6, 15);
    return ArticleNewsEntity(
      articleUid: 'a1',
      title: title,
      description: description,
      content: 'Full body',
      category: category,
      status: status,
      thumbnailUrl: thumbnailUrl,
      authorUid: 'u1',
      authorName: 'Author',
      createdAt: now,
      updatedAt: now,
      publishedAt: now,
      viewsCount: 0,
    );
  }

  testWidgets('renders title, description, category and status',
      (tester) async {
    final article = buildArticle();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AuthorArticleTile(
              article: article,
              dateFormat: dateFormat,
            ),
          ),
        ),
      ),
    );

    expect(find.text('My story'), findsOneWidget);
    expect(find.text('A short summary.'), findsOneWidget);
    expect(find.text('Technology'), findsOneWidget);
    expect(find.text('Published'), findsOneWidget);
    expect(find.byType(DateChip), findsOneWidget);
  });

  testWidgets('uses fallback copy when title and description are blank',
      (tester) async {
    final article = buildArticle(
      title: '   ',
      description: '  ',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthorArticleTile(
            article: article,
            dateFormat: dateFormat,
          ),
        ),
      ),
    );

    expect(find.text('Untitled story'), findsOneWidget);
    expect(find.text('No description yet.'), findsOneWidget);
  });

  testWidgets('shows Draft status label for draft articles', (tester) async {
    final article = buildArticle(status: 'draft');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthorArticleTile(
            article: article,
            dateFormat: dateFormat,
          ),
        ),
      ),
    );

    expect(find.text('Draft'), findsOneWidget);
  });
}
