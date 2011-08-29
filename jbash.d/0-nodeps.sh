# no dependencies
# 
_jbash_upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}

have()
{
  unset -v have
  type $1 &>/dev/null && have="yes"
}

# print each arg on its own line, for pipelining
args-into-lines () {
  for arg in "$@"; do
    printf "%s\n" "$arg"
  done
}

split-string () {
  echo "$2" | tr $1 "\n"
}
join-string () {
  local sep="$1"
  shift
  ( IFS="$sep" && echo "$*" )
}

map-args () {
  local mapFn="$1"
  shift
  for arg; do echo $($mapFn "$arg"); done
}

contains () {
  grep -q "$2" <<<"$1"
}
containsWhitespace () {
  contains "$1" " "
}
maybeQuote () {
  local arg="$1"

  if containsWhitespace "$arg"; then
    printf "\"%s\"\n" "$arg"
  else
    printf "%s\n" "$arg"
  fi
}
