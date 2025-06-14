// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(mangaRepository)
const mangaRepositoryProvider = MangaRepositoryProvider._();

final class MangaRepositoryProvider
    extends $FunctionalProvider<MangaRepository, MangaRepository>
    with $Provider<MangaRepository> {
  const MangaRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mangaRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mangaRepositoryHash();

  @$internal
  @override
  $ProviderElement<MangaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MangaRepository create(Ref ref) {
    return mangaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MangaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $ValueProvider<MangaRepository>(value),
    );
  }
}

String _$mangaRepositoryHash() => r'd6a072abd46b12d0617c2ee0948cad9aa1e0f18a';

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
