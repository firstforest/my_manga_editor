// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_page_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(MangaPageViewModelNotifier)
const mangaPageViewModelNotifierProvider =
    MangaPageViewModelNotifierProvider._();

final class MangaPageViewModelNotifierProvider extends $AsyncNotifierProvider<
    MangaPageViewModelNotifier, MangaPageViewModel> {
  const MangaPageViewModelNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mangaPageViewModelNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mangaPageViewModelNotifierHash();

  @$internal
  @override
  MangaPageViewModelNotifier create() => MangaPageViewModelNotifier();

  @$internal
  @override
  $AsyncNotifierProviderElement<MangaPageViewModelNotifier, MangaPageViewModel>
      $createElement($ProviderPointer pointer) =>
          $AsyncNotifierProviderElement(pointer);
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
    final ref = this.ref as $Ref<AsyncValue<MangaPageViewModel>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<MangaPageViewModel>>,
        AsyncValue<MangaPageViewModel>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
