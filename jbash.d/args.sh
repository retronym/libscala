# args: functions for common argument processing
#
# the idea is that every program is the same with respect
# to certain options (especially, -cp/-classpath)
#

_jbash_help () {
  local nohelp="No help for $jbash_name."

  [[ -n "$jbash_usage" ]] && { _jbash_usage ; echo ""; }
  printf "%s\n" "${jbash_help:-$nohelp}"
}

_jbash_usage () {
  if [[ -n "$jbash_usage" ]]; then
    printf "Usage: $jbash_name %s\n" "$jbash_usage"
  else
    echo "No usage for $jbash_name."
  fi
}

_upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}

# handles standard args; sets jbash_args with residuals.
jbash-command () {
  _upvar jbash_program "$1"
  shift
  local saved="$@"

  while [ $# -gt 0 ]; do
    case "$1" in
             -help) _jbash_help && exit 1 ;;
            -usage) _jbash_usage && exit 1 ;;
            -debug) _jbash_debug=1 && shift ;;
    -cp|-classpath) append-classpath "$2" && shift 2 ;;
                 *)
        jlog "[args] passing through argument $1" &&
        jbash_args=("${jbash_args[@]}" "$1") &&
        shift ;;
    esac
  done
  
  jlog "[args]   in: $saved"
  jlog "[args]  out: $jbash_args"
  
  _upvar jbash_args "$@"
}
