import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_saved_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/remove_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/save_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

class MockGetSavedArticleUseCase extends Mock
    implements GetSavedArticleUseCase {}

class MockSaveArticleUseCase extends Mock implements SaveArticleUseCase {}

class MockRemoveArticleUseCase extends Mock implements RemoveArticleUseCase {}

void main() {
  late LocalArticleBloc bloc;
  late MockGetSavedArticleUseCase mockGetSavedArticleUseCase;
  late MockSaveArticleUseCase mockSaveArticleUseCase;
  late MockRemoveArticleUseCase mockRemoveArticleUseCase;

  setUp(() {
    mockGetSavedArticleUseCase = MockGetSavedArticleUseCase();
    mockSaveArticleUseCase = MockSaveArticleUseCase();
    mockRemoveArticleUseCase = MockRemoveArticleUseCase();

    bloc = LocalArticleBloc(
      mockGetSavedArticleUseCase,
      mockSaveArticleUseCase,
      mockRemoveArticleUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  const tArticle = ArticleEntity(
    id: 1,
    title: 'Test Title',
    description: 'Test Description',
  );

  final tArticles = [tArticle];

  test('initial state should be LocalArticlesLoading', () {
    expect(bloc.state, const LocalArticlesLoading());
  });

  test('emits [LocalArticlesDone] when GetSavedArticles is added', () async {
    // arrange
    when(() => mockGetSavedArticleUseCase()).thenAnswer((_) async => tArticles);

    // assert later
    final expected = [
      LocalArticlesDone(tArticles),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    // act
    bloc.add(const GetSavedArticles());
  });

  test('emits [LocalArticleRemoved] when RemoveArticle is added', () async {
    // arrange
    when(() => mockRemoveArticleUseCase(params: tArticle))
        .thenAnswer((_) async => Future.value());
    when(() => mockGetSavedArticleUseCase()).thenAnswer((_) async => tArticles);

    // assert later
    final expected = [
      LocalArticleRemoved(tArticles),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    // act
    bloc.add(const RemoveArticle(tArticle));
  });

  test('emits [LocalArticleSaved] when SaveArticle is added', () async {
    // arrange
    when(() => mockSaveArticleUseCase(params: tArticle))
        .thenAnswer((_) async => Future.value());
    when(() => mockGetSavedArticleUseCase()).thenAnswer((_) async => tArticles);

    // assert later
    final expected = [
      LocalArticleSaved(tArticles),
    ];

    expectLater(bloc.stream, emitsInOrder(expected));

    // act
    bloc.add(const SaveArticle(tArticle));
  });
}
