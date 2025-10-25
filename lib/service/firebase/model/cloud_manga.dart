import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:my_manga_editor/service/firebase/model/edit_lock.dart';

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
    @JsonKey(name: 'editLock') EditLock? editLock, // Optional edit lock
  }) = _CloudManga;

  factory CloudManga.fromJson(Map<String, dynamic> json) =>
      _$CloudMangaFromJson(json);
}

extension CloudMangaExt on CloudManga {
  // Convert CloudManga to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'startPageDirection': startPageDirection,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (editLock != null) 'editLock': editLock!.toJson(),
    };
  }

  // Convert Firestore DocumentSnapshot to CloudManga
  static CloudManga fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data()!;
    return CloudManga(
      id: snapshot.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      startPageDirection: data['startPageDirection'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      editLock: data['editLock'] != null
          ? EditLock.fromJson(data['editLock'] as Map<String, dynamic>)
          : null,
    );
  }
}
