import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/failure.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/core/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/pages/home/daily_news.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile.dart';

/// Mock class for RemoteArticlesBloc to control state emission during tests.
class MockRemoteArticlesBloc
    extends MockBloc<RemoteArticlesEvent, RemoteArticlesState>
    implements RemoteArticlesBloc {}

class UnhandledRemoteArticlesState extends RemoteArticlesState {
  const UnhandledRemoteArticlesState();
}

void main() {
  late MockRemoteArticlesBloc mockRemoteArticlesBloc;
  final testArticle = const ArticleEntity(
    id: 1,
    title: 'Titulo',
    author: 'autor',
    description: 'una descripción...',
    url: 'https://hey.com',
    urlToImage: 'https://image.com',
    publishedAt: '2023-01-01',
    content: 'Content...',
  );

  setUp(() {
    mockRemoteArticlesBloc = MockRemoteArticlesBloc();
  });

  /// Helper to wrap the widget under test with necessary providers and Material structure.
  Widget makeTestableWidget(Widget body) {
    return BlocProvider<RemoteArticlesBloc>.value(
      value: mockRemoteArticlesBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  group('DailyNews Widget Tests', () {
    testWidgets(
      'Should display AppBar with "Daily News" title and bookmark icon',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockRemoteArticlesBloc.state)
            .thenReturn(const RemoteArticlesLoading());

        // Act
        await tester.pumpWidget(makeTestableWidget(const DailyNews()));

        // Assert
        expect(find.text('Daily News'), findsOneWidget);
        expect(find.byIcon(Icons.bookmark), findsOneWidget);
      },
    );

    testWidgets(
      'Should display CupertinoActivityIndicator when state is RemoteArticlesLoading',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockRemoteArticlesBloc.state)
            .thenReturn(const RemoteArticlesLoading());

        // Act
        await tester.pumpWidget(makeTestableWidget(const DailyNews()));

        // Assert
        expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Should display SnackBar with error message when state changes to RemoteArticlesError',
      (WidgetTester tester) async {
        // Arrange
        const errorMessage = 'Network connection failed';
        whenListen(
          mockRemoteArticlesBloc,
          Stream.fromIterable([
            const RemoteArticlesLoading(),
            const RemoteArticlesError(ServerFailure(errorMessage)),
          ]),
          initialState: const RemoteArticlesLoading(),
        );

        // Act
        await tester.pumpWidget(makeTestableWidget(const DailyNews()));
        await tester.pump(); // Process the stream and trigger the listener

        // Assert
        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text(errorMessage), findsOneWidget);
      },
    );

    testWidgets(
      'Should display refresh icon when state is RemoteArticlesError',
      (WidgetTester tester) async {
        // Arrange
        when(() => mockRemoteArticlesBloc.state).thenReturn(
            const RemoteArticlesError(ServerFailure('An error occurred')));

        // Act
        await tester.pumpWidget(makeTestableWidget(const DailyNews()));

        // Assert
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      },
    );

    testWidgets(
      'Should display list of ArticleWidgets and FAB when state is RemoteArticlesDone',
      (WidgetTester tester) async {
        // Arrange
        final articles = [
          testArticle,
          const ArticleEntity(
            id: 2,
            title: 'Titulo',
            author: 'autor',
            description: 'Una descripción..',
            url: 'https://hey.com',
            urlToImage: 'https://image2.com',
            publishedAt: '2023-01-02',
            content: 'Content...',
          ),
        ];
        when(() => mockRemoteArticlesBloc.state)
            .thenReturn(RemoteArticlesDone(articles));

        // Act
        await tester.pumpWidget(makeTestableWidget(const DailyNews()));

        // Assert
        expect(find.byType(ArticleWidget), findsAtLeastNWidgets(1));
        expect(find.text('una descripción...'), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      },
    );

    testWidgets(
      'Should navigate to saved articles when bookmark icon is tapped',
      (WidgetTester tester) async {
        when(() => mockRemoteArticlesBloc.state)
            .thenReturn(const RemoteArticlesLoading());

        await tester.pumpWidget(
          BlocProvider<RemoteArticlesBloc>.value(
            value: mockRemoteArticlesBloc,
            child: MaterialApp(
              home: const DailyNews(),
              routes: {
                AppRouteName.savedArticles.path: (_) => const Scaffold(
                      body: Text('Saved Articles Screen'),
                    ),
              },
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.bookmark));
        await tester.pumpAndSettle();

        expect(find.text('Saved Articles Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'Should navigate to article detail when an article tile is tapped',
      (WidgetTester tester) async {
        when(() => mockRemoteArticlesBloc.state)
            .thenReturn(RemoteArticlesDone([testArticle]));

        await tester.pumpWidget(
          BlocProvider<RemoteArticlesBloc>.value(
            value: mockRemoteArticlesBloc,
            child: MaterialApp(
              home: const DailyNews(),
              routes: {
                AppRouteName.articleDetails.path: (_) => const Scaffold(
                      body: Text('Article Details Screen'),
                    ),
              },
            ),
          ),
        );

        await tester.tap(find.byType(ArticleWidget));
        await tester.pumpAndSettle();

        expect(find.text('Article Details Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'Should render empty widget for unhandled state',
      (WidgetTester tester) async {
        when(() => mockRemoteArticlesBloc.state)
            .thenReturn(const UnhandledRemoteArticlesState());

        await tester.pumpWidget(makeTestableWidget(const DailyNews()));

        expect(find.byType(SizedBox), findsOneWidget);
        expect(find.byType(Scaffold), findsNothing);
      },
    );
  });
}
