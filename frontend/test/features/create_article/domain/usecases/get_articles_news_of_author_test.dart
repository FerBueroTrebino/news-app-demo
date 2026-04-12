import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_news_repository.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/get_articles_news_of_author.dart';

class MockArticleNewsRepository extends Mock implements ArticleNewsRepository {}

void main() {
  late GetArticlesNewsOfAuthorUseCase useCase;
  late MockArticleNewsRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleNewsRepository();
    useCase = GetArticlesNewsOfAuthorUseCase(mockRepository);
  });

  test('throws ArgumentError when params is null', () {
    expect(
      () => useCase(),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('authorUid is required'),
        ),
      ),
    );
    verifyNever(() => mockRepository.watchArticlesNewsOfAuthor(any()));
  });

  test('throws ArgumentError when authorUid is empty', () {
    expect(
      () => useCase(params: ''),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('authorUid is required'),
        ),
      ),
    );
    verifyNever(() => mockRepository.watchArticlesNewsOfAuthor(any()));
  });

  test('delegates to watchArticlesNewsOfAuthor', () async {
    const authorUid = 'author-1';
    when(() => mockRepository.watchArticlesNewsOfAuthor(authorUid))
        .thenAnswer((_) => Stream.value(<ArticleNewsEntity>[]));

    await useCase(params: authorUid).first;

    verify(() => mockRepository.watchArticlesNewsOfAuthor(authorUid)).called(1);
  });
}
