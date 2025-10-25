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
    required Map<String, dynamic> memoDelta, // Quill Delta for memo
    required Map<String, dynamic> stageDirectionDelta, // Quill Delta for stage directions
    required Map<String, dynamic> dialoguesDelta, // Quill Delta for dialogues
    required DateTime createdAt, // Creation timestamp
    required DateTime updatedAt, // Last modification timestamp
  }) = _CloudMangaPage;

  factory CloudMangaPage.fromJson(Map<String, dynamic> json) =>
      _$CloudMangaPageFromJson(json);
}

extension CloudMangaPageExt on CloudMangaPage {
  Map<String, dynamic> toFirestore() {
    return {
      'pageIndex': pageIndex,
      'memoDelta': memoDelta,
      'stageDirectionDelta': stageDirectionDelta,
      'dialoguesDelta': dialoguesDelta,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
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
      memoDelta: data['memoDelta'] as Map<String, dynamic>,
      stageDirectionDelta: data['stageDirectionDelta'] as Map<String, dynamic>,
      dialoguesDelta: data['dialoguesDelta'] as Map<String, dynamic>,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
