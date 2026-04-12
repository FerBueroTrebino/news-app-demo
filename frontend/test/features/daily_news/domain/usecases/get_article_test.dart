import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/core/error/failure.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late GetArticleUseCase getArticleUseCase;

  late MockArticleRepository mockArticleRepository;

  late MockGetArticlesNewsListUseCase mockArticlesNewsListUseCase;

  setUp(() {
    mockArticleRepository = MockArticleRepository();

    mockArticlesNewsListUseCase = MockGetArticlesNewsListUseCase();

    getArticleUseCase =
        GetArticleUseCase(mockArticleRepository, mockArticlesNewsListUseCase);
  });

  final tPublishedNews = ArticleNewsEntity(
    articleUid: 'uid1',
    title: 'News Title',
    description: 'News Desc',
    content: 'News content',
    category: 'general',
    status: 'published',
    thumbnailUrl: 'https://thumb',
    authorUid: 'a1',
    authorName: 'Author One',
    createdAt: DateTime.utc(2026, 1, 1),
    updatedAt: DateTime.utc(2026, 1, 2),
    publishedAt: DateTime.utc(2026, 1, 2),
  );

  test(
    'should get a list of articles from the repository when successful',
    () async {
      when(() => mockArticlesNewsListUseCase())
          .thenAnswer((_) => Stream.value(<ArticleNewsEntity>[]));

      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => DataSuccess(testArticleList));

      final result = await getArticleUseCase().first;

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());

      expect(result.data, equals(testArticleList));

      verify(() => mockArticleRepository.getNewsArticles()).called(1);

      verify(() => mockArticlesNewsListUseCase()).called(1);

      verifyNoMoreInteractions(mockArticleRepository);

      verifyNoMoreInteractions(mockArticlesNewsListUseCase);
    },
  );

  test(
    'should merge Firestore articles with API articles (newest published first)',
    () async {
      when(() => mockArticlesNewsListUseCase())
          .thenAnswer((_) => Stream.value([tPublishedNews]));

      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => DataSuccess(testArticleList));

      final result = await getArticleUseCase().first;

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());

      expect(result.data!.length, testArticleList.length + 1);

      expect(
        result.data!.first,
        const ArticleEntity(
          author: 'Author One',
          title: 'News Title',
          description: 'News Desc',
          content: 'News content',
          url: 'article-news://uid1',
          urlToImage: 'https://thumb',
          publishedAt: '2026-01-02T00:00:00.000Z',
        ),
      );

      expect(result.data!.skip(1).toList(), testArticleList);

      verify(() => mockArticleRepository.getNewsArticles()).called(1);

      verify(() => mockArticlesNewsListUseCase()).called(1);
    },
  );

  test(
    'should return an empty list when successful and no articles are found',
    () async {
      when(() => mockArticlesNewsListUseCase())
          .thenAnswer((_) => Stream.value(<ArticleNewsEntity>[]));

      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => const DataSuccess(<ArticleEntity>[]));

      final result = await getArticleUseCase().first;

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());

      expect(result.data, isEmpty);

      verify(() => mockArticleRepository.getNewsArticles()).called(1);

      verify(() => mockArticlesNewsListUseCase()).called(1);
    },
  );

  test(
    'should return a failed data state when the repository fails and there '
    'is no Firestore article from the list use case',
    () async {
      const tFailure = ServerFailure("An unexpected error occurred");

      when(() => mockArticlesNewsListUseCase())
          .thenAnswer((_) => Stream.value(<ArticleNewsEntity>[]));

      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => const DataFailed(tFailure));

      final result = await getArticleUseCase().first;

      expect(result, isA<DataFailed<List<ArticleEntity>>>());

      expect(result.error, equals(tFailure));

      verify(() => mockArticleRepository.getNewsArticles()).called(1);

      verify(() => mockArticlesNewsListUseCase()).called(1);
    },
  );

  test(
    'should return success with Firestore articles when API fails but '
    'articles exist from the list use case',
    () async {
      const tFailure = ServerFailure("An unexpected error occurred");

      when(() => mockArticlesNewsListUseCase())
          .thenAnswer((_) => Stream.value([tPublishedNews]));

      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => const DataFailed(tFailure));

      final result = await getArticleUseCase().first;

      expect(result, isA<DataSuccess<List<ArticleEntity>>>());

      expect(result.data, hasLength(1));

      expect(result.data!.first.url, 'article-news://uid1');
    },
  );

  test(
    'should sort merged articles by publishedAt descending',
    () async {
      final newerApi = const ArticleEntity(
        id: 1,
        title: 'Newer API',
        publishedAt: '2027-01-01T00:00:00.000Z',
      );
      final olderApi = const ArticleEntity(
        id: 2,
        title: 'Older API',
        publishedAt: '2025-01-01T00:00:00.000Z',
      );
      final midFirestore = ArticleNewsEntity(
        articleUid: 'mid',
        title: 'Mid Firestore',
        description: 'd',
        content: 'c',
        category: 'general',
        status: 'published',
        thumbnailUrl: '',
        authorUid: 'a',
        authorName: 'A',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
        publishedAt: DateTime.utc(2026, 6, 1),
      );

      when(() => mockArticlesNewsListUseCase())
          .thenAnswer((_) => Stream.value([midFirestore]));
      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => DataSuccess([newerApi, olderApi]));

      final result = await getArticleUseCase().first;

      expect(result.data!.map((e) => e.title).toList(), [
        'Newer API',
        'Mid Firestore',
        'Older API',
      ]);
    },
  );

  test(
    'should use createdAt when Firestore article has no publishedAt',
    () async {
      final newsNoPublished = ArticleNewsEntity(
        articleUid: 'uid2',
        title: 'T',
        description: 'd',
        content: 'c',
        category: 'general',
        status: 'published',
        thumbnailUrl: 'x',
        authorUid: 'a',
        authorName: 'A',
        createdAt: DateTime.utc(2026, 5, 5),
        updatedAt: DateTime.utc(2026, 5, 5),
        publishedAt: null,
      );

      when(() => mockArticlesNewsListUseCase())
          .thenAnswer((_) => Stream.value([newsNoPublished]));
      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => const DataSuccess(<ArticleEntity>[]));

      final result = await getArticleUseCase().first;

      expect(result.data!.single.publishedAt, '2026-05-05T00:00:00.000Z');
    },
  );

  test(
    'should map empty Firestore thumbnail to null urlToImage',
    () async {
      final noThumb = ArticleNewsEntity(
        articleUid: 'uid3',
        title: 'T',
        description: 'd',
        content: 'c',
        category: 'general',
        status: 'published',
        thumbnailUrl: '',
        authorUid: 'a',
        authorName: 'A',
        createdAt: DateTime.utc(2026, 1, 1),
        updatedAt: DateTime.utc(2026, 1, 1),
        publishedAt: DateTime.utc(2026, 1, 2),
      );

      when(() => mockArticlesNewsListUseCase())
          .thenAnswer((_) => Stream.value([noThumb]));
      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => const DataSuccess(<ArticleEntity>[]));

      final result = await getArticleUseCase().first;

      expect(result.data!.single.urlToImage, isNull);
    },
  );

  test(
    'should call getNewsArticles only once when the news list stream emits '
    'multiple times',
    () async {
      when(() => mockArticlesNewsListUseCase()).thenAnswer(
        (_) => Stream.fromIterable([
          <ArticleNewsEntity>[],
          [tPublishedNews],
        ]),
      );
      when(() => mockArticleRepository.getNewsArticles())
          .thenAnswer((_) async => DataSuccess(testArticleList));

      final out = await getArticleUseCase().take(2).toList();

      expect(out, hasLength(2));
      verify(() => mockArticleRepository.getNewsArticles()).called(1);
    },
  );
}
