#

# foreach with the local branches of the current repo.
foreach-git-branch () {
  # have to chop off the stupid asterisk to prevent globbing
  git branch | cut -c 3- | foreach-stdin "$@"
}

# run the command in each immediate subdir of the current dir
# which is a git repository.
foreach-git-dir () {
  local cmd="$@"

  for dir in $(ls -1) ; do
    [[ -d "$dir/.git" ]] && run-in-dir "$dir" "$@"
  done
}
