# 漫画制作用プロットエディター

漫画を描く際のアイデアメモからセリフ作成、ページごとの構成・ページ割りなどを一括管理できるエディターです。
ページ毎のセリフのみを[ClipStudioPaint](https://www.clipstudio.net/)
のストーリーエディター機能で読み込むことを想定してコピーする機能を持っています。

## 主な機能

- **作品全体のメモ領域**

    - 箇条書きでアイデアを整理したり、チェックボックスで TODO 管理が可能

- **ページ単位のメモ & セリフ入力**

    - ページごとに「描きたい内容のメモ」「セリフ」「ト書き」(セリフ以外の描写) を入力できます

- **ページの見開き表示 & 並び換え**

    - 見開き単位でページを確認可能
    - ページの順番をドラッグ & ドロップなどで簡単に並び替えられます

- **Export 機能**

    - 作成したプロットやセリフなどをエクスポートできます。
    - **ページ毎のセリフをコピーし、ClipStudio に貼り付け**られるため、実制作への移行がスムーズ

- **GUI ベースの使いやすい操作**
    - 直感的な画面操作でストレスなくプロット作成が可能

## 動作環境

以下で動作を確認しています

- Windows 11
- macOS Seqoia 15.2

## **インストール方法**

1. ソースコードをクローン
   ```bash
   git clone <リポジトリURL>
   ```
2. `mise i`
3. `flutter run`

[mise](https://mise.jdx.dev/)と[Flutter](https://docs.flutter.dev/get-started/install)
に関しては公式サイトをご参照ください。

---

## 使用方法 (Usage)

1. **新規作品の作成**

    - アプリを起動し、「新規作品作成」ボタンから作品情報を入力して開始。

2. **作品全体のメモ管理**

    - 作品全体で描きたい内容やストーリー概要を、作品全体メモ領域に整理。
    - TODO リストや箇条書きも活用しながらアイデアを蓄積。

3. **ページ単位の内容入力**

    - ページごとに「メモ」「セリフ」「ト書き」を入力。
    - ひき・めくりを意識しながらセリフ量やページ構成を調整。

4. **ページ割りのチェック**

    - 見開き表示でページを視覚的にチェック。
    - ページの並びが気になる場合はドラッグ & ドロップなどで順序を変更。

5. **エクスポート / クリップスタジオへのコピー**
    - 必要に応じて、全体またはページ単位の内容をエクスポート。
    - セリフをコピーしてクリップスタジオに貼り付けると、作業効率アップ。

## ライセンス (License)

本ソフトウェアは **MIT License** のもとで公開されています。詳細は [LICENSE](LICENSE) ファイルをご確認ください。
