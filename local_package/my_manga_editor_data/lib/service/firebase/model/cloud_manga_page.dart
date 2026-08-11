import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloud_manga_page.freezed.dart';
part 'cloud_manga_page.g.dart';

@freezed
abstract class CloudMangaPage with _$CloudMangaPage {
  const factory CloudMangaPage({
    required String id, // Firestore document ID
    required String mangaId, // Parent manga ID
    required int pageIndex, // Page order (0-based)
    required DateTime createdAt, // Creation timestamp
    required DateTime updatedAt, // Last modification timestamp
    String? memoDeltaId, // CloudDelta document ID for memoDelta
    List<Map<String, dynamic>>?
        sceneUnits, // List of {dialoguesDeltaId, stageDirectionDeltaId}
    // Legacy fields (read-only, for migration)
    @JsonKey(includeToJson: false) String? stageDirectionDeltaId,
    @JsonKey(includeToJson: false) String? dialoguesDeltaId,
  }) = _CloudMangaPage;

  factory CloudMangaPage.fromJson(Map<String, dynamic> json) =>
      _$CloudMangaPageFromJson(json);
}

extension CloudMangaPageExt on CloudMangaPage {
  /// 現行スキーマバージョン。
  /// スキーマ変更時はインクリメントし、fromFirestore に移行ステップを追記する。
  /// 過去の移行ステップは編集しない (.claude/rules/data-layer.md 参照)。
  ///
  /// 版履歴: docs/design/data-model.md の「スキーマバージョン履歴」
  static const schemaVersion = 2;

  Map<String, dynamic> toFirestore() {
    return {
      'schemaVersion': schemaVersion,
      'pageIndex': pageIndex,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (memoDeltaId != null) 'memoDeltaId': memoDeltaId,
      if (sceneUnits != null) 'sceneUnits': sceneUnits,
    };
  }

  static CloudMangaPage fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String mangaId,
  ) {
    var data = snapshot.data()!;

    // 単方向アップグレードチェーン: 旧版を読み込み時に段階的に最新版へ変換する
    // (lazy migration)。schemaVersion フィールドがないドキュメントは v1 とみなす。
    final version = data['schemaVersion'] as int? ?? 1;
    if (version < 2) {
      data = _migrateV1ToV2(data);
    }

    return CloudMangaPage(
      id: snapshot.id,
      mangaId: mangaId,
      pageIndex: data['pageIndex'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      memoDeltaId: data['memoDeltaId'] as String?,
      sceneUnits: (data['sceneUnits'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }

  /// v1 → v2: トップレベルの dialoguesDeltaId / stageDirectionDeltaId を
  /// sceneUnits 配列 1 要素に変換する。
  /// schemaVersion 導入前に書かれた v2 形式 (sceneUnits あり・schemaVersion なし)
  /// はそのまま通す。
  static Map<String, dynamic> _migrateV1ToV2(Map<String, dynamic> data) {
    if (data['sceneUnits'] != null) {
      return data;
    }
    if (data['dialoguesDeltaId'] == null &&
        data['stageDirectionDeltaId'] == null) {
      return data;
    }
    return {
      ...data,
      'sceneUnits': [
        {
          'dialoguesDeltaId': data['dialoguesDeltaId'] as String?,
          'stageDirectionDeltaId': data['stageDirectionDeltaId'] as String?,
        }
      ],
    };
  }
}
