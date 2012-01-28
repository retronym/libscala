# args: functions for common argument processing
#
# the idea is that every program is the same with respect
# to certain options (especially, -cp/-classpath)
#

jrunHelp () {
  cat <<EOM
Usage: $(basename "$0") [options...]
$jrun_help

Common options:
  -h | -help        print this message
  -v | -verbose     chattier output
  -d | -debug       debug output
  -cp <path>        specify classpath
EOM
}

jrun-arg () {
  local index="$1"
  echo "${jrun_args[$index]}"
}

_jrun_by_ref()
{
  local jrun_flags jrun_args upargs=() upvars=()
  local jrun_classpath="." jrun_saved="$@"
  
  addFlag () {
    jrun_flags="${jrun_flags}$1"
    case "$1" in
      d) jrunDebug=1 ;;
      q) jrun_quiet=1 ;;
      v) jrun_verbose=1 ;;
    esac
  }
  addClasspath () {
    if [[ "$jrun_classpath" == "." ]]; then
      jrun_classpath="$1"
    else
      jrun_classpath="${jrun_classpath}$(pathSeparator)$1"
    fi
  }
  addArg () {
    jlog "[args] passing through argument $1" &&
    jrun_args=("${jrun_args[@]}" "$1")
  }

  while [ $# -gt 0 ]; do
    case "$1" in
          -h|-help) jrunHelp && exit 1 ;;
         -d|-debug) addFlag d && shift ;;
         -q|-quiet) addFlag q && shift ;;
       -v|-verbose) addFlag v && shift ;;
    -cp|-classpath) addClasspath "$2" && shift 2 ;;
                 *) addArg "$1" && shift ;;
    esac
  done
  
  jlog "[args]   in: $jrun_saved"
  jlog "[args]  out: $jrun_args"

  [[ $jrun_flags ]]     && { upvars+=( jrun_flags     ); upargs+=(-v jrun_flags "$jrun_flags" ); }
  [[ $jrun_classpath ]] && { upvars+=( jrun_classpath ); upargs+=(-v jrun_classpath "$jrun_classpath" ); }
  [[ $jrun_args  ]]     && { upvars+=( jrun_args      ); upargs+=(-a${#jrun_args[@]} jrun_args "${jrun_args[@]}"); }

  # end
  (( ${#upvars[@]} )) && local "${upvars[@]}" && _upvars "${upargs[@]}"
}


# handles standard args; sets jrun_args with residuals.
jrun-command () {
  # _jrun_upvar jrun_program $(basename "$1")
  jrun_program=$(basename "$1")
  shift
  local saved="$@"

  while [ $# -gt 0 ]; do
    case "$1" in
          -h|-help) _jrun_help && exit 1 ;;
         -d|-debug) _jrunDebug=1 && shift ;;
    -cp|-classpath) append-classpath "$2" && shift 2 ;;
                 *)
        jlog "[args] passing through argument $1" &&
        jrun_args=("${jrun_args[@]}" "$1") &&
        shift ;;
    esac
  done
  
  jlog "[args]   in: $saved"
  jlog "[args]  out: $jrun_args"
  
  jrun_args="$@"
  # _jrun_upvar jrun_args "$@"
}
