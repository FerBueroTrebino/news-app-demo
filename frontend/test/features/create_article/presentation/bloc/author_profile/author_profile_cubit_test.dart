import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/get_articles_news_of_author.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/author_profile/author_profile_cubit.dart';

class MockGetArticlesNewsOfAuthorUseCase extends Mock
    implements GetArticlesNewsOfAuthorUseCase {}

void main() {
  late AuthorProfileCubit cubit;
  late MockGetArticlesNewsOfAuthorUseCase mockGetArticlesNewsOfAuthorUseCase;

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

  setUp(() {
    mockGetArticlesNewsOfAuthorUseCase = MockGetArticlesNewsOfAuthorUseCase();
    cubit = AuthorProfileCubit(mockGetArticlesNewsOfAuthorUseCase);
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
}
