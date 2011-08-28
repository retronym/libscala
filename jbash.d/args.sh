# args: functions for common argument processing
#
# the idea is that every program is the same with respect
# to certain options (especially, -cp/-classpath)
#

_jbash_help () {
  local help="${jbash_help:-No help for $jbash_name.}"

  _jbash_usage
  echo "$help"
}

_jbash_usage () {
  local usage="${jbash_usage:-No usage for $jbash_name.}"
  
  echo "$usage"
  echo ""
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
          -h|-help) _jbash_help && exit 1 ;;
         -d|-debug) _jbash_debug=1 && shift ;;
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
