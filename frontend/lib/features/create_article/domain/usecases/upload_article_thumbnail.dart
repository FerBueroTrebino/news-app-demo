import 'dart:typed_data';

import '../../../../core/usecase/usecase.dart';
import '../repository/article_thumbnail_storage.dart';

class UploadArticleThumbnailParams {
  const UploadArticleThumbnailParams({
    required this.articleUid,
    required this.bytes,
  });

  final String articleUid;
  final Uint8List bytes;
}

class UploadArticleThumbnailUseCase
    implements UseCase<String, UploadArticleThumbnailParams> {
  UploadArticleThumbnailUseCase(this._storage);

  final ArticleThumbnailStorage _storage;

  @override
  Future<String> call({UploadArticleThumbnailParams? params}) {
    final p = params!;
    return _storage.uploadJpegThumbnail(
      articleUid: p.articleUid,
      bytes: p.bytes,
    );
  }
}
