---
name: verify
description: 変更したパッケージの analyze・test・コード生成の漏れをまとめて確認する。コミットする前、PR を作る前、「確認して」「テスト通る？」「CI 通りそう？」と聞かれたときに使う。
---

# verify

コミット・PR の前に、CI (`.github/workflows/ci.yml`) で落ちる変更を手元で止める。

## 1. 変更範囲を把握する

```bash
git diff --name-only origin/develop...HEAD
git diff --name-only HEAD
git ls-files --others --exclude-standard
```

3 つの出力を合わせたファイル一覧から、確認するパッケージを決める。

| 変更ファイルのパス | パッケージ |
|---|---|
| `lib/`, `test/`, `pubspec.yaml` | ルート (`.`) |
| `local_package/my_manga_editor_data/` | データ層 |
| `local_package/my_manga_editor_common/` | 共通 |

データ層・共通はルートから import されているので、そのどちらかを変えたらルートも確認する。
`.dart` も `pubspec.yaml` も変えていなければ、何もせず「確認不要」と報告して終わる。

## 2. コード生成の漏れを直す

変更した `.dart` に `@freezed` / `@riverpod` / `@Riverpod(` / `@JsonSerializable` / `@GenerateNiceMocks`
が含まれるか、`part '*.g.dart'` / `part '*.freezed.dart'` を持つなら、そのパッケージで

```bash
dart run build_runner build -d
```

を実行する ([.claude/rules/code-generation.md](../../rules/code-generation.md))。
実行後に生成ファイルの差分が出たら、生成し忘れていたということ。差分をコミット対象に含め、報告に書く。

## 3. analyze と test

対象パッケージごとに、そのディレクトリで実行する (`flutter analyze` / `flutter test` はカレントパッケージしか見ない)。

```bash
flutter analyze
flutter test
```

失敗したら原因を直して再実行する。直すときの禁止事項:

- テストを削除する・skip する・期待値を実装に合わせて書き換える、で通さない
- テストのほうが間違っていると判断したら、直さずにその根拠を報告してユーザーに判断を仰ぐ

## 4. 利用者向けの記録

`lib/` の変更が利用者から見える振る舞いを変えているのに、`CHANGELOG.md` の `## [Unreleased]` が
更新されていなければ指摘する ([書き方](../../../docs/release.md#リリースノートを書く))。
失敗扱いにはしない。

## 5. 報告

次の形で報告する。**コマンドの出力を見ずに「通った」と書かない**。

```
| 確認 | パッケージ | 結果 |
|---|---|---|
| build_runner | data | 差分なし |
| analyze | root | No issues found |
| test | root | All tests passed (114) |
| CHANGELOG | - | 追記済み |
```

失敗が残っている場合は、失敗したコマンドとエラー出力の要点を添える。
