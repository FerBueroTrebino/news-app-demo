part of 'edit_article_cubit.dart';

enum EditArticleSubmissionStatus { initial, loading, success, failure }

class EditArticleState extends Equatable {
  const EditArticleState({
    this.imageBytes,
    this.submissionStatus = EditArticleSubmissionStatus.initial,
    this.errorMessage,
  });

  final Uint8List? imageBytes;
  final EditArticleSubmissionStatus submissionStatus;
  final String? errorMessage;

  EditArticleState copyWith({
    Uint8List? imageBytes,
    bool clearImage = false,
    EditArticleSubmissionStatus? submissionStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return EditArticleState(
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [imageBytes, submissionStatus, errorMessage];
}
