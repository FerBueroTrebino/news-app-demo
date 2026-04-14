import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/article_news_entity.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/delete_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/get_articles_news_of_author.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/pick_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/post_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/update_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/author_profile/author_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/create_article/create_article_cubit.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/pages/author_profile.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/pages/create_article.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/pages/create_article_auth_wrapper.dart';
import 'package:news_app_clean_architecture/injection_container.dart' as inject;

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockPickArticleImageUseCase extends Mock
    implements PickArticleImageUseCase {}

class MockPostArticleNewsUseCase extends Mock
    implements PostArticleNewsUseCase {}

class MockGetArticlesNewsOfAuthorUseCase extends Mock
    implements GetArticlesNewsOfAuthorUseCase {}
class MockUpdateArticleNewsUseCase extends Mock implements UpdateArticleNewsUseCase {}
class MockDeleteArticleNewsUseCase extends Mock implements DeleteArticleNewsUseCase {}

class TestCreateArticleCubit extends CreateArticleCubit {
  TestCreateArticleCubit(super.pick, super.post);

  void setStateForTest(CreateArticleState state) => emit(state);
}

/// Valid 1×1 PNG for thumbnail bytes in submit tests.
final Uint8List kTestPngBytes = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
);

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockPickArticleImageUseCase mockPick;
  late MockPostArticleNewsUseCase mockPost;
  late MockGetArticlesNewsOfAuthorUseCase mockGetArticles;
  late MockUpdateArticleNewsUseCase mockUpdateArticle;
  late MockDeleteArticleNewsUseCase mockDeleteArticle;

  final testUser = AuthUser(
    uid: 'user-1',
    email: 'writer@example.com',
    displayName: 'Writer',
  );

  ArticleNewsEntity sampleArticle({required String title}) {
    final t = DateTime.utc(2024, 3, 1);
    return ArticleNewsEntity(
      articleUid: 'a-1',
      title: title,
      description: 'Desc',
      content: 'Content',
      category: 'general',
      status: 'draft',
      thumbnailUrl: '',
      authorUid: testUser.uid,
      authorName: 'Writer',
      createdAt: t,
      updatedAt: t,
      viewsCount: 0,
    );
  }

  Future<void> resetSlAndRegister() async {
    await inject.sl.reset();
    inject.sl.registerFactory<CreateArticleCubit>(
      () => CreateArticleCubit(mockPick, mockPost),
    );
    inject.sl.registerFactory<AuthorProfileCubit>(
      () => AuthorProfileCubit(
        mockGetArticles,
        mockUpdateArticle,
        mockDeleteArticle,
      ),
    );
  }

  setUp(() async {
    mockAuthCubit = MockAuthCubit();
    mockPick = MockPickArticleImageUseCase();
    mockPost = MockPostArticleNewsUseCase();
    mockGetArticles = MockGetArticlesNewsOfAuthorUseCase();
    mockUpdateArticle = MockUpdateArticleNewsUseCase();
    mockDeleteArticle = MockDeleteArticleNewsUseCase();
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
    when(() => mockAuthCubit.stream).thenAnswer(
      (_) => Stream<AuthState>.value(const Unauthenticated()),
    );
    await resetSlAndRegister();
  });

  tearDown(() async {
    await inject.sl.reset();
  });

  setUpAll(() {
    registerFallbackValue(
      PostArticleNewsParams(
        article: ArticleNewsEntity(
          articleUid: 'fb',
          title: 't',
          description: 'd',
          content: 'c',
          category: 'general',
          status: 'draft',
          thumbnailUrl: '',
          authorUid: 'a',
          authorName: 'n',
          createdAt: DateTime.utc(2000),
          updatedAt: DateTime.utc(2000),
        ),
        thumbnailBytes: Uint8List(0),
      ),
    );
  });

  group('CreateArticleAuthWrapper', () {
    Widget wrap(Widget child) => MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: child,
          ),
        );

    testWidgets('shows centered loader for AuthInitial', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(wrap(const CreateArticleAuthWrapper()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Create News'), findsOneWidget);
    });

    testWidgets('shows centered loader for AuthLoading', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(wrap(const CreateArticleAuthWrapper()));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows SignInScreen when unauthenticated', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(wrap(const CreateArticleAuthWrapper()));

      expect(
        find.text('You need to sign in to create an article.'),
        findsOneWidget,
      );
    });

    testWidgets('shows CreateArticle when authenticated using sl cubit',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));

      await tester.pumpWidget(wrap(const CreateArticleAuthWrapper()));

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Create article'), findsOneWidget);
    });

    testWidgets('shows error SnackBar when auth emits error message',
        (tester) async {
      whenListen(
        mockAuthCubit,
        Stream.value(
          const Unauthenticated(errorMessage: 'Could not sign out.'),
        ),
        initialState: const Unauthenticated(),
      );

      await tester.pumpWidget(wrap(const CreateArticleAuthWrapper()));
      await tester.pump();
      await tester.pump();

      expect(find.text('Could not sign out.'), findsOneWidget);
    });
  });

  group('AuthorProfile (authenticated via sl)', () {
    Widget wrapProfile() => MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const AuthorProfile(),
          ),
        );

    testWidgets('shows loading while article stream has no events',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      when(() => mockGetArticles(params: testUser.uid))
          .thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(wrapProfile());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when author has no articles',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      when(() => mockGetArticles(params: testUser.uid))
          .thenAnswer((_) => Stream.value(<ArticleNewsEntity>[]));

      await tester.pumpWidget(wrapProfile());
      await tester.pump();
      await tester.pump();

      expect(find.text('No articles yet.'), findsOneWidget);
    });

    testWidgets('shows article tiles when stream yields articles',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      when(() => mockGetArticles(params: testUser.uid)).thenAnswer(
        (_) => Stream.value([
          sampleArticle(title: 'First post'),
        ]),
      );

      await tester.pumpWidget(wrapProfile());
      await tester.pump();
      await tester.pump();

      expect(find.text('First post'), findsOneWidget);
    });

    testWidgets('shows failure UI and retries load', (tester) async {
      var call = 0;
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      when(() => mockGetArticles(params: testUser.uid)).thenAnswer((_) {
        call++;
        if (call == 1) {
          return Stream<List<ArticleNewsEntity>>.error(Exception('net'));
        }
        return Stream.value([sampleArticle(title: 'After retry')]);
      });

      await tester.pumpWidget(wrapProfile());
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Could not load your articles. Please try again.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();

      expect(find.text('After retry'), findsOneWidget);
      expect(call, 2);
    });

    testWidgets('shows failure when use case throws synchronously',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      when(() => mockGetArticles(params: testUser.uid)).thenThrow(Exception());

      await tester.pumpWidget(wrapProfile());
      await tester.pump();

      expect(
        find.text('Could not load your articles. Please try again.'),
        findsOneWidget,
      );
    });
  });

  group('CreateArticle page — submit and listener', () {
    Future<void> useTallSurface(WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
    }

    Future<void> pumpForm(
      WidgetTester tester,
      TestCreateArticleCubit cubit,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/form',
          routes: {
            '/form': (_) => BlocProvider<AuthCubit>.value(
                  value: mockAuthCubit,
                  child: BlocProvider<CreateArticleCubit>.value(
                    value: cubit,
                    child: const Scaffold(
                      body: CreateArticle(),
                    ),
                  ),
                ),
            AppRouteName.authorProfile.path: (_) => const Scaffold(
                  body: Text('NAV_AUTHOR_PROFILE'),
                ),
            AppRouteName.home.path: (_) => const Scaffold(
                  body: Text('NAV_HOME'),
                ),
          },
        ),
      );
      await tester.pump();
    }

    testWidgets('submit without thumbnail shows alert SnackBar',
        (tester) async {
      await useTallSurface(tester);
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      final cubit = TestCreateArticleCubit(mockPick, mockPost);
      await pumpForm(tester, cubit);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Valid title');
      await tester.enterText(fields.at(1), 'Valid description');
      await tester.enterText(fields.at(2), 'Valid body content here');

      await tester.ensureVisible(find.text('Create article'));
      await tester.tap(find.text('Create article'));
      await tester.pump();
      await tester.pump();

      expect(
        find.text('Please choose an image from your library.'),
        findsOneWidget,
      );

      await cubit.close();
    });

    testWidgets('submit does not post when auth has no user', (tester) async {
      await useTallSurface(tester);
      when(() => mockAuthCubit.state).thenReturn(const Unauthenticated());
      final cubit = TestCreateArticleCubit(mockPick, mockPost)
        ..setStateForTest(CreateArticleState(imageBytes: kTestPngBytes));

      await pumpForm(tester, cubit);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Valid title');
      await tester.enterText(fields.at(1), 'Valid description');
      await tester.enterText(fields.at(2), 'Valid body content here');

      await tester.ensureVisible(find.text('Create article'));
      await tester.tap(find.text('Create article'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verifyNever(() => mockPost(params: any(named: 'params')));

      await cubit.close();
    });

    testWidgets('submit calls post use case when thumbnail and auth valid',
        (tester) async {
      await useTallSurface(tester);
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      when(() => mockPost(params: any(named: 'params')))
          .thenAnswer((_) async => 'new-article-id');

      final cubit = TestCreateArticleCubit(mockPick, mockPost)
        ..setStateForTest(CreateArticleState(imageBytes: kTestPngBytes));

      await pumpForm(tester, cubit);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Valid title');
      await tester.enterText(fields.at(1), 'Valid description');
      await tester.enterText(fields.at(2), 'Valid body content here');

      await tester.ensureVisible(find.text('Create article'));
      await tester.tap(find.text('Create article'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(() => mockPost(params: any(named: 'params'))).called(1);

      await cubit.close();
    });

    testWidgets('navigates to author profile after draft success',
        (tester) async {
      await useTallSurface(tester);
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      final cubit = TestCreateArticleCubit(mockPick, mockPost);
      await pumpForm(tester, cubit);

      cubit.setStateForTest(
        const CreateArticleState(
          submissionStatus: CreateArticleSubmissionStatus.loading,
        ),
      );
      await tester.pump();
      cubit.setStateForTest(
        const CreateArticleState(
          submissionStatus: CreateArticleSubmissionStatus.success,
          createdArticleStatus: 'draft',
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('NAV_AUTHOR_PROFILE'), findsOneWidget);
      expect(
        find.text('Draft saved successfully in your profile.'),
        findsOneWidget,
      );

      await cubit.close();
    });

    testWidgets('navigates home after published success', (tester) async {
      await useTallSurface(tester);
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      final cubit = TestCreateArticleCubit(mockPick, mockPost);
      await pumpForm(tester, cubit);

      cubit.setStateForTest(
        const CreateArticleState(
          submissionStatus: CreateArticleSubmissionStatus.loading,
        ),
      );
      await tester.pump();
      cubit.setStateForTest(
        const CreateArticleState(
          submissionStatus: CreateArticleSubmissionStatus.success,
          createdArticleStatus: 'published',
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('NAV_HOME'), findsOneWidget);
      expect(find.text('Article published successfully.'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('shows error SnackBar on submission failure', (tester) async {
      await useTallSurface(tester);
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      final cubit = TestCreateArticleCubit(mockPick, mockPost);
      await pumpForm(tester, cubit);

      cubit.setStateForTest(
        const CreateArticleState(
          submissionStatus: CreateArticleSubmissionStatus.loading,
        ),
      );
      await tester.pump();
      cubit.setStateForTest(
        const CreateArticleState(
          submissionStatus: CreateArticleSubmissionStatus.failure,
          errorMessage: 'Server unavailable',
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Server unavailable'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('changing category and publish mode updates form',
        (tester) async {
      await useTallSurface(tester);
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      final cubit = TestCreateArticleCubit(mockPick, mockPost);
      await pumpForm(tester, cubit);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Business').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Publish'));
      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();

      expect(find.text('Publish'), findsWidgets);

      await cubit.close();
    });
  });
}
