import 'dart:async';
import 'dart:typed_data';

import 'package:file/file.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class HangingImageCacheManager implements BaseCacheManager {
  final List<StreamController<FileResponse>> _controllers = [];

  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    final controller = StreamController<FileResponse>();
    _controllers.add(controller);
    scheduleMicrotask(() {
      if (!controller.isClosed) {
        controller.add(DownloadProgress(url, 1000, 0));
      }
    });
    return controller.stream;
  }

  @override
  Future<void> dispose() async {
    for (final c in _controllers) {
      await c.close();
    }
    _controllers.clear();
  }

  @override
  Future<void> emptyCache() => throw UnimplementedError();

  @override
  Future<FileInfo> downloadFile(
    String url, {
    String? key,
    Map<String, String>? authHeaders,
    bool force = false,
  }) =>
      throw UnimplementedError();

  @override
  Stream<FileInfo> getFile(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) =>
      throw UnimplementedError();

  @override
  Future<FileInfo?> getFileFromCache(
    String key, {
    bool ignoreMemCache = false,
  }) =>
      throw UnimplementedError();

  @override
  Future<FileInfo?> getFileFromMemory(String key) => throw UnimplementedError();

  @override
  Future<File> getSingleFile(
    String url, {
    String? key,
    Map<String, String>? headers,
  }) =>
      throw UnimplementedError();

  @override
  Future<File> putFile(
    String url,
    Uint8List fileBytes, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  }) =>
      throw UnimplementedError();

  @override
  Future<File> putFileStream(
    String url,
    Stream<List<int>> source, {
    String? key,
    String? eTag,
    Duration maxAge = const Duration(days: 30),
    String fileExtension = 'file',
  }) =>
      throw UnimplementedError();

  @override
  Future<void> removeFile(String key) => throw UnimplementedError();
}
