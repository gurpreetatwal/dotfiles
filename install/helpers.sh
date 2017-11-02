# use apt if its available
which apt > /dev/null && apt=apt || apt=apt-get
function installif {
  for pkg in $@; do
    dpkg -s $pkg | grep -q 'Status: install ok installed' && continue;
    color $green "Install $pkg"
    sudo $apt install -q -y $pkg
  done
}

# link source ~/.dest
function link {

  if [[ $# != 2 ]]; then
    printf "Usage: link <source> <dest>\n"
    exit 1
  fi

  SOURCE=$1; DEST=$2
  DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

  if [[ ! -h "$DEST" || $(readlink "$DEST") != "$DIR/$SOURCE" ]]; then
    [[ -e $DEST ]] && mv $DEST "$DEST.bak"
    ln -s "$DIR/$SOURCE" "$DEST"
  fi
}
