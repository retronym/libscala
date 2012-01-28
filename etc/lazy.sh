# lazy vals
#

# Create a lazy val.  The first argument is the name,
# the remainder are the thunk to execute.  The value is
# stored in <name>_value and is marked readonly.
lazyval () {
  local name="$1"
  shift
  declare -a args=( $(map-args quote "$@") )
  # set -x
  local fxn=$(cat <<EOM
$name () {
  if [[ -z "\$${name}_value" ]]; then
    ${name}_value="\$(${args[@]})"
    readonly ${name}_value
  fi
  echo "\$${name}_value"
}
EOM
  )
  jlog "[lazyval] $fxn"
  eval "$fxn"
}

[[ -n "$pathSeparator_value" ]] || {
  # pathSeparator () { echo ":"; }
  # pathSeparator=":"
  lazyval pathSeparator java-property path.separator
  lazyval javaClassPath java-property java.class.path
  lazyval sunBootClassPath java-property sun.boot.class.path
}
