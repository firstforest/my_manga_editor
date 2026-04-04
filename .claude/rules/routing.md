---
paths:
  - "lib/router.dart"
  - "lib/feature/**/page/**"
---

# Routing (go_router)

Defined in `lib/router.dart` as a `@Riverpod(keepAlive: true)` provider.

## Routes
```
/login                    → LoginPage
/manga                    → MangaSelectPage (kanban board)
/manga/:mangaId           → MangaEditPage
/manga/:mangaId/grid      → MangaGridPage
/settings                 → SettingPage
```

## Auth Guard
- `authStateStreamProvider` を監視し、未認証ユーザーを `/login` にリダイレクト
- ログイン済みで `/login` にアクセスした場合は `/manga` にリダイレクト

## Path Parameters
- `mangaId` は `MangaId(state.pathParameters['mangaId']!)` で取得
