# lazy vals
#

lazyval () {
  local name="$1"
  shift
  declare -a args=( $(map-args maybeQuote "$@") )
  local fxn=$(cat <<EOM
$name () {
  [[ -z "\$${name}_value" ]] && ${name}_value="\$(eval ${args[@]})"
  echo "\$${name}_value"
}
EOM
  )
  echo "$fxn"
  eval "$fxn"
}
# readonly "${name}_value"


# "lazy vals"
# jbash_path_separator=""
# pathSeparator () {
#   [[ -z "$jbash_path_separator" ]] && {
#     jbash_path_separator=$(java-property path.separator)
#     readonly jbash_path_separator
#   }
#   echo "$jbash_path_separator"
# }
# javaClassPath () {
#   java-property java.class.path
# }
