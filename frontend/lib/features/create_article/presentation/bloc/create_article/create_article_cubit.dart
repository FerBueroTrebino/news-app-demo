import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/usecases/pick_article_image.dart';

part 'create_article_state.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  CreateArticleCubit(this._pickArticleImageUseCase)
      : super(const CreateArticleState());

  final PickArticleImageUseCase _pickArticleImageUseCase;

  Future<void> pickImageFromGallery() async {
    final picked = await _pickArticleImageUseCase();
    if (picked == null) return;
    emit(CreateArticleState(imageBytes: picked.bytes));
  }

  void clearImage() {
    emit(const CreateArticleState());
  }
}
