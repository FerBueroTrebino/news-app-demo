import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:news_app_clean_architecture/features/create_article/data/repository/article_thumbnail_storage_impl.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

void main() {
  late ArticleThumbnailStorageImpl impl;
  late MockFirebaseStorage mockStorage;
  late MockReference mockRef;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockRef = MockReference();
    impl = ArticleThumbnailStorageImpl(mockStorage);
  });

  group('objectPathForArticle', () {
    test('returns expected storage path', () {
      expect(
        ArticleThumbnailStorageImpl.objectPathForArticle('abc'),
        'media/articles/abc/thumbnail.jpg',
      );
    });
  });

  group('resolveToNetworkUrl', () {
    test('returns null for empty and whitespace', () async {
      expect(await impl.resolveToNetworkUrl(''), isNull);
      expect(await impl.resolveToNetworkUrl('   '), isNull);
    });

    test('returns same string for http and https URLs', () async {
      expect(
        await impl.resolveToNetworkUrl('http://x/y'),
        'http://x/y',
      );
      expect(
        await impl.resolveToNetworkUrl('https://x/y'),
        'https://x/y',
      );
      verifyNever(() => mockStorage.ref(any()));
    });

    test('loads download URL from storage ref when value is a path', () async {
      when(() => mockStorage.ref('media/a')).thenReturn(mockRef);
      when(() => mockRef.getDownloadURL())
          .thenAnswer((_) async => 'https://cdn/file');

      final url = await impl.resolveToNetworkUrl('media/a');

      expect(url, 'https://cdn/file');
      verify(() => mockStorage.ref('media/a')).called(1);
    });

    test('returns null when getDownloadURL throws', () async {
      when(() => mockStorage.ref('bad')).thenReturn(mockRef);
      when(() => mockRef.getDownloadURL()).thenThrow(Exception('missing'));

      expect(await impl.resolveToNetworkUrl('bad'), isNull);
    });
  });
}
