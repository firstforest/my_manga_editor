import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_manga_editor/feature/app_notice/provider/app_notice_provider.dart';

/// アプリ全体の一番上にお知らせバナーを重ねる。`MaterialApp.builder` から使う。
///
/// 画面を問わず出すのは、事前告知を「アプリを開いている人」に確実に届けるため。
/// GitHub や X を見ていない利用者にも届く唯一の経路になる。
class AppNoticeScope extends StatelessWidget {
  const AppNoticeScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppNoticeBanner(),
        Expanded(child: child),
      ],
    );
  }
}

/// 本文表示領域の高さ上限。これを超える分はバナー内でスクロールして読む。
/// 4 行程度に相当し、下の編集画面を潰さない範囲に収めている。
const double _maxMessageHeight = 96;

/// お知らせ 1 件分のバナー。出すものが無ければ何も描画しない。
class AppNoticeBanner extends ConsumerWidget {
  const AppNoticeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notice = ref.watch(visibleNoticeProvider);
    if (notice == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.secondaryContainer,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Icon(
                Icons.campaign_outlined,
                color: theme.colorScheme.onSecondaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                // 編集画面を潰さないよう高さは抑えるが、切り捨てはしない。
                // 狭い画面では収まらないことがあり、ellipsis だと告知の後半
                // (「〜が表示されなくなります」など一番伝えたい部分) が黙って消える。
                // 本文の長さは scripts/config.mjs 側でも制限している。
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: _maxMessageHeight),
                  child: SingleChildScrollView(
                    child: Text(
                      notice.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => ref
                    .read(dismissedNoticeIdProvider.notifier)
                    .dismiss(notice.id),
                child: const Text('閉じる'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
