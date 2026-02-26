# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## リポジトリ概要

macOS向けの個人dotfilesリポジトリ。シェル設定、Git設定、カスタム関数などを管理する。

## セットアップ

```bash
rake setup    # etc/ と zsh/ のシンボリックリンクを $HOME に作成
```

Rakefileが `etc/` 配下のファイルを `~/.ファイル名` として、`zsh/zshrc` を `~/.zshrc` としてシンボリックリンクする。

## 構造

- **`zsh/zshrc`** — メインのzsh設定。エイリアス、PATH設定、関数定義を含む。Zpreztoフレームワークを使用
- **`zsh/zshgit`** — Gitブランチをプロンプトに表示するための vcs_info 設定
- **`etc/`** — ドットファイル群（gitconfig, zpreztorc, gemrc, tigrc, rspec, gitignore_global）。Rakeで `~/.<ファイル名>` にシンボリックリンクされる
- **`functions/`** — カスタムシェル関数。PATHに追加済みでコマンドとして直接実行可能
  - `geppou` — screenpipe + git log から月報を生成しAIアプリに送信（bash）
  - `vpn_timer` — AppleScript経由でVPN接続/タイマー切断を管理（zsh）
- **`install.sh`** — 初回セットアップスクリプト。`rake setup` + ツールインストール
- **`zsh/install-tools.sh`** — Homebrew経由で依存ツール（peco, jq, gibo, shellcheck等）をインストール

## 開発時の注意

- シェル関数は `functions/` に配置すればPATH経由で実行可能になる（zshrcで `$HOME/.dotfiles/functions` をPATHに追加済み）
- `etc/` に設定ファイルを追加した場合、Rakefileの `cleans` 配列への追加は不要（`etc:link` タスクがglobで自動検出する）が、`rake clobber` で削除したい場合は追加が必要
- 言語環境管理は anyenv（rbenv, nodenv, phpenv, pyenv）を使用
- UIインタラクティブ選択には fzf と peco を使用（fzfが新しい関数での標準）
