import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_detail/article_detail_save_button.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class MockLocalArticleBloc
    extends MockBloc<LocalArticlesEvent, LocalArticlesState>
    implements LocalArticleBloc {}

void main() {
  late MockLocalArticleBloc mockLocalArticleBloc;

  const testArticle = ArticleEntity(
    id: 1,
    title: 'Article title',
    author: 'Author',
    description: 'Description',
    url: 'https://example.com/article',
    urlToImage: null,
    publishedAt: '2026-04-10',
    content: 'Article content',
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

  Widget makeTestableWidget(Widget body) {
    return MaterialApp(home: body);
  }

  group('ArticleDetailsView Widget Tests', () {
    testWidgets('Shows fallback when article is null', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(const ArticleDetailsView(article: null)),
      );

      expect(find.text('No article available.'), findsOneWidget);
    });

    testWidgets('Shows article content and save button when not saved',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([]));

      await tester.pumpWidget(
        makeTestableWidget(const ArticleDetailsView(article: testArticle)),
      );

      expect(find.text('Article title'), findsOneWidget);
      expect(find.byType(ArticleDetailSaveButton), findsOneWidget);
    });

    testWidgets('Hides save button when article is already saved',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([testArticle]));

      await tester.pumpWidget(
        makeTestableWidget(const ArticleDetailsView(article: testArticle)),
      );

      expect(find.byType(ArticleDetailSaveButton), findsNothing);
    });

    testWidgets('Dispatches SaveArticle when save button is tapped',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([]));

      await tester.pumpWidget(
        makeTestableWidget(const ArticleDetailsView(article: testArticle)),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      verify(() => mockLocalArticleBloc.add(const SaveArticle(testArticle)))
          .called(1);
    });

    testWidgets('Shows success snackbar when article is saved', (tester) async {
      whenListen(
        mockLocalArticleBloc,
        Stream.fromIterable(const [
          LocalArticlesDone([]),
          LocalArticleSaved([testArticle]),
        ]),
        initialState: const LocalArticlesDone([]),
      );
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([]));

      await tester.pumpWidget(
        makeTestableWidget(const ArticleDetailsView(article: testArticle)),
      );
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Article saved successfully.'), findsOneWidget);
    });

    testWidgets('Shows error snackbar when save fails', (tester) async {
      whenListen(
        mockLocalArticleBloc,
        Stream.fromIterable(const [
          LocalArticlesDone([]),
          LocalArticlesError('Failed to save article.'),
        ]),
        initialState: const LocalArticlesDone([]),
      );
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([]));

      await tester.pumpWidget(
        makeTestableWidget(const ArticleDetailsView(article: testArticle)),
      );
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.text('There was an error saving the article.'),
        findsOneWidget,
      );
    });
  });
}
