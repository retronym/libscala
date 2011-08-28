# core functions
#

_jutils_help () {
  local nohelp="No help for $jutils_name."

  [[ -n "$jutils_usage" ]] && { _jutils_usage ; echo ""; }
  printf "%s\n" "${jutils_help:-$nohelp}"
}

_jutils_usage () {
  if [[ -n "$jutils_usage" ]]; then
    printf "Usage: $jutils_name %s\n" "$jutils_usage"
  else
    echo "No usage for $jutils_name."
  fi
}
