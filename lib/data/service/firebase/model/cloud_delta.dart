import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cloud_delta.freezed.dart';
part 'cloud_delta.g.dart';

/// Cloud Firestore model for Delta documents
/// Represents a single Quill Delta stored in the deltas subcollection
@freezed
abstract class CloudDelta with _$CloudDelta {
  const factory CloudDelta({
    required String id, // Firestore document ID
    required String mangaId, // Parent manga ID
    required List<dynamic> ops, // Quill Delta operations
    required String fieldName, // 'ideaMemo', 'memoDelta', 'stageDirectionDelta', 'dialoguesDelta'
    String? pageId, // Page ID if this delta belongs to a page (null for ideaMemo)
    required DateTime createdAt, // Creation timestamp
    required DateTime updatedAt, // Last modification timestamp
  }) = _CloudDelta;

  factory CloudDelta.fromJson(Map<String, dynamic> json) =>
      _$CloudDeltaFromJson(json);
}

extension CloudDeltaExt on CloudDelta {
  // Convert CloudDelta to Firestore document data
  Map<String, dynamic> toFirestore() {
    return {
      'ops': ops,
      'fieldName': fieldName,
      if (pageId != null) 'pageId': pageId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Convert Firestore DocumentSnapshot to CloudDelta
  static CloudDelta fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    String mangaId,
  ) {
    final data = snapshot.data()!;
    return CloudDelta(
      id: snapshot.id,
      mangaId: mangaId,
      ops: data['ops'] as List<dynamic>,
      fieldName: data['fieldName'] as String,
      pageId: data['pageId'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }
}
