import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

import '../entities/article_image_pick_source.dart';
import '../entities/picked_article_image.dart';
import '../repository/article_image_picker_repository.dart';

class PickArticleImageParams {
  const PickArticleImageParams({
    this.source = ArticleImagePickSource.gallery,
  });

  final ArticleImagePickSource source;
}

class PickArticleImageUseCase
    implements UseCase<PickedArticleImage?, PickArticleImageParams> {
  PickArticleImageUseCase(this._repository);

  final ArticleImagePickerRepository _repository;

  @override
  Future<PickedArticleImage?> call({PickArticleImageParams? params}) {
    final source = params?.source ?? ArticleImagePickSource.gallery;
    return _repository.pickFromDevice(source: source);
  }
}
