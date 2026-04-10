import 'package:dio/dio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/news_response_model.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

class MockArticleRepository extends Mock implements ArticleRepository {}

class MockNewsApiService extends Mock implements NewsApiService {}

class MockArticleDao extends Mock implements ArticleDao {}

class MockAppDatabase extends Mock implements AppDatabase {}

class MockDio extends Mock implements Dio {}

const testArticleEntity = ArticleEntity(
  id: 1,
  author: 'author',
  title: 'title',
  description: 'description',
  url: 'url',
  urlToImage: 'urlToImage',
  publishedAt: 'publishedAt',
  content: 'content',
);

const testArticleModel = ArticleModel(
  id: 1,
  author: 'author',
  title: 'title',
  description: 'description',
  url: 'url',
  urlToImage: 'urlToImage',
  publishedAt: 'publishedAt',
  content: 'content',
);

final testArticleList = [
  testArticleEntity,
  const ArticleEntity(
    id: 2,
    author: 'author',
    title: 'title',
    description: 'description',
    url: 'url',
    urlToImage: 'urlToImage',
    publishedAt: 'publishedAt',
    content: 'content',
  ),
];

final testArticleModelList = [
  testArticleModel,
  const ArticleModel(
    id: 2,
    author: 'author',
    title: 'title',
    description: 'description',
    url: 'url',
    urlToImage: 'urlToImage',
    publishedAt: 'publishedAt',
    content: 'content',
  ),
];

final testNewsResponseModel = NewsResponseModel(
  status: 'ok',
  totalResults: 2,
  articles: testArticleModelList,
);

final testArticleMap = {
  'author': 'author',
  'title': 'title',
  'description': 'description',
  'url': 'url',
  'urlToImage': 'urlToImage',
  'publishedAt': 'publishedAt',
  'content': 'content',
};

final testNewsResponseMap = {
  'status': 'ok',
  'totalResults': 2,
  'articles': [testArticleMap, testArticleMap],
};
