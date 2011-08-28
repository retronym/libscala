# general run functions.
#

pathSeparator=":"
javaClassPath="."
# pathSeparator=$(java-property path.separator)
# javaClassPath=$(java-property java.class.path)

# Given a program which can be found on the path,
# gives its assessment of where its "home" is, which
# is to say, the directory with the bin directory.
program-home () {
  program=$(which "$1") && ( cd $(dirname $program)/.. && pwd )
}

run-code () {
  jlog "[run] $@"
  "$@"
}

logAndRun () {
  if (( $blib_debug )); then
    # print the arguments one to a line, quoting any containing spaces
    echo "# Executing command line:" && {
      for arg; do maybeQuote "$arg"; done
      echo ""
    }
  fi

  "$@"
}
