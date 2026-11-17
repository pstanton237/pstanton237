#!/usr/bin/env bash
# README의 merged 마커 사이를 최근 머지된 외부 PR 5건으로 교체한다. GH_TOKEN 필요.
set -euo pipefail
user=pstanton237

list=$(gh api -X GET search/issues \
  -f q="author:$user is:pr is:merged -user:$user" -f sort=updated -f per_page=30 \
  --jq '.items | sort_by(.pull_request.merged_at) | reverse | .[:5][]
        | "- \(.repository_url | sub(".*/repos/"; "")): [\(.title)](\(.html_url)) · \(.pull_request.merged_at[:10])"')
[ -n "$list" ] || { echo "no merged PRs found" >&2; exit 1; }

LIST="$list" awk '
  /<!-- merged:start -->/ { print; print ENVIRON["LIST"]; skip=1; next }
  /<!-- merged:end -->/   { skip=0 }
  !skip
' README.md > README.md.tmp
mv README.md.tmp README.md
