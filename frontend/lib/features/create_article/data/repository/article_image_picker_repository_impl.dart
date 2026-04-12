import 'package:image_picker/image_picker.dart';

import '../../domain/entities/picked_article_image.dart';
import '../../domain/entities/article_image_pick_source.dart';
import '../../domain/repository/article_image_picker_repository.dart';

class ArticleImagePickerRepositoryImpl implements ArticleImagePickerRepository {
  ArticleImagePickerRepositoryImpl({ImagePicker? imagePicker})
      : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<PickedArticleImage?> pickFromDevice({
    required ArticleImagePickSource source,
  }) async {
    final imageSource = switch (source) {
      ArticleImagePickSource.gallery => ImageSource.gallery,
      ArticleImagePickSource.camera => ImageSource.camera,
    };
    final XFile? file = await _imagePicker.pickImage(source: imageSource);
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return PickedArticleImage(bytes: bytes);
  }
}
