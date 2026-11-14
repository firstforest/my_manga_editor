import 'dart:typed_data';

import 'package:my_manga_editor_common/logger.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/exceptions.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:my_manga_editor_data/service/firebase/memo_image_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'memo_image_repository.g.dart';

/// メモに貼る画像の保存と削除。
class MemoImageRepository {
  MemoImageRepository({required MemoImageStorageService storageService})
      : _storageService = storageService;

  final MemoImageStorageService _storageService;

  /// 1 枚の上限。`storage.rules` の上限と揃える。
  static const maxBytes = 10 * 1024 * 1024;

  /// 画像を保存し、メモに埋め込む URL を返す。
  ///
  /// 形式はファイル名ではなく先頭のバイト列で判定する
  /// (クリップボードから来る画像には名前がないため)。
  Future<String> upload(MangaId mangaId, Uint8List bytes) async {
    if (bytes.length > maxBytes) {
      throw MemoImageTooLargeException(maxBytes);
    }
    final contentType = detectImageContentType(bytes);
    if (contentType == null) {
      throw UnsupportedMemoImageException();
    }
    try {
      return await _storageService.upload(
        mangaId: mangaId.id,
        bytes: bytes,
        contentType: contentType,
      );
    } on FirebaseServiceException catch (e) {
      logger.e('Failed to upload memo image: $mangaId', error: e);
      throw StorageException(e.message, code: e.code);
    }
  }

  /// 作品に貼った画像をすべて消す。失敗しても作品の削除は止めない。
  Future<void> deleteAllForManga(MangaId mangaId) async {
    try {
      await _storageService.deleteAllForManga(mangaId.id);
    } on FirebaseServiceException catch (e) {
      logger.e('Failed to delete memo images: $mangaId', error: e);
    }
  }
}

/// 画像の先頭バイト列から MIME タイプを判定する。扱えない形式は null。
String? detectImageContentType(Uint8List bytes) {
  bool startsWith(List<int> sig, [int offset = 0]) {
    if (bytes.length < offset + sig.length) return false;
    for (var i = 0; i < sig.length; i++) {
      if (bytes[offset + i] != sig[i]) return false;
    }
    return true;
  }

  if (startsWith(const [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])) {
    return 'image/png';
  }
  if (startsWith(const [0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (startsWith('GIF87a'.codeUnits) || startsWith('GIF89a'.codeUnits)) {
    return 'image/gif';
  }
  if (startsWith('RIFF'.codeUnits) && startsWith('WEBP'.codeUnits, 8)) {
    return 'image/webp';
  }
  return null;
}

@Riverpod(keepAlive: true)
MemoImageRepository memoImageRepository(Ref ref) {
  return MemoImageRepository(
    storageService: ref.watch(memoImageStorageServiceProvider),
  );
}
