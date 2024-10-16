// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_page_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mangaPageViewModelNotifierHash() =>
    r'187e50216a1d2bad0b1446c130eaf8b0ccab8f4a';

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
  late final String fileName;

  FutureOr<MangaPageViewModel> build(
    String fileName,
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
    String fileName,
  ) {
    return MangaPageViewModelNotifierProvider(
      fileName,
    );
  }

  @override
  MangaPageViewModelNotifierProvider getProviderOverride(
    covariant MangaPageViewModelNotifierProvider provider,
  ) {
    return call(
      provider.fileName,
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
    String fileName,
  ) : this._internal(
          () => MangaPageViewModelNotifier()..fileName = fileName,
          from: mangaPageViewModelNotifierProvider,
          name: r'mangaPageViewModelNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$mangaPageViewModelNotifierHash,
          dependencies: MangaPageViewModelNotifierFamily._dependencies,
          allTransitiveDependencies:
              MangaPageViewModelNotifierFamily._allTransitiveDependencies,
          fileName: fileName,
        );

  MangaPageViewModelNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.fileName,
  }) : super.internal();

  final String fileName;

  @override
  FutureOr<MangaPageViewModel> runNotifierBuild(
    covariant MangaPageViewModelNotifier notifier,
  ) {
    return notifier.build(
      fileName,
    );
  }

  @override
  Override overrideWith(MangaPageViewModelNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: MangaPageViewModelNotifierProvider._internal(
        () => create()..fileName = fileName,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        fileName: fileName,
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
    return other is MangaPageViewModelNotifierProvider &&
        other.fileName == fileName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, fileName.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MangaPageViewModelNotifierRef
    on AutoDisposeAsyncNotifierProviderRef<MangaPageViewModel> {
  /// The parameter `fileName` of this provider.
  String get fileName;
}

class _MangaPageViewModelNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<MangaPageViewModelNotifier,
        MangaPageViewModel> with MangaPageViewModelNotifierRef {
  _MangaPageViewModelNotifierProviderElement(super.provider);

  @override
  String get fileName =>
      (origin as MangaPageViewModelNotifierProvider).fileName;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
