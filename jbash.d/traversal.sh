#
# functional-bash.sh
# Author: Paul Phillips <paulp@improving.org>
#

scalabash-help () {
  cat <<EOM
Illustrative examples hopefully suffice.

% printf "/etc passwd\n/dev stdin\n" | foreach-stdin 'cd %1 && ls -l %2'
-rw-r--r--  1 root  wheel  5086 Aug 25 23:06 passwd
lr-xr-xr-x  1 root  wheel  0 Aug 25 23:22 stdin -> fd/0

% run-in-dir /dev 'ls disk*' | mkString ", "
disk0, disk0s1, disk0s2, disk1, disk1s1, disk1s2, disk1s3, disk2, disk2s1, disk2s3
EOM
}

# In scala lingo this function is approximately
#   String* => String* => T
#
# The initial strings are the command to be run, optionally
# including one or more % position markers.  A bash function
# is created and bound: the return value is the name of
# the function.
#
# That function takes any number of arguments and replaces
# any %-markers with the corresponding argument.  That is,
# %1 is the first argument, %2 is the second, etc.  You can
# use % as an alias for %1, but it must have whitespace on
# both sides.  See foreach-stdin for examples.
bind-foreach () {
  local name="anon$RANDOM"
  local cmd=$(jbash-percent-substitution "$@")

  jlog "[debug] eval $name() { ( "$cmd"; ) }"

  eval "$name() { ( "$cmd"; ) }"
  echo $name
}

jbash-percent-substitution () {
  local cmd=""

  for arg in $@; do
    arg1=$(echo "$arg" | sed -E 's/%([[:digit:]])/"$\1"/g;' | sed -E 's/([[:space:]]%[[:space:]])/ "$1" /g;')
    cmd="${cmd} $arg1"
  done
  
  echo "$cmd"
}

# Fail of a workaround, hopefully to be removed when I figure
# out the right way.
bind-in-same-shell () {
  local varname="$1"
  shift
  local tmpfile=$(mktemp -t foreach)
  
  "$@" >$tmpfile

  jlog "[debug] eval \"$varname=$(cat $tmpfile)\""

  eval "$varname=$(cat $tmpfile)"
}

# Iterates over stdin, running a command for each line.
# Use %1, %2, etc. for positional arguments.  Examples:
#
#   % printf "foo\nbar\nbaz\n" | foreach-stdin echo %1%1
#   foofoo
#   barbar
#   bazbaz
#
#   % printf "/etc passwd\n/dev stdin\n" | foreach-stdin 'cd %1 && ls -l %2'
#   -rw-r--r--  1 root  wheel  5086 Aug 25 23:06 passwd
#   lr-xr-xr-x  1 root  wheel  0 Aug 25 23:22 stdin -> fd/0
#
foreach-stdin () {
  # Trying to call bind-foreach directly, I can't figure out
  # how to hang onto the function name and have it exist without
  # going through an extra name and temporary file.
  local fxnname="foreach$RANDOM"
  bind-in-same-shell $fxnname bind-foreach "$@"

  jlog "[debug] fxn=$(eval echo \$$fxnname)"
  # now we find out the name of the anonymous function
  local fxn=$(eval echo \$$fxnname)

  while read arg; do
    $fxn $arg
  done
}

# first argument is directory to run command in (or file, parent will be used)
# remainder of arguments are command to run.
run-in-dir () {  
  local dir="$1"
  shift 1

  # Uses subshell to avoid changing script directory
  if [[ -d "$dir" ]]; then
    ( cd "$dir" && eval "$@" )
  elif [[ -f "$dir" ]]; then
    local parent=$(dirname "$dir")
    ( cd "$parent" && eval "$@" )
  fi
}
