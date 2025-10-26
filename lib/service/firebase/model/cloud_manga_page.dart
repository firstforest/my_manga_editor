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
    String? stageDirectionDeltaId, // CloudDelta document ID for stageDirectionDelta
    String? dialoguesDeltaId, // CloudDelta document ID for dialoguesDelta
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
      if (stageDirectionDeltaId != null) 'stageDirectionDeltaId': stageDirectionDeltaId,
      if (dialoguesDeltaId != null) 'dialoguesDeltaId': dialoguesDeltaId,
    };
  }

  static CloudMangaPage fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String mangaId,
  ) {
    final data = snapshot.data()!;
    return CloudMangaPage(
      id: snapshot.id,
      mangaId: mangaId,
      pageIndex: data['pageIndex'] as int,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      memoDeltaId: data['memoDeltaId'] as String?,
      stageDirectionDeltaId: data['stageDirectionDeltaId'] as String?,
      dialoguesDeltaId: data['dialoguesDeltaId'] as String?,
    );
  }
}
