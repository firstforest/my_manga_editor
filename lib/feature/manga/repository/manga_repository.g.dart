// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mangaRepository)
const mangaRepositoryProvider = MangaRepositoryProvider._();

final class MangaRepositoryProvider extends $FunctionalProvider<MangaRepository,
    MangaRepository, MangaRepository> with $Provider<MangaRepository> {
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
      providerOverride: $SyncValueProvider<MangaRepository>(value),
    );
  }
}

String _$mangaRepositoryHash() => r'c46f468b4ed50bdb9b1da3faacd0fa7c2d97d035';
