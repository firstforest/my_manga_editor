---
paths:
  - "lib/router.dart"
  - "lib/feature/**/page/**"
---

# Routing (go_router)

Defined in `lib/router.dart` as a `@Riverpod(keepAlive: true)` provider.

## Routes
```
/                         → SplashPage (redirect が行き先を決めるまでの待機画面)
/update-required          → UpdateRequiredPage (最小バージョンゲート)
/login                    → LoginPage
/manga                    → MangaSelectPage (kanban board)
/manga/:mangaId           → MangaEditPage
/manga/:mangaId/grid      → MangaGridPage
```

**`/` のルートは消さないこと。** Flutter Web は hash 戦略 (`https://.../#/`) なので、
ルート URL を開いたときのロケーションは `/` になる。認証状態が確定するまで redirect は
`null` を返して `/` に留まるため、ここにルートが無いと利用者に「Page Not Found」が見える。

## Redirect の順序
1. **バージョンゲート**を最優先で評価する (認証より先)。旧ビルドがキャッシュされて
   ログイン自体が動かない状況でも更新案内を出せるようにするため
2. 認証状態がロード中は `null` を返し、`/` (SplashPage) で待つ
3. 未認証なら `/login`、ログイン済みで `/login` にいるなら `/manga` へ

## Path Parameters
- `mangaId` は `MangaId(state.pathParameters['mangaId']!)` で取得
