import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor_data/service/firebase/model/edit_lock.dart';

part 'cloud_manga.freezed.dart';
part 'cloud_manga.g.dart';

@freezed
abstract class CloudManga with _$CloudManga {
  const factory CloudManga({
    required String id, // Firestore document ID
    required String userId, // Owner UID
    required String name, // Manga title
    required String startPageDirection, // 'left' or 'right'
    required DateTime createdAt, // Creation timestamp
    required DateTime updatedAt, // Last modification timestamp
    String? ideaMemoDeltaId, // CloudDelta document ID for ideaMemo
    @JsonKey(name: 'editLock') EditLock? editLock, // Optional edit lock
    String? status, // Manga status: 'idea', 'inProgress', 'complete'
    List<String>? tags, // Tags attached to the manga (null/absent = no tags)
  }) = _CloudManga;

  factory CloudManga.fromJson(Map<String, dynamic> json) =>
      _$CloudMangaFromJson(json);
}

extension CloudMangaExt on CloudManga {
  /// 現行スキーマバージョン。
  /// スキーマ変更時はインクリメントし、fromFirestore に移行ステップを追記する。
  /// 過去の移行ステップは編集しない (.claude/rules/data-layer.md 参照)。
  static const schemaVersion = 1;

  // Convert CloudManga to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'schemaVersion': schemaVersion,
      'userId': userId,
      'name': name,
      'startPageDirection': startPageDirection,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (ideaMemoDeltaId != null) 'ideaMemoDeltaId': ideaMemoDeltaId,
      if (editLock != null) 'editLock': editLock!.toJson(),
      if (status != null) 'status': status,
      // タグなしは空配列で表す。キーの有無で状態を持たせないため常に書く。
      'tags': tags ?? const <String>[],
    };
  }

  // Convert Firestore DocumentSnapshot to CloudManga
  static CloudManga fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    final rawTags = data['tags'] as List<dynamic>?;
    // serverTimestamp は解決されるまでローカルスナップショット上では null で読める
    // (ServerTimestampBehavior.none)。書き込み直後の読み直しで落ちないよう、
    // 未解決のあいだは読み取り時刻を仮置きする。次のスナップショットで確定値に入れ替わる。
    final now = DateTime.now();

    // schemaVersion は現在 v1 のみ (なし = v1)。
    // バージョン追加時はここに単方向アップグレードチェーンを追記する。
    return CloudManga(
      id: snapshot.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      startPageDirection: data['startPageDirection'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? now,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? now,
      ideaMemoDeltaId: data['ideaMemoDeltaId'] as String?,
      editLock: data['editLock'] != null
          ? EditLock.fromJson(data['editLock'] as Map<String, dynamic>)
          : null,
      status: data['status'] as String?,
      // tags フィールドを持たない旧ドキュメントは null のまま読み、
      // ドメイン変換時に空リストへ倒す (タグなし)。
      // 遅延ビュー (cast) にすると型不正な要素が後の反復で初めて落ち、
      // 一覧画面全体を巻き込む。ここで即座に変換して失敗をこの 1 件に閉じ込める。
      tags: rawTags == null ? null : List<String>.from(rawTags),
    );
  }
}
