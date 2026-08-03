// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(allMangaList)
final allMangaListProvider = AllMangaListProvider._();

final class AllMangaListProvider extends $FunctionalProvider<
        AsyncValue<List<Manga>>, List<Manga>, Stream<List<Manga>>>
    with $FutureModifier<List<Manga>>, $StreamProvider<List<Manga>> {
  AllMangaListProvider._()
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
final mangaPageIdListProvider = MangaPageIdListFamily._();

final class MangaPageIdListProvider extends $FunctionalProvider<
        AsyncValue<List<MangaPageId>>,
        List<MangaPageId>,
        Stream<List<MangaPageId>>>
    with
        $FutureModifier<List<MangaPageId>>,
        $StreamProvider<List<MangaPageId>> {
  MangaPageIdListProvider._(
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
  MangaPageIdListFamily._()
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

@ProviderFor(onlineStatus)
final onlineStatusProvider = OnlineStatusProvider._();

final class OnlineStatusProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  OnlineStatusProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'onlineStatusProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$onlineStatusHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return onlineStatus(ref);
  }
}

String _$onlineStatusHash() => r'2ebc01d21f5bc1ecc40bc7e89f9dfd6cd17c12b5';

@ProviderFor(MangaNotifier)
final mangaProvider = MangaNotifierFamily._();

final class MangaNotifierProvider
    extends $StreamNotifierProvider<MangaNotifier, Manga?> {
  MangaNotifierProvider._(
      {required MangaNotifierFamily super.from,
      required MangaId super.argument})
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

String _$mangaNotifierHash() => r'56bea4728a39c3e371135c40de48701989c65cea';

final class MangaNotifierFamily extends $Family
    with
        $ClassFamilyOverride<MangaNotifier, AsyncValue<Manga?>, Manga?,
            Stream<Manga?>, MangaId> {
  MangaNotifierFamily._()
      : super(
          retry: null,
          name: r'mangaProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MangaNotifierProvider call(
    MangaId id,
  ) =>
      MangaNotifierProvider._(argument: id, from: this);

  @override
  String toString() => r'mangaProvider';
}

abstract class _$MangaNotifier extends $StreamNotifier<Manga?> {
  late final _$args = ref.$arg as MangaId;
  MangaId get id => _$args;

  Stream<Manga?> build(
    MangaId id,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Manga?>, Manga?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Manga?>, Manga?>,
        AsyncValue<Manga?>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

@ProviderFor(MangaPageNotifier)
final mangaPageProvider = MangaPageNotifierFamily._();

final class MangaPageNotifierProvider
    extends $StreamNotifierProvider<MangaPageNotifier, MangaPage> {
  MangaPageNotifierProvider._(
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

String _$mangaPageNotifierHash() => r'64b2c0f999dc7922548a778060644f1a63909430';

final class MangaPageNotifierFamily extends $Family
    with
        $ClassFamilyOverride<MangaPageNotifier, AsyncValue<MangaPage>,
            MangaPage, Stream<MangaPage>, MangaPageId> {
  MangaPageNotifierFamily._()
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
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MangaPage>, MangaPage>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<MangaPage>, MangaPage>,
        AsyncValue<MangaPage>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}

@ProviderFor(DeltaNotifier)
final deltaProvider = DeltaNotifierFamily._();

final class DeltaNotifierProvider
    extends $AsyncNotifierProvider<DeltaNotifier, Delta?> {
  DeltaNotifierProvider._(
      {required DeltaNotifierFamily super.from,
      required (
        MangaId,
        DeltaId,
      )
          super.argument})
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
        '$argument';
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

String _$deltaNotifierHash() => r'2f8d18b9f65f066aa26ddfcf1df435d4d7809531';

final class DeltaNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
            DeltaNotifier,
            AsyncValue<Delta?>,
            Delta?,
            FutureOr<Delta?>,
            (
              MangaId,
              DeltaId,
            )> {
  DeltaNotifierFamily._()
      : super(
          retry: null,
          name: r'deltaProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  DeltaNotifierProvider call(
    MangaId mangaId,
    DeltaId id,
  ) =>
      DeltaNotifierProvider._(argument: (
        mangaId,
        id,
      ), from: this);

  @override
  String toString() => r'deltaProvider';
}

abstract class _$DeltaNotifier extends $AsyncNotifier<Delta?> {
  late final _$args = ref.$arg as (
    MangaId,
    DeltaId,
  );
  MangaId get mangaId => _$args.$1;
  DeltaId get id => _$args.$2;

  FutureOr<Delta?> build(
    MangaId mangaId,
    DeltaId id,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Delta?>, Delta?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<Delta?>, Delta?>,
        AsyncValue<Delta?>,
        Object?,
        Object?>;
    return element.handleCreate(
        ref,
        () => build(
              _$args.$1,
              _$args.$2,
            ));
  }
}
