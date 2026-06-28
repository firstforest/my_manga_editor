import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_manga_editor/feature/auth/page/login_page.dart';
import 'package:my_manga_editor/feature/manga/page/manga_edit_page.dart';
import 'package:my_manga_editor/feature/manga/page/manga_grid_page.dart';
import 'package:my_manga_editor/feature/manga/page/manga_select_page.dart';
import 'package:my_manga_editor/feature/setting/page/setting_page.dart';
import 'package:my_manga_editor/feature/update_gate/page/update_required_page.dart';
import 'package:my_manga_editor/feature/update_gate/provider/update_gate_provider.dart';
import 'package:my_manga_editor_data/model/manga.dart';
import 'package:my_manga_editor_data/repository/auth_repository.dart';

part 'router.g.dart';

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
      // バージョンゲートを最優先で評価する。
      final needsUpdate = ref.read(updateRequiredProvider);
      final isUpdateRoute = state.matchedLocation == '/update-required';
      if (needsUpdate) {
        return isUpdateRoute ? null : '/update-required';
      }
      if (isUpdateRoute) return '/';

      final authState = ref.read(authStateStreamProvider);
      if (authState.isLoading) return null;

      final isLoggedIn = authState.hasValue && authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/manga';
      return null;
    },
    routes: [
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
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingPage(),
      ),
    ],
  );
}
