import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/read_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article_reader/article_reader_cubit.dart';

class MockReadArticleUseCase extends Mock implements ReadArticleUseCase {}

void main() {
  late MockReadArticleUseCase mockReadArticleUseCase;
  late ArticleReaderCubit cubit;

  const testArticle = ArticleEntity(
    title: 'Article title',
    description: 'Article description',
    content: 'Article content',
  );

  setUpAll(() {
    registerFallbackValue(
      const ReadArticleParams(article: testArticle),
    );
  });

  setUp(() {
    mockReadArticleUseCase = MockReadArticleUseCase();
    cubit = ArticleReaderCubit(mockReadArticleUseCase);
    when(() => mockReadArticleUseCase.call(params: any(named: 'params')))
        .thenAnswer((_) async {});
    when(() => mockReadArticleUseCase.stop()).thenAnswer((_) async {});
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is idle', () {
    expect(cubit.state, const ArticleReaderState());
    expect(cubit.state.isReading, isFalse);
  });

  test('toggleRead emits reading then idle on success', () async {
    final expected = [
      const ArticleReaderState(isReading: true),
      const ArticleReaderState(isReading: false),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));

    await cubit.toggleRead(testArticle);

    verify(() => mockReadArticleUseCase.call(params: any(named: 'params')))
        .called(1);
  });

  test('toggleRead emits error state when use case throws', () async {
    when(() => mockReadArticleUseCase.call(params: any(named: 'params')))
        .thenThrow(Exception('tts error'));

    final expected = [
      const ArticleReaderState(isReading: true),
      const ArticleReaderState(
        isReading: false,
        errorMessage: 'Unable to read this article right now.',
      ),
    ];

    expectLater(cubit.stream, emitsInOrder(expected));

    await cubit.toggleRead(testArticle);
  });

  test('toggleRead while reading stops playback', () async {
    final completer = Completer<void>();
    when(() => mockReadArticleUseCase.call(params: any(named: 'params')))
        .thenAnswer((_) => completer.future);

    unawaited(cubit.toggleRead(testArticle));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.isReading, isTrue);

    await cubit.toggleRead(testArticle);
    expect(cubit.state.isReading, isFalse);
    verify(() => mockReadArticleUseCase.stop()).called(1);

    completer.complete();
  });

  test('acknowledgeError clears existing error message', () async {
    when(() => mockReadArticleUseCase.call(params: any(named: 'params')))
        .thenThrow(Exception('tts error'));

    await cubit.toggleRead(testArticle);
    expect(cubit.state.errorMessage, isNotNull);

    cubit.acknowledgeError();

    expect(cubit.state.errorMessage, isNull);
  });
}
