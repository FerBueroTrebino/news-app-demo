import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/post_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/pick_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/picked_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/create_article/create_article_cubit.dart';

class MockPickArticleImageUseCase extends Mock
    implements PickArticleImageUseCase {}

class MockPostArticleNewsUseCase extends Mock
    implements PostArticleNewsUseCase {}

void main() {
  late CreateArticleCubit cubit;
  late MockPickArticleImageUseCase mockPickArticleImageUseCase;
  late MockPostArticleNewsUseCase mockPostArticleNewsUseCase;

  final tBytes = Uint8List.fromList([1, 2, 3]);

  final tDraft = ArticleNewsEntity(
    articleUid: 'draft',
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
    viewsCount: 0,
  );

  final tAuthor = AuthUser(
    uid: 'author-1',
    email: 'writer@example.com',
    displayName: 'Display Name',
  );

  setUpAll(() {
    registerFallbackValue(
      PostArticleNewsParams(
        article: ArticleNewsEntity(
          articleUid: 'fb',
          title: 't',
          description: 'd',
          content: 'c',
          category: 'general',
          status: 'draft',
          thumbnailUrl: '',
          authorUid: 'a',
          authorName: 'n',
          createdAt: DateTime.utc(2000),
          updatedAt: DateTime.utc(2000),
        ),
        thumbnailBytes: Uint8List(0),
      ),
    );
  });

  setUp(() {
    mockPickArticleImageUseCase = MockPickArticleImageUseCase();
    mockPostArticleNewsUseCase = MockPostArticleNewsUseCase();
    cubit = CreateArticleCubit(
      mockPickArticleImageUseCase,
      mockPostArticleNewsUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is CreateArticleState', () {
    expect(cubit.state, const CreateArticleState());
  });

  test('pickImageFromGallery does not emit when picker returns null', () async {
    when(() => mockPickArticleImageUseCase()).thenAnswer((_) async => null);

    await cubit.pickImageFromGallery();

    expect(cubit.state, const CreateArticleState());
    verify(() => mockPickArticleImageUseCase()).called(1);
  });

  test('pickImageFromGallery emits image bytes when picker returns image',
      () async {
    when(() => mockPickArticleImageUseCase()).thenAnswer(
      (_) async => PickedArticleImage(bytes: tBytes),
    );

    final expected = [
      CreateArticleState(imageBytes: tBytes),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));

    await cubit.pickImageFromGallery();
    verify(() => mockPickArticleImageUseCase()).called(1);
  });

  test('clearImage clears imageBytes', () async {
    when(() => mockPickArticleImageUseCase()).thenAnswer(
      (_) async => PickedArticleImage(bytes: tBytes),
    );

    await cubit.pickImageFromGallery();
    expect(cubit.state.imageBytes, tBytes);

    cubit.clearImage();

    expect(cubit.state.imageBytes, isNull);
  });

  test('acknowledgeSubmissionResult resets submission-related fields',
      () async {
    when(() => mockPostArticleNewsUseCase(params: any(named: 'params')))
        .thenAnswer((_) async => 'new-id');

    await cubit.submitArticle(
      author: tAuthor,
      draft: tDraft,
      thumbnailBytes: tBytes,
    );

    expect(cubit.state.submissionStatus, CreateArticleSubmissionStatus.success);
    expect(cubit.state.createdArticleId, 'new-id');

    cubit.acknowledgeSubmissionResult();

    expect(cubit.state.submissionStatus, CreateArticleSubmissionStatus.initial);
    expect(cubit.state.createdArticleId, isNull);
    expect(cubit.state.createdArticleStatus, isNull);
    expect(cubit.state.errorMessage, isNull);
  });

  test('submitArticle emits loading then success with id and draft status',
      () async {
    when(() => mockPostArticleNewsUseCase(params: any(named: 'params')))
        .thenAnswer((_) async => 'article-uid');

    final expected = [
      const CreateArticleState(
        submissionStatus: CreateArticleSubmissionStatus.loading,
      ),
      const CreateArticleState(
        submissionStatus: CreateArticleSubmissionStatus.success,
        createdArticleId: 'article-uid',
        createdArticleStatus: 'draft',
      ),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));

    await cubit.submitArticle(
      author: tAuthor,
      draft: tDraft,
      thumbnailBytes: tBytes,
    );

    verify(() => mockPostArticleNewsUseCase(params: any(named: 'params')))
        .called(1);
  });

  test('submitArticle emits loading then failure when use case throws',
      () async {
    when(() => mockPostArticleNewsUseCase(params: any(named: 'params')))
        .thenThrow(Exception('network'));

    final expected = [
      const CreateArticleState(
        submissionStatus: CreateArticleSubmissionStatus.loading,
      ),
      const CreateArticleState(
        submissionStatus: CreateArticleSubmissionStatus.failure,
        errorMessage: 'Could not save the article. Please try again.',
      ),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));

    await cubit.submitArticle(
      author: tAuthor,
      draft: tDraft,
      thumbnailBytes: tBytes,
    );
  });

  group('resolveAuthorDisplayName', () {
    test('uses trimmed display name when at least 2 characters', () {
      const author = AuthUser(
        uid: 'u',
        displayName: '  Jane  ',
      );
      expect(cubit.resolveAuthorDisplayName(author), 'Jane');
    });

    test('truncates display name to 50 characters', () {
      final long = 'a' * 60;
      final author = AuthUser(uid: 'u', displayName: long);
      expect(cubit.resolveAuthorDisplayName(author), 'a' * 50);
    });

    test('falls back to email local part when display name is too short', () {
      const author = AuthUser(
        uid: 'u',
        email: 'john.doe@example.com',
        displayName: 'x',
      );
      expect(cubit.resolveAuthorDisplayName(author), 'john.doe');
    });

    test('returns Author when no usable name or email', () {
      const author = AuthUser(uid: 'u', email: 'a@b.c', displayName: ' ');
      expect(cubit.resolveAuthorDisplayName(author), 'Author');
    });
  });
}
