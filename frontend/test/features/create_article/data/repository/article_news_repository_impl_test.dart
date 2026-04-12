// ignore_for_file: subtype_of_sealed_class

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/data/data_sources/firestore_articles_service.dart';
import 'package:news_app_clean_architecture/features/create_article/data/repository/article_news_repository_impl.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_thumbnail_url_resolver.dart';

class MockFirestoreArticlesService extends Mock
    implements FirestoreArticlesService {}

class MockArticleThumbnailUrlResolver extends Mock
    implements ArticleThumbnailUrlResolver {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late ArticleNewsRepositoryImpl repository;
  late MockFirestoreArticlesService mockArticlesService;
  late MockArticleThumbnailUrlResolver mockResolver;
  late MockDocumentReference mockDocRef;

  final created = DateTime.utc(2024, 1, 1);
  final updated = DateTime.utc(2024, 1, 2);

  ArticleNewsEntity buildEntity({String thumbnailUrl = 'path/in/storage'}) {
    return ArticleNewsEntity(
      articleUid: 'art-1',
      title: 'T',
      description: 'D',
      content: 'C',
      category: 'general',
      status: 'draft',
      thumbnailUrl: thumbnailUrl,
      authorUid: 'auth-1',
      authorName: 'Writer',
      createdAt: created,
      updatedAt: updated,
      viewsCount: 0,
    );
  }

  setUp(() {
    mockArticlesService = MockFirestoreArticlesService();
    mockResolver = MockArticleThumbnailUrlResolver();
    mockDocRef = MockDocumentReference();
    repository = ArticleNewsRepositoryImpl(mockArticlesService, mockResolver);
  });

  setUpAll(() {
    registerFallbackValue(FakeDocumentReference());
    registerFallbackValue(<String, dynamic>{});
  });

  test('allocateNewArticleId returns new document id', () async {
    when(() => mockDocRef.id).thenReturn('generated');
    when(() => mockArticlesService.newArticleDocument()).thenReturn(mockDocRef);

    final id = await repository.allocateNewArticleId();

    expect(id, 'generated');
    verify(() => mockArticlesService.newArticleDocument()).called(1);
  });

  test('createArticle sets model map on article document', () async {
    final entity = buildEntity(thumbnailUrl: 'https://existing');
    when(() => mockArticlesService.articleDocument('art-1'))
        .thenReturn(mockDocRef);
    when(
      () => mockArticlesService.setArticle(any(), any()),
    ).thenAnswer((_) async {});

    await repository.createArticle(entity);

    final captured = verify(
      () => mockArticlesService.setArticle(mockDocRef, captureAny()),
    ).captured.single as Map<String, dynamic>;

    expect(captured['articleUid'], 'art-1');
    expect(captured['title'], 'T');
    expect(captured['thumbnailUrl'], 'https://existing');
    verify(() => mockArticlesService.articleDocument('art-1')).called(1);
  });

  group('watch streams', () {
    MockQueryDocumentSnapshot snapshotWithMap(Map<String, dynamic> data) {
      final doc = MockQueryDocumentSnapshot();
      when(() => doc.id).thenReturn(data['articleUid'] as String? ?? 'doc-id');
      when(() => doc.data()).thenReturn(data);
      return doc;
    }

    test('watchArticlesNewsList resolves thumbnail URLs', () async {
      final doc = snapshotWithMap(<String, dynamic>{
        'articleUid': 'a1',
        'title': 'Title',
        'description': 'd',
        'content': 'c',
        'category': 'g',
        'status': 'published',
        'thumbnailUrl': 'storage/ref',
        'authorUid': 'u1',
        'authorName': 'Name',
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(updated),
        'viewsCount': 1,
      });
      when(() => mockArticlesService.watchAllArticles())
          .thenAnswer((_) => Stream.value([doc]));
      when(() => mockResolver.resolveToNetworkUrl(any()))
          .thenAnswer((_) async => 'https://cdn/img.jpg');

      final list = await repository.watchArticlesNewsList().first;

      expect(list, hasLength(1));
      expect(list.single.thumbnailUrl, 'https://cdn/img.jpg');
      verify(() => mockResolver.resolveToNetworkUrl('storage/ref')).called(1);
    });

    test('watchPublishedArticlesNewsList uses status query', () async {
      final doc = snapshotWithMap(<String, dynamic>{
        'articleUid': 'a1',
        'title': 'T',
        'description': '',
        'content': '',
        'category': '',
        'status': 'published',
        'thumbnailUrl': '',
        'authorUid': '',
        'authorName': '',
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(updated),
      });
      when(() => mockArticlesService.watchArticlesByStatus('published'))
          .thenAnswer((_) => Stream.value([doc]));
      when(() => mockResolver.resolveToNetworkUrl(any()))
          .thenAnswer((_) async => null);

      final list = await repository.watchPublishedArticlesNewsList().first;

      expect(list.single.thumbnailUrl, '');
      verify(() => mockArticlesService.watchArticlesByStatus('published'))
          .called(1);
    });

    test('watchArticlesNewsOfAuthor filters by author uid', () async {
      final doc = snapshotWithMap(<String, dynamic>{
        'articleUid': 'a1',
        'title': 'T',
        'description': '',
        'content': '',
        'category': '',
        'status': 'draft',
        'thumbnailUrl': 'https://already',
        'authorUid': 'author-x',
        'authorName': '',
        'createdAt': Timestamp.fromDate(created),
        'updatedAt': Timestamp.fromDate(updated),
      });
      when(() => mockArticlesService.watchArticlesByAuthorUid('author-x'))
          .thenAnswer((_) => Stream.value([doc]));
      when(() => mockResolver.resolveToNetworkUrl('https://already'))
          .thenAnswer((_) async => 'https://already');

      await repository.watchArticlesNewsOfAuthor('author-x').first;

      verify(() => mockArticlesService.watchArticlesByAuthorUid('author-x'))
          .called(1);
    });
  });
}
