# args: functions for common argument processing
#
# the idea is that every program is the same with respect
# to certain options (especially, -cp/-classpath)
#

jbashHelp () {
  cat <<EOM
Usage: $jbash_program [options...]
$jbash_help

Common options:
  -h | -help        print this message
  -v | -verbose     chattier output
  -d | -debug       debug output
  -cp <path>        specify classpath
EOM
}

jbash-arg () {
  local index="$1"
  echo "${jbash_args[$index]}"
}

_jbash_by_ref()
{
  local jbash_flags jbash_args upargs=() upvars=()
  local jbash_classpath="." jbash_saved="$@"
  
  addFlag () {
    jbash_flags="${jbash_flags}$1"
    case "$1" in
      d) jbash_debug=1 ;;
      q) jbash_quiet=1 ;;
      v) jbash_verbose=1 ;;
    esac
  }
  addClasspath () {
    if [[ "$jbash_classpath" == "." ]]; then
      jbash_classpath="$1"
    else
      jbash_classpath="${jbash_classpath}$(pathSeparator)$1"
    fi
  }
  addArg () {
    jlog "[args] passing through argument $1" &&
    jbash_args=("${jbash_args[@]}" "$1")
  }

  while [ $# -gt 0 ]; do
    case "$1" in
          -h|-help) jbashHelp && exit 1 ;;
         -d|-debug) addFlag d && shift ;;
         -q|-quiet) addFlag q && shift ;;
       -v|-verbose) addFlag v && shift ;;
    -cp|-classpath) addClasspath "$2" && shift 2 ;;
                 *) addArg "$1" && shift ;;
    esac
  done
  
  jlog "[args]   in: $jbash_saved"
  jlog "[args]  out: $jbash_args"

  [[ $jbash_flags ]]     && { upvars+=( jbash_flags     ); upargs+=(-v jbash_flags "$jbash_flags" ); }
  [[ $jbash_classpath ]] && { upvars+=( jbash_classpath ); upargs+=(-v jbash_classpath "$jbash_classpath" ); }
  [[ $jbash_args  ]]     && { upvars+=( jbash_args      ); upargs+=(-a${#jbash_args[@]} jbash_args "${jbash_args[@]}"); }

  # end
  (( ${#upvars[@]} )) && local "${upvars[@]}" && _upvars "${upargs[@]}"
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
