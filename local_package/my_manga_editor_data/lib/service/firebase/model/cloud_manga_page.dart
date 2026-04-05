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
    List<Map<String, dynamic>>? sceneUnits, // List of {dialoguesDeltaId, stageDirectionDeltaId}
    // Legacy fields (read-only, for migration)
    @JsonKey(includeToJson: false) String? stageDirectionDeltaId,
    @JsonKey(includeToJson: false) String? dialoguesDeltaId,
  }) = _CloudMangaPage;

  factory CloudMangaPage.fromJson(Map<String, dynamic> json) =>
      _$CloudMangaPageFromJson(json);
}

extension CloudMangaPageExt on CloudMangaPage {
  Map<String, dynamic> toFirestore() {
    return {
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
    final data = snapshot.data()!;

    // Lazy migration: convert legacy fields to sceneUnits
    List<Map<String, dynamic>>? sceneUnits;
    if (data['sceneUnits'] != null) {
      sceneUnits = (data['sceneUnits'] as List<dynamic>)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } else if (data['dialoguesDeltaId'] != null ||
        data['stageDirectionDeltaId'] != null) {
      sceneUnits = [
        {
          'dialoguesDeltaId': data['dialoguesDeltaId'] as String?,
          'stageDirectionDeltaId': data['stageDirectionDeltaId'] as String?,
        }
      ];
    }

    return CloudMangaPage(
      id: snapshot.id,
      mangaId: mangaId,
      pageIndex: data['pageIndex'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      memoDeltaId: data['memoDeltaId'] as String?,
      sceneUnits: sceneUnits,
    );
  }
}
