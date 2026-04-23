# Figma Link

Figmaからリンクをコピーした際に付加される定型文を検出し、URLのみに変換するメニューバー常駐ツール。

## 例

Figma Dev Modeからリンクをコピーすると、以下のようなテキストがクリップボードに入る：

```
これらの1個のデザインをFigmaから実装して。
@https://www.figma.com/design/d48M6jy3QeOxQ52YiV8dP8/DANC?node-id=1951-48464&m=dev
```

figma-linkが起動中であれば、コピーした瞬間にダイアログが表示される：

```
┌─────────────────────────────────────┐
│  Figmaリンクを検出しました           │
│  URLのみに変換しますか？             │
│                                     │
│  https://www.figma.com/design/...   │
│                                     │
│    [ そのまま ]  [ クリーニング ]     │
└─────────────────────────────────────┘
```

「クリーニング」を選ぶと、クリップボードがURL部分のみに置き換わる：

```
https://www.figma.com/design/d48M6jy3QeOxQ52YiV8dP8/DANC?node-id=1951-48464&m=dev
```

## 使い方

```bash
figma-link start    # メニューバーアプリを起動（メニューバーに「Fig」と表示される）
figma-link stop     # 停止
figma-link status   # 動作状態を確認
figma-link build    # Swiftソースからビルド
figma-link help     # ヘルプを表示
```

メニューバーの「Fig」からも監視の一時停止・再開・終了が可能。

## Figmaアプリに連動した自動制御

Figmaアプリの起動・終了に合わせて、figma-linkを自動で起動・停止できます。

### セットアップ

LaunchAgentを登録する：

```bash
launchctl load ~/Library/LaunchAgents/com.terada.figma-link-watcher.plist
```

### 動作

- **Figmaアプリが起動** → figma-linkが自動で起動（メニューバーに「Fig」が表示される）
- **Figmaアプリが終了** → figma-linkが自動で停止
- **ログイン時** → 監視スクリプトが自動で起動
- **監視間隔** → 10秒ごとにFigmaの起動状態をチェック

### 管理コマンド

```bash
# 登録確認
launchctl list | grep figma

# 一時的に無効化
launchctl unload ~/Library/LaunchAgents/com.terada.figma-link-watcher.plist

# 再度有効化
launchctl load ~/Library/LaunchAgents/com.terada.figma-link-watcher.plist

# 完全に削除
launchctl unload ~/Library/LaunchAgents/com.terada.figma-link-watcher.plist
rm ~/Library/LaunchAgents/com.terada.figma-link-watcher.plist

# 監視スクリプトを手動実行（テスト用）
bash ~/.dotfiles/figma-link/watch-figma.sh
```

### ファイル

- `watch-figma.sh` — Figmaの起動状態を監視するスクリプト
- `~/Library/LaunchAgents/com.terada.figma-link-watcher.plist` — launchd エージェント設定

## ファイル構成

- `FigmaLink.swift` — メニューバーアプリのソース（Figmaアプリの起動・終了イベント監視機能搭載）
- `figma-link-menu` — コンパイル済みバイナリ
- `watch-figma.sh` — Figmaの起動状態を定期監視するスクリプト

CLIラッパーは `~/.dotfiles/functions/figma-link` にある。

## ビルド

```bash
figma-link build
# または直接:
swiftc -o figma-link-menu FigmaLink.swift -framework Cocoa
```

## 仕組み

### クリップボード監視（メニューバーアプリ）

- `NSPasteboard.general.changeCount`（整数カウンタ）を1秒間隔でチェック
- 変化があった場合のみクリップボード内容を読み取り、Figma定型文パターンに一致するか判定
- 一致した場合にダイアログを表示し、ユーザーの選択に応じてクリーニング

### Figmaアプリ起動・終了の自動検知

- `NSWorkspace.didLaunchApplicationNotification` / `didTerminateApplicationNotification` でイベント監視
- Figmaアプリ（Bundle ID: `com.figma.Desktop`）の起動・終了を検知
- 起動時 → 監視開始、終了時 → 監視停止（メニューバーアプリの制御）

### 自動起動スクリプト（launchd 監視）

- `watch-figma.sh` が10秒ごとにFigmaの起動状態をチェック
- Figmaが起動していて figma-link が停止中 → `figma-link start` を実行
- Figmaが停止していて figma-link が起動中 → `figma-link stop` を実行
