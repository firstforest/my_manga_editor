// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clipboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// システムクリップボード。使えない環境 (Firefox など) では null になる。
///
/// `SystemClipboard.instance` を直接触るとテストから差し替えられないので、
/// provider 経由で取得する。

@ProviderFor(clipboardWriter)
final clipboardWriterProvider = ClipboardWriterProvider._();

/// システムクリップボード。使えない環境 (Firefox など) では null になる。
///
/// `SystemClipboard.instance` を直接触るとテストから差し替えられないので、
/// provider 経由で取得する。

final class ClipboardWriterProvider extends $FunctionalProvider<
    ClipboardWriter?,
    ClipboardWriter?,
    ClipboardWriter?> with $Provider<ClipboardWriter?> {
  /// システムクリップボード。使えない環境 (Firefox など) では null になる。
  ///
  /// `SystemClipboard.instance` を直接触るとテストから差し替えられないので、
  /// provider 経由で取得する。
  ClipboardWriterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'clipboardWriterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$clipboardWriterHash();

  @$internal
  @override
  $ProviderElement<ClipboardWriter?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClipboardWriter? create(Ref ref) {
    return clipboardWriter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClipboardWriter? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClipboardWriter?>(value),
    );
  }
}

String _$clipboardWriterHash() => r'16fcd37f9fcea85e278febe82f87933f25cdd260';
