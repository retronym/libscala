#!/usr/bin/env bash
#

# jbash_auto_args=1
. jbash.sh
jbash-init-args "$@"
set -- "${jbash_args[@]}"

# for arg in "$jbash_args"; do
for arg in "${jbash_args[@]}"; do
# for arg; do  
  cp-find-class "$arg"
done
