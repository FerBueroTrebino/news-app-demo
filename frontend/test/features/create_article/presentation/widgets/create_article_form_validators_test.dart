import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/presentation/widgets/create_article_form_validators.dart';

void main() {
  group('CreateArticleFormValidators.title', () {
    test('returns error when empty or whitespace', () {
      expect(CreateArticleFormValidators.title(null), 'Enter a title');
      expect(CreateArticleFormValidators.title(''), 'Enter a title');
      expect(CreateArticleFormValidators.title('   '), 'Enter a title');
    });

    test('returns error when shorter than 3 characters', () {
      expect(
        CreateArticleFormValidators.title('ab'),
        'Title must be at least 3 characters',
      );
    });

    test('returns error when longer than 120 characters', () {
      expect(
        CreateArticleFormValidators.title('a' * 121),
        'Title must be at most 120 characters',
      );
    });

    test('returns null for valid length after trim', () {
      expect(CreateArticleFormValidators.title('  abc  '), isNull);
    });
  });

  group('CreateArticleFormValidators.description', () {
    test('returns error when empty or whitespace', () {
      expect(CreateArticleFormValidators.description(null), 'Enter a description');
      expect(CreateArticleFormValidators.description(''), 'Enter a description');
    });

    test('returns error when shorter than 3 characters', () {
      expect(
        CreateArticleFormValidators.description('xx'),
        'Description must be at least 90 characters',
      );
    });

    test('returns error when longer than 250 characters', () {
      expect(
        CreateArticleFormValidators.description('a' * 251),
        'Description must be at most 250 characters',
      );
    });

    test('returns null for valid length after trim', () {
      expect(CreateArticleFormValidators.description('  abc  '), isNull);
    });
  });

  group('CreateArticleFormValidators.content', () {
    test('returns error when empty or whitespace', () {
      expect(CreateArticleFormValidators.content(null), 'Enter the article body');
      expect(CreateArticleFormValidators.content(''), 'Enter the article body');
    });

    test('returns error when shorter than 3 characters', () {
      expect(
        CreateArticleFormValidators.content('ab'),
        'Content must be at least 100 characters',
      );
    });

    test('returns error when longer than 20,000 characters', () {
      expect(
        CreateArticleFormValidators.content('a' * 20001),
        'Content must be at most 20,000 characters',
      );
    });

    test('returns null for valid length after trim', () {
      expect(CreateArticleFormValidators.content('  abc  '), isNull);
    });
  });
}
