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

string-chars () {
  local exprcmd i
  
  exprcmd=expr
  have gexpr && exprcmd=gexpr

  for str; do
    i=1
    while (( i <= ${#str} ))
    do
      char=$($exprcmd substr "$str" $i 1)
      echo "$char"
      (( i += 1 ))
    done
  done
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

