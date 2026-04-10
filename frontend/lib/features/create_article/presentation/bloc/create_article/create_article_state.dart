part of 'create_article_cubit.dart';

class CreateArticleState extends Equatable {
  const CreateArticleState({this.imageBytes});

  final Uint8List? imageBytes;

  @override
  List<Object?> get props => [imageBytes];
}
