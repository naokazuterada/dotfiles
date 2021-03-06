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

if ! type brew >/dev/null 2>&1; then
  info "Install homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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

if ! type wp >/dev/null 2>&1; then
  info "Install wp-cli"
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  sudo mv wp-cli.phar /usr/local/bin/wp

  info "Enable wp-cli tab completions"
  curl -O https://raw.githubusercontent.com/wp-cli/wp-cli/v1.5.1/utils/wp-completion.bash
  chmod +x wp-completion.bash
  mkdir ~/bin
  mkdir ~/bin/wp-cli
  sudo mv wp-completion.bash ~/bin/wp-cli/wp-completion.bash
fi

if ! type subl >/dev/null 2>&1; then
  info "Link Sublime Text 3"
  ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl
fi

if ! type nkf >/dev/null 2>&1; then
  info "Install nkf"
  brew install nkf
fi

if ! type awscli >/dev/null 2>&1; then
  info "Install awscli"
  brew install awscli
fi

# anyenv =============
if ! type anyenv >/dev/null 2>&1; then
  info "Install anyenv"
  git clone https://github.com/riywo/anyenv ~/.anyenv
  # These lines are already written in zshrc
  # echo 'export PATH="$HOME/.anyenv/bin:$PATH"' >> ~/.your_profile
  # echo 'eval "$(anyenv init -)"' >> ~/.your_profile
  exec $SHELL -l
  echo ":::Please restart shel and execute following commands..."
  echo "anyenv install nodenv"
  echo "anyenv install phpenv"
  echo "anyenv install pyenv"
  echo "anyenv install rbenv"
fi
# /anyenv =============