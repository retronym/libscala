#!/usr/bin/env bash
#
# libscala
# by extempore
#
# Source this file to find your scala world somewhat enhanced.
#

[[ -d "$BASH_COMPLETION_DIR" ]] || [[ -d "$BASH_COMPLETION" ]] || [[ -d "$BASH_COMPLETION_COMPAT_DIR" ]] || {
  echo "This won't work without bash completion set up."
  return
}

[[ -d "$SCALA_SRC_HOME" ]] || {
  echo "Note: some features require \$SCALA_SRC_HOME be set to a checkout of scala trunk."
}

[[ -n "$LIBSCALA_HOME" ]] || export LIBSCALA_HOME="$(dirname $BASH_SOURCE)"

export PATH="$PATH:$LIBSCALA_HOME/bin"

export libscalaRoot="$(cd "$(dirname $BASH_SOURCE)" && pwd)"
[[ -f "$libscalaRoot/bash.d/boot" ]] && . "$libscalaRoot/bash.d/boot"

export libscalaBash="$libscalaRoot/bash.d"
export libscalaEtc="$libscalaRoot/etc"
export scalaGitRepo="$SCALA_SRC_HOME"
export scalaGitUrl="https://github.com/scala/scala"
export scalaSvnMap="$libscalaEtc/scala-svn-to-sha1-map.txt"
export scalaJiraUrl="http://issues.scala-lang.org"

# thanks for the easy transition git
# Can't use --no-edit because it isn't understood by anything
# prior to the version which changed merge behavior.
export GIT_MERGE_AUTOEDIT=no

# Source the extra completion and helper functions.
trySource scala-291 scala java github git-aliases git jira

# Adding -XX: flags to java
complete -o default -F _java_with_jvm_opts java
# Adding -J-XX: flags to scala and friends
complete -o default -F _scala_with_jvm_opts fsc scalac scala pscalac pscala qscalac qscala scalac29 scala29 scalac3 scala3

complete -o default -F _git g

# Adding rXXXX svn revision completion to some gh- commands
complete -F _scala_svn_rev_completion gh-commit gh-svn

# Delete the cached bytecode disassemblies
alias git-javap-clean='git update-ref -d refs/notes/textconv/javap'

# Add this line to your .profile if you want all your aliases to have
# bash completion. WARNING: if you have a lot of aliases, this might
# cause a small slowdown on login, in the order of a second.
# source $libscalaBash/complete-alias
