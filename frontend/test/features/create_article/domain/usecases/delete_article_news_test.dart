import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_news_repository.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/delete_article_news.dart';

class MockArticleNewsRepository extends Mock implements ArticleNewsRepository {}

void main() {
  late DeleteArticleNewsUseCase useCase;
  late MockArticleNewsRepository mockRepository;

  setUp(() {
    mockRepository = MockArticleNewsRepository();
    useCase = DeleteArticleNewsUseCase(mockRepository);
  });

  test('delegates delete by article uid to repository', () async {
    when(() => mockRepository.deleteArticle('article-1'))
        .thenAnswer((_) async {});

    await useCase(
      params: const DeleteArticleNewsParams(articleUid: 'article-1'),
    );

    verify(() => mockRepository.deleteArticle('article-1')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('throws TypeError when params are null', () async {
    expect(() => useCase(params: null), throwsA(isA<TypeError>()));
    verifyZeroInteractions(mockRepository);
  });
}
