#!/bin/sh
# --------------------------------------
# Goal:
#   - グローバルにRailsをインストールせずに、Bundlerを使ってプロジェクトディレクトリにRails:newする
#   - git init & gitignore
#
# Dependencies:
#   - bundler (installed global)
#
# Usage:
#   rails_new [APPNAME]
#
# TODO:
#   - railsと依存のgemを2回インストールしているので無駄かも。最初にDLしたものをコピーしてうまくいくだろうか？
# --------------------------------------

app_name=$1

if [ -z $app_name ]; then
  echo "usage: rails_new [app_name]"
  echo "[app_name]を指定して下さい"
elif [ -d $app_name ]; then
  echo "[ERROR] ディレクトリ[$app_name]が既に存在します"
else

  mkdir -p $app_name
  cd $app_name

  bundle init
  echo 'gem "rails"' >> Gemfile
  bundle install --path=vendor/bundle --binstubs=vendor/bin
  rm ./Gemfile
  bundle exec rails new . --skip-bundle
  bundle install --path=vendor/bundle --binstubs=vendor/bin

  # git ---------
  # git関係をやりたくない場合はここを消してください
  git init
  rm .gitignore

  cat << EOT >> .gitignore
*.DS_Store
*.rbc
*.sassc
/.bundle
/brakeman.html
/db/*.sqlite3
/log/*.log
/vendor/*
/log/*
/tmp/*
/db/*.sqlite3
/public/system/*
/public/uploads/*
/coverage/
/spec/tmp/*
.sass-cache
.rspec
.project
capybara-*.html
EOT

  git commit -a -m 'Initialize with rails (auto commit by rails_new)'
  # /git ---------

fi