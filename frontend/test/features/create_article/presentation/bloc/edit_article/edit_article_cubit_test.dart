import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/picked_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/pick_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/update_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/edit_article/edit_article_cubit.dart';

class MockPickArticleImageUseCase extends Mock implements PickArticleImageUseCase {}
class MockUpdateArticleNewsUseCase extends Mock implements UpdateArticleNewsUseCase {}

void main() {
  late MockPickArticleImageUseCase mockPickArticleImageUseCase;
  late MockUpdateArticleNewsUseCase mockUpdateArticleNewsUseCase;
  late EditArticleCubit cubit;

  final sampleArticle = ArticleNewsEntity(
    articleUid: 'article-1',
    title: 'Title',
    description: 'Description',
    content: 'Content',
    category: 'general',
    status: 'draft',
    thumbnailUrl: '',
    authorUid: 'author-1',
    authorName: 'Author',
    createdAt: DateTime.utc(2024, 1, 1),
    updatedAt: DateTime.utc(2024, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(UpdateArticleNewsParams(article: sampleArticle));
  });

  setUp(() {
    mockPickArticleImageUseCase = MockPickArticleImageUseCase();
    mockUpdateArticleNewsUseCase = MockUpdateArticleNewsUseCase();
    cubit = EditArticleCubit(
      mockPickArticleImageUseCase,
      mockUpdateArticleNewsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is EditArticleState', () {
    expect(cubit.state, const EditArticleState());
  });

  test('pickImageFromGallery does not emit when picker returns null', () async {
    when(() => mockPickArticleImageUseCase()).thenAnswer((_) async => null);

    await cubit.pickImageFromGallery();

    expect(cubit.state.imageBytes, isNull);
  });

  test('pickImageFromGallery emits picked image bytes', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    when(() => mockPickArticleImageUseCase()).thenAnswer(
      (_) async => PickedArticleImage(bytes: bytes),
    );

    await cubit.pickImageFromGallery();

    expect(cubit.state.imageBytes, bytes);
  });

  test('clearPickedImage clears selected image bytes', () async {
    final bytes = Uint8List.fromList([1, 2, 3]);
    when(() => mockPickArticleImageUseCase()).thenAnswer(
      (_) async => PickedArticleImage(bytes: bytes),
    );
    await cubit.pickImageFromGallery();

    cubit.clearPickedImage();

    expect(cubit.state.imageBytes, isNull);
  });

  test('submitEdit emits success when update succeeds', () async {
    when(() => mockUpdateArticleNewsUseCase(params: any(named: 'params')))
        .thenAnswer((_) async {});

    await cubit.submitEdit(sampleArticle);

    expect(cubit.state.submissionStatus, EditArticleSubmissionStatus.success);
  });

  test('submitEdit emits failure with friendly message on exception', () async {
    when(() => mockUpdateArticleNewsUseCase(params: any(named: 'params')))
        .thenThrow(Exception('failed'));

    await cubit.submitEdit(sampleArticle);

    expect(cubit.state.submissionStatus, EditArticleSubmissionStatus.failure);
    expect(
      cubit.state.errorMessage,
      'Could not update the article. Please try again.',
    );
  });

  test('acknowledgeResult resets status and clears error message', () async {
    when(() => mockUpdateArticleNewsUseCase(params: any(named: 'params')))
        .thenThrow(Exception('failed'));
    await cubit.submitEdit(sampleArticle);

    cubit.acknowledgeResult();

    expect(cubit.state.submissionStatus, EditArticleSubmissionStatus.initial);
    expect(cubit.state.errorMessage, isNull);
  });
}
