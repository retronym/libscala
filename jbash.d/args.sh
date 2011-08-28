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
  
  echo "Usage: $jbash_program $usage"
  echo ""
}

jbash-arg () {
  local index="$1"
  echo "${jbash_args[$index]}"
}

# handles standard args; sets jbash_args with residuals.
jbash-command () {
  # _jbash_upvar jbash_program $(basename "$1")
  jbash_program=$(basename "$1")
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
  
  jbash_args="$@"
  # _jbash_upvar jbash_args "$@"
}
