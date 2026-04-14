import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/presentation/models/article_publish_mode.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/create_article_body_field.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/create_article_title_field.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/create_article_category_field.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/create_article_description_field.dart';
import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/create_article_publish_mode_field.dart';

void main() {
  group('CreateArticleTitleField', () {
    testWidgets('shows Title label and validates empty input', (tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CreateArticleTitleField(controller: controller),
            ),
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(formKey.currentState!.validate(), isFalse);
    });

    testWidgets('accepts valid title after trim', (tester) async {
      final controller = TextEditingController(text: '  Valid title here  ');
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CreateArticleTitleField(controller: controller),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isTrue);
    });
  });

  group('CreateArticleDescriptionField', () {
    testWidgets('shows description label and validates empty input',
        (tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CreateArticleDescriptionField(controller: controller),
            ),
          ),
        ),
      );

      expect(
        find.text('Summary'),
        findsOneWidget,
      );
      expect(formKey.currentState!.validate(), isFalse);
    });
  });

  group('CreateArticleBodyField', () {
    testWidgets('shows article body label and validates empty input',
        (tester) async {
      final controller = TextEditingController();
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CreateArticleBodyField(controller: controller),
            ),
          ),
        ),
      );

      expect(find.text('Article body'), findsOneWidget);
      expect(formKey.currentState!.validate(), isFalse);
    });
  });

  group('CreateArticleCategoryField', () {
    testWidgets('invokes onChanged when another category is selected',
        (tester) async {
      String category = 'general';
      late void Function(void Function()) setState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, ss) {
                setState = ss;
                return CreateArticleCategoryField(
                  value: category,
                  onChanged: (v) => setState(() => category = v),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('General'), findsWidgets);

      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Technology').last);
      await tester.pumpAndSettle();

      expect(category, 'technology');
    });
  });

  group('CreateArticlePublishModeField', () {
    testWidgets('shows Status label and calls onSelectionChanged for Publish',
        (tester) async {
      ArticlePublishMode selected = ArticlePublishMode.draft;
      late void Function(void Function()) setState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, ss) {
                setState = ss;
                return CreateArticlePublishModeField(
                  selected: selected,
                  onSelectionChanged: (mode) => setState(() => selected = mode),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Publish'), findsOneWidget);

      await tester.tap(find.text('Publish'));
      await tester.pumpAndSettle();

      expect(selected, ArticlePublishMode.publish);
    });
  });
}
