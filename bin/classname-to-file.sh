#!/usr/bin/env bash
#

for arg; do
  if [[ "$arg" == *.class ]]; then
    echo "$arg"
  else
    echo "$arg.class" | tr '.' '/'
  fi
done
