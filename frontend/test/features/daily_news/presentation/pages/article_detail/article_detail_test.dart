import 'package:bloc_test/bloc_test.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/read_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_reader/article_reader_cubit.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/article_detail/article_detail.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_detail/article_detail_save_button.dart';
import 'package:news_app_clean_architecture/config/di/injection_container.dart';

class MockLocalArticleBloc
    extends MockBloc<LocalArticlesEvent, LocalArticlesState>
    implements LocalArticleBloc {}

class MockReadArticleUseCase extends Mock implements ReadArticleUseCase {}

void main() {
  late MockLocalArticleBloc mockLocalArticleBloc;
  late MockReadArticleUseCase mockReadArticleUseCase;

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

  setUpAll(() {
    registerFallbackValue(
      const ReadArticleParams(article: testArticle),
    );
  });

  setUp(() {
    mockLocalArticleBloc = MockLocalArticleBloc();
    mockReadArticleUseCase = MockReadArticleUseCase();
    if (sl.isRegistered<LocalArticleBloc>()) {
      sl.unregister<LocalArticleBloc>();
    }
    if (sl.isRegistered<ArticleReaderCubit>()) {
      sl.unregister<ArticleReaderCubit>();
    }
    sl.registerFactory<LocalArticleBloc>(() => mockLocalArticleBloc);
    sl.registerFactory<ArticleReaderCubit>(
      () => ArticleReaderCubit(mockReadArticleUseCase),
    );
    when(
      () => mockReadArticleUseCase.call(params: any(named: 'params')),
    ).thenAnswer((_) async {});
    when(() => mockReadArticleUseCase.stop()).thenAnswer((_) async {});
  });

  tearDown(() {
    if (sl.isRegistered<LocalArticleBloc>()) {
      sl.unregister<LocalArticleBloc>();
    }
    if (sl.isRegistered<ArticleReaderCubit>()) {
      sl.unregister<ArticleReaderCubit>();
    }
  });

  Widget makeTestableWidget(Widget body) {
    return MaterialApp(home: body);
  }

  group('ArticleDetailsView Widget Tests', () {
    testWidgets('Shows headphones action in app bar', (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([]));

      await tester.pumpWidget(
        makeTestableWidget(const ArticleDetailsView(article: testArticle)),
      );

      expect(find.byIcon(Icons.headphones), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsNothing);
    });

    testWidgets('Tapping read action calls read article use case',
        (tester) async {
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([]));

      await tester.pumpWidget(
        makeTestableWidget(const ArticleDetailsView(article: testArticle)),
      );

      await tester.tap(find.byIcon(Icons.headphones));
      await tester.pump();

      final captured = verify(
        () => mockReadArticleUseCase.call(params: captureAny(named: 'params')),
      ).captured.single as ReadArticleParams;
      expect(captured.article, testArticle);
    });

    testWidgets('Shows stop icon while reading and stops when tapped',
        (tester) async {
      final completer = Completer<void>();
      when(() => mockReadArticleUseCase.call(params: any(named: 'params')))
          .thenAnswer((_) => completer.future);
      when(() => mockLocalArticleBloc.state)
          .thenReturn(const LocalArticlesDone([]));

      await tester.pumpWidget(
        makeTestableWidget(const ArticleDetailsView(article: testArticle)),
      );

      await tester.tap(find.byIcon(Icons.headphones));
      await tester.pump();
      expect(find.byIcon(Icons.stop), findsOneWidget);

      await tester.tap(find.byIcon(Icons.stop));
      await tester.pump();

      verify(() => mockReadArticleUseCase.stop()).called(greaterThan(0));

      completer.complete();
      await tester.pump();
    });

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
