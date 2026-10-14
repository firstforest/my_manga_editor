import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/manga/provider/clipboard_provider.dart';
import 'package:my_manga_editor/feature/manga/provider/manga_providers.dart';
import 'package:my_manga_editor_common/logger.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:super_clipboard/super_clipboard.dart';

/// ページのセリフをクリップボードへ書き込んだ結果。
enum CopyPageDialoguesResult {
  /// クリップボードへ書き込んだ
  copied,

  /// コピーする本文が無かった (クリップボードは書き換えない)
  empty,

  /// 実行環境にクリップボードが無く、書き込めなかった
  unavailable,

  /// セリフの読み込み、またはクリップボードへの書き込み中にエラーが起きた
  failed,
}

/// ページ内の全カットのセリフをプレーンテキスト化し、
/// カットの順序を保ったまま空行区切りで連結する。
///
/// `ref` を使う処理は await をまたぐ前にまとめて始める。await の後に `ref` を
/// 触ると、その間に画面が閉じられていた場合に StateError になるため。
Future<String> buildPageDialoguesText(WidgetRef ref, MangaPage page) async {
  final pending = [
    for (final unit in page.sceneUnits)
      ref
          .read(deltaProvider(page.mangaId, unit.dialoguesDeltaId).notifier)
          .exportPlainText(),
  ];
  final texts = await Future.wait(pending);
  return texts.where((text) => text.isNotEmpty).join('\n\n');
}

/// ページのセリフをまとめてクリップボードへ書き込む。
Future<CopyPageDialoguesResult> copyPageDialogues(
  WidgetRef ref,
  MangaPage page,
) async {
  // クリップボードの取得も await より前に済ませる (buildPageDialoguesText と同じ理由)
  final clipboard = ref.read(clipboardWriterProvider);

  final String combined;
  try {
    combined = await buildPageDialoguesText(ref, page);
  } catch (e, stackTrace) {
    // Delta の読み込み失敗。ここで拾わないと Future が捨てられ、
    // ボタンを押しても何も起きない状態になる
    logger.e('セリフの読み込みに失敗しました', error: e, stackTrace: stackTrace);
    return CopyPageDialoguesResult.failed;
  }

  // 空の内容で既存のクリップボードを潰さない
  if (combined.isEmpty) {
    return CopyPageDialoguesResult.empty;
  }
  if (clipboard == null) {
    return CopyPageDialoguesResult.unavailable;
  }

  final item = DataWriterItem();
  item.add(Formats.plainText(combined));
  try {
    await clipboard.write([item]);
  } catch (e, stackTrace) {
    logger.e('セリフのコピーに失敗しました', error: e, stackTrace: stackTrace);
    return CopyPageDialoguesResult.failed;
  }
  return CopyPageDialoguesResult.copied;
}

/// セリフをコピーし、結果を SnackBar で伝える。
Future<void> copyPageDialoguesWithFeedback(
  BuildContext context,
  WidgetRef ref,
  MangaPage page,
  int pageIndex,
) async {
  final result = await copyPageDialogues(ref, page);
  if (!context.mounted) {
    return;
  }
  final message = switch (result) {
    CopyPageDialoguesResult.copied => 'Page $pageIndex をコピーしました',
    CopyPageDialoguesResult.empty => 'Page $pageIndex にコピーするセリフがありません',
    CopyPageDialoguesResult.unavailable ||
    CopyPageDialoguesResult.failed =>
      'Page $pageIndex のコピーに失敗しました',
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
