import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_manga_editor/feature/auth/page/login_page.dart';
import 'package:my_manga_editor/feature/manga/page/manga_edit_page.dart';
import 'package:my_manga_editor/feature/manga/page/manga_grid_page.dart';
import 'package:my_manga_editor/feature/manga/page/manga_select_page.dart';
import 'package:my_manga_editor/feature/splash/page/splash_page.dart';
import 'package:my_manga_editor/feature/update_gate/page/update_required_page.dart';
import 'package:my_manga_editor/feature/update_gate/provider/update_gate_provider.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/auth_repository.dart';

part 'router.g.dart';

const _rootRoute = '/';
const _updateRoute = '/update-required';
const _loginRoute = '/login';
const _homeRoute = '/manga';

/// redirect の行き先を決める。
///
/// GoRouter や Firebase に依存しない純粋関数として切り出してある
/// (この判定を間違えると画面が出ないので、テストで固定したい)。
///
/// 戻り値が null なら現在地に留まる。
@visibleForTesting
String? resolveRedirect({
  required bool needsUpdate,
  required bool authLoading,
  required bool isLoggedIn,
  required String location,
}) {
  // バージョンゲートを認証より先に評価する。旧ビルドがキャッシュされて
  // ログイン自体が動かない状況でも、更新案内までは出せるようにするため。
  if (needsUpdate) return location == _updateRoute ? null : _updateRoute;
  if (location == _updateRoute) return _rootRoute;

  // 認証状態が確定するまでは `/` (SplashPage) で待つ。
  if (authLoading) return null;

  if (!isLoggedIn) return location == _loginRoute ? null : _loginRoute;

  // `/` は行き先が決まるまでの中継地点なので、確定したら必ず送り出す。
  // ここで留めると SplashPage が永久に表示される。
  if (location == _loginRoute || location == _rootRoute) return _homeRoute;
  return null;
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final authNotifier = ValueNotifier<AsyncValue<Object?>>(const AsyncLoading());
  ref.listen(authStateStreamProvider, (_, next) {
    authNotifier.value = next;
  });
  ref.onDispose(authNotifier.dispose);

  // 更新必須状態が変わったら router を再評価させる。
  final updateNotifier = ValueNotifier<bool>(ref.read(updateRequiredProvider));
  ref.listen(updateRequiredProvider, (_, next) {
    updateNotifier.value = next;
  });
  ref.onDispose(updateNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: Listenable.merge([authNotifier, updateNotifier]),
    redirect: (context, state) {
      final authState = ref.read(authStateStreamProvider);
      return resolveRedirect(
        needsUpdate: ref.read(updateRequiredProvider),
        authLoading: authState.isLoading,
        isLoggedIn: authState.hasValue && authState.value != null,
        location: state.matchedLocation,
      );
    },
    routes: [
      // ルート URL を開いたときの着地点。redirect が行き先を決めるまでの待機画面。
      // Flutter Web は hash 戦略なので、`https://.../` を開くとここに来る。
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/update-required',
        builder: (context, state) => const UpdateRequiredPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/manga',
        builder: (context, state) => const MangaSelectPage(),
        routes: [
          GoRoute(
            path: ':mangaId',
            builder: (context, state) {
              final mangaId = MangaId(state.pathParameters['mangaId']!);
              return MangaEditPage(mangaId: mangaId);
            },
            routes: [
              GoRoute(
                path: 'grid',
                builder: (context, state) {
                  final mangaId = MangaId(state.pathParameters['mangaId']!);
                  return MangaGridPage(mangaId: mangaId);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
