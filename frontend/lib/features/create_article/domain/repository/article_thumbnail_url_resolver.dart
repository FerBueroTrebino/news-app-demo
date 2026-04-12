/// Turns a persisted thumbnail value (download URL or legacy Storage path)
/// into an `http(s)` URL suitable for image widgets.
abstract class ArticleThumbnailUrlResolver {
  Future<String?> resolveToNetworkUrl(String storedThumbnailReference);
}
