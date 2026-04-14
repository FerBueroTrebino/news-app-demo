import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/article_news_model.dart';
import '../../domain/entities/article_news_entity.dart';
import '../data_sources/firestore_articles_service.dart';
import '../../domain/repository/article_news_repository.dart';
import '../../domain/repository/article_thumbnail_url_resolver.dart';

class ArticleNewsRepositoryImpl implements ArticleNewsRepository {
  ArticleNewsRepositoryImpl(
    this._articlesService,
    this._thumbnailUrlResolver,
  );

  final FirestoreArticlesService _articlesService;
  final ArticleThumbnailUrlResolver _thumbnailUrlResolver;

  @override
  Future<String> allocateNewArticleId() async {
    return _articlesService.newArticleDocument().id;
  }

  @override
  Future<void> createArticle(ArticleNewsEntity article) async {
    final ref = _articlesService.articleDocument(article.articleUid);
    await _articlesService.setArticle(
      ref,
      ArticleNewsModel.fromEntity(article).toFirestoreCreateMap(),
    );
  }

  @override
  Future<void> updateArticle(ArticleNewsEntity article) async {
    final ref = _articlesService.articleDocument(article.articleUid);
    await _articlesService.updateArticle(
      ref,
      ArticleNewsModel.fromEntity(article).toFirestoreUpdateMap(),
    );
  }

  @override
  Future<void> deleteArticle(String articleUid) async {
    final ref = _articlesService.articleDocument(articleUid);
    await _articlesService.deleteArticle(ref);
  }

  Stream<List<ArticleNewsEntity>> _watchArticlesFromDocs(
    Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> docStream,
  ) {
    return docStream.asyncMap((docs) async {
      final entities = docs
          .map((d) => ArticleNewsModel.fromFirestore(d).toEntity())
          .toList();
      return Future.wait(
        entities.map((e) async {
          final url = await _thumbnailUrlResolver.resolveToNetworkUrl(
            e.thumbnailUrl,
          );
          return e.copyWith(thumbnailUrl: url ?? '');
        }),
      );
    });
  }

  @override
  Stream<List<ArticleNewsEntity>> watchArticlesNewsList() {
    return _watchArticlesFromDocs(_articlesService.watchAllArticles());
  }

  @override
  Stream<List<ArticleNewsEntity>> watchPublishedArticlesNewsList() {
    return _watchArticlesFromDocs(
      _articlesService.watchArticlesByStatus('published'),
    );
  }

  @override
  Stream<List<ArticleNewsEntity>> watchArticlesNewsOfAuthor(
    String authorUid,
  ) {
    return _watchArticlesFromDocs(
      _articlesService.watchArticlesByAuthorUid(authorUid),
    );
  }
}
