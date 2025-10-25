/// Base exception for repository operations
abstract class RepositoryException implements Exception {
  String get message;

  @override
  String toString() => message;
}

/// User not authenticated or auth token expired
class AuthException implements RepositoryException {
  @override
  final String message;
  AuthException([this.message = 'User not authenticated']);
}

/// Requested resource (manga/page) not found
class NotFoundException implements RepositoryException {
  final String resourceType; // 'Manga' or 'MangaPage'
  final String resourceId;

  @override
  String get message => '$resourceType with ID $resourceId not found';

  NotFoundException(this.resourceType, this.resourceId);
}

/// Validation error (e.g., invalid pageIndex, empty name)
class ValidationException implements RepositoryException {
  @override
  final String message;
  ValidationException(this.message);
}

/// Firestore operation failed (network error, quota exceeded, etc.)
class StorageException implements RepositoryException {
  @override
  final String message;
  final String? code; // Firestore error code
  StorageException(this.message, {this.code});
}

/// User has insufficient permissions (Firestore security rules denied)
class PermissionException implements RepositoryException {
  @override
  final String message;
  PermissionException([this.message = 'Permission denied']);
}
