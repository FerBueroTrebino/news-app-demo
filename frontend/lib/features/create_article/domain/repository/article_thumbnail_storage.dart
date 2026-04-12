import 'dart:typed_data';

/// Persists article thumbnails in Firebase Storage and returns the download URL.
abstract class ArticleThumbnailStorage {
  /// Uploads JPEG bytes to the canonical object path for [articleUid] and
  /// returns the public download URL.
  Future<String> uploadJpegThumbnail({
    required String articleUid,
    required Uint8List bytes,
  });
}
