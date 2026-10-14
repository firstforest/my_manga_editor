// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 全作品に付いているタグを平坦化し、重複を除いて昇順に並べたもの。
///
/// タグは独立したエンティティを持たないので、「存在するタグ」はここで導出する。

@ProviderFor(TagList)
final tagListProvider = TagListProvider._();

/// 全作品に付いているタグを平坦化し、重複を除いて昇順に並べたもの。
///
/// タグは独立したエンティティを持たないので、「存在するタグ」はここで導出する。
final class TagListProvider extends $NotifierProvider<TagList, List<String>> {
  /// 全作品に付いているタグを平坦化し、重複を除いて昇順に並べたもの。
  ///
  /// タグは独立したエンティティを持たないので、「存在するタグ」はここで導出する。
  TagListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagListHash();

  @$internal
  @override
  TagList create() => TagList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$tagListHash() => r'ba0cde597d4628b2bf964e11ba659091ff35b46d';

/// 全作品に付いているタグを平坦化し、重複を除いて昇順に並べたもの。
///
/// タグは独立したエンティティを持たないので、「存在するタグ」はここで導出する。

abstract class _$TagList extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<String>, List<String>>,
        List<String>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// 作品一覧の絞り込み状態。アプリ起動中のみ保持し、永続化しない。

@ProviderFor(TagFilterNotifier)
final tagFilterProvider = TagFilterNotifierProvider._();

/// 作品一覧の絞り込み状態。アプリ起動中のみ保持し、永続化しない。
final class TagFilterNotifierProvider
    extends $NotifierProvider<TagFilterNotifier, TagFilter> {
  /// 作品一覧の絞り込み状態。アプリ起動中のみ保持し、永続化しない。
  TagFilterNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagFilterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagFilterNotifierHash();

  @$internal
  @override
  TagFilterNotifier create() => TagFilterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagFilter>(value),
    );
  }
}

String _$tagFilterNotifierHash() => r'cca0dafc0ea87df86a8a4457961865b10b20db33';

/// 作品一覧の絞り込み状態。アプリ起動中のみ保持し、永続化しない。

abstract class _$TagFilterNotifier extends $Notifier<TagFilter> {
  TagFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TagFilter, TagFilter>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TagFilter, TagFilter>, TagFilter, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// 作品一覧を現在の絞り込み条件で絞ったもの。
///
/// Firestore へ追加のクエリは投げず、購読済みの一覧をクライアント側で filter する。

@ProviderFor(filteredMangaList)
final filteredMangaListProvider = FilteredMangaListProvider._();

/// 作品一覧を現在の絞り込み条件で絞ったもの。
///
/// Firestore へ追加のクエリは投げず、購読済みの一覧をクライアント側で filter する。

final class FilteredMangaListProvider
    extends $FunctionalProvider<List<Manga>, List<Manga>, List<Manga>>
    with $Provider<List<Manga>> {
  /// 作品一覧を現在の絞り込み条件で絞ったもの。
  ///
  /// Firestore へ追加のクエリは投げず、購読済みの一覧をクライアント側で filter する。
  FilteredMangaListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'filteredMangaListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredMangaListHash();

  @$internal
  @override
  $ProviderElement<List<Manga>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<Manga> create(Ref ref) {
    return filteredMangaList(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Manga> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Manga>>(value),
    );
  }
}

String _$filteredMangaListHash() => r'd803301c1aa43d6468adccab7a1057b92b5eac29';
