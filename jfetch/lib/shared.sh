# shared

[[ -n "$JRUN_DEBUG" ]] && jrun_debug=1
set -e

jrun_home=${JRUN_HOME:-~/.jrun}
[[ -d "$jrun_home" ]] || mkdir "$jrun_home"
rm -f $jrun_home/last-output.log

jrunInit () {
  export PATH="$jrun_home/bin:$PATH"
}

execRunner () {
  echo "execRunner"
  
  # print the arguments one to a line, quoting any containing spaces
  (( $jrun_debug )) && echo "# Executing command line:" && {
    for arg; do
      if echo "$arg" | grep -q ' '; then
        printf "\"%s\"\n" "$arg"
      else
        printf "%s\n" "$arg"
      fi
    done
    echo ""
  } && true

  ( "$@" )
}
