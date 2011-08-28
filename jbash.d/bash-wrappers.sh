#

# _run

# saving-shell-settings () {
#   local saved="$-"
#   "$@"
#   local retval=$?
# }
#   

have()
{
  unset -v have
  type $1 &>/dev/null && have="yes"
}

string-chars () {
  local exprcmd i
  
  exprcmd=expr
  have gexpr && exprcmd=gexpr

  for str; do
    i=1
    while (( i <= ${#str} ))
    do
      char=$($exprcmd substr "$str" $i 1)
      echo "$char"
      (( i += 1 ))
    done
  done
}

# $1 is string with options to set, e.g. vx
# Remainder is command to eval.
# Original options will be restored.
run-with-shell-option () {
  local saved="$-"
  local opts="$1"
  shift

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
  
#   eval 
# 
# if [[ $- == *v* ]]; then
#     BASH_COMPLETION_ORIGINAL_V_VALUE="-v"
# else
#     BASH_COMPLETION_ORIGINAL_V_VALUE="+v"
# fi
# 
# if [[ -n $BASH_COMPLETION_DEBUG ]]; then
#     set -v
# else
#     set +v
# fi
