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

## 自動起動

### 初回セットアップ

LaunchAgentのplistを `~/Library/LaunchAgents/` に配置して登録する：

```bash
cat > ~/Library/LaunchAgents/com.terada.figma-link.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.terada.figma-link</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/terada/.dotfiles/figma-link/figma-link-menu</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF
launchctl load ~/Library/LaunchAgents/com.terada.figma-link.plist
```

### 管理コマンド

```bash
# 自動起動を無効化
launchctl unload ~/Library/LaunchAgents/com.terada.figma-link.plist

# 自動起動を再度有効化
launchctl load ~/Library/LaunchAgents/com.terada.figma-link.plist

# 自動起動を完全に削除
launchctl unload ~/Library/LaunchAgents/com.terada.figma-link.plist
rm ~/Library/LaunchAgents/com.terada.figma-link.plist
```

## ファイル構成

- `FigmaLink.swift` — メニューバーアプリのソース
- `figma-link-menu` — コンパイル済みバイナリ

CLIラッパーは `functions/figma-link` にある。

## ビルド

```bash
figma-link build
# または直接:
swiftc -o figma-link-menu FigmaLink.swift -framework Cocoa
```

## 仕組み

- `NSPasteboard.general.changeCount`（整数カウンタ）を1秒間隔でチェック
- 変化があった場合のみクリップボード内容を読み取り、Figma定型文パターンに一致するか判定
- 一致した場合にダイアログを表示し、ユーザーの選択に応じてクリーニング
