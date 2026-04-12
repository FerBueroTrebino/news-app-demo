import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/usecases/post_article_news.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/usecases/pick_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/domain/entities/picked_article_image.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/create_article_submit_button.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/create_article_thumbnail_field.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/bloc/create_article/create_article_cubit.dart';

class MockPickArticleImageUseCase extends Mock
    implements PickArticleImageUseCase {}

class MockPostArticleNewsUseCase extends Mock
    implements PostArticleNewsUseCase {}

/// Decodes to a valid 1×1 PNG for [Image.memory] in tests.
Uint8List get _testPngBytes => base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );

/// Exposes [emit] for widget tests that need a specific [CreateArticleState].
class TestCreateArticleCubit extends CreateArticleCubit {
  TestCreateArticleCubit(super.pick, super.post);

  void setStateForTest(CreateArticleState state) => emit(state);
}

void main() {
  late MockPickArticleImageUseCase mockPick;
  late MockPostArticleNewsUseCase mockPost;

  setUp(() {
    mockPick = MockPickArticleImageUseCase();
    mockPost = MockPostArticleNewsUseCase();
  });

  group('CreateArticleSubmitButton', () {
    testWidgets('shows label and invokes onPressed when not loading',
        (tester) async {
      var tapped = false;
      final cubit = TestCreateArticleCubit(mockPick, mockPost);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<CreateArticleCubit>.value(
              value: cubit,
              child: CreateArticleSubmitButton(
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Create article'), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(tapped, isTrue);
      await cubit.close();
    });

    testWidgets('shows progress indicator and disables tap while loading',
        (tester) async {
      var tapped = false;
      final cubit = TestCreateArticleCubit(mockPick, mockPost)
        ..setStateForTest(
          const CreateArticleState(
            submissionStatus: CreateArticleSubmissionStatus.loading,
          ),
        );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<CreateArticleCubit>.value(
              value: cubit,
              child: CreateArticleSubmitButton(
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();

      expect(tapped, isFalse);
      await cubit.close();
    });
  });

  group('CreateArticleThumbnailField', () {
    testWidgets('shows choose button when no image is selected',
        (tester) async {
      when(() => mockPick()).thenAnswer((_) async => null);
      final cubit = CreateArticleCubit(mockPick, mockPost);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<CreateArticleCubit>.value(
              value: cubit,
              child: const CreateArticleThumbnailField(),
            ),
          ),
        ),
      );

      expect(find.text('Choose from library'), findsOneWidget);
      await tester.tap(find.text('Choose from library'));
      await tester.pump();

      verify(() => mockPick()).called(1);
      await cubit.close();
    });

    testWidgets('shows preview and Remove image when bytes are set',
        (tester) async {
      when(() => mockPick()).thenAnswer(
        (_) async => PickedArticleImage(bytes: _testPngBytes),
      );
      final cubit = CreateArticleCubit(mockPick, mockPost);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<CreateArticleCubit>.value(
              value: cubit,
              child: const CreateArticleThumbnailField(),
            ),
          ),
        ),
      );

      await cubit.pickImageFromGallery();
      await tester.pump();
      await tester.pump();

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Remove image'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('clearImage removes preview', (tester) async {
      final cubit = TestCreateArticleCubit(mockPick, mockPost)
        ..setStateForTest(CreateArticleState(imageBytes: _testPngBytes));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<CreateArticleCubit>.value(
              value: cubit,
              child: const CreateArticleThumbnailField(),
            ),
          ),
        ),
      );

      expect(find.text('Remove image'), findsOneWidget);
      await tester.tap(find.text('Remove image'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Choose from library'), findsOneWidget);
      await cubit.close();
    });
  });
}
