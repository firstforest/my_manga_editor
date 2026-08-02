// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 利用者が最後に閉じたお知らせの ID。
///
/// 端末ローカルに保存する。お知らせは「見逃さないこと」が大事で、
/// 端末をまたいで既読を同期する必要はない
/// (別の端末で開いたらもう一度見せてよい)。

@ProviderFor(DismissedNoticeId)
final dismissedNoticeIdProvider = DismissedNoticeIdProvider._();

/// 利用者が最後に閉じたお知らせの ID。
///
/// 端末ローカルに保存する。お知らせは「見逃さないこと」が大事で、
/// 端末をまたいで既読を同期する必要はない
/// (別の端末で開いたらもう一度見せてよい)。
final class DismissedNoticeIdProvider
    extends $AsyncNotifierProvider<DismissedNoticeId, String?> {
  /// 利用者が最後に閉じたお知らせの ID。
  ///
  /// 端末ローカルに保存する。お知らせは「見逃さないこと」が大事で、
  /// 端末をまたいで既読を同期する必要はない
  /// (別の端末で開いたらもう一度見せてよい)。
  DismissedNoticeIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dismissedNoticeIdProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dismissedNoticeIdHash();

  @$internal
  @override
  DismissedNoticeId create() => DismissedNoticeId();
}

String _$dismissedNoticeIdHash() => r'17206c405bd9479fa6cfda969e15b421080de9c8';

/// 利用者が最後に閉じたお知らせの ID。
///
/// 端末ローカルに保存する。お知らせは「見逃さないこと」が大事で、
/// 端末をまたいで既読を同期する必要はない
/// (別の端末で開いたらもう一度見せてよい)。

abstract class _$DismissedNoticeId extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<String?>, String?>,
        AsyncValue<String?>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

/// いま表示すべきお知らせ。出すものが無ければ null。
///
/// 既読判定が読み込み中の間は表示しない。
/// 一瞬出てすぐ消えるより、少し遅れて出るほうがましなため。

@ProviderFor(visibleNotice)
final visibleNoticeProvider = VisibleNoticeProvider._();

/// いま表示すべきお知らせ。出すものが無ければ null。
///
/// 既読判定が読み込み中の間は表示しない。
/// 一瞬出てすぐ消えるより、少し遅れて出るほうがましなため。

final class VisibleNoticeProvider
    extends $FunctionalProvider<AppNotice?, AppNotice?, AppNotice?>
    with $Provider<AppNotice?> {
  /// いま表示すべきお知らせ。出すものが無ければ null。
  ///
  /// 既読判定が読み込み中の間は表示しない。
  /// 一瞬出てすぐ消えるより、少し遅れて出るほうがましなため。
  VisibleNoticeProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'visibleNoticeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$visibleNoticeHash();

  @$internal
  @override
  $ProviderElement<AppNotice?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppNotice? create(Ref ref) {
    return visibleNotice(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppNotice? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppNotice?>(value),
    );
  }
}

String _$visibleNoticeHash() => r'a8d3aa2bf869cb9200cecd9dae8358a951c8f5cf';
