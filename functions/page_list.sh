#!/bin/sh
# --------------------------------------
# Goal:
#   - Get list of page urls from base_url
# Usage:
#   page_list.sh {base_url}
# Example:
#   $ page_list.sh http://example.com
#   http://example.com
#   http://example.com/about
#   http://example.com/works
#   http://example.com/works/01/
#   http://example.com/works/02/
# --------------------------------------

wget --spider -r $1 2>&1 | grep '^--' | awk '{ print $3 }' | grep -vi '\.\(css\|js\|png\|gif\|jpg\|jpeg\|ico\|txt\)$'