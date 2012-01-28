# core functions
#

_jlog_init () {
  jlog "[init] command line is $jrun_sh $jrun_sh_args"
  jlog "[init] jrun_home is $jrun_home"
} && _jlog_init

isSetButEmpty () {
  [[ "${!1+x}" = x && -z "${!1}" ]]
}
isUnset () {
  [[ "${!1+x}" != x ]] # && -z "${!1}" ]]
}
isSet () {
  [[ $# -eq 1 ]] && {
    jlog "$(caller 0)   => isSet($1)"
    [[ "x${!1}" != "x" ]]
  }
}

for arg in 0-nodeps lazy; do
  . "$jrun_sources/$arg.sh"
done
