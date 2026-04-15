import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_reader.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/read_article.dart';

class MockArticleReader extends Mock implements ArticleReader {}

void main() {
  late MockArticleReader mockArticleReader;
  late ReadArticleUseCase useCase;

  const testArticle = ArticleEntity(
    title: 'Breaking news title',
    description: 'Short description',
    content: 'Main content body',
  );

  setUp(() {
    mockArticleReader = MockArticleReader();
    useCase = ReadArticleUseCase(mockArticleReader);

    when(() => mockArticleReader.prepare()).thenAnswer((_) async {});
    when(() => mockArticleReader.stop()).thenAnswer((_) async {});
    when(() => mockArticleReader.speak(any())).thenAnswer((_) async {});
  });

  test('reads title, description and content in order', () async {
    await useCase.call(
      params: const ReadArticleParams(article: testArticle),
    );

    verifyInOrder([
      () => mockArticleReader.prepare(),
      () => mockArticleReader.stop(),
      () => mockArticleReader.speak('Breaking news title'),
      () => mockArticleReader.speak('Short description'),
      () => mockArticleReader.speak('Main content body'),
    ]);
    verifyNoMoreInteractions(mockArticleReader);
  });

  test('removes truncated suffix from content before speaking', () async {
    const article = ArticleEntity(
      title: 'Title',
      description: 'Description',
      content: 'Long content [+231 chars]',
    );

    await useCase.call(
      params: const ReadArticleParams(article: article),
    );

    verify(() => mockArticleReader.speak('Long content')).called(1);
  });

  test('does not speak when all fields are empty', () async {
    const article = ArticleEntity(
      title: ' ',
      description: '',
      content: null,
    );

    await useCase.call(
      params: const ReadArticleParams(article: article),
    );

    verifyNever(() => mockArticleReader.prepare());
    verifyNever(() => mockArticleReader.stop());
    verifyNever(() => mockArticleReader.speak(any()));
  });

  test('stop delegates to article reader stop', () async {
    await useCase.stop();

    verify(() => mockArticleReader.stop()).called(1);
  });
}
