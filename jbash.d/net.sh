# net

programExists () {
  which curl >/dev/null
}

# Download $url to $path, unless already there.
downloadFile () {
  if [[ $# -eq 0 ]]; then
    echo "No arguments to downloadFile"
    return 1
  fi
  
  local url="$1"
  local path=${2:-$(basename "$1")}
  
  if [[ -f "$path" ]]; then
    echo "Already exists: $path" 1>&2
    return 0
  else
    declare dir=$(dirname "$path")
    [[ -d "$dir" ]] || mkdir -p "$dir"
    
    if programExists curl; then
      logAndRun curl --show-error --silent --url "$url" --output "$path" \
        --write-out "Wrote %{size_download} bytes to $path\n"
    elif programExists wget; then
      logAndRun wget --quiet --input-file=<<<"$url" --output-document="$path"
    else
      echo "No curl or wget" 1>&2
      return 1
    fi
  fi
}
