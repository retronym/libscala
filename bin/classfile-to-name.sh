#!/usr/bin/env bash
#

for arg; do
  if [[ "$arg" == *.class ]]; then
    echo "${arg%.class}" | tr '/' '.' | sed -e 's/^[./]*//g'
  else
    echo "$arg"
  fi
done
