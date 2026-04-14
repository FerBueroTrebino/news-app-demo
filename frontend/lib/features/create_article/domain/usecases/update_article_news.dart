import 'dart:typed_data';

import '../../../../core/usecase/usecase.dart';
import '../entities/article_news_entity.dart';
import '../repository/article_news_repository.dart';
import 'upload_article_thumbnail.dart';

class UpdateArticleNewsUseCase
    implements UseCase<void, UpdateArticleNewsParams> {
  UpdateArticleNewsUseCase(
    this._repository,
    this._uploadArticleThumbnail,
  );

  final ArticleNewsRepository _repository;
  final UploadArticleThumbnailUseCase _uploadArticleThumbnail;

  @override
  Future<void> call({UpdateArticleNewsParams? params}) async {
    final p = params!;
    final thumbnailUrl = p.thumbnailBytes == null
        ? p.article.thumbnailUrl
        : await _uploadArticleThumbnail(
            params: UploadArticleThumbnailParams(
              articleUid: p.article.articleUid,
              bytes: p.thumbnailBytes!,
            ),
          );

    return _repository.updateArticle(
      p.article.copyWith(thumbnailUrl: thumbnailUrl),
    );
  }
}

class UpdateArticleNewsParams {
  const UpdateArticleNewsParams({
    required this.article,
    this.thumbnailBytes,
  });

  final ArticleNewsEntity article;
  final Uint8List? thumbnailBytes;
}
