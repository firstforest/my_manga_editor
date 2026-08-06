import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:markdown_quill/markdown_quill.dart';
import 'package:my_manga_editor_common/delta_text.dart';
import 'package:my_manga_editor_common/logger.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/manga_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manga_providers.g.dart';

@riverpod
Stream<List<Manga>> allMangaList(Ref ref) {
  return ref.watch(mangaRepositoryProvider).watchAllMangaList();
}

@riverpod
Stream<List<MangaPageId>> mangaPageIdList(Ref ref, MangaId mangaId) {
  return ref.watch(mangaRepositoryProvider).watchAllMangaPageIdList(mangaId);
}

@riverpod
Stream<bool> onlineStatus(Ref ref) {
  return ref.watch(mangaRepositoryProvider).watchOnlineStatus();
}

@riverpod
class MangaNotifier extends _$MangaNotifier {
  @override
  Stream<Manga?> build(MangaId id) {
    final repo = ref.watch(mangaRepositoryProvider);
    return repo.getMangaStream(id);
  }

  Future<void> addNewPage(int index) async {
    final repo = ref.watch(mangaRepositoryProvider);
    await repo.createNewMangaPage(id);
    final pageIdList = await repo.watchAllMangaPageIdList(id).first;
    await reorderPage(pageIdList, pageIdList.length - 1, index);
  }

  // newIndex は ReorderableListView.onReorderItem と同様に
  // oldIndex の要素を取り除いた後のリストに対する挿入位置を受け取る
  Future<void> reorderPage(
      List<MangaPageId> pageIdList, int oldIndex, int newIndex) async {
    final item = pageIdList.removeAt(oldIndex);
    pageIdList.insert(newIndex, item);
    ref.read(mangaRepositoryProvider).reorderPages(id, pageIdList);
  }

  Future<void> updateName(String value) async {
    await ref.read(mangaRepositoryProvider).updateMangaName(id, value);
  }

  void delete() {
    ref.read(mangaRepositoryProvider).deleteManga(id);
  }

  void updateStartPage(MangaStartPage value) {
    ref.read(mangaRepositoryProvider).updateStartPage(id, value);
  }

  void updateStatus(MangaStatus status) {
    ref.read(mangaRepositoryProvider).updateMangaStatus(id, status);
  }

  /// 作品全体を Markdown ファイルとして書き出し、書き出した作品名を返す。
  ///
  /// 戻り値は画面の完了通知に使う。呼び出し側が `mangaProvider` を読み直すと
  /// まだ loading の場合に作品名が取れないため、ここで確定した名前を渡す。
  ///
  /// 失敗したときは logger.e に詳細を残したうえで例外をそのまま投げる
  /// (呼び出し側の画面で利用者に通知するため)。
  Future<String> download() async {
    final manga = await future;
    if (manga == null) {
      logger.e('書き出し対象の作品が見つかりません: ${id.id}');
      throw StateError('Manga not found: ${id.id}');
    }
    logger.d('download ${manga.name}');
    try {
      final content =
          await ref.read(mangaRepositoryProvider).toMarkdown(manga.id);
      await FileSaver.instance.saveFile(
        name: 'komatto_${sanitizeFileName(manga.name)}',
        fileExtension: 'md',
        mimeType: MimeType.markdown,
        bytes: Uint8List.fromList(utf8.encode(content)),
      );
    } catch (e, stackTrace) {
      logger.e('作品の書き出しに失敗しました: ${manga.name}',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
    return manga.name;
  }
}

/// 作品名をファイル名に使える形に直す。
///
/// OS がファイル名に使えない `/ \ : * ? " < > |` と制御文字を `_` に置き換える。
/// 日本語や英数字はそのまま残す。
String sanitizeFileName(String name) =>
    name.replaceAll(RegExp(r'[/\\:*?"<>|\x00-\x1f\x7f]'), '_');

@riverpod
class MangaPageNotifier extends _$MangaPageNotifier {
  @override
  Stream<MangaPage> build(MangaPageId pageId) {
    final repo = ref.watch(mangaRepositoryProvider);
    return repo.getMangaPageStream(pageId).where((e) => e != null).cast();
  }

  void delete() {
    ref.read(mangaRepositoryProvider).deleteMangaPage(pageId);
  }

  Future<void> addSceneUnit() async {
    final page = await future;
    await ref
        .read(mangaRepositoryProvider)
        .addSceneUnit(page.mangaId, pageId);
  }

  Future<void> removeSceneUnit(int index) async {
    final page = await future;
    await ref
        .read(mangaRepositoryProvider)
        .removeSceneUnit(page.mangaId, pageId, index);
  }
}

@riverpod
class DeltaNotifier extends _$DeltaNotifier {
  @override
  Future<Delta?> build(MangaId mangaId, DeltaId id) async {
    if (id.id.isEmpty) {
      return null;
    }
    final repo = ref.read(mangaRepositoryProvider);
    final delta = await repo.getDeltaStream(mangaId, id).first;
    if (delta == null || delta.isEmpty) {
      return null;
    }
    return delta;
  }

  void updateDelta(Delta delta) {
    ref.read(mangaRepositoryProvider).saveDelta(mangaId, id, delta);
    state = AsyncValue.data(delta);
  }

  Future<String> exportPlainText() async {
    final delta = await future;
    return switch (delta) {
      Delta d when d.isNotEmpty => deltaToPlainText(d),
      _ => '',
    };
  }

  Future<String> exportMarkdown() async {
    final delta = await future;
    final deltaToMd = DeltaToMarkdown();
    return switch (delta) {
      Delta d when d.isNotEmpty => deltaToMd.convert(d),
      _ => '',
    };
  }
}
