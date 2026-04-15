import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/article_entity.dart';
import '../../../domain/usecases/read_article.dart';

part 'article_reader_state.dart';

class ArticleReaderCubit extends Cubit<ArticleReaderState> {
  ArticleReaderCubit(this._readArticleUseCase)
      : super(const ArticleReaderState());

  final ReadArticleUseCase _readArticleUseCase;

  Future<void> toggleRead(ArticleEntity article) async {
    if (state.isReading) {
      await stopReading();
      return;
    }

    emit(state.copyWith(isReading: true, clearErrorMessage: true));
    try {
      await _readArticleUseCase.call(
        params: ReadArticleParams(article: article),
      );
      if (isClosed) return;
      emit(state.copyWith(isReading: false));
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          isReading: false,
          errorMessage: 'Unable to read this article right now.',
        ),
      );
    }
  }

  Future<void> stopReading() async {
    await _readArticleUseCase.stop();
    if (isClosed) return;
    emit(state.copyWith(isReading: false));
  }

  void acknowledgeError() {
    if (state.errorMessage == null) return;
    emit(state.copyWith(clearErrorMessage: true));
  }

  @override
  Future<void> close() async {
    await _readArticleUseCase.stop();
    return super.close();
  }
}
