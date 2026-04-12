import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';

import '../../../../../helpers/test_helper.dart';

void main() {
  late AppDatabase database;
  late ArticleDao articleDao;

  setUp(() async {
    database = await $FroomAppDatabase.inMemoryDatabaseBuilder().build();
    articleDao = database.articleDAO;
  });

  tearDown(() async {
    await database.close();
  });

  test('should insert and retrieve articles', () async {
    // arrange
    const article = testArticleModel;

    // act
    await articleDao.insertArticle(article);
    final result = await articleDao.getArticles();

    // assert
    expect(result, isNotEmpty);
    expect(result[0].title, article.title);
  });

  test('should delete an article', () async {
    // arrange
    const article = testArticleModel;
    await articleDao.insertArticle(article);

    // act
    await articleDao.deleteArticle(article);
    final result = await articleDao.getArticles();

    // assert
    expect(result, isEmpty);
  });
}
