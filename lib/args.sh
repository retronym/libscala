# args
#

_upvar() {
    if unset -v "$1"; then           # Unset & validate varname
        if (( $# == 2 )); then
            eval $1=\"\$2\"          # Return single value
        else
            eval $1=\(\"\${@:2}\"\)  # Return array
        fi
    fi
}

jutils_initialize () {
  # process args if setting indicates
  (( $jutils_auto_args )) && jutils-init-args "$@"

  # set -e unless running in debug mode
  # (( $jutils_debug )) || set -es

  jlog "[init] $jutils_name in $jutils_home."
  set -u
}

# handles standard args; sets jutils_args with unprocessed.
jutils-init-args () {
  local saved="$@"
  . $JUTILS_HOME/jutils.sh

  while [ $# -gt 0 ]; do
    case "$1" in
      -help)
        _jutils_help
        exit 1
        ;;
      -usage)
        _jutils_usage
        exit 1
        ;;
      -debug)
        jutils_debug=1
        shift
        ;;
      -cp|-classpath)
        append-classpath "$2"
        shift 2
        ;;
      *)
        jlog "[args] passing through argument $1"
        jutils_args=("${jutils_args[@]}" "$1")
        shift
        ;;
    esac
  done
  
  jlog "[args]   in: $saved"
  jlog "[args]  out: $jutils_args"
  
  declare -r jutils_args
  set -- "$jutils_args"
}

jutils-reset-args () {
  jlog "[reset] in ${jutils_args[@]}"
  set -- "${jutils_args[@]}"
  jlog "[reset] out $@"
}
