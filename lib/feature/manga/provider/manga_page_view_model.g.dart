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
    r'6e806e17d4fcdab6c85d202c896e6abdd3267688';

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
