# jutils.sh
# source this first

[[ "x${JUTILS_DEBUG}" == "x" ]] || jutils_debug=1
# jutils_debug=$?   # sets it to 1 if JUTILS_DEBUG is non-empty, 0 otherwise
jlog () {
  # avoid non-zero return hitting set -e with || true
  (( $jutils_debug )) && printf "%s\n" "$@" 1>&2 || true
}

# only source once
# [[ "x${jutils_dollar0}" == "x" ]] || { jlog "Already set: $jutils_dollar0"; return; }

declare jutils_dollar0="$BASH_SOURCE"
declare jutils_args0="$@"
declare jutils_name=$(basename "$jutils_dollar0")

jlog "[init] command line is $jutils_dollar0 $jutils_args0"

# changing directory will alter relative paths, so note script dir up front
declare jutils_dollar0_path=$( [[ $jutils_dollar0 = /* ]] && echo "$jutils_dollar0" || echo "$PWD/${jutils_dollar0#./}" )
declare jutils_home="${JUTILS_HOME:-$(cd "$(dirname "$jutils_dollar0_path")/.." ; pwd)}"
declare jutils_lib="$jutils_home/lib"

# once jutils_lib is set we can source the others
for arg in $jutils_lib/*.sh; do
  jlog "Sourcing $arg" && . "$arg"
done
