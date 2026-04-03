import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:my_manga_editor/feature/auth/page/login_page.dart';
import 'package:my_manga_editor/feature/manga/page/manga_edit_page.dart';
import 'package:my_manga_editor/feature/manga/page/manga_grid_page.dart';
import 'package:my_manga_editor/feature/manga/page/manga_select_page.dart';
import 'package:my_manga_editor/feature/setting/page/setting_page.dart';
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

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateStreamProvider);
      if (authState.isLoading) return null;

      final isLoggedIn = authState.hasValue && authState.value != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MangaSelectPage(),
      ),
      GoRoute(
        path: '/manga/:mangaId',
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
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingPage(),
      ),
    ],
  );
}
