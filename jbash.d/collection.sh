#!/usr/bin/env bash
#
# Create a "collection" from a classpath.
# The elements of the collection are lines of output.
# 

file-to-class () {
  for arg; do
    echo ${arg%.class} | tr '/' '.' | sed -e 's/^[./]*//g'
  done
}

# Use %1 for the current file
cwd-foreach-file () {
  if [[ $# -eq 0 ]]; then
    local cmd="echo \$1"
  else
    local cmd=$(jbash-percent-substitution "$@")
  fi

  find . -type f -print0 | while IFS= read -r -d '' file; do set -- "$file"; eval $cmd; done
}

cwd-files-ext () {
  find . -type f -print | grep ".$1\$"
}
cwd-classes () {
  cwd-files-ext class | xargs file-to-class
}
jar-classes () {
  local source="$1"
  local dir=$(jbash-explode "$source")

  jbash_source="$source" &&
  ( cd "$dir" && cwd-files-ext class | foreach-stdin echo '$(quote %1)' )

  # ( cd "$dir" && cwd-files-ext class | foreach-stdin echo '$(quote %1)' '$(quote $(file-to-class %1))' )
}

# 
#   for file in $(find . -name '*.class')
#   do
#     classname="$(file-to-class $file)"
#     filename="$(absolute_path $file)"
#     
#     if [[ ! $grep ]] || [[ $classname =~ $grep ]]; then
#       cmd=$(interpolate "$filename" "$classname" "$source")
#       echo "% $cmd"
#       eval "$cmd"
#       echo ""
#     fi
#   done
#   popd >/dev/null
# }
# 
# while getopts :c:g:p: opt; do
#   case $opt in
#     c) command="$OPTARG" ;;
#     g) grep="$OPTARG" ;;
#     p) package="$OPTARG" ; packagepath=$(echo $package | tr '.' '/') ;;
#     :) echo "Option -$OPTARG requires an argument." >&2 ; exit 1 ;;
#     *) echo "Unrecognized argument $OPTARG" ; exit 1 ;;
#   esac
# done
# 
# shift $((OPTIND-1))
# targets="$@"
# 
# for target in $targets;
# do
#   traverse-source $(absolute_path $target)
# done
# 
