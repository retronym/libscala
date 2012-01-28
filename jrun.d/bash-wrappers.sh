#

have()
{
  unset -v have
  type $1 &>/dev/null && have="yes"
}

# $1 is string with options to set, e.g. vx
# Remainder is command to eval.
# Original options will be restored.
using-shopts () {
  local saved="$-"
  local enable="$1"
  local disable="$2"
  shift 2

  # set all the opts in the first arg
  for ch in $(string-chars $opts); do
    set -${ch}
  done
  
  # unset all the opts, except those which were already set
  eval "$@" && {
    for ch in $(string-chars $opts); do
      if ! contains "$saved" "$ch"; then
        set +${ch}
      fi
    done
  }
}
using-shopt-names () {
  local saved=$(mktemp -t jrun)
  local enable="$1"
  local disable="$2"
  shift 2

  shopt -p >"$saved"
  # enable/disable all the opts
  for opt in $enable; do shopt -s $opt; done
  for opt in $disable; do shopt -u $opt; done
  
  # run and restore the original opts
  eval "$@"
  source "$saved"
}

using-extglob () {
  using-shopt-names extglob "" "$@"
}
using-globstar () {
  using-shopt-names extglob "" "$@"
}
trace () {
  using-shopts "x" "" "$@"
}
