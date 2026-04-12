import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/post_article_news.dart';
import '../../../domain/usecases/pick_article_image.dart';
import '../../../domain/entities/article_news_entity.dart';
import '../../../../../features/auth/domain/entities/auth_user.dart';

part 'create_article_state.dart';

class CreateArticleCubit extends Cubit<CreateArticleState> {
  CreateArticleCubit(
    this._pickArticleImageUseCase,
    this._postArticleNewsUseCase,
  ) : super(const CreateArticleState());

  final PickArticleImageUseCase _pickArticleImageUseCase;
  final PostArticleNewsUseCase _postArticleNewsUseCase;

  Future<void> pickImageFromGallery() async {
    final picked = await _pickArticleImageUseCase();
    if (picked == null) return;
    emit(state.copyWith(imageBytes: picked.bytes));
  }

  void clearImage() {
    emit(state.copyWith(clearImage: true));
  }

  void acknowledgeSubmissionResult() {
    emit(state.copyWith(
      submissionStatus: CreateArticleSubmissionStatus.inital,
      clearErrorMessage: true,
      clearCreatedArticleId: true,
      clearCreatedArticleStatus: true,
    ));
  }

  Future<void> submitArticle({
    required AuthUser author,
    required ArticleNewsEntity draft,
    required Uint8List thumbnailBytes,
  }) async {
    emit(state.copyWith(
      submissionStatus: CreateArticleSubmissionStatus.loading,
      clearErrorMessage: true,
      clearCreatedArticleId: true,
      clearCreatedArticleStatus: true,
    ));
    try {
      final id = await _postArticleNewsUseCase(
        params: PostArticleNewsParams(
          article: draft,
          thumbnailBytes: thumbnailBytes,
        ),
      );
      emit(state.copyWith(
        submissionStatus: CreateArticleSubmissionStatus.success,
        createdArticleId: id,
        createdArticleStatus: draft.status,
      ));
    } catch (_) {
      emit(state.copyWith(
        submissionStatus: CreateArticleSubmissionStatus.failure,
        errorMessage: 'Could not save the article. Please try again.',
      ));
    }
  }

  String resolveAuthorDisplayName(AuthUser author) {
    final fromDisplay = author.displayName?.trim();
    if (fromDisplay != null && fromDisplay.length >= 2) {
      return fromDisplay.length > 50
          ? fromDisplay.substring(0, 50)
          : fromDisplay;
    }
    final fromEmail = author.email?.split('@').first.trim();
    if (fromEmail != null && fromEmail.length >= 2) {
      return fromEmail.length > 50 ? fromEmail.substring(0, 50) : fromEmail;
    }
    return 'Author';
  }
}
