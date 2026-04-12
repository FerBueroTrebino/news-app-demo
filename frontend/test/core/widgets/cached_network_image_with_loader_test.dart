import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/core/widgets/cached_network_image_with_loader.dart';
import '../../helpers/hanging_image_cache_manager.dart';

void main() {
  const testUrl = 'https://example.com/image.png';

  tearDown(() async {
    // Allow image stream / codec futures to settle after each test.
    await Future<void>.delayed(Duration.zero);
  });

  testWidgets(
      'shows centered progress indicator with default size while loading',
      (tester) async {
    final cacheManager = HangingImageCacheManager();
    addTearDown(cacheManager.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: CachedNetworkImageWithLoader(
            cacheManager: cacheManager,
            imageUrl: testUrl,
            progressIndicatorSize: 28,
            imageBuilder: (_, __) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.strokeWidth, 2);

    expect(
      find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 28 && w.height == 28,
        ),
      ),
      findsOneWidget,
    );
    expect(find.byType(Center), findsWidgets);
  });

  testWidgets('wrapProgress receives themed indicator for tile-style layout',
      (tester) async {
    final cacheManager = HangingImageCacheManager();
    addTearDown(cacheManager.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: CachedNetworkImageWithLoader(
            cacheManager: cacheManager,
            imageUrl: testUrl,
            progressIndicatorSize: 24,
            imageBuilder: (_, __) => const SizedBox.shrink(),
            wrapProgress: (context, indicator) => AspectRatio(
              aspectRatio: 16 / 9,
              child: ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(child: indicator),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(AspectRatio), findsOneWidget);
    expect(find.byType(ColoredBox), findsOneWidget);

    expect(
      find.ancestor(
        of: find.byType(CircularProgressIndicator),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 24 && w.height == 24,
        ),
      ),
      findsOneWidget,
    );
  });
}
