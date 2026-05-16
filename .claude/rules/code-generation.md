---
paths:
  - "lib/**/*.dart"
  - "local_package/**/*.dart"
---

# Code Generation (build_runner)

`@freezed` クラス / `@riverpod` プロバイダー / `*.g.dart` / `*.freezed.dart` を import するファイルを変更したら、対応するパッケージで `build_runner` を実行する必要がある。

## 2 つの build_runner チェーン

ルートパッケージとデータ層パッケージは**別々に** `build_runner` を持つ。変更したファイルがあるパッケージで実行する。

```bash
# Root package: lib/ 配下の @riverpod / @freezed
dart run build_runner build -d

# Data package: local_package/my_manga_editor_data 配下の @freezed / @riverpod / JsonSerializable
cd local_package/my_manga_editor_data && dart run build_runner build -d && cd -
```

両方変更した場合は両方実行する。ルート側の `build_runner` はデータ層パッケージを処理しない。

## 実行タイミング

以下のいずれかを変更したら必ず実行する：

- `@freezed` を付けたクラス
- `@riverpod` / `@Riverpod(...)` を付けた関数・クラス
- `@JsonSerializable` を付けたクラス
- `*.g.dart` / `*.freezed.dart` を import / part しているファイル
