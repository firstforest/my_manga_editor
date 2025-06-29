// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_comment_area.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(mangaDescription)
const mangaDescriptionProvider = MangaDescriptionFamily._();

final class MangaDescriptionProvider
    extends $FunctionalProvider<AsyncValue<String>, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  const MangaDescriptionProvider._(
      {required MangaDescriptionFamily super.from,
      required MangaId super.argument})
      : super(
          retry: null,
          name: r'mangaDescriptionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mangaDescriptionHash();

  @override
  String toString() {
    return r'mangaDescriptionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    final argument = this.argument as MangaId;
    return mangaDescription(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MangaDescriptionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$mangaDescriptionHash() => r'af379cc6a3925f9f2d123e0fc8dfa9f2130970c0';

final class MangaDescriptionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String>, MangaId> {
  const MangaDescriptionFamily._()
      : super(
          retry: null,
          name: r'mangaDescriptionProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  MangaDescriptionProvider call(
    MangaId mangaId,
  ) =>
      MangaDescriptionProvider._(argument: mangaId, from: this);

  @override
  String toString() => r'mangaDescriptionProvider';
}

@ProviderFor(AiCommentList)
const aiCommentListProvider = AiCommentListFamily._();

final class AiCommentListProvider
    extends $NotifierProvider<AiCommentList, List<AiComment>> {
  const AiCommentListProvider._(
      {required AiCommentListFamily super.from,
      required MangaId super.argument})
      : super(
          retry: null,
          name: r'aiCommentListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$aiCommentListHash();

  @override
  String toString() {
    return r'aiCommentListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AiCommentList create() => AiCommentList();

  @$internal
  @override
  $NotifierProviderElement<AiCommentList, List<AiComment>> $createElement(
          $ProviderPointer pointer) =>
      $NotifierProviderElement(pointer);

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AiComment> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $ValueProvider<List<AiComment>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AiCommentListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$aiCommentListHash() => r'aa5b76b17cf3164d24094fa002838bc8ea412be8';

final class AiCommentListFamily extends $Family
    with
        $ClassFamilyOverride<AiCommentList, List<AiComment>, List<AiComment>,
            List<AiComment>, MangaId> {
  const AiCommentListFamily._()
      : super(
          retry: null,
          name: r'aiCommentListProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AiCommentListProvider call(
    MangaId mangaId,
  ) =>
      AiCommentListProvider._(argument: mangaId, from: this);

  @override
  String toString() => r'aiCommentListProvider';
}

abstract class _$AiCommentList extends $Notifier<List<AiComment>> {
  late final _$args = ref.$arg as MangaId;
  MangaId get mangaId => _$args;

  List<AiComment> build(
    MangaId mangaId,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref as $Ref<List<AiComment>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<AiComment>>, List<AiComment>, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
