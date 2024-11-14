// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_page_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mangaPageViewModelNotifierHash() =>
    r'9df62f6bef43c3ed40b84819fe26dd94b403a5b2';

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

abstract class _$MangaPageViewModelNotifier
    extends BuildlessAutoDisposeAsyncNotifier<MangaPageViewModel> {
  late final String uuid;

  FutureOr<MangaPageViewModel> build(
    String uuid,
  );
}

/// See also [MangaPageViewModelNotifier].
@ProviderFor(MangaPageViewModelNotifier)
const mangaPageViewModelNotifierProvider = MangaPageViewModelNotifierFamily();

/// See also [MangaPageViewModelNotifier].
class MangaPageViewModelNotifierFamily
    extends Family<AsyncValue<MangaPageViewModel>> {
  /// See also [MangaPageViewModelNotifier].
  const MangaPageViewModelNotifierFamily();

  /// See also [MangaPageViewModelNotifier].
  MangaPageViewModelNotifierProvider call(
    String uuid,
  ) {
    return MangaPageViewModelNotifierProvider(
      uuid,
    );
  }

  @override
  MangaPageViewModelNotifierProvider getProviderOverride(
    covariant MangaPageViewModelNotifierProvider provider,
  ) {
    return call(
      provider.uuid,
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
  String? get name => r'mangaPageViewModelNotifierProvider';
}

/// See also [MangaPageViewModelNotifier].
class MangaPageViewModelNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<MangaPageViewModelNotifier,
        MangaPageViewModel> {
  /// See also [MangaPageViewModelNotifier].
  MangaPageViewModelNotifierProvider(
    String uuid,
  ) : this._internal(
          () => MangaPageViewModelNotifier()..uuid = uuid,
          from: mangaPageViewModelNotifierProvider,
          name: r'mangaPageViewModelNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaPageViewModelNotifierHash,
          dependencies: MangaPageViewModelNotifierFamily._dependencies,
          allTransitiveDependencies:
              MangaPageViewModelNotifierFamily._allTransitiveDependencies,
          uuid: uuid,
        );

  MangaPageViewModelNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.uuid,
  }) : super.internal();

  final String uuid;

  @override
  FutureOr<MangaPageViewModel> runNotifierBuild(
    covariant MangaPageViewModelNotifier notifier,
  ) {
    return notifier.build(
      uuid,
    );
  }

  @override
  Override overrideWith(MangaPageViewModelNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MangaPageViewModelNotifierProvider._internal(
        () => create()..uuid = uuid,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        uuid: uuid,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MangaPageViewModelNotifier,
      MangaPageViewModel> createElement() {
    return _MangaPageViewModelNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MangaPageViewModelNotifierProvider && other.uuid == uuid;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, uuid.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MangaPageViewModelNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<MangaPageViewModel> {
  /// The parameter `uuid` of this provider.
  String get uuid;
}

class _MangaPageViewModelNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MangaPageViewModelNotifier,
        MangaPageViewModel> with MangaPageViewModelNotifierRef {
  _MangaPageViewModelNotifierProviderElement(super.provider);

  @override
  String get uuid => (origin as MangaPageViewModelNotifierProvider).uuid;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
