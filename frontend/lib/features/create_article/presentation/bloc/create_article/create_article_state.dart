part of 'create_article_cubit.dart';

enum CreateArticleSubmissionStatus { inital, loading, success, failure }

class CreateArticleState extends Equatable {
  const CreateArticleState({
    this.imageBytes,
    this.submissionStatus = CreateArticleSubmissionStatus.inital,
    this.errorMessage,
    this.createdArticleId,
    this.createdArticleStatus,
  });

  final Uint8List? imageBytes;
  final CreateArticleSubmissionStatus submissionStatus;
  final String? errorMessage;
  final String? createdArticleId;
  final String? createdArticleStatus;

  CreateArticleState copyWith({
    Uint8List? imageBytes,
    bool clearImage = false,
    CreateArticleSubmissionStatus? submissionStatus,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? createdArticleId,
    bool clearCreatedArticleId = false,
    String? createdArticleStatus,
    bool clearCreatedArticleStatus = false,
  }) {
    return CreateArticleState(
      imageBytes: clearImage ? null : (imageBytes ?? this.imageBytes),
      submissionStatus: submissionStatus ?? this.submissionStatus,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      createdArticleId: clearCreatedArticleId
          ? null
          : (createdArticleId ?? this.createdArticleId),
      createdArticleStatus: clearCreatedArticleStatus
          ? null
          : (createdArticleStatus ?? this.createdArticleStatus),
    );
  }

  @override
  List<Object?> get props => [
        imageBytes,
        submissionStatus,
        errorMessage,
        createdArticleId,
        createdArticleStatus,
      ];
}
