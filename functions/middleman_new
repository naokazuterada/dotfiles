#!/bin/sh
# --------------------------------------
# Goal:
#   middleman-templateをcheckoutして、新規サイトをサクッと作り始める
# --------------------------------------

app_name=$1

if [ -z $app_name ]; then
  echo "usage: middleman_new [app_name]"
  echo "[app_name]を指定して下さい"
elif [ -d $app_name ]; then
  echo "[ERROR] ディレクトリ[$app_name]が既に存在します"
else

  git clone git@github.com:naokazuterada/middleman-template.git $app_name
  cd $app_name

  git submodule init
  git submodule update

  bundle install --path=vendor/bundle --binstubs=vendor/bin

fi