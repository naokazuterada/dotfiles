#!/bin/bash
# watch-figma.sh - Figmaアプリの起動・終了を監視し、figma-linkを自動制御

FIGMA_LINK_CMD="$HOME/.dotfiles/functions/figma-link"

# Figmaが起動中かチェック
is_figma_running() {
    # /Applications/Figma.app が実行中かどうかを確認
    lsof /Applications/Figma.app/Contents/MacOS/Figma > /dev/null 2>&1
    return $?
}

# figma-linkが起動中かチェック
is_figmalink_running() {
    pgrep -f "figma-link-menu" > /dev/null 2>&1
    return $?
}

# figma-link-menu 自体がNSWorkspaceでFigmaの起動・終了を監視しているため、
# このwatcherはfigma-link-menuが落ちていた場合の復旧のみを担う
if ! is_figmalink_running; then
    "$FIGMA_LINK_CMD" start > /dev/null 2>&1
fi
