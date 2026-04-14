import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_news_repository.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_thumbnail_storage.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/update_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/upload_article_thumbnail.dart';

class MockArticleNewsRepository extends Mock implements ArticleNewsRepository {}

class MockArticleThumbnailStorage extends Mock
    implements ArticleThumbnailStorage {}

void main() {
  late UpdateArticleNewsUseCase useCase;
  late MockArticleNewsRepository mockRepository;
  late MockArticleThumbnailStorage mockStorage;
  late UploadArticleThumbnailUseCase uploadThumbnail;

  final article = ArticleNewsEntity(
    articleUid: 'article-1',
    title: 'Title',
    description: 'Description',
    content: 'Body',
    category: 'technology',
    status: 'draft',
    thumbnailUrl: 'existing-url',
    authorUid: 'author-1',
    authorName: 'Writer',
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2024, 1, 2),
    publishedAt: DateTime.utc(2024, 1, 3),
    viewsCount: 10,
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
    useCase = UpdateArticleNewsUseCase(mockRepository, uploadThumbnail);
  });

  test('updates article using existing thumbnail when bytes are null', () async {
    when(() => mockRepository.updateArticle(any())).thenAnswer((_) async {});

    await useCase(
      params: UpdateArticleNewsParams(article: article),
    );

    final captured = verify(
      () => mockRepository.updateArticle(captureAny()),
    ).captured.single as ArticleNewsEntity;
    expect(captured.thumbnailUrl, 'existing-url');
    verifyNever(
      () => mockStorage.uploadJpegThumbnail(
        articleUid: any(named: 'articleUid'),
        bytes: any(named: 'bytes'),
      ),
    );
  });

  test('uploads thumbnail and updates article with uploaded url', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    when(
      () => mockStorage.uploadJpegThumbnail(
        articleUid: any(named: 'articleUid'),
        bytes: any(named: 'bytes'),
      ),
    ).thenAnswer((_) async => 'https://cdn/new-thumb.jpg');
    when(() => mockRepository.updateArticle(any())).thenAnswer((_) async {});

    await useCase(
      params: UpdateArticleNewsParams(article: article, thumbnailBytes: bytes),
    );

    verify(
      () => mockStorage.uploadJpegThumbnail(
        articleUid: 'article-1',
        bytes: bytes,
      ),
    ).called(1);
    final captured = verify(
      () => mockRepository.updateArticle(captureAny()),
    ).captured.single as ArticleNewsEntity;
    expect(captured.thumbnailUrl, 'https://cdn/new-thumb.jpg');
  });

  test('throws TypeError when params are null', () async {
    expect(() => useCase(params: null), throwsA(isA<TypeError>()));
    verifyZeroInteractions(mockRepository);
    verifyZeroInteractions(mockStorage);
  });
}
