import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/usecases/post_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/upload_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_news_repository.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_thumbnail_storage.dart';

class MockArticleNewsRepository extends Mock implements ArticleNewsRepository {}

class MockArticleThumbnailStorage extends Mock
    implements ArticleThumbnailStorage {}

void main() {
  late PostArticleNewsUseCase useCase;
  late MockArticleNewsRepository mockRepository;
  late MockArticleThumbnailStorage mockStorage;
  late UploadArticleThumbnailUseCase uploadThumbnail;

  final inputArticle = ArticleNewsEntity(
    articleUid: 'ignored',
    title: 'Title',
    description: 'Desc',
    content: 'Body',
    category: 'technology',
    status: 'draft',
    thumbnailUrl: '',
    authorUid: 'author-1',
    authorName: 'Writer',
    createdAt: DateTime.utc(2020, 1, 1),
    updatedAt: DateTime.utc(2020, 1, 2),
    publishedAt: DateTime.utc(2020, 1, 3),
    viewsCount: 7,
  );

  setUpAll(() {
    registerFallbackValue(
      ArticleNewsEntity(
        articleUid: 'fallback',
        title: 'f',
        description: 'f',
        content: 'f',
        category: 'general',
        status: 'draft',
        thumbnailUrl: 'f',
        authorUid: 'f',
        authorName: 'f',
        createdAt: DateTime.utc(2000),
        updatedAt: DateTime.utc(2000),
      ),
    );
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockRepository = MockArticleNewsRepository();
    mockStorage = MockArticleThumbnailStorage();
    uploadThumbnail = UploadArticleThumbnailUseCase(mockStorage);
    useCase = PostArticleNewsUseCase(mockRepository, uploadThumbnail);
  });

  test('allocates id, uploads thumbnail, creates article, returns uid',
      () async {
    final bytes = Uint8List.fromList([9, 8, 7]);
    final before = DateTime.now();
    when(() => mockRepository.allocateNewArticleId())
        .thenAnswer((_) async => 'new-uid');
    when(
      () => mockStorage.uploadJpegThumbnail(
        articleUid: any(named: 'articleUid'),
        bytes: any(named: 'bytes'),
      ),
    ).thenAnswer((_) async => 'https://cdn/thumb.jpg');
    when(() => mockRepository.createArticle(any())).thenAnswer((_) async {});

    final uid = await useCase(
      params:
          PostArticleNewsParams(article: inputArticle, thumbnailBytes: bytes),
    );
    final after = DateTime.now();

    expect(uid, 'new-uid');

    final createArticleVerify =
        verify(() => mockRepository.createArticle(captureAny()));
    final captured = createArticleVerify.captured.single as ArticleNewsEntity;
    createArticleVerify.called(1);

    expect(captured.articleUid, 'new-uid');
    expect(captured.title, inputArticle.title);
    expect(captured.description, inputArticle.description);
    expect(captured.content, inputArticle.content);
    expect(captured.category, inputArticle.category);
    expect(captured.status, inputArticle.status);
    expect(captured.thumbnailUrl, 'https://cdn/thumb.jpg');
    expect(captured.authorUid, inputArticle.authorUid);
    expect(captured.authorName, inputArticle.authorName);
    expect(captured.publishedAt, inputArticle.publishedAt);
    expect(captured.viewsCount, inputArticle.viewsCount);
    expect(captured.updatedAt, captured.createdAt);
    expect(
      captured.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
      isTrue,
    );
    expect(
      captured.createdAt.isBefore(after.add(const Duration(seconds: 1))),
      isTrue,
    );

    verify(() => mockRepository.allocateNewArticleId()).called(1);
    verify(
      () => mockStorage.uploadJpegThumbnail(
        articleUid: 'new-uid',
        bytes: bytes,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockRepository);
    verifyNoMoreInteractions(mockStorage);
  });

  test('throws TypeError when params are null', () async {
    expect(() => useCase(params: null), throwsA(isA<TypeError>()));
    verifyZeroInteractions(mockRepository);
    verifyZeroInteractions(mockStorage);
  });

  test('does not create article when thumbnail upload fails', () async {
    final bytes = Uint8List.fromList([1]);
    when(() => mockRepository.allocateNewArticleId())
        .thenAnswer((_) async => 'new-uid');
    when(
      () => mockStorage.uploadJpegThumbnail(
        articleUid: any(named: 'articleUid'),
        bytes: any(named: 'bytes'),
      ),
    ).thenThrow(Exception('upload failed'));

    expect(
      () => useCase(
        params:
            PostArticleNewsParams(article: inputArticle, thumbnailBytes: bytes),
      ),
      throwsException,
    );

    verify(() => mockRepository.allocateNewArticleId()).called(1);
    verifyNever(() => mockRepository.createArticle(any()));
  });
}
