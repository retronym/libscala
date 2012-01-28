#!bash
#

import () {
  # @description importer routine to get external functionality.
  # @description the first location searched is the script directory.
  # @description if not found, search the module in the paths contained in $SHELL_LIBRARY_PATH environment variable
  # @param $1 the .blib file to import, without .blib extension
  module="$1"
  
  die () {
    local code="$1"
    echo "$script_name: $2" && exit $code
  }

  isSet "module" || die $? "Unable to import unspecified module."
  isSet "script_absolute_dir" || die $? "Undefined script absolute dir."

  if [[ -e "$script_absolute_dir/$module.blib" ]]; then
    # import from script directory
    echo "$script_absolute_dir/${module}.blib"
    . "$script_absolute_dir/$module.blib"
    return
  elif isSet "SHELL_LIBRARY_PATH"; then
    # import from the shell script library path
    # save the separator and use the ':' instead
    local saved_IFS="$IFS"
    IFS=':'
    for path in $SHELL_LIBRARY_PATH; do
      [[ -e "$path/$module.blib" ]] && source "$path/$module.blib" && return
    done
    # restore the standard separator
    IFS="$saved_IFS"
  fi

  die 1 "Unable to find module $module."
}
