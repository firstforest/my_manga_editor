---
paths:
  - "lib/feature/**/view/**"
  - "lib/feature/**/page/**"
  - "lib/widgets/**"
  - "lib/theme/**"
---

# UI デザインの基本ルール

テーマの実体は [lib/theme/app_theme.dart](../../lib/theme/app_theme.dart)。

## 余白

- 余白（`SizedBox` の幅・高さ、`EdgeInsets`、`spacing` など）は **4 の倍数** にする。基本は 8 の倍数、詰めたいときに 4・12
- 欄と欄を仕切る 1px の線（カットの中のセリフとト書きの間など）は余白ではなく線なので、この限りでない

## 色

- `Colors.*` や `Color(0x...)` を画面のコードに直書きしない。`Theme.of(context).colorScheme` の役割か、`AppTokens.of(context)` から読む
- 補助の文字（ページ番号・件数・日付）は `onSurfaceVariant`、枠と線は `outlineVariant`、エラーは `error`、うまくいっている状態は `AppTokens.success`
- 差し色（`primary`）は、ボタン・選択中のタグ・入力中の欄の縁など、操作に関わるところにだけ使う

## 紙のメタファー

- 書ける場所（メモ・セリフ・ト書き・何でも書ける場所など）は、机に置いた紙として [PaperSheet](../../lib/widgets/paper_sheet.dart) で描く。角は直角、罫線色の細い縁、入力中は差し色の縁
- 1 枚の紙を欄に区切って使うとき（カットの中）は、中の欄は `outlined: false` にして縁を外側の紙に任せる
- 紙やカードに角丸を付けない。ボタン・チップなど触って操作する部品は Material の既定の丸みのままでよい

## 影

- 影は浮いているもの（ドラッグ中のもの・メニュー・ダイアログ）だけに付ける。置いてあるものは細い縁で区切る
