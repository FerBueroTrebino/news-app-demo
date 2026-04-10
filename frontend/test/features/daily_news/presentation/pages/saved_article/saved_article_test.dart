import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/core/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/saved_article/saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class MockLocalArticleBloc
    extends MockBloc<LocalArticlesEvent, LocalArticlesState>
    implements LocalArticleBloc {}

void main() {
  late MockLocalArticleBloc mockLocalArticleBloc;

  const testArticle = ArticleEntity(
    id: 1,
    title: 'Saved article',
    author: 'Author',
    description: 'Description',
    url: 'https://example.com/saved',
    urlToImage: 'https://example.com/saved.png',
    publishedAt: '2026-04-10',
    content: 'Saved content',
  );

  setUp(() {
    mockLocalArticleBloc = MockLocalArticleBloc();
    if (sl.isRegistered<LocalArticleBloc>()) {
      sl.unregister<LocalArticleBloc>();
    }
    sl.registerFactory<LocalArticleBloc>(() => mockLocalArticleBloc);
  });

  tearDown(() {
    if (sl.isRegistered<LocalArticleBloc>()) {
      sl.unregister<LocalArticleBloc>();
    }
  });

  group('SavedArticles Widget Tests', () {
    testWidgets('Shows loading indicator for loading state', (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesLoading());

      await tester.pumpWidget(const MaterialApp(home: SavedArticles()));

      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
    });

    testWidgets('Shows empty message when there are no saved articles',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([]));

      await tester.pumpWidget(const MaterialApp(home: SavedArticles()));

      expect(find.text('NO SAVED ARTICLES'), findsOneWidget);
    });

    testWidgets('Shows saved article list when articles are available',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([testArticle]));

      await tester.pumpWidget(const MaterialApp(home: SavedArticles()));

      expect(find.byType(ArticleWidget), findsOneWidget);
      expect(find.text('Saved article'), findsOneWidget);
      expect(find.byIcon(Icons.bookmark_remove_rounded), findsOneWidget);
    });

    testWidgets('Dispatches RemoveArticle when remove button is tapped',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([testArticle]));

      await tester.pumpWidget(const MaterialApp(home: SavedArticles()));

      await tester.tap(find.byIcon(Icons.bookmark_remove_rounded));
      await tester.pump();

      verify(() => mockLocalArticleBloc.add(const RemoveArticle(testArticle)))
          .called(1);
    });

    testWidgets('Shows snackbar when article is removed', (tester) async {
      whenListen(
        mockLocalArticleBloc,
        Stream.fromIterable(const [
          LocalArticlesDone([testArticle]),
          LocalArticleRemoved([]),
        ]),
        initialState: const LocalArticlesDone([testArticle]),
      );
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([testArticle]));

      await tester.pumpWidget(const MaterialApp(home: SavedArticles()));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Article removed from saved.'), findsOneWidget);
    });

    testWidgets('Shows snackbar with error message on failure', (tester) async {
      whenListen(
        mockLocalArticleBloc,
        Stream.fromIterable(const [
          LocalArticlesDone([testArticle]),
          LocalArticlesError('Failed to remove article.'),
        ]),
        initialState: const LocalArticlesDone([testArticle]),
      );
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([testArticle]));

      await tester.pumpWidget(const MaterialApp(home: SavedArticles()));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to remove article.'), findsOneWidget);
    });

    testWidgets('Navigates to article details when article tile is tapped',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([testArticle]));

      await tester.pumpWidget(
        MaterialApp(
          home: const SavedArticles(),
          routes: {
            AppRouteName.articleDetails.path: (_) =>
                const Scaffold(body: Text('Article Detail Screen')),
          },
        ),
      );

      await tester.tap(find.byType(ArticleWidget));
      await tester.pumpAndSettle();

      expect(find.text('Article Detail Screen'), findsOneWidget);
    });
  });
}
