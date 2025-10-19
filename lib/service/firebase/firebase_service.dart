import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_manga_editor/service/firebase/model/cloud_manga.dart';
import 'package:my_manga_editor/service/firebase/model/cloud_manga_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_service.g.dart';

/// Service for Firebase Firestore CRUD operations
/// Handles all cloud storage interactions for manga data
class FirebaseService {
  FirebaseService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  /// Get the current authenticated user's UID
  /// Throws FirebaseServiceException if user is not authenticated
  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseServiceException('User not authenticated');
    }
    return user.uid;
  }

  /// Get reference to user's mangas collection
  CollectionReference<Map<String, dynamic>> get _mangasCollection {
    return _firestore.collection('users').doc(_userId).collection('mangas');
  }

  /// Upload a manga to Firestore
  /// Creates a new document if id is provided but doesn't exist
  /// Updates existing document if it exists
  Future<void> uploadManga(CloudManga manga) async {
    try {
      final docRef = _mangasCollection.doc(manga.id);
      await docRef.set(manga.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to upload manga: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Upload a manga page to Firestore
  /// Creates or updates a page in the manga's pages subcollection
  Future<void> uploadMangaPage(CloudMangaPage page) async {
    try {
      final pageRef = _mangasCollection
          .doc(page.mangaId)
          .collection('pages')
          .doc(page.id);
      await pageRef.set(page.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to upload manga page: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Delete a manga and all its pages from Firestore
  /// Uses batch write to delete manga document and all page subcollection documents
  Future<void> deleteManga(String mangaId) async {
    try {
      final batch = _firestore.batch();

      // Delete all pages first
      final pagesSnapshot =
          await _mangasCollection.doc(mangaId).collection('pages').get();
      for (final doc in pagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete manga document
      batch.delete(_mangasCollection.doc(mangaId));

      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to delete manga: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Delete a manga page from Firestore
  Future<void> deleteMangaPage(String mangaId, String pageId) async {
    try {
      await _mangasCollection
          .doc(mangaId)
          .collection('pages')
          .doc(pageId)
          .delete();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to delete manga page: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Fetch all mangas for the current user
  /// Returns a list of CloudManga objects
  Future<List<CloudManga>> fetchUserMangas() async {
    try {
      final snapshot = await _mangasCollection.get();
      return snapshot.docs
          .map((doc) => CloudMangaExt.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to fetch user mangas: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Fetch all pages for a specific manga
  /// Returns a list of CloudMangaPage objects ordered by pageIndex
  Future<List<CloudMangaPage>> fetchMangaPages(String mangaId) async {
    try {
      final snapshot = await _mangasCollection
          .doc(mangaId)
          .collection('pages')
          .orderBy('pageIndex')
          .get();
      return snapshot.docs
          .map((doc) => CloudMangaPageExt.fromFirestore(doc, mangaId))
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to fetch manga pages: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Fetch a specific manga by ID
  /// Returns null if manga doesn't exist
  Future<CloudManga?> fetchManga(String mangaId) async {
    try {
      final snapshot = await _mangasCollection.doc(mangaId).get();
      if (!snapshot.exists) {
        return null;
      }
      return CloudMangaExt.fromFirestore(snapshot);
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to fetch manga: ${e.message}',
        code: e.code,
      );
    }
  }

  /// Fetch a specific manga page by ID
  /// Returns null if page doesn't exist
  Future<CloudMangaPage?> fetchMangaPage(
      String mangaId, String pageId) async {
    try {
      final snapshot = await _mangasCollection
          .doc(mangaId)
          .collection('pages')
          .doc(pageId)
          .get();
      if (!snapshot.exists) {
        return null;
      }
      return CloudMangaPageExt.fromFirestore(snapshot, mangaId);
    } on FirebaseException catch (e) {
      throw FirebaseServiceException(
        'Failed to fetch manga page: ${e.message}',
        code: e.code,
      );
    }
  }
}

/// Exception thrown when Firebase operations fail
class FirebaseServiceException implements Exception {
  FirebaseServiceException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => code != null ? '[$code] $message' : message;
}

/// Provider for FirebaseFirestore instance
@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Provider for FirebaseService
@riverpod
FirebaseService firebaseService(Ref ref) {
  return FirebaseService(
    firestore: ref.watch(firebaseFirestoreProvider),
    auth: FirebaseAuth.instance,
  );
}
