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
