# classpath functions.
#

jbashClasspath=""
jbashClasspathArg () {
  [[ -n "$jbashClasspath" ]] && echo "-classpath $jbashClasspath"
}

echoerr () {
  echo "$@" >&2
}

# danger danger
# shopt -s nullglob

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
  local jars=$(cp-expand "$1")
  jbashClasspath="$jbash_home/.lib/javassist.jar:."
  
  for jar in "$jars"; do
    jar-signatures "$jar"
  done
}

jar-signatures () {
  ( cd "$(jbash-explode "$1")" && dir-class-files | foreach-stdin class-signatures %1 )
}

class-signatures () {
  run-java javassist.tools.Dump "$1" 2>&1 | \
    grep ^signature: | \
    sed 's/^signature: //;'
}

cp-expand-star () {
  local sep=$(pathSeparator)
  if contains "$1" '*'; then
    eval ls "$1" | mkString $sep
  else
    echo "$1"
  fi
}

cp-split () {
  split-string "$(pathSeparator)" "$1"
}

cp-star () {
  find "$@" -name '*.jar' | xargs cp-join
}

cp-join () {
  join-string $(pathSeparator) "$@"
}

cp-expand () {
  local sep=$(pathSeparator)
  
  for elem in $(cp-split "$1"); do
    cp-expand-star "$elem"
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

dir-class-files () {
  ( cd "$1" && find . -name '*.class' )
}
dir-class-names () {
  dir-class-files "$1" | xargs class-file-to-name
}
cwd-class-names () {
  dir-class-names .
}
jar-class-names () {
  dir-class-names "$(jbash-explode "$1")"
}
class-names () {
  for arg; do
    dir-class-names "$(jbash-explode "$arg")"
  done
}
class-files () {
  for arg; do
    dir-class-files "$(jbash-explode "$arg")"
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
    for name in $(directory-classes "$dir" $grep)
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

