import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/repository/article_thumbnail_storage.dart';
import '../../domain/repository/article_thumbnail_url_resolver.dart';

class ArticleThumbnailStorageImpl
    implements ArticleThumbnailStorage, ArticleThumbnailUrlResolver {
  ArticleThumbnailStorageImpl(this._storage);

  final FirebaseStorage _storage;

  static String objectPathForArticle(String articleUid) =>
      'media/articles/$articleUid/thumbnail.jpg';

  @override
  Future<String> uploadJpegThumbnail({
    required String articleUid,
    required Uint8List bytes,
  }) async {
    final ref = _storage.ref(objectPathForArticle(articleUid));
    await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return ref.getDownloadURL();
  }

  @override
  Future<String?> resolveToNetworkUrl(String storedThumbnailReference) async {
    final value = storedThumbnailReference.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    try {
      return await _storage.ref(value).getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}
