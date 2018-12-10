#!/bin/bash

cd "$(dirname "$0")"

set -e

info() {
  echo -e "\033[34m$@\033[m" # blue
}

warn() {
  echo -e "\033[33m$@\033[m" # yellow
}

error() {
  echo -e "\033[31m$@\033[m" # red
}

info "Enable dotfile, make symbolic link to '${HOME}' directory"
rake setup

# zsh tools
info "Install zsh tools"
./zsh/install-tools.sh


info "Link Sublime Text"
ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/

info "Link Sublime Text - User Packages"
ln -s "/Users/terada/Karappo Inc. Dropbox/Terada Naokazu/AppSync/Sublime Text 3/Packages/User" "~/Library/Application Support/Sublime Text 3/Packages/User"

info "Link SourceTree"
ln -s /Applications/SourceTree.app/Contents/Resources/stree /usr/local/bin/
