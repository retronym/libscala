# lazy vals
#

# Create a lazy val.  The first argument is the name,
# the remainder are the thunk to execute.  The value is
# stored in <name>_value and is marked readonly.
lazyval () {
  local name="$1"
  shift
  declare -a args=( $(map-args quote "$@") )
  local fxn=$(cat <<EOM
$name () {
  [[ -z "\$${name}_value" ]] && ${name}_value="\$(eval "${args[@]}")"
  readonly "${name}_value"
  echo "\$${name}_value"
}
EOM
  )
  jlog "[lazyval] $fxn"
  eval "$fxn"
}

lazyval pathSeparator java-property path.separator
lazyval javaClassPath java-property java.class.path
lazyval sunBootClassPath java-property sun.boot.class.path

# jbash-lazyvals () {
#   # "lazy vals"
#   lazyval pathSeparator java-property path.separator
#   lazyval javaClassPath java-property java.class.path
#   lazyval sunBootClassPath java-property sun.boot.class.path
# } && jbash-lazyvals
