import '../entities/article_news_entity.dart';

abstract class ArticleNewsRepository {
  Future<String> allocateNewArticleId();

  Future<void> createArticle(ArticleNewsEntity article);

  Future<void> updateArticle(ArticleNewsEntity article);

  Future<void> deleteArticle(String articleUid);

  Stream<List<ArticleNewsEntity>> watchArticlesNewsList();

  Stream<List<ArticleNewsEntity>> watchPublishedArticlesNewsList();

  Stream<List<ArticleNewsEntity>> watchArticlesNewsOfAuthor(String authorUid);
}
