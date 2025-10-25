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
    );
  }
}
