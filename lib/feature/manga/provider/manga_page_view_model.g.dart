// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_page_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MangaPageViewModelNotifier)
const mangaPageViewModelProvider = MangaPageViewModelNotifierProvider._();

final class MangaPageViewModelNotifierProvider extends $AsyncNotifierProvider<
    MangaPageViewModelNotifier, MangaPageViewModel> {
  const MangaPageViewModelNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mangaPageViewModelProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mangaPageViewModelNotifierHash();

  @$internal
  @override
  MangaPageViewModelNotifier create() => MangaPageViewModelNotifier();
}

String _$mangaPageViewModelNotifierHash() =>
    r'39b77278b106b8d826218e4d07296a307143600b';

abstract class _$MangaPageViewModelNotifier
    extends $AsyncNotifier<MangaPageViewModel> {
  FutureOr<MangaPageViewModel> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<MangaPageViewModel>, MangaPageViewModel>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<MangaPageViewModel>, MangaPageViewModel>,
        AsyncValue<MangaPageViewModel>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
