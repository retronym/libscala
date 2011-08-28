# running scala
#

jbashScalaOpts=""
jbashScalaPath="scala"
# lazyval sunBootClassPath java-property sun.boot.class.path

set-scala-opts () {
  jbashScalaOpts="$@"
}
set-scala-path () {
  jbashScalaPath="$1"
}

scala-home () {
     [[ -n "$SCALA_HOME" ]] && echo "$SCALA_HOME" \
  || program-home scala \
  || true
}
scala-property () {
  run-scala-expr 'util.Properties.scalaPropOrEmpty(\"$1\")'
}

run-scalac () {
  jlog "[run-scalac] scalac $@"
  scalac "$@"
}
run-scala () {
  jlog "[run-scala] scala $@"
  $jbashScalaPath "$@"
}

run-scala-expr () {
  local file=$(wrap-scala-expr "$@")
  local dirname=$(dirname "$file")
  local basename=$(basename "$file")
  local name=${basename%%.scala}
  
  jlog "[run-scala-expr] $name in $dirname"

  ( builtin cd "$dirname" &&
      run-scalac $jbashScalaOpts -cp $jbashClasspath "$file" && 
      run-scala $jbashScalaOpts -cp $jbashClasspath "$name"
  )
}

# Creates a java program and returns the name of the source file.
wrap-scala-expr () {
  local dir=$(mktemp -d -t jbash)
  local name="jbash$RANDOM"
  local file="$dir/$name.scala"
  jlog "[wrap-scala-expr] file $file"
  
  cat >"$file" <<EOM
object $name {
  def main(args: Array[String]) {
    Console.println($@)
  }
}
EOM

  echo "$file"
}
