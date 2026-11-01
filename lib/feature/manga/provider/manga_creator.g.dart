// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_creator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 作品の新規作成。状態は持たない。
///
/// 画面は listen せずに notifier を読んで [create] を呼ぶ。autoDispose だと
/// 書き込みを待つ間に破棄されて、続きで ref を使えなくなるので keepAlive にする。

@ProviderFor(MangaCreator)
final mangaCreatorProvider = MangaCreatorProvider._();

/// 作品の新規作成。状態は持たない。
///
/// 画面は listen せずに notifier を読んで [create] を呼ぶ。autoDispose だと
/// 書き込みを待つ間に破棄されて、続きで ref を使えなくなるので keepAlive にする。
final class MangaCreatorProvider extends $NotifierProvider<MangaCreator, void> {
  /// 作品の新規作成。状態は持たない。
  ///
  /// 画面は listen せずに notifier を読んで [create] を呼ぶ。autoDispose だと
  /// 書き込みを待つ間に破棄されて、続きで ref を使えなくなるので keepAlive にする。
  MangaCreatorProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mangaCreatorProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mangaCreatorHash();

  @$internal
  @override
  MangaCreator create() => MangaCreator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$mangaCreatorHash() => r'8c8c5b5fb3abdf48a9caff5047ced74b6c22d330';

/// 作品の新規作成。状態は持たない。
///
/// 画面は listen せずに notifier を読んで [create] を呼ぶ。autoDispose だと
/// 書き込みを待つ間に破棄されて、続きで ref を使えなくなるので keepAlive にする。

abstract class _$MangaCreator extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
