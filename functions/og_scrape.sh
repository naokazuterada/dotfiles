#!/bin/bash
# --------------------------------------
# Goal:
#   - Facebook og data bulk scraping
# Usage:
#   ./og_scrape.sh {url} {url} {url} ...
# --------------------------------------

argv=("$@")
for i in `seq 1 $#`
do
  curl -d scrape=true -d id=${argv[$i-1]} https://graph.facebook.com/
done
