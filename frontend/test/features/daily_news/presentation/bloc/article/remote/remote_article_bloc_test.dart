import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/failure.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
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
        .thenAnswer((_) async => DataSuccess(tArticles));

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
        .thenAnswer((_) async => DataFailed(failure));

    // assert later -> wait for emits
    final expected = [
      RemoteArticlesError(failure),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    // act
    bloc.add(const GetArticles());
  });
}
