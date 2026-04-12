import '../entities/picked_article_image.dart';
import '../entities/article_image_pick_source.dart';

abstract class ArticleImagePickerRepository {
  Future<PickedArticleImage?> pickFromDevice({
    required ArticleImagePickSource source,
  });
}
