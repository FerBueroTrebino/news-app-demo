import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/core/error/failure.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class MockGetArticleUseCase extends Mock implements GetArticleUseCase {}

void main() {
  late RemoteArticlesBloc bloc;
  late MockGetArticleUseCase mockGetArticleUseCase;

  setUp(() {
    mockGetArticleUseCase = MockGetArticleUseCase();
    bloc = RemoteArticlesBloc(mockGetArticleUseCase);
  });

  tearDown(() {
    bloc.close();
  });

  final tArticles = [
    const ArticleEntity(
      id: 1,
      title: 'Test Title',
      description: 'Test Description',
    )
  ];

  test('initial state should be RemoteArticlesLoading', () {
    expect(bloc.state, const RemoteArticlesLoading());
  });

  test(
      'emits [RemoteArticlesDone] when GetArticles is added and usecase returns DataSuccess',
      () async {
    // arrange
    when(() => mockGetArticleUseCase())
        .thenAnswer((_) => Stream.value(DataSuccess(tArticles)));

    // assert later -> wait for emits
    final expected = [
      RemoteArticlesDone(tArticles),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    // act
    bloc.add(const GetArticles());
  });

  test(
      'emits [RemoteArticlesError] when GetArticles is added and usecase returns DataFailed',
      () async {
    // arrange
    const failure = ServerFailure("An unexpected error occurred");
    when(() => mockGetArticleUseCase())
        .thenAnswer((_) => Stream.value(DataFailed(failure)));

    // assert later -> wait for emits
    final expected = [
      RemoteArticlesError(failure),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    // act
    bloc.add(const GetArticles());
  });

  blocTest<RemoteArticlesBloc, RemoteArticlesState>(
    'does not emit when use case returns success with an empty article list',
    build: () {
      when(() => mockGetArticleUseCase()).thenAnswer(
        (_) => Stream.value(const DataSuccess(<ArticleEntity>[])),
      );

      return RemoteArticlesBloc(mockGetArticleUseCase);
    },
    act: (bloc) => bloc.add(const GetArticles()),
    expect: () => const <RemoteArticlesState>[],
    verify: (bloc) {
      expect(bloc.state, const RemoteArticlesLoading());
    },
  );
}
