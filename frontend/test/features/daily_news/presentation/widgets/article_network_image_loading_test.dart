import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_detail/article_detail_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/article_tile/article_image.dart';

import '../../../../helpers/hanging_image_cache_manager.dart';

void main() {
  const testUrl = 'https://example.com/article-thumb.jpg';

  tearDown(() async {
    await Future<void>.delayed(Duration.zero);
  });

  testWidgets('ArticleTileImage shows loading indicator while image is pending',
      (tester) async {
    final cacheManager = HangingImageCacheManager();
    addTearDown(cacheManager.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Center(
            child: ArticleTileImage(
              url: testUrl,
              cacheManager: cacheManager,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AspectRatio),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.strokeWidth, 2);
  });

  testWidgets(
      'ArticleDetailImage shows loading indicator while image is pending',
      (tester) async {
    final cacheManager = HangingImageCacheManager();
    addTearDown(cacheManager.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: SingleChildScrollView(
            child: ArticleDetailImage(
              imageUrl: testUrl,
              cacheManager: cacheManager,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 28 && w.height == 28,
        ),
      ),
      findsOneWidget,
    );
  });
}
