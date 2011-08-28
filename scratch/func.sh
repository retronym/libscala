# functions I'm not using yet


is-mutable-variable () {
  $( unset "$1" 2>/dev/null )
}

errTrap () {
  echo "Error trapped: $?"
  caller
}
# inherit ERR trap in subshells
trap errTrap ERR
