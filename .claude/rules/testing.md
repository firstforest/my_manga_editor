---
paths:
  - "test/**"
  - "local_package/**/test/**"
---

# Testing

## 何を差し替えるか (レイヤーごと)

| テスト対象 | 差し替えるもの | 例 |
|---|---|---|
| Widget / Notifier / Provider (`test/feature/`) | `MangaRepository` を手書きの Fake にして `mangaRepositoryProvider.overrideWithValue` で渡す。Provider 単位の入力は `xxxProvider.overrideWith` | [copy_page_dialogues_test.dart](../../test/feature/manga/view/copy_page_dialogues_test.dart), [tag_providers_test.dart](../../test/feature/manga/provider/tag_providers_test.dart) |
| Repository (`my_manga_editor_data/test/repository/`) | `FirebaseService` / `AuthService` / `ConnectivityService` を mockito の `@GenerateNiceMocks` で | [manga_repository_tags_test.dart](../../local_package/my_manga_editor_data/test/repository/manga_repository_tags_test.dart) |
| Service (`my_manga_editor_data/test/service/`) | Firestore は `FakeFirebaseFirestore`、`FirebaseAuth` / `User` は mockito。書き込み結果は実際のドキュメントを読んで確かめる | [firebase_service_tags_test.dart](../../local_package/my_manga_editor_data/test/service/firebase_service_tags_test.dart) |
| スキーマ移行 (`test/data_migration/`) | `FakeFirebaseFirestore` に fixture の生ドキュメントを書いて読み戻す | [schema_version_fixture_test.dart](../../test/data_migration/schema_version_fixture_test.dart) |

- Repository の Fake は `class _FakeMangaRepository extends Fake implements MangaRepository` とし、テストが使うメソッドだけ override する。どのメソッドを使うかをクラスの上にコメントで書く
- 失敗系は別の Fake (`_FailingMangaRepository` など) を作り、`Stream.error` や例外で再現する
- mockito の生成ファイル (`*.mocks.dart`) は `@GenerateNiceMocks` を変えたら `build_runner` で再生成する ([code-generation.md](./code-generation.md))

## ProviderContainer

- テスト (または `setUp`) ごとに新しく作り、`addTearDown(container.dispose)` で破棄する
- テスト内で作った `StreamController` も `addTearDown` で閉じる

## Widget テスト

- Quill エディタを含む Widget (`MangaPageWidget` など) は重いので、検証したい導線 (ボタン → SnackBar など) だけを持つ最小の画面を `_host(...)` として組み、`ProviderScope` の overrides で依存を渡す。何を検証していないかをコメントに書く
- Quill を含む画面をそのまま pump するときは `FlutterQuillLocalizations.localizationsDelegates` を `MaterialApp` に渡す

## スキーマ変更

- 変更**前**の版の生ドキュメントを `test/data_migration/fixtures/<model>/` に JSON で足す (`v<N>_<状態>.json`)。手順の全体は [data-layer.md](./data-layer.md) の「Schema Migration」
