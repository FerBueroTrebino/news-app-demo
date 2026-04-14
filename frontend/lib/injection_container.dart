import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/create_article/data/data_sources/firestore_articles_service.dart';
import 'package:news_app_clean_architecture/features/create_article/data/data_sources/firestore_authors_service.dart';
import 'package:news_app_clean_architecture/features/create_article/data/repository/article_image_picker_repository_impl.dart';
import 'package:news_app_clean_architecture/features/create_article/data/repository/article_news_repository_impl.dart';
import 'package:news_app_clean_architecture/features/create_article/data/repository/article_thumbnail_storage_impl.dart';
import 'package:news_app_clean_architecture/features/create_article/data/repository/author_repository_impl.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_image_picker_repository.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_news_repository.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_thumbnail_storage.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/article_thumbnail_url_resolver.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/repository/author_repository.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/pick_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/get_articles_news_list.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/get_articles_news_of_author.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/post_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/upload_article_thumbnail.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/sync_author_on_login.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/update_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/delete_article_news.dart';
import 'package:news_app_clean_architecture/features/auth/data/repository/auth_repository_impl.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/author_profile/author_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/create_article/create_article_cubit.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/edit_article/edit_article_cubit.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/repository/article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'features/daily_news/data/data_sources/local/app_database.dart';
import 'features/daily_news/domain/usecases/get_saved_article.dart';
import 'features/daily_news/domain/usecases/remove_article.dart';
import 'features/daily_news/domain/usecases/save_article.dart';
import 'features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  final database =
      await $FroomAppDatabase.databaseBuilder('app_database.db').build();
  sl.registerSingleton<AppDatabase>(database);

  // Dio
  sl.registerSingleton<Dio>(Dio());
  sl.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);
  sl.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  sl.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
  final googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize(serverClientId: googleWebClientId);
  sl.registerSingleton<GoogleSignIn>(googleSignIn);

  // Dependencies
  sl.registerSingleton<NewsApiService>(NewsApiService(sl()));
  sl.registerSingleton<FirebaseAuthService>(
    FirebaseAuthService(sl(), sl()),
  );
  sl.registerSingleton<FirestoreAuthorsService>(
    FirestoreAuthorsService(sl()),
  );
  sl.registerSingleton<FirestoreArticlesService>(
    FirestoreArticlesService(sl()),
  );
  sl.registerSingleton<AuthorRepository>(
    AuthorRepositoryImpl(sl()),
  );
  final articleThumbnailFirebase = ArticleThumbnailStorageImpl(sl());
  sl.registerSingleton<ArticleThumbnailStorage>(articleThumbnailFirebase);
  sl.registerSingleton<ArticleThumbnailUrlResolver>(articleThumbnailFirebase);
  sl.registerSingleton<UploadArticleThumbnailUseCase>(
    UploadArticleThumbnailUseCase(sl()),
  );
  sl.registerSingleton<ArticleNewsRepository>(
    ArticleNewsRepositoryImpl(sl(), sl()),
  );
  sl.registerSingleton<ArticleImagePickerRepository>(
    ArticleImagePickerRepositoryImpl(),
  );

  sl.registerSingleton<ArticleRepository>(ArticleRepositoryImpl(sl(), sl()));
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(sl()),
  );

  //UseCases
  sl.registerSingleton<GetArticlesNewsListUseCase>(
    GetArticlesNewsListUseCase(sl()),
  );

  sl.registerSingleton<GetArticleUseCase>(
    GetArticleUseCase(sl(), sl()),
  );

  sl.registerSingleton<GetSavedArticleUseCase>(GetSavedArticleUseCase(sl()));

  sl.registerSingleton<SaveArticleUseCase>(SaveArticleUseCase(sl()));

  sl.registerSingleton<RemoveArticleUseCase>(RemoveArticleUseCase(sl()));
  sl.registerSingleton<GetCurrentUserUseCase>(
    GetCurrentUserUseCase(sl()),
  );
  sl.registerSingleton<SignInWithGoogleUseCase>(
    SignInWithGoogleUseCase(sl()),
  );
  sl.registerSingleton<SignOutUseCase>(
    SignOutUseCase(sl()),
  );
  sl.registerSingleton<SyncAuthorOnLoginUseCase>(
    SyncAuthorOnLoginUseCase(sl()),
  );
  sl.registerSingleton<PickArticleImageUseCase>(
    PickArticleImageUseCase(sl()),
  );
  sl.registerSingleton<PostArticleNewsUseCase>(
    PostArticleNewsUseCase(sl(), sl()),
  );
  sl.registerSingleton<UpdateArticleNewsUseCase>(
    UpdateArticleNewsUseCase(sl(), sl()),
  );
  sl.registerSingleton<DeleteArticleNewsUseCase>(
    DeleteArticleNewsUseCase(sl()),
  );
  sl.registerSingleton<GetArticlesNewsOfAuthorUseCase>(
    GetArticlesNewsOfAuthorUseCase(sl()),
  );

  //Blocs
  sl.registerFactory<RemoteArticlesBloc>(() => RemoteArticlesBloc(sl()));

  sl.registerFactory<LocalArticleBloc>(
      () => LocalArticleBloc(sl(), sl(), sl()));
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<CreateArticleCubit>(
    () => CreateArticleCubit(sl(), sl()),
  );
  sl.registerFactory<EditArticleCubit>(
    () => EditArticleCubit(sl(), sl()),
  );
  sl.registerFactory<AuthorProfileCubit>(
    () => AuthorProfileCubit(sl(), sl(), sl()),
  );
}
