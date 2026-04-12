import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/usecases/pick_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/picked_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_image_pick_source.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  late PickArticleImageUseCase useCase;
  late MockArticleImagePickerRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleImagePickerRepository();
    useCase = PickArticleImageUseCase(mockRepository);
  });

  test('delegates to repository with gallery when params are null', () async {
    when(
      () => mockRepository.pickFromDevice(
        source: ArticleImagePickSource.gallery,
      ),
    ).thenAnswer((_) async => null);

    await useCase();

    verify(
      () => mockRepository.pickFromDevice(
        source: ArticleImagePickSource.gallery,
      ),
    ).called(1);
  });

  test('passes source from params', () async {
    when(
      () => mockRepository.pickFromDevice(
        source: ArticleImagePickSource.camera,
      ),
    ).thenAnswer((_) async => null);

    await useCase(
      params: const PickArticleImageParams(
        source: ArticleImagePickSource.camera,
      ),
    );

    verify(
      () => mockRepository.pickFromDevice(
        source: ArticleImagePickSource.camera,
      ),
    ).called(1);
  });

  test('returns image from repository', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final image = PickedArticleImage(bytes: bytes);
    when(
      () => mockRepository.pickFromDevice(
        source: ArticleImagePickSource.gallery,
      ),
    ).thenAnswer((_) async => image);

    final result = await useCase();

    expect(result, same(image));
  });

  test('rethrows exceptions from the repository', () async {
    when(
      () => mockRepository.pickFromDevice(
        source: ArticleImagePickSource.gallery,
      ),
    ).thenThrow(Exception('picker'));

    expect(() => useCase(), throwsException);
  });
}
