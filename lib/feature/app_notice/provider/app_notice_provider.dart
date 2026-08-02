import 'package:my_manga_editor/feature/app_config/provider/app_config_provider.dart';
import 'package:my_manga_editor_data/my_manga_editor_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_notice_provider.g.dart';

/// 利用者が最後に閉じたお知らせの ID。
///
/// 端末ローカルに保存する。お知らせは「見逃さないこと」が大事で、
/// 端末をまたいで既読を同期する必要はない
/// (別の端末で開いたらもう一度見せてよい)。
@Riverpod(keepAlive: true)
class DismissedNoticeId extends _$DismissedNoticeId {
  static const _key = 'dismissedNoticeId';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  /// [id] のお知らせを閉じたことを記録する。
  Future<void> dismiss(String id) async {
    state = AsyncData(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
  }
}

/// いま表示すべきお知らせ。出すものが無ければ null。
///
/// 既読判定が読み込み中の間は表示しない。
/// 一瞬出てすぐ消えるより、少し遅れて出るほうがましなため。
@riverpod
AppNotice? visibleNotice(Ref ref) {
  final notice = ref.watch(appConfigProvider).asData?.value?.notice;
  if (notice == null) {
    return null;
  }
  final dismissed = ref.watch(dismissedNoticeIdProvider);
  if (!dismissed.hasValue) {
    return null;
  }
  return notice.id == dismissed.value ? null : notice;
}
