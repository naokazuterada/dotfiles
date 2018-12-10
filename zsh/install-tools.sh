#!/bin/bash

info() {
    echo -e "\033[34m$@\033[m" # blue
}

warn() {
    echo -e "\033[33m$@\033[m" # yellow
}

error() {
    echo -e "\033[31m$@\033[m" # red
}

unset https_proxy

if [[ ! -d ~/.zprezto ]]; then
  info "Install zprezto"
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
  setopt EXTENDED_GLOB
  for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md\(.N\); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
  done
fi

# if [[ ! -d ~/.zjump ]]; then
#     info "Install z"
#     git clone https://github.com/rupa/z.git ~/.zjump
# fi

if ! type wget >/dev/null 2>&1; then
  info "Install wget"
  brew install wget
fi

if ! type gibo >/dev/null 2>&1; then
  info "Install gibo"
  brew install gibo
  gibo -u
fi

if ! type shellcheck >/dev/null 2>&1; then
  info "Install shellcheck"
  brew install shellcheck
fi

if ! type peco >/dev/null 2>&1; then
  info "Install peco"
  brew install peco
fi

if ! type jq >/dev/null 2>&1; then
  info "Install jq"
  brew install jq
fi

if ! type ndenv >/dev/null 2>&1; then
  info "Install ndenv"
  brew install ndenv
fi
