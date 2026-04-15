part of 'article_reader_cubit.dart';

class ArticleReaderState extends Equatable {
  const ArticleReaderState({
    this.isReading = false,
    this.errorMessage,
  });

  final bool isReading;
  final String? errorMessage;

  ArticleReaderState copyWith({
    bool? isReading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ArticleReaderState(
      isReading: isReading ?? this.isReading,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        isReading,
        errorMessage,
      ];
}
