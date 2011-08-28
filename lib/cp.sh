# classpath functions.
#

jutilsClasspath=""

pathSeparator () {
  java-property path.separator
}
javaClassPath () {
  java-property java.class.path
}

# Given a program which can be found on the path,
# gives its assessment of where its "home" is, which
# is to say, the directory with the bin directory.
program-home () {
  local program=$(which "$1") && ( cd $(dirname $program)/.. && pwd )
}

run-code () {
  jlog "[run] $@"
  "$@"
}

# cp-signatures java.util.Map
#
# (Ljava/lang/Object;)TV;
# (TK;TV;)TV;
# (Ljava/lang/Object;)TV;
# (Ljava/util/Map<+TK;+TV;>;)V
# ()Ljava/util/Set<TK;>;
# ()Ljava/util/Collection<TV;>;
# ()Ljava/util/Set<Ljava/util/Map$Entry<TK;TV;>;>;
# <K:Ljava/lang/Object;V:Ljava/lang/Object;>Ljava/lang/Object;
cp-signatures () {
  local cp=$(cp-join "$jutilsClasspath" "$jutils_home/.lib/javassist.jar" ".")
  for arg; do
    path=$(cp-find-class "$arg")
    java -classpath "$cp" javassist.tools.Dump "$path" 2>&1 | grep ^signature: | sed 's/^signature: //;'
  done
}

cp-star () {
  cp-join $(find "$@" -name '*.jar')
}

cp-join () {
  mkString $pathSeparator "$@"
}

cp-boot-classpath () {
  java-property sun.boot.class.path
}

cp-find-jar () {
  jutilsExtraJavaSource=$(whereClassSource)
  # jutilsClasspath="$(cp-boot-classpath)"
  run-java-expr "new WhereClass().findAll(\"$1\")"
  
  jutilsExtraJavaSource=""
}

cp-find-class () {
  jlog "[cp-find-class] $@"
  
  [[ -f "$1" ]] && echo "$1" && return
  
  local container=$(cp-find-jar "$1")
  local dir=$(mktemp -d -t jutils)
  local path="$(echo "$1" | tr '.' '/' ).class"
  
  cp-extract "$container" "$path"
}

cp-extract () {
  jlog "[cp-extract] $1 $2"
  ( cd "$dir" && jar xvf "$1" "$2" >/dev/null && echo "$(pwd)/$2" )
}

append-classpath () {
  for arg in "$@"; do
    if [[ -n "$arg" ]]; then
      if [[ -n "$jutilsClasspath" ]]; then
        jutilsClasspath="$jutilsClasspath${pathSeparator}"
      fi
      jutilsClasspath="$jutilsClasspath${arg}"
    fi
  done
    
  jlog "[cp] append-classpath, now $jutilsClasspath"
}


# 
# path-to-classname () {
#   local file="$1"
#   
#   path=${file%.class}
#   name=$(echo ${path#./} | tr '/' '.')
#   echo \'$name\'
# }
# 

directory-classnames () {
  local dir="$1"
  local filter="$2"
  
  process () {
    path=${1%.class}
    [[ ! $filter ]] || [[ $path =~ $filter ]] && echo ${path#./} | tr '/' '.'
  }
  
  (
    cd "$dir" && 
      find . -name '*.class' | \
      while read file; do process "$file" ; done
  )
}
jar-classnames () {
  dir=$(mktemp -d -t jutils)
  jar="$1"
  [[ "$jar" == /* ]] || jar="$(pwd)/$1"
  
  ( cd "$dir" && jar xf "$jar" >/dev/null && directory-classnames . "$2" )
}

classnames () {
  for arg; do
    directory-classnames "$arg"
  done
}

foreach-classname () {
  OPTIND=1
  local grep=""
  local dir=""
  local jar=""

  while getopts :d:g:j: opt; do
    case $opt in
      g) grep="$OPTARG" ;;
      d) dir="$OPTARG" ;;
      j) jar="$OPTARG" ;;
      :) echo "Option -$OPTARG requires an argument." >&2 ; return ;;
      *) echo "Unrecognized argument $OPTARG" ;;
    esac
  done

  shift $((OPTIND-1))
  if [[ $# -eq 0 ]]; then
    echo "Usage: foreach-classname [-g filter] [-d directory] [-j jar] <command line>"
    return
  fi

  local args="$@"

  if [[ "$dir" != "" ]]; then
    for name in $(directory-classnames "$dir" $grep)
    do
      $args $name
    done
  fi
  
  if [[ "$jar" != "" ]]; then
    for name in $(jar-classnames "$jar" $grep)
    do
      $args $name
    done
  fi
}

