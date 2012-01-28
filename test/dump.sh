#!/usr/bin/env bash
#

# jrun_auto_args=1
. jrun.sh
jrun-init-args "$@"
set -- "${jrun_args[@]}"

# for arg in "$jrun_args"; do
for arg in "${jrun_args[@]}"; do
# for arg; do  
  cp-find-class "$arg"
done
