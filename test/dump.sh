#!/usr/bin/env bash
#

# jutils_auto_args=1
. jutils.sh
jutils-init-args "$@"
set -- "${jutils_args[@]}"

# for arg in "$jutils_args"; do
for arg in "${jutils_args[@]}"; do
# for arg; do  
  cp-find-class "$arg"
done
