import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/usecases/upload_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_thumbnail_storage.dart';

class MockArticleThumbnailStorage extends Mock
    implements ArticleThumbnailStorage {}

void main() {
  late UploadArticleThumbnailUseCase useCase;
  late MockArticleThumbnailStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue('');
  });

  setUp(() {
    mockStorage = MockArticleThumbnailStorage();
    useCase = UploadArticleThumbnailUseCase(mockStorage);
  });

  test('delegates to storage and returns download URL', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    const articleUid = 'art-1';
    when(
      () => mockStorage.uploadJpegThumbnail(
        articleUid: articleUid,
        bytes: bytes,
      ),
    ).thenAnswer((_) async => 'https://cdn.example/thumb.jpg');

    final result = await useCase(
      params:
          UploadArticleThumbnailParams(articleUid: articleUid, bytes: bytes),
    );

    expect(result, 'https://cdn.example/thumb.jpg');
    verify(
      () => mockStorage.uploadJpegThumbnail(
        articleUid: articleUid,
        bytes: bytes,
      ),
    ).called(1);
    verifyNoMoreInteractions(mockStorage);
  });

  test('throws TypeError when params are null', () async {
    expect(() => useCase(params: null), throwsA(isA<TypeError>()));
    verifyZeroInteractions(mockStorage);
  });

  test('propagates errors from storage', () async {
    final bytes = Uint8List.fromList([1]);
    when(
      () => mockStorage.uploadJpegThumbnail(
        articleUid: any(named: 'articleUid'),
        bytes: any(named: 'bytes'),
      ),
    ).thenThrow(Exception('upload failed'));

    expect(
      () => useCase(
        params: UploadArticleThumbnailParams(
          articleUid: 'x',
          bytes: bytes,
        ),
      ),
      throwsException,
    );
  });
}
