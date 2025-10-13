// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allMangaList)
const allMangaListProvider = AllMangaListProvider._();

final class AllMangaListProvider extends $FunctionalProvider<
        AsyncValue<List<Manga>>, List<Manga>, Stream<List<Manga>>>
    with $FutureModifier<List<Manga>>, $StreamProvider<List<Manga>> {
  const AllMangaListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'allMangaListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$allMangaListHash();

  @$internal
  @override
  $StreamProviderElement<List<Manga>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Manga>> create(Ref ref) {
    return allMangaList(ref);
  }
}

String _$allMangaListHash() => r'5f074610a4e477f0f97b8e41b457128d81c2be2d';

@ProviderFor(mangaPageIdList)
const mangaPageIdListProvider = MangaPageIdListFamily._();

final class MangaPageIdListProvider extends $FunctionalProvider<
        AsyncValue<List<MangaPageId>>,
        List<MangaPageId>,
        Stream<List<MangaPageId>>>
    with
        $FutureModifier<List<MangaPageId>>,
        $StreamProvider<List<MangaPageId>> {
  const MangaPageIdListProvider._(
      {required MangaPageIdListFamily super.from,
      required MangaId super.argument})
      : super(
          retry: null,
          name: r'mangaPageIdListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mangaPageIdListHash();

  @override
  String toString() {
    return r'mangaPageIdListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<MangaPageId>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<MangaPageId>> create(Ref ref) {
    final argument = this.argument as MangaId;
    return mangaPageIdList(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MangaPageIdListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mangaPageIdListHash() => r'f1bfa90b042b6b7553332844e1d271e4119251dd';

final class MangaPageIdListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<MangaPageId>>, MangaId> {
  const MangaPageIdListFamily._()
      : super(
          retry: null,
          name: r'mangaPageIdListProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MangaPageIdListProvider call(
    MangaId mangaId,
  ) =>
      MangaPageIdListProvider._(argument: mangaId, from: this);

  @override
  String toString() => r'mangaPageIdListProvider';
}

@ProviderFor(MangaNotifier)
const mangaProvider = MangaNotifierFamily._();

final class MangaNotifierProvider
    extends $StreamNotifierProvider<MangaNotifier, Manga?> {
  const MangaNotifierProvider._(
      {required MangaNotifierFamily super.from, required int super.argument})
      : super(
          retry: null,
          name: r'mangaProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mangaNotifierHash();

  @override
  String toString() {
    return r'mangaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MangaNotifier create() => MangaNotifier();

  @override
  bool operator ==(Object other) {
    return other is MangaNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mangaNotifierHash() => r'ad765c3a4b528781a056a461240d6eec34ec9d7a';

final class MangaNotifierFamily extends $Family
    with
        $ClassFamilyOverride<MangaNotifier, AsyncValue<Manga?>, Manga?,
            Stream<Manga?>, int> {
  const MangaNotifierFamily._()
      : super(
          retry: null,
          name: r'mangaProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MangaNotifierProvider call(
    int id,
  ) =>
      MangaNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'mangaProvider';
}

abstract class _$MangaNotifier extends $StreamNotifier<Manga?> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  Stream<Manga?> build(
    int id,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<AsyncValue<Manga?>, Manga?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Manga?>, Manga?>,
        AsyncValue<Manga?>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(MangaPageNotifier)
const mangaPageProvider = MangaPageNotifierFamily._();

final class MangaPageNotifierProvider
    extends $StreamNotifierProvider<MangaPageNotifier, MangaPage> {
  const MangaPageNotifierProvider._(
      {required MangaPageNotifierFamily super.from,
      required MangaPageId super.argument})
      : super(
          retry: null,
          name: r'mangaPageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mangaPageNotifierHash();

  @override
  String toString() {
    return r'mangaPageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MangaPageNotifier create() => MangaPageNotifier();

  @override
  bool operator ==(Object other) {
    return other is MangaPageNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mangaPageNotifierHash() => r'03df73457b892b2a95b39b252b4e391e20a043dc';

final class MangaPageNotifierFamily extends $Family
    with
        $ClassFamilyOverride<MangaPageNotifier, AsyncValue<MangaPage>,
            MangaPage, Stream<MangaPage>, MangaPageId> {
  const MangaPageNotifierFamily._()
      : super(
          retry: null,
          name: r'mangaPageProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MangaPageNotifierProvider call(
    MangaPageId pageId,
  ) =>
      MangaPageNotifierProvider._(argument: pageId, from: this);

  @override
  String toString() => r'mangaPageProvider';
}

abstract class _$MangaPageNotifier extends $StreamNotifier<MangaPage> {
  late final _$args = ref.$arg as MangaPageId;
  MangaPageId get pageId => _$args;

  Stream<MangaPage> build(
    MangaPageId pageId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<AsyncValue<MangaPage>, MangaPage>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<MangaPage>, MangaPage>,
        AsyncValue<MangaPage>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(DeltaNotifier)
const deltaProvider = DeltaNotifierFamily._();

final class DeltaNotifierProvider
    extends $StreamNotifierProvider<DeltaNotifier, Delta?> {
  const DeltaNotifierProvider._(
      {required DeltaNotifierFamily super.from,
      required DeltaId? super.argument})
      : super(
          retry: null,
          name: r'deltaProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deltaNotifierHash();

  @override
  String toString() {
    return r'deltaProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeltaNotifier create() => DeltaNotifier();

  @override
  bool operator ==(Object other) {
    return other is DeltaNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deltaNotifierHash() => r'98e6ed6ecd0cf6fef935369ba190a707aa2d8085';

final class DeltaNotifierFamily extends $Family
    with
        $ClassFamilyOverride<DeltaNotifier, AsyncValue<Delta?>, Delta?,
            Stream<Delta?>, DeltaId?> {
  const DeltaNotifierFamily._()
      : super(
          retry: null,
          name: r'deltaProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  DeltaNotifierProvider call(
    DeltaId? id,
  ) =>
      DeltaNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'deltaProvider';
}

abstract class _$DeltaNotifier extends $StreamNotifier<Delta?> {
  late final _$args = ref.$arg as DeltaId?;
  DeltaId? get id => _$args;

  Stream<Delta?> build(
    DeltaId? id,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<AsyncValue<Delta?>, Delta?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Delta?>, Delta?>,
        AsyncValue<Delta?>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
