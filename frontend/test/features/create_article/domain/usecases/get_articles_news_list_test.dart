import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/get_articles_news_list.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_news_repository.dart';

class MockArticleNewsRepository extends Mock implements ArticleNewsRepository {}

void main() {
  late GetArticlesNewsListUseCase useCase;

  late MockArticleNewsRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleNewsRepository();

    useCase = GetArticlesNewsListUseCase(mockRepository);
  });

  test('delegates to watchPublishedArticlesNewsList', () async {
    when(() => mockRepository.watchPublishedArticlesNewsList())
        .thenAnswer((_) => Stream.value(<ArticleNewsEntity>[]));

    await useCase().first;

    verify(() => mockRepository.watchPublishedArticlesNewsList()).called(1);

    verifyNever(() => mockRepository.watchArticlesNewsList());
  });
}
