# string functions.
#

# mkString "\n" < /some/file does get the newline through the obstacle course.
mkString () {
  local sep="$1"
  local first=1

  while read line; do
    if (( $first )); then
      first=0
      printf "%s" "$line"
    else
      printf "${sep}%s" "$line"
    fi
  done

  echo ""
}

# first the separator, then the rest
mkString-args () {
  local sep="$1"
  shift
  
  args-into-lines "$@" | mkString "$sep"
}

absolute-path () {
  if [[ -d "$1" ]]; then
    ( cd "$1" ; pwd )
  else
    base1=$(basename "$1")
    dir1=$(dirname "$1")
    
    ( cd "$dir1" && echo "$(pwd -P)/$base1" )
  fi
}

