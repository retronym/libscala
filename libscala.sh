#!/usr/bin/env bash
#
# libscala
# by extempore
#
# Source this file to find your scala world somewhat enhanced.
#

source "$(dirname $BASH_SOURCE)/etc/00boot"

export scalaGitRepo="$SCALA_SRC_HOME"
export scalaGitUrl="https://github.com/scala/scala"
export scalaSvnMap="$libscalaHome/data/scala-svn-to-sha1-map.txt"

# Source all the completions, functions, etc.
trySource "$libscalaHome/bash.d/"*
trySource "$libscalaHome/completion.d/"*
# trySource "$libscalaHome/jrun/jrun.d/"*

# Adding -XX: flags to java
complete -o default -F _java_with_jvm_opts java
# Adding -J-XX: flags to scala and friends
complete -o default -F _scala_with_jvm_opts fsc scalac scala pscalac pscala qscalac qscala scalac29 scala29 scalac3 scala3
# Adding rXXXX svn revision completion to some gh- commands
complete -F _scala_svn_rev_completion gh-commit gh-svn

# Complete on local git branches
alias gbr='git branch'
alias gco='git checkout'
complete -F _git_branch_local_only gbr gco

# Delete the cached bytecode disassemblies
alias git-javap-clean='git update-ref -d refs/notes/textconv/javap'
