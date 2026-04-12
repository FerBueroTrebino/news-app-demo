import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:news_app_clean_architecture/features/create_article/domain/entities/picked_article_image.dart';

void main() {
  test('holds bytes reference', () {
    final bytes = Uint8List.fromList([1, 2, 3]);
    final image = PickedArticleImage(bytes: bytes);

    expect(image.bytes, same(bytes));
  });
}
