# VPN Timer

VPN接続して指定時間後に自動切断するmacOSアプリ。

Dockに置いてワンクリックで起動できる。ターミナル不要。

## 使い方

1. 起動するとダイアログで接続時間を選択（10秒〜8時間）
2. VPNに自動接続
3. 画面右上にフローティングウィンドウが表示され、残り時間をリアルタイムでカウントダウン
4. 指定時間後にバックグラウンドで自動切断＆通知
5. HUDの「VPN を切断」ボタンで即時切断も可能
6. HUDを閉じてもタイマーは継続。再度アプリを起動するとHUDを再表示

## 起動方法

- **Dock**: Finderで `~/Applications/VPN Timer.app` をDockにドラッグ（右クリック > オプション > Dockに追加 で常駐）
- **Spotlight**: `Cmd + Space` → 「VPN Timer」
- **Launchpad**: アプリ一覧から選択

## ファイル構成

- `VPNTimer.applescript` — メインアプリのソース（時間選択・VPN接続・タイマー管理）
- `VPNTimerHUD.swift` — カウントダウンHUDウィンドウのソース
- `vpn-timer-hud` — HUDのコンパイル済みバイナリ

## ビルド

```bash
# HUDバイナリのコンパイル
swiftc -o vpn-timer-hud VPNTimerHUD.swift -framework Cocoa

# アプリのビルド
osacompile -o ~/Applications/VPN\ Timer.app VPNTimer.applescript
```

ソースを変更したら上記コマンドで再ビルドする。

## 初回セットアップ

### 1. メニューバーにVPNステータスを表示

システム設定 > VPN > 「メニューバーにVPNステータスを表示」をON

### 2. アクセシビリティ権限の許可

システム設定 > プライバシーとセキュリティ > アクセシビリティ で「applet」を許可する。

`osacompile` で作成したアプリは内部的に「applet」プロセスとして実行されるため、「VPN Timer」ではなく「applet」に権限を付与する必要がある。

## ターミナル版

`functions/vpn_timer` にターミナルから実行するシェルスクリプト版もある。fzfで時間選択し、フォアグラウンドでタイマーを実行する。
