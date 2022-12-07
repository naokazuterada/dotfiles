#!/bin/sh
# --------------------------------------
# Goal:
#   submoduleをきちんと削除
#
# Reference:
#   https://qiita.com/k_yamashita/items/040c04f8798d2384806e
#
# --------------------------------------

git submodule deinit -f $1
git rm -f $1
rm -rf .git/modules/$1