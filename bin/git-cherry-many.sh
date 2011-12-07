#!/usr/bin/env bash
#

set -e
cherry_head=".git/CHERRY_PICK_HEAD"

while read sha; do
  echo "Picking off $sha"
  git-cherry-pick-theirs $sha

  if [[ -e $cherry_head ]]; then
    echo "Failed: git adding."
    git add .
    git commit --allow-empty -C $(cat $cherry_head) || { echo "Failed: $?"; exit 1; }
  fi
done
