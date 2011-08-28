# classpath functions.
#

jbashClasspath=""
jbashClasspathArg () {
  [[ -n "$jbashClasspath" ]] && echo "-classpath $jbashClasspath"
}

echoerr () {
  echo "$@" >&2
}

# "lazy vals"
# lazyval pathSeparator java-property path.separator
# lazyval javaClassPath java-property java.class.path
# lazyval sunBootClassPath java-property sun.boot.class.path
# 

# danger danger
shopt -s nullglob

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
  local cp=$(cp-join "$jbashClasspath" "$jbash_home/.lib/javassist.jar" ".")
  for arg; do
    path=$(cp-find-class "$arg")
    java -classpath "$cp" javassist.tools.Dump "$path" 2>&1 | grep ^signature: | sed 's/^signature: //;'
  done
}

cp-expand-star () {
  if contains "$1" '*'; then
    eval ls "$1" | mkString $(pathSeparator)
  else
    echo "$1"
  fi
}

cp-split () {
  local sep=$(pathSeparator)
  local toSplit="$1"
  
  [[ -z "$sep" ]] && { echoerr "No path separator!"; return; }
  
  ( IFS="$sep"
    for arg in "$toSplit" ; do 
      echo "$arg"
    done
  )
}

cp-star () {
  cp-join "$(find "$@" -name '*.jar')"
}

cp-join () {
  mkString-args $(pathSeparator) "$@"
}

cp-expand () {
  for arg in $(cp-split); do
    if contains "$arg" '*'; then
      ls $arg
    else
      echo "$arg"
    fi
  done
}

cp-find-jar () {
  jbashExtraJavaSource=$(whereClassSource)
  # jbashClasspath="$(cp-boot-classpath)"
  run-java-expr "new WhereClass().findAll(\"$1\")"
  
  jbashExtraJavaSource=""
}

cp-find-class () {
  jlog "[cp-find-class] $@"
  
  [[ -f "$1" ]] && echo "$1" && return
  
  local container=$(cp-find-jar "$1")
  local dir=$(mktemp -d -t jbash)
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
      if [[ -n "$jbashClasspath" ]]; then
        jbashClasspath="$jbashClasspath$(pathSeparator)"
      fi
      jbashClasspath="$jbashClasspath${arg}"
    fi
  done
    
  jlog "[cp] append-classpath, now $jbashClasspath"
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
    [[ ! $filter && $path =~ $filter ]] && echo ${path#./} | tr '/' '.'
  }
  
  (
    cd "$dir" && 
      find . -name '*.class' | \
      while read file; do process "$file" ; done
  )
}
jar-classnames () {
  dir=$(mktemp -d -t jbash)
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

