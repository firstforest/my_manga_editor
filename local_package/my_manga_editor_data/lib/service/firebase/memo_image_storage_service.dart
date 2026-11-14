import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'memo_image_storage_service.g.dart';

/// メモに貼る画像を Cloud Storage に置く。
///
/// 置き場所は `users/{userId}/mangas/{mangaId}/memoImages/{imageId}`。
/// 作品単位でまとめて消せるよう、作品 ID の下に置く。
class MemoImageStorageService {
  MemoImageStorageService({
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _storage = storage,
        _auth = auth;

  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseServiceException('User not authenticated');
    }
    return user.uid;
  }

  Reference _folder(String mangaId) =>
      _storage.ref('users/$_userId/mangas/$mangaId/memoImages');

  /// 画像を保存し、表示に使うダウンロード URL を返す。
  Future<String> upload({
    required String mangaId,
    required Uint8List bytes,
    required String contentType,
  }) async {
    try {
      final ref = _folder(mangaId).child(const Uuid().v4());
      await ref.putData(bytes, SettableMetadata(contentType: contentType));
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to upload memo image: ${e.message}',
        code: e.code,
      );
    }
  }

  /// 作品に貼った画像をすべて消す。
  Future<void> deleteAllForManga(String mangaId) async {
    try {
      final result = await _folder(mangaId).listAll();
      await Future.wait(result.items.map((item) => item.delete()));
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to delete memo images: ${e.message}',
        code: e.code,
      );
    }
  }
}

@riverpod
MemoImageStorageService memoImageStorageService(Ref ref) {
  return MemoImageStorageService(
    storage: FirebaseStorage.instance,
    auth: FirebaseAuth.instance,
  );
}
