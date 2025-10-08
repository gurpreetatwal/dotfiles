#!/bin/bash

sudo apt-get install laptop-mode-tools ttf-mscorefonts-installer

# install base16-shell
if [[ ! -e ~/.config/base16-shell ]]; then
  git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
  find  ~/.config/base16-shell/scripts -type f -exec chmod 744 {} \;
  ~/.config/base16-shell/scripts/base16-google-dark.sh
fi

# install tmux plugin manager
if [[ ! -e ~/.tmux/plugins/tpm ]]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [[ ! "$(which thefuck)" ]]; then
  make pip2
  pip3 install --user --upgrade setuptools thefuck
fi
