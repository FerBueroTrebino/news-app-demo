import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/daily_news/data/models/news_response_model.dart';

import '../../../../helpers/test_helper.dart';

void main() {
  group('fromJson', () {
    test(
      'should return a valid model when the JSON is correct',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = testNewsResponseMap;

        // act
        final result = NewsResponseModel.fromJson(jsonMap);

        // assert
        expect(result.status, testNewsResponseModel.status);
        expect(result.totalResults, testNewsResponseModel.totalResults);
        expect(result.articles.length, testNewsResponseModel.articles.length);
        expect(result.articles[0].author,
            testNewsResponseModel.articles[0].author);
      },
    );

    test(
      'should return a model with empty articles when JSON articles is null',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'status': 'ok',
          'totalResults': 0,
          'articles': null,
        };

        // act
        final result = NewsResponseModel.fromJson(jsonMap);

        // assert
        expect(result.articles, isEmpty);
      },
    );

    test(
      'should handle null status safely',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'status': null,
          'totalResults': 0,
          'articles': null,
        };

        // act
        final result = NewsResponseModel.fromJson(jsonMap);

        // assert
        expect(result.status, '');
      },
    );

    test(
      'should handle null totalResults safely',
      () async {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'status': 'ok',
          'totalResults': null,
          'articles': null,
        };

        // act
        final result = NewsResponseModel.fromJson(jsonMap);

        // assert
        expect(result.totalResults, 0);
      },
    );
  });
}
