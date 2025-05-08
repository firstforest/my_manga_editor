// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_comment_area.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mangaDescriptionHash() => r'd9d91d46c7bc748d32dfb0aacda7eea04142dc69';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [mangaDescription].
@ProviderFor(mangaDescription)
const mangaDescriptionProvider = MangaDescriptionFamily();

/// See also [mangaDescription].
class MangaDescriptionFamily extends Family<AsyncValue<String>> {
  /// See also [mangaDescription].
  const MangaDescriptionFamily();

  /// See also [mangaDescription].
  MangaDescriptionProvider call(
    int mangaId,
  ) {
    return MangaDescriptionProvider(
      mangaId,
    );
  }

  @override
  MangaDescriptionProvider getProviderOverride(
    covariant MangaDescriptionProvider provider,
  ) {
    return call(
      provider.mangaId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'mangaDescriptionProvider';
}

/// See also [mangaDescription].
class MangaDescriptionProvider extends AutoDisposeFutureProvider<String> {
  /// See also [mangaDescription].
  MangaDescriptionProvider(
    int mangaId,
  ) : this._internal(
          (ref) => mangaDescription(
            ref as MangaDescriptionRef,
            mangaId,
          ),
          from: mangaDescriptionProvider,
          name: r'mangaDescriptionProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaDescriptionHash,
          dependencies: MangaDescriptionFamily._dependencies,
          allTransitiveDependencies:
              MangaDescriptionFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaDescriptionProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mangaId,
  }) : super.internal();

  final int mangaId;

  @override
  Override overrideWith(
    FutureOr<String> Function(MangaDescriptionRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaDescriptionProvider._internal(
        (ref) => create(ref as MangaDescriptionRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mangaId: mangaId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<String> createElement() {
    return _MangaDescriptionProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaDescriptionProvider && other.mangaId == mangaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mangaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaDescriptionRef on AutoDisposeFutureProviderRef<String> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MangaDescriptionProviderElement
    extends AutoDisposeFutureProviderElement<String> with MangaDescriptionRef {
  _MangaDescriptionProviderElement(super.provider);

  @override
  int get mangaId => (origin as MangaDescriptionProvider).mangaId;
}

String _$aiCommentListHash() => r'aa5b76b17cf3164d24094fa002838bc8ea412be8';

abstract class _$AiCommentList
    extends BuildlessAutoDisposeNotifier<List<AiComment>> {
  late final int mangaId;

  List<AiComment> build(
    int mangaId,
  );
}

/// See also [AiCommentList].
@ProviderFor(AiCommentList)
const aiCommentListProvider = AiCommentListFamily();

/// See also [AiCommentList].
class AiCommentListFamily extends Family<List<AiComment>> {
  /// See also [AiCommentList].
  const AiCommentListFamily();

  /// See also [AiCommentList].
  AiCommentListProvider call(
    int mangaId,
  ) {
    return AiCommentListProvider(
      mangaId,
    );
  }

  @override
  AiCommentListProvider getProviderOverride(
    covariant AiCommentListProvider provider,
  ) {
    return call(
      provider.mangaId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'aiCommentListProvider';
}

/// See also [AiCommentList].
class AiCommentListProvider
    extends AutoDisposeNotifierProviderImpl<AiCommentList, List<AiComment>> {
  /// See also [AiCommentList].
  AiCommentListProvider(
    int mangaId,
  ) : this._internal(
          () => AiCommentList()..mangaId = mangaId,
          from: aiCommentListProvider,
          name: r'aiCommentListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$aiCommentListHash,
          dependencies: AiCommentListFamily._dependencies,
          allTransitiveDependencies:
              AiCommentListFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  AiCommentListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.mangaId,
  }) : super.internal();

  final int mangaId;

  @override
  List<AiComment> runNotifierBuild(
    covariant AiCommentList notifier,
  ) {
    return notifier.build(
      mangaId,
    );
  }

  @override
  Override overrideWith(AiCommentList Function() create) {
    return ProviderOverride(
      origin: this,
      override: AiCommentListProvider._internal(
        () => create()..mangaId = mangaId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        mangaId: mangaId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<AiCommentList, List<AiComment>>
      createElement() {
    return _AiCommentListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AiCommentListProvider && other.mangaId == mangaId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, mangaId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AiCommentListRef on AutoDisposeNotifierProviderRef<List<AiComment>> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _AiCommentListProviderElement
    extends AutoDisposeNotifierProviderElement<AiCommentList, List<AiComment>>
    with AiCommentListRef {
  _AiCommentListProviderElement(super.provider);

  @override
  int get mangaId => (origin as AiCommentListProvider).mangaId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
