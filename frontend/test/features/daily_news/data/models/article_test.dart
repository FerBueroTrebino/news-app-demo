import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  test(
    'should be a subclass of ArticleEntity',
    () async {
      // assert
      expect(testArticleModel, isA<ArticleEntity>());
    },
  );

  group('fromJson', () {
    test(
      'should return a valid model when the JSON is correct',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = testArticleMap;

        // act
        final result = ArticleModel.fromJson(jsonMap);

        // assert
        expect(result.author, testArticleModel.author);
        expect(result.title, testArticleModel.title);
        expect(result.description, testArticleModel.description);
        expect(result.url, testArticleModel.url);
        expect(result.urlToImage, testArticleModel.urlToImage);
        expect(result.publishedAt, testArticleModel.publishedAt);
        expect(result.content, testArticleModel.content);
      },
    );

    group('fromEntity', () {
      test(
        'should return a valid model from entity',
        () async {
          // act
          final result = ArticleModel.fromEntity(testArticleEntity);

          // assert
          expect(result.id, testArticleEntity.id);
          expect(result.author, testArticleEntity.author);
          expect(result.title, testArticleEntity.title);
          expect(result.description, testArticleEntity.description);
          expect(result.url, testArticleEntity.url);
          expect(result.urlToImage, testArticleEntity.urlToImage);
          expect(result.publishedAt, testArticleEntity.publishedAt);
          expect(result.content, testArticleEntity.content);
        },
      );
    });

    test(
      'should return a model with default image when urlToImage is null or empty',
      () async {
        // arrange
        final Map<String, dynamic> jsonMapNull = Map.from(testArticleMap);
        jsonMapNull['urlToImage'] = null;

        final Map<String, dynamic> jsonMapEmpty = Map.from(testArticleMap);
        jsonMapEmpty['urlToImage'] = "";

        // act
        final resultNull = ArticleModel.fromJson(jsonMapNull);
        final resultEmpty = ArticleModel.fromJson(jsonMapEmpty);

        // assert
        expect(resultNull.urlToImage, isNotEmpty);
        expect(resultEmpty.urlToImage, isNotEmpty);
      },
    );

    test(
      'should return a model with default empty strings when fields are absent or null',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = {};

        // act
        final result = ArticleModel.fromJson(jsonMap);

        // assert
        expect(result.author, "");
        expect(result.title, "");
        expect(result.description, "");
        expect(result.url, "");
        expect(result.urlToImage, isNotEmpty);
        expect(result.publishedAt, "");
        expect(result.content, "");
      },
    );
  });
}
