import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article_news_entity.dart';
import '../../../domain/usecases/pick_article_image.dart';
import '../../../domain/usecases/update_article_news.dart';

part 'edit_article_state.dart';

class EditArticleCubit extends Cubit<EditArticleState> {
  EditArticleCubit(
    this._pickArticleImageUseCase,
    this._updateArticleNewsUseCase,
  ) : super(const EditArticleState());

  final PickArticleImageUseCase _pickArticleImageUseCase;
  final UpdateArticleNewsUseCase _updateArticleNewsUseCase;

  Future<void> pickImageFromGallery() async {
    final picked = await _pickArticleImageUseCase();
    if (picked == null) return;
    emit(state.copyWith(imageBytes: picked.bytes));
  }

  void clearPickedImage() {
    emit(state.copyWith(clearImage: true));
  }

  Future<void> submitEdit(ArticleNewsEntity article) async {
    emit(state.copyWith(
      submissionStatus: EditArticleSubmissionStatus.loading,
      clearErrorMessage: true,
    ));
    try {
      await _updateArticleNewsUseCase(
        params: UpdateArticleNewsParams(
          article: article,
          thumbnailBytes: state.imageBytes,
        ),
      );
      emit(state.copyWith(
        submissionStatus: EditArticleSubmissionStatus.success,
      ));
    } catch (_) {
      emit(state.copyWith(
        submissionStatus: EditArticleSubmissionStatus.failure,
        errorMessage: 'Could not update the article. Please try again.',
      ));
    }
  }

  void acknowledgeResult() {
    emit(state.copyWith(
      submissionStatus: EditArticleSubmissionStatus.initial,
      clearErrorMessage: true,
    ));
  }
}
