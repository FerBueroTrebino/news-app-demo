import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/delete_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/get_articles_news_of_author.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/update_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/author_profile/author_profile_cubit.dart';

class MockGetArticlesNewsOfAuthorUseCase extends Mock
    implements GetArticlesNewsOfAuthorUseCase {}
class MockUpdateArticleNewsUseCase extends Mock implements UpdateArticleNewsUseCase {}
class MockDeleteArticleNewsUseCase extends Mock implements DeleteArticleNewsUseCase {}

void main() {
  late AuthorProfileCubit cubit;
  late MockGetArticlesNewsOfAuthorUseCase mockGetArticlesNewsOfAuthorUseCase;
  late MockUpdateArticleNewsUseCase mockUpdateArticleNewsUseCase;
  late MockDeleteArticleNewsUseCase mockDeleteArticleNewsUseCase;

  ArticleNewsEntity articleWithUpdatedAt(DateTime updatedAt) {
    return ArticleNewsEntity(
      articleUid: 'id-${updatedAt.millisecondsSinceEpoch}',
      title: 't',
      description: 'd',
      content: 'c',
      category: 'general',
      status: 'draft',
      thumbnailUrl: '',
      authorUid: 'author-1',
      authorName: 'n',
      createdAt: DateTime.utc(2000),
      updatedAt: updatedAt,
    );
  }

  setUpAll(() {
    registerFallbackValue(
      UpdateArticleNewsParams(article: articleWithUpdatedAt(DateTime.utc(2000))),
    );
    registerFallbackValue(
      const DeleteArticleNewsParams(articleUid: 'fallback'),
    );
  });

  setUp(() {
    mockGetArticlesNewsOfAuthorUseCase = MockGetArticlesNewsOfAuthorUseCase();
    mockUpdateArticleNewsUseCase = MockUpdateArticleNewsUseCase();
    mockDeleteArticleNewsUseCase = MockDeleteArticleNewsUseCase();
    cubit = AuthorProfileCubit(
      mockGetArticlesNewsOfAuthorUseCase,
      mockUpdateArticleNewsUseCase,
      mockDeleteArticleNewsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is AuthorProfileState', () {
    expect(cubit.state, const AuthorProfileState());
  });

  test(
      'loadAuthorArticles emits loading then success with articles sorted by updatedAt desc',
      () async {
    final older = articleWithUpdatedAt(DateTime.utc(2020, 1, 1));
    final newer = articleWithUpdatedAt(DateTime.utc(2020, 3, 1));

    when(() => mockGetArticlesNewsOfAuthorUseCase(params: 'author-1'))
        .thenAnswer((_) => Stream.value([older, newer]));

    final expected = [
      const AuthorProfileState(
        authorArticlesStatus: AuthorArticlesListStatus.loading,
      ),
      AuthorProfileState(
        authorArticlesStatus: AuthorArticlesListStatus.success,
        authorArticles: [newer, older],
      ),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));

    cubit.loadAuthorArticles('author-1');

    await Future<void>.delayed(Duration.zero);

    verify(() => mockGetArticlesNewsOfAuthorUseCase(params: 'author-1'))
        .called(1);
  });

  test(
      'loadAuthorArticles emits loading then failure when stream reports error',
      () async {
    when(() => mockGetArticlesNewsOfAuthorUseCase(params: 'author-1'))
        .thenAnswer((_) => Stream.error(Exception('firestore')));

    final expected = [
      const AuthorProfileState(
        authorArticlesStatus: AuthorArticlesListStatus.loading,
      ),
      const AuthorProfileState(
        authorArticlesStatus: AuthorArticlesListStatus.failure,
        authorArticlesError: 'Could not load your articles. Please try again.',
      ),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));

    cubit.loadAuthorArticles('author-1');

    await Future<void>.delayed(Duration.zero);
  });

  test('loadAuthorArticles emits loading then failure when use case throws',
      () async {
    when(() => mockGetArticlesNewsOfAuthorUseCase(params: ''))
        .thenThrow(ArgumentError('authorUid is required'));

    final expected = [
      const AuthorProfileState(
        authorArticlesStatus: AuthorArticlesListStatus.loading,
      ),
      const AuthorProfileState(
        authorArticlesStatus: AuthorArticlesListStatus.failure,
        authorArticlesError: 'Could not load your articles. Please try again.',
      ),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));

    cubit.loadAuthorArticles('');

    await Future<void>.delayed(Duration.zero);
  });

  test('loadAuthorArticles cancels prior subscription when called again',
      () async {
    final controller = StreamController<List<ArticleNewsEntity>>.broadcast();
    var firstListenCount = 0;

    when(() => mockGetArticlesNewsOfAuthorUseCase(params: 'a')).thenAnswer((_) {
      firstListenCount++;
      return controller.stream;
    });

    when(() => mockGetArticlesNewsOfAuthorUseCase(params: 'b')).thenAnswer(
      (_) => Stream.value([
        articleWithUpdatedAt(DateTime.utc(2021, 1, 1)),
      ]),
    );

    cubit.loadAuthorArticles('a');
    await Future<void>.delayed(Duration.zero);

    cubit.loadAuthorArticles('b');
    await Future<void>.delayed(Duration.zero);

    controller.add([
      articleWithUpdatedAt(DateTime.utc(1999, 1, 1)),
    ]);
    await Future<void>.delayed(Duration.zero);

    expect(
      cubit.state.authorArticles.single.articleUid,
      'id-${DateTime.utc(2021, 1, 1).millisecondsSinceEpoch}',
    );
    expect(firstListenCount, 1);

    await controller.close();
  });

  test('publishAuthorArticle emits loading then success and updates list',
      () async {
    final article = articleWithUpdatedAt(DateTime.utc(2024, 1, 1));
    when(() => mockGetArticlesNewsOfAuthorUseCase(params: 'author-1'))
        .thenAnswer((_) => Stream.value([article]));
    cubit.loadAuthorArticles('author-1');
    await Future<void>.delayed(Duration.zero);
    when(() => mockUpdateArticleNewsUseCase(params: any(named: 'params')))
        .thenAnswer((_) async {});

    await cubit.publishAuthorArticle(article);

    expect(cubit.state.publishStatus, AuthorArticlePublishStatus.success);
    expect(cubit.state.authorArticles.single.status, 'published');
    verify(() => mockUpdateArticleNewsUseCase(params: any(named: 'params')))
        .called(1);
  });

  test('publishAuthorArticle emits failure when update throws', () async {
    final article = articleWithUpdatedAt(DateTime.utc(2024, 1, 1));
    when(() => mockUpdateArticleNewsUseCase(params: any(named: 'params')))
        .thenThrow(Exception('failed'));

    await cubit.publishAuthorArticle(article);

    expect(cubit.state.publishStatus, AuthorArticlePublishStatus.failure);
    expect(
      cubit.state.publishError,
      'Could not publish the article. Please try again.',
    );
  });

  test('requestEditArticle and acknowledgeEditNavigation toggle edit state',
      () {
    final article = articleWithUpdatedAt(DateTime.utc(2024, 1, 1));

    cubit.requestEditArticle(article);
    expect(cubit.state.editActionStatus, AuthorArticleEditActionStatus.navigate);
    expect(cubit.state.selectedArticleForEdit, article);

    cubit.acknowledgeEditNavigation();
    expect(cubit.state.editActionStatus, AuthorArticleEditActionStatus.initial);
    expect(cubit.state.selectedArticleForEdit, isNull);
  });

  test('deleteAuthorArticle returns true on success', () async {
    when(() => mockDeleteArticleNewsUseCase(params: any(named: 'params')))
        .thenAnswer((_) async {});

    final result = await cubit.deleteAuthorArticle('article-1');

    expect(result, isTrue);
    verify(() => mockDeleteArticleNewsUseCase(params: any(named: 'params')))
        .called(1);
  });

  test('deleteAuthorArticle returns false on failure', () async {
    when(() => mockDeleteArticleNewsUseCase(params: any(named: 'params')))
        .thenThrow(Exception('failed'));

    final result = await cubit.deleteAuthorArticle('article-1');

    expect(result, isFalse);
  });
}
