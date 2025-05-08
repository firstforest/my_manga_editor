// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allMangaListHash() => r'5f074610a4e477f0f97b8e41b457128d81c2be2d';

/// See also [allMangaList].
@ProviderFor(allMangaList)
final allMangaListProvider = AutoDisposeStreamProvider<List<Manga>>.internal(
  allMangaList,
  name: r'allMangaListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$allMangaListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllMangaListRef = AutoDisposeStreamProviderRef<List<Manga>>;
String _$mangaPageIdListHash() => r'f1bfa90b042b6b7553332844e1d271e4119251dd';

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

/// See also [mangaPageIdList].
@ProviderFor(mangaPageIdList)
const mangaPageIdListProvider = MangaPageIdListFamily();

/// See also [mangaPageIdList].
class MangaPageIdListFamily extends Family<AsyncValue<List<MangaPageId>>> {
  /// See also [mangaPageIdList].
  const MangaPageIdListFamily();

  /// See also [mangaPageIdList].
  MangaPageIdListProvider call(
    int mangaId,
  ) {
    return MangaPageIdListProvider(
      mangaId,
    );
  }

  @override
  MangaPageIdListProvider getProviderOverride(
    covariant MangaPageIdListProvider provider,
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
  String? get name => r'mangaPageIdListProvider';
}

/// See also [mangaPageIdList].
class MangaPageIdListProvider
    extends AutoDisposeStreamProvider<List<MangaPageId>> {
  /// See also [mangaPageIdList].
  MangaPageIdListProvider(
    int mangaId,
  ) : this._internal(
          (ref) => mangaPageIdList(
            ref as MangaPageIdListRef,
            mangaId,
          ),
          from: mangaPageIdListProvider,
          name: r'mangaPageIdListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaPageIdListHash,
          dependencies: MangaPageIdListFamily._dependencies,
          allTransitiveDependencies:
              MangaPageIdListFamily._allTransitiveDependencies,
          mangaId: mangaId,
        );

  MangaPageIdListProvider._internal(
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
    Stream<List<MangaPageId>> Function(MangaPageIdListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MangaPageIdListProvider._internal(
        (ref) => create(ref as MangaPageIdListRef),
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
  AutoDisposeStreamProviderElement<List<MangaPageId>> createElement() {
    return _MangaPageIdListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaPageIdListProvider && other.mangaId == mangaId;
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
mixin MangaPageIdListRef on AutoDisposeStreamProviderRef<List<MangaPageId>> {
  /// The parameter `mangaId` of this provider.
  int get mangaId;
}

class _MangaPageIdListProviderElement
    extends AutoDisposeStreamProviderElement<List<MangaPageId>>
    with MangaPageIdListRef {
  _MangaPageIdListProviderElement(super.provider);

  @override
  int get mangaId => (origin as MangaPageIdListProvider).mangaId;
}

String _$mangaNotifierHash() => r'4dafefd7a32a31dc0d24977603ca77b5f3d0790c';

abstract class _$MangaNotifier
    extends BuildlessAutoDisposeStreamNotifier<Manga?> {
  late final int id;

  Stream<Manga?> build(
    int id,
  );
}

/// See also [MangaNotifier].
@ProviderFor(MangaNotifier)
const mangaNotifierProvider = MangaNotifierFamily();

/// See also [MangaNotifier].
class MangaNotifierFamily extends Family<AsyncValue<Manga?>> {
  /// See also [MangaNotifier].
  const MangaNotifierFamily();

  /// See also [MangaNotifier].
  MangaNotifierProvider call(
    int id,
  ) {
    return MangaNotifierProvider(
      id,
    );
  }

  @override
  MangaNotifierProvider getProviderOverride(
    covariant MangaNotifierProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'mangaNotifierProvider';
}

/// See also [MangaNotifier].
class MangaNotifierProvider
    extends AutoDisposeStreamNotifierProviderImpl<MangaNotifier, Manga?> {
  /// See also [MangaNotifier].
  MangaNotifierProvider(
    int id,
  ) : this._internal(
          () => MangaNotifier()..id = id,
          from: mangaNotifierProvider,
          name: r'mangaNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaNotifierHash,
          dependencies: MangaNotifierFamily._dependencies,
          allTransitiveDependencies:
              MangaNotifierFamily._allTransitiveDependencies,
          id: id,
        );

  MangaNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Stream<Manga?> runNotifierBuild(
    covariant MangaNotifier notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(MangaNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MangaNotifierProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<MangaNotifier, Manga?>
      createElement() {
    return _MangaNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaNotifierProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaNotifierRef on AutoDisposeStreamNotifierProviderRef<Manga?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _MangaNotifierProviderElement
    extends AutoDisposeStreamNotifierProviderElement<MangaNotifier, Manga?>
    with MangaNotifierRef {
  _MangaNotifierProviderElement(super.provider);

  @override
  int get id => (origin as MangaNotifierProvider).id;
}

String _$mangaPageNotifierHash() => r'03df73457b892b2a95b39b252b4e391e20a043dc';

abstract class _$MangaPageNotifier
    extends BuildlessAutoDisposeStreamNotifier<MangaPage> {
  late final int pageId;

  Stream<MangaPage> build(
    int pageId,
  );
}

/// See also [MangaPageNotifier].
@ProviderFor(MangaPageNotifier)
const mangaPageNotifierProvider = MangaPageNotifierFamily();

/// See also [MangaPageNotifier].
class MangaPageNotifierFamily extends Family<AsyncValue<MangaPage>> {
  /// See also [MangaPageNotifier].
  const MangaPageNotifierFamily();

  /// See also [MangaPageNotifier].
  MangaPageNotifierProvider call(
    int pageId,
  ) {
    return MangaPageNotifierProvider(
      pageId,
    );
  }

  @override
  MangaPageNotifierProvider getProviderOverride(
    covariant MangaPageNotifierProvider provider,
  ) {
    return call(
      provider.pageId,
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
  String? get name => r'mangaPageNotifierProvider';
}

/// See also [MangaPageNotifier].
class MangaPageNotifierProvider extends AutoDisposeStreamNotifierProviderImpl<
    MangaPageNotifier, MangaPage> {
  /// See also [MangaPageNotifier].
  MangaPageNotifierProvider(
    int pageId,
  ) : this._internal(
          () => MangaPageNotifier()..pageId = pageId,
          from: mangaPageNotifierProvider,
          name: r'mangaPageNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaPageNotifierHash,
          dependencies: MangaPageNotifierFamily._dependencies,
          allTransitiveDependencies:
              MangaPageNotifierFamily._allTransitiveDependencies,
          pageId: pageId,
        );

  MangaPageNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pageId,
  }) : super.internal();

  final int pageId;

  @override
  Stream<MangaPage> runNotifierBuild(
    covariant MangaPageNotifier notifier,
  ) {
    return notifier.build(
      pageId,
    );
  }

  @override
  Override overrideWith(MangaPageNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MangaPageNotifierProvider._internal(
        () => create()..pageId = pageId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pageId: pageId,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<MangaPageNotifier, MangaPage>
      createElement() {
    return _MangaPageNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaPageNotifierProvider && other.pageId == pageId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pageId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MangaPageNotifierRef on AutoDisposeStreamNotifierProviderRef<MangaPage> {
  /// The parameter `pageId` of this provider.
  int get pageId;
}

class _MangaPageNotifierProviderElement
    extends AutoDisposeStreamNotifierProviderElement<MangaPageNotifier,
        MangaPage> with MangaPageNotifierRef {
  _MangaPageNotifierProviderElement(super.provider);

  @override
  int get pageId => (origin as MangaPageNotifierProvider).pageId;
}

String _$deltaNotifierHash() => r'98e6ed6ecd0cf6fef935369ba190a707aa2d8085';

abstract class _$DeltaNotifier
    extends BuildlessAutoDisposeStreamNotifier<Delta?> {
  late final int? id;

  Stream<Delta?> build(
    int? id,
  );
}

/// See also [DeltaNotifier].
@ProviderFor(DeltaNotifier)
const deltaNotifierProvider = DeltaNotifierFamily();

/// See also [DeltaNotifier].
class DeltaNotifierFamily extends Family<AsyncValue<Delta?>> {
  /// See also [DeltaNotifier].
  const DeltaNotifierFamily();

  /// See also [DeltaNotifier].
  DeltaNotifierProvider call(
    int? id,
  ) {
    return DeltaNotifierProvider(
      id,
    );
  }

  @override
  DeltaNotifierProvider getProviderOverride(
    covariant DeltaNotifierProvider provider,
  ) {
    return call(
      provider.id,
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
  String? get name => r'deltaNotifierProvider';
}

/// See also [DeltaNotifier].
class DeltaNotifierProvider
    extends AutoDisposeStreamNotifierProviderImpl<DeltaNotifier, Delta?> {
  /// See also [DeltaNotifier].
  DeltaNotifierProvider(
    int? id,
  ) : this._internal(
          () => DeltaNotifier()..id = id,
          from: deltaNotifierProvider,
          name: r'deltaNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$deltaNotifierHash,
          dependencies: DeltaNotifierFamily._dependencies,
          allTransitiveDependencies:
              DeltaNotifierFamily._allTransitiveDependencies,
          id: id,
        );

  DeltaNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int? id;

  @override
  Stream<Delta?> runNotifierBuild(
    covariant DeltaNotifier notifier,
  ) {
    return notifier.build(
      id,
    );
  }

  @override
  Override overrideWith(DeltaNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: DeltaNotifierProvider._internal(
        () => create()..id = id,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeStreamNotifierProviderElement<DeltaNotifier, Delta?>
      createElement() {
    return _DeltaNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DeltaNotifierProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin DeltaNotifierRef on AutoDisposeStreamNotifierProviderRef<Delta?> {
  /// The parameter `id` of this provider.
  int? get id;
}

class _DeltaNotifierProviderElement
    extends AutoDisposeStreamNotifierProviderElement<DeltaNotifier, Delta?>
    with DeltaNotifierRef {
  _DeltaNotifierProviderElement(super.provider);

  @override
  int? get id => (origin as DeltaNotifierProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
