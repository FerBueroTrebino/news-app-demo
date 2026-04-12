import 'dart:typed_data';

import 'upload_article_thumbnail.dart';
import '../entities/article_news_entity.dart';
import '../../../../core/usecase/usecase.dart';
import '../repository/article_news_repository.dart';

class PostArticleNewsParams {
  const PostArticleNewsParams({
    required this.article,
    required this.thumbnailBytes,
  });

  final ArticleNewsEntity article;
  final Uint8List thumbnailBytes;
}

class PostArticleNewsUseCase implements UseCase<String, PostArticleNewsParams> {
  PostArticleNewsUseCase(
    this._repository,
    this._uploadArticleThumbnail,
  );

  final ArticleNewsRepository _repository;
  final UploadArticleThumbnailUseCase _uploadArticleThumbnail;

  @override
  Future<String> call({PostArticleNewsParams? params}) async {
    final p = params!;
    final articleUid = await _repository.allocateNewArticleId();
    final thumbnailUrl = await _uploadArticleThumbnail(
      params: UploadArticleThumbnailParams(
        articleUid: articleUid,
        bytes: p.thumbnailBytes,
      ),
    );
    final now = DateTime.now();
    final article = ArticleNewsEntity(
      articleUid: articleUid,
      title: p.article.title,
      description: p.article.description,
      content: p.article.content,
      category: p.article.category,
      status: p.article.status,
      thumbnailUrl: thumbnailUrl,
      authorUid: p.article.authorUid,
      authorName: p.article.authorName,
      createdAt: now,
      publishedAt: p.article.publishedAt,
      updatedAt: now,
      viewsCount: p.article.viewsCount,
    );
    await _repository.createArticle(article);
    return articleUid;
  }
}
