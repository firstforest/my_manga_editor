import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:super_clipboard/super_clipboard.dart';

part 'clipboard_provider.g.dart';

/// システムクリップボード。使えない環境 (Firefox など) では null になる。
///
/// `SystemClipboard.instance` を直接触るとテストから差し替えられないので、
/// provider 経由で取得する。
@riverpod
ClipboardWriter? clipboardWriter(Ref ref) => SystemClipboard.instance;
