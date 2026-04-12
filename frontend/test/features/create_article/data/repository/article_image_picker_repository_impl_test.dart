import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_image_pick_source.dart';
import 'package:news_app_clean_architecture/features/create_article/data/repository/article_image_picker_repository_impl.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  late ArticleImagePickerRepositoryImpl repository;
  late MockImagePicker mockPicker;
  late Directory tempDir;

  setUp(() async {
    mockPicker = MockImagePicker();
    repository = ArticleImagePickerRepositoryImpl(imagePicker: mockPicker);
    tempDir = await Directory.systemTemp.createTemp('article_picker_test_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUpAll(() {
    registerFallbackValue(ImageSource.gallery);
    registerFallbackValue(ImageSource.camera);
  });

  test('returns null when user cancels pick', () async {
    when(() => mockPicker.pickImage(source: any(named: 'source')))
        .thenAnswer((_) async => null);

    final fromGallery = await repository.pickFromDevice(
      source: ArticleImagePickSource.gallery,
    );
    final fromCamera = await repository.pickFromDevice(
      source: ArticleImagePickSource.camera,
    );

    expect(fromGallery, isNull);
    expect(fromCamera, isNull);
  });

  test('maps gallery source to ImageSource.gallery', () async {
    when(() => mockPicker.pickImage(source: ImageSource.gallery))
        .thenAnswer((_) async => null);

    await repository.pickFromDevice(source: ArticleImagePickSource.gallery);

    verify(() => mockPicker.pickImage(source: ImageSource.gallery)).called(1);
  });

  test('returns PickedArticleImage with file bytes when pick succeeds',
      () async {
    final file = File('${tempDir.path}/pick.bin');
    await file.writeAsBytes([10, 20, 30]);
    final xFile = XFile(file.path);

    when(() => mockPicker.pickImage(source: ImageSource.gallery))
        .thenAnswer((_) async => xFile);

    final picked = await repository.pickFromDevice(
      source: ArticleImagePickSource.gallery,
    );

    expect(picked, isNotNull);
    expect(picked!.bytes, [10, 20, 30]);
  });
}
