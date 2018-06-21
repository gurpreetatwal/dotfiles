# vi: ft=zsh

# Colored output
black=30 red=31 green=32 brown=33 blue=34 purple=35 cyan=36 gray=37
color() {
  printf "\e[1;$1m$2\e[0m" "${*:3}"
}

# use apt if its available
which apt > /dev/null && apt="apt" || apt="apt-get"

# install a package only if it is not currently installed
installif() {
  for pkg in "$@"; do
    color $cyan "[apt]:  %-20s" "$pkg"

    if dpkg -s "$pkg" 2> /dev/null | grep -q 'Status: install ok installed'; then
      color $green " installed\n"
      continue;
    fi

    color $green " installing\n"
    sudo $apt install --quiet=4 --yes "$pkg"
  done
}

# link source ~/.dest
link() {

  if [[ $# != 2 ]]; then
    printf "Usage: link <source> <dest>\n"
    exit 1
  fi

  SOURCE="$1"; DEST="$2"
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

  color $cyan "[link]: %-20s" "$SOURCE"

  if [[ ! -h "$DEST" || $(readlink "$DEST") != "$DIR/$SOURCE" ]]; then
    [[ -e "$DEST" ]] && mv "$DEST" "$DEST.bak"
    color $green " linking to $DEST\n"
    ln -s "$DIR/$SOURCE" "$DEST"
  else
    color $green " linked to $DEST\n"
  fi
}
