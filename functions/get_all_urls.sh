#!/bin/bash
# --------------------------------------
# Goal:
#   - Get list of page urls from base_url
# Usage:
#   ./get_all_urls.sh {base_url}
# --------------------------------------

wget --spider -r $1 2>&1 | grep '^--' | awk '{ print $3 }'