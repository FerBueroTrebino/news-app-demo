import 'package:flutter/material.dart';

import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/pages/author_profile.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/post_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/pages/create_article.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/pages/sign_in_screen.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/pick_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/app_bar_create_article.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/create_article/create_article_cubit.dart';

class MockAuthCubit extends MockCubit<AuthState> implements AuthCubit {}

class MockPickArticleImageUseCase extends Mock
    implements PickArticleImageUseCase {}

class MockPostArticleNewsUseCase extends Mock
    implements PostArticleNewsUseCase {}

void main() {
  late MockAuthCubit mockAuthCubit;
  late MockPickArticleImageUseCase mockPick;
  late MockPostArticleNewsUseCase mockPost;

  final testUser = AuthUser(
    uid: 'user-1',
    email: 'a@b.com',
    displayName: 'Tester',
  );

  setUp(() {
    mockAuthCubit = MockAuthCubit();
    mockPick = MockPickArticleImageUseCase();
    mockPost = MockPostArticleNewsUseCase();
    when(() => mockAuthCubit.close()).thenAnswer((_) async {});
    when(() => mockAuthCubit.stream).thenAnswer(
      (_) => Stream<AuthState>.value(const Unauthenticated()),
    );
  });

  group('AppBarCreateArticle', () {
    testWidgets('shows title and hides actions when unauthenticated',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: Scaffold(
              appBar: AppBarCreateArticle(),
            ),
          ),
        ),
      );

      expect(find.text('Create News'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsNothing);
      expect(find.byIcon(Icons.logout), findsNothing);
    });

    testWidgets('shows profile and logout when authenticated', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      when(() => mockAuthCubit.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: Scaffold(
              appBar: AppBarCreateArticle(),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      verify(() => mockAuthCubit.signOut()).called(1);
    });

    testWidgets('navigates to author profile when person icon is tapped',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: '/',
          routes: {
            '/': (_) => BlocProvider<AuthCubit>.value(
                  value: mockAuthCubit,
                  child: Scaffold(
                    appBar: AppBarCreateArticle(),
                  ),
                ),
            AppRouteName.authorProfile.path: (_) =>
                const Scaffold(body: Text('Author profile route')),
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();

      expect(find.text('Author profile route'), findsOneWidget);
    });
  });

  group('SignInScreen', () {
    testWidgets('shows copy and invokes signInWithGoogle on tap',
        (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const Unauthenticated());
      when(() => mockAuthCubit.signInWithGoogle()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const SignInScreen(),
          ),
        ),
      );

      expect(
        find.text('You need to sign in to create an article.'),
        findsOneWidget,
      );
      expect(find.text('Sign in with Google'), findsOneWidget);

      await tester.tap(find.text('Sign in with Google'));
      await tester.pump();

      verify(() => mockAuthCubit.signInWithGoogle()).called(1);
    });
  });

  group('AuthorProfile', () {
    testWidgets('shows sign-in message when not authenticated', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(const Unauthenticated());

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: const AuthorProfile(),
          ),
        ),
      );

      expect(find.text('My articles'), findsOneWidget);
      expect(find.text('Sign in to view your articles.'), findsOneWidget);
    });
  });

  group('CreateArticle', () {
    testWidgets('renders form sections and submit button', (tester) async {
      when(() => mockAuthCubit.state).thenReturn(Authenticated(testUser));
      final createCubit = CreateArticleCubit(mockPick, mockPost);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AuthCubit>.value(
            value: mockAuthCubit,
            child: BlocProvider<CreateArticleCubit>.value(
              value: createCubit,
              child: const Scaffold(
                body: CreateArticle(),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Choose from library'), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Article body'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Create article'), findsOneWidget);

      await createCubit.close();
    });
  });
}
